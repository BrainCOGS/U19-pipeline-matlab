%{
# ROI segmentation
-> previousimaging.FieldOfView
-> previousimaging.SegParameterSet
---
num_chunks                      : tinyint           # number of different segmentation chunks within the session
cross_chunks_x_shifts           : blob              # nChunks x niter, 
cross_chunks_y_shifts           : blob              # nChunks x niter, 
cross_chunks_reference_image    : longblob          # reference image for cross-chunk registration
%}

classdef Segmentation < dj.Imported
  
  methods(Access=protected)
    function makeTuples(self, key)
      
      %% imaging directory      
      if isstruct(key)
        fovdata       = fetch(previousimaging.FieldOfView & key,'fov_directory');
        fov_directory = lab.utils.format_bucket_path(fovdata.fov_directory);
        keydata       = key;
      else
        fov_directory  = fetch1(previousimaging.FieldOfView & key,'fov_directory');
        fov_directory = lab.utils.format_bucket_path(fov_directory);
        keydata       = fetch(key);
      end
      
                  
      %Check if directory exists in system
      lab.utils.assert_mounted_location(fov_directory)
        
      
      result          = keydata;
      
      %% analysis params
      %%Get structure for searching in SegParameterSetParameter table      
      params        = imaging.utils.getParametersFromQuery(previousimaging.SegParameterSetParameter & key, ...
                                                          'seg_parameter_value');

      frameRate     = fetch1(previousimaging.ScanInfo & key, 'frame_rate');
      
      % selectFileChunks
      chunk_cfg.auto_select_behav    = params.chunks_auto_select_behav;
      chunk_cfg.auto_select_bleach   = params.chunks_auto_select_bleach;
      chunk_cfg.filesPerChunk        = params.cnmf_files_per_chunk;
      chunk_cfg.T11_minNtrials       = params.chunks_towers_min_n_trials;
      chunk_cfg.T11_perfTh           = params.chunks_towers_perf_thresh;
      chunk_cfg.T11_biasTh           = params.chunks_towers_bias_thresh;
      chunk_cfg.T11_fracBad          = params.chunks_towers_max_frac_bad;
      chunk_cfg.T12_minNtrials       = params.chunks_visguide_min_n_trials;
      chunk_cfg.T12_perfTh           = params.chunks_visguide_perf_thresh;
      chunk_cfg.T12_biasTh           = params.chunks_visguide_bias_thresh;
      chunk_cfg.T12_fracBad          = params.chunks_visguide_max_frac_bad;
      chunk_cfg.min_NconsecBlocks    = params.chunks_min_num_consecutive_blocks;
      chunk_cfg.breakNonConsecBlocks = params.chunks_break_nonconsecutive_blocks;

      % cnmf, general
      cnmf_cfg.K                     = params.cnmf_num_components;
      cnmf_cfg.tau                   = params.cnmf_tau;
      cnmf_cfg.p                     = params.cnmf_p;
      cnmf_cfg.iterations            = params.cnmf_num_iter;
      cnmf_cfg.filesPerChunk         = params.cnmf_files_per_chunk;
      cnmf_cfg.protoNumChunks        = params.cnmf_proto_num_chunks;
      cnmf_cfg.zeroIsMinimum         = params.cnmf_zero_is_minimum;
      cnmf_cfg.defaultTimeScale      = params.cnmf_default_timescale;
      cnmf_cfg.timeResolution        = 1000/frameRate;
      cnmf_cfg.dFFRectification      = params.cnmf_dff_rectification;
      cnmf_cfg.minROISignificance    = params.cnmf_min_roi_significance;
      cnmf_cfg.frameRate             = frameRate;
      cnmf_cfg.minNumFrames          = params.cnmf_min_num_frames;
      cnmf_cfg.maxCentroidDistance   = params.cnmf_max_centroid_dist;
      cnmf_cfg.minDistancePixels     = params.cnmf_min_dist_pixels;
      cnmf_cfg.minShapeCorr          = params.cnmf_min_shape_corr;
      cnmf_cfg.pixelsSurround        = params.cnmf_pixels_surround;

      % cnmf, goodness of fit
      gof_cfg.containEnergy          = params.gof_contain_energy;
      gof_cfg.coreEnergy             = params.gof_core_energy;
      gof_cfg.noiseRange             = params.gof_noise_range;
      gof_cfg.maxBaseline            = params.gof_max_baseline;
      gof_cfg.minActivation          = params.gof_min_activation;
      gof_cfg.highActivation         = params.gof_high_activation;
      gof_cfg.minTimeSpan            = params.gof_min_time_span;
      gof_cfg.bkgTimeSpan            = params.gof_bkg_time_span;
      gof_cfg.minDeltaFoverF         = params.gof_min_dff;
      
      %% select tif file chunks based on behavior and bleaching
      % fileChunk is an array of size chunks x 2, where rows are [firstFileIdx lastFileIdx]
     % if ~isempty(fetch(behavior.TowersBlock & key,'level'))
        fileChunk                            = selectFileChunks(key,chunk_cfg); 
      %else
      %  fileChunk = [];
      %end
            
      %% run segmentation and populate this table
      if isempty(gcp('nocreate')); parpool('IdleTimeout', 120); end
      
      segmentationMethod = fetch1(previousimaging.SegmentationMethod & key,'seg_method');
      switch segmentationMethod
        case 'cnmf'
          outputFiles                      = runCNMF(fov_directory, fileChunk, cnmf_cfg, gof_cfg); 
        case 'suite2p'
          warning('suite2p is not yet supported in this pipeline')
      end
      
      % just 'posthoc' files
      fileidx     = logical(cellfun(@(x)(sum(contains(x,'posthoc')>0)),outputFiles));
      outputFiles = outputFiles(fileidx);

%       %% shut down parallel pool
%       if ~isempty(gcp('nocreate'))
%         if exist('poolobj','var')
%           delete(poolobj)
%         else
%           delete(gcp('nocreate'))
%         end
%       end
      
      %% load summary file
      reorder = false;
      for iFile = 1:numel(outputFiles)
        if contains(outputFiles{iFile},'.fig')
          outputFiles{iFile} = [outputFiles{iFile}(1:end-3) 'mat'];
          reorder = true;
        end
      end
      if reorder; outputFiles = unique(outputFiles,'stable'); end
      
      data                                 = load(outputFiles{1});
      num_chunks                           = numel(data.chunk);
      result.num_chunks                    = num_chunks;
      result.cross_chunks_x_shifts         = data.registration.xShifts;
      result.cross_chunks_y_shifts         = data.registration.yShifts;
      result.cross_chunks_reference_image  = data.registration.reference;
      self.insert(result)
      
      %% write to previousimaging.SegmentationChunks (some session chunk-specific info)
      chunkRange = zeros(num_chunks,2);
      chunkdata  = cell(1,num_chunks);
      for iChunk = 1:num_chunks
        result                       = keydata;
        chunkdata{iChunk}            = load(outputFiles{1+iChunk});
        result.segmentation_chunk_id = iChunk;
        result.tif_file_list         = chunkdata{iChunk}.source.movieFile;
        result.region_image_size     = chunkdata{iChunk}.source.cropping.selectSize;
        result.region_image_x_range  = chunkdata{iChunk}.source.cropping.xRange;
        result.region_image_y_range  = chunkdata{iChunk}.source.cropping.yRange;
        
        % figure out imaging frame range in the chunk (with respect to whole session)
        file_key_first = key;
        file_key_first.fov_filename = result.tif_file_list{1};
        frame_range_first            = fetch1(previousimaging.FieldOfViewFile & file_key_first,'file_frame_range');
        
        file_key_last = key;
        file_key_last.fov_filename = result.tif_file_list{end};                                 
        frame_range_last             = fetch1(previousimaging.FieldOfViewFile & file_key_last,'file_frame_range');   
        
        chunkRange(iChunk,:)         = [frame_range_first(1) frame_range_last(end)];
        result.imaging_frame_range   = chunkRange(iChunk,:);
        
        insert(previousimaging.SegmentationChunks, result)
        clear result 
        
        % write global background (neuropil) activity data to previousimaging.SegmentationBackground
        result                       = keydata;
        result.segmentation_chunk_id = iChunk;
        result.background_spatial    = reshape(chunkdata{iChunk}.cnmf.bkgSpatial,chunkdata{iChunk}.cnmf.region.ImageSize);
        result.background_temporal   = chunkdata{iChunk}.cnmf.bkgTemporal;
        
        insert(previousimaging.SegmentationBackground, result)
        clear result
      end
            
      %% write ROI-specific info into relevant tables
      fprintf('inserting data in ROI tables...\n')
      % initialize data structures
      globalXY      = data.registration.globalXY;
      nROIs         = size(globalXY,2);
      totalFrames   = fetch1(previousimaging.ScanInfo & key,'nframes');
      roi_data      = keydata;
      morpho_data   = keydata;
      trace_data    = keydata;
      
      
      % loop through ROIs
      for iROI = 1:nROIs
        roi_data.roi_idx                    = iROI;  
        morpho_data.roi_idx                 = iROI;
        trace_data.roi_idx                  = iROI;
        
        roi_data.roi_global_xy              = globalXY(:,iROI);
        roi_data.roi_is_in_chunks           = [];   
        roi_data.roi_spatial                = [];
        
        trace_data.time_constants           = data.cnmf.timeConstants{iROI};
        trace_data.init_concentration       = data.cnmf.initConcentration{iROI};
        trace_data.dff_roi                  = nan(1,totalFrames);
        trace_data.dff_surround             = nan(1,totalFrames);
        trace_data.spiking                  = nan(1,totalFrames);
        trace_data.dff_roi_is_significant   = nan(1,totalFrames);
        trace_data.dff_roi_is_baseline      = nan(1,totalFrames);
        
        % now look in file chunks and fill activity etc
        for iChunk = 1:numel(chunkdata)
          % find roi in chunks
          localIdx                          = data.chunk.globalID == iROI;
          if sum(localIdx) == 0; continue; end
          roi_data.roi_is_in_chunks         = [roi_data.roi_is_in_chunks iChunk];
            
          % activity traces
          frameIdx                                    = chunkRange(iChunk,1):chunkRange(iChunk,2);
          uniqueData                                  = chunkdata{iChunk}.cnmf.uniqueData(localIdx,:);
          uniqueBase                                  = halfSampleMode(uniqueData');
          surroundData                                = chunkdata{iChunk}.cnmf.surroundData(localIdx,:);
          trace_data.dff_roi(frameIdx)                = uniqueData / uniqueBase - 1;
          trace_data.dff_surround(frameIdx)           = surroundData / uniqueBase - 1;
          trace_data.spiking(frameIdx)                = chunkdata{iChunk}.cnmf.spiking(localIdx,:);
          trace_data.dff_roi_is_significant(frameIdx) = chunkdata{iChunk}.cnmf.isSignificant(localIdx,:);
          trace_data.dff_roi_is_baseline(frameIdx)    = chunkdata{iChunk}.cnmf.isBaseline(localIdx,:);
          
          % roi: shape and morphological classification
          if isempty(roi_data.roi_spatial)
            roi_data.roi_spatial      = reshape(full(chunkdata{iChunk}.cnmf.spatial(:,localIdx)),chunkdata{iChunk}.cnmf.region.ImageSize);
            roi_data.surround_spatial = reshape(full(chunkdata{iChunk}.cnmf.surround(:,localIdx)),chunkdata{iChunk}.cnmf.region.ImageSize);
            morpho_data.morphology    = char(chunkdata{iChunk}.cnmf.morphology(localIdx));
          end
        end
        
        % insert in tables
        insert(previousimaging.SegmentationRoi, roi_data)
        insert(previousimaging.SegmentationRoiMorphologyAuto, morpho_data)
        insert(previousimaging.Trace, trace_data)
      end

    end
  end
end

%% ------------------------------------------------------------------------
%% file chunk selection
%% ------------------------------------------------------------------------

function fileChunk = selectFileChunks(key,chunk_cfg)

% fileChunk is an array of size chunks x 2, where rows are [firstFileIdx lastFileIdx]

%% check if enforcing this is actually desired
file_ids       = fetchn(previousimaging.FieldOfViewFile & key,'file_number');
nfiles         = numel(file_ids);
fileChunk      = [1 nfiles];

if ~chunk_cfg.auto_select_behav && ~chunk_cfg.auto_select_bleach && nfiles < chunk_cfg.filesPerChunk
  fileChunk = [];
  return
end

%% select imaging chunks based on behavior blocks (at least two consecutive blocks)
if chunk_cfg.auto_select_behav

  % flatten log and summarize block info 
  addImagingSync     = false;
  logSumm            = flattenVirmenLogFromDJ(key,addImagingSync); %%%%% write this

  session.badData    = false;
  session.blockID    = unique(logSumm.blockID);
  badTr              = isBadTrial(logSumm);

  nBlock             = numel(session.blockID);
  session.fracBadTr  = nan(1,nBlock);     
  session.meanPerf   = nan(1,nBlock); 
  session.nTrials    = nan(1,nBlock);
  session.meanBias   = nan(1,nBlock); 
  session.mazeID     = nan(1,nBlock);

  for iBlock = 1:nBlock
    thisBlock                   = session.blockID(iBlock);
    theseTrials                 = logSumm.blockID == thisBlock;
    session.fracBadTr(iBlock)   = sum(badTr(theseTrials))/sum(theseTrials);
    session.meanPerf(iBlock)    = mode(logSumm.meanPerfBlock(theseTrials));
    session.meanBias(iBlock)    = mode(logSumm.meanBiasBlock(theseTrials));
    session.mazeID(iBlock)      = mode(logSumm.currMaze(theseTrials));
    session.nTrials(iBlock)     = sum(theseTrials);
  end

  isRealBlock                   = session.nTrials > 3;
  realBlockIdx                  = 1:sum(isRealBlock);
  session.blockIdx              = nan(1, numel(session.nTrials));
  session.blockIdx(isRealBlock) = realBlockIdx;

  % find blocks/sessions with good behavior
  goodSess                      = enforcePerformanceCriteria(session, chunk_cfg);

  if isempty(goodSess)
    fileChunk = [];
    return
  end
  
  % if good blocks, determine which imaging files to segment based on behavior
  % do this by picking a continuous stretch of files going from the first
  % tif file containing the first good behavior block to the last tif file
  % containing the last good behavior block. Further chunking will depend
  % on max num file criterion / bleaching
  isGoodBlock              = [goodSess.extractThisBlock false];
  frameRanges              = fetchn(previousimaging.SyncImagingBehavior & key,'sync_im_frame_span_by_behav_block');
  frameRangesPerBlock      = cell2mat(frameRanges{1}');
  frameRangesPerGoodBlock  = frameRangesPerBlock(goodSess.extractThisBlock,:);
  frameRangesPerFile       = cell2mat(fetchn(previousimaging.FieldOfViewFile & key,'file_frame_range'));
  
  % break chunks of non-consecutive blocks if necessary
  if chunk_cfg.breakNonConsecBlocks
    isGood_diff        = diff([0 isGoodBlock]);
    numchunks          = sum(isGood_diff == 1);
    fileChunk          = zeros(numchunks,2);
    
    curr_idx = 1;
    for iChunk = 1:numchunks
      firstidx             = find(isGoodBlock(curr_idx:end) & isGood_diff(curr_idx:end) == 1,1,'first') + curr_idx - 1;
      lastidx              = find(~isGoodBlock(firstidx:end) & isGood_diff(firstidx:end) < 1,1,'first') + firstidx - 2;
      curr_idx             = lastidx+find(isGoodBlock(lastidx+1:end),1,'first')-2;
      
      thisRange            = frameRangesPerBlock(firstidx:lastidx,:);
      fileChunk(iChunk,:)  = [find(min(thisRange(:)) < frameRangesPerFile(:,2), 1, 'first') ...
                              find(max(thisRange(:)) > frameRangesPerFile(:,1), 1, 'last')];
    end
    
  else
    fileChunk              = [find(min(frameRangesPerGoodBlock(:)) < frameRangesPerFile(:,2), 1, 'first') ...
                              find(max(frameRangesPerGoodBlock(:)) > frameRangesPerFile(:,1), 1, 'last')];
  end
  
end

%% enforce bleaching and max num file criteria if necessary

% bleaching
if chunk_cfg.auto_select_bleach
  lastGoodFile           = fetch1(previousimaging.ScanInfo & key,'last_good_file');
  deleteIdx              = fileChunk(:,1) > lastGoodFile;
  fileChunk(deleteIdx,:) = [];
  if isempty(fileChunk); return; end
  fillInIdx              = fileChunk(:,2) > lastGoodFile;
  fileChunk(fillInIdx,2) = lastGoodFile;
end

% max files per chunk. Split in half if it exceeds this criterion in the
% case of many consecutive blocks, otherwise break at disjoint blocks
if size(fileChunk,1) == 1
  if diff(fileChunk) > chunk_cfg.filesPerChunk
    oldchunk       = fileChunk;
    fileChunk(1,:) = [oldchunk(1) floor(oldchunk(end)/2)]; 
    fileChunk(2,:) = [floor(oldchunk(end)/2)+1 oldchunk(end)]; 
  end
end

end

%% ------------------------------------------------------------------------
%% segmentation code stripped down for datajoint
%% ------------------------------------------------------------------------

%% --------------------------------------------------------------------------------------------------
function [outputFiles,fileChunk] = runCNMF(moviePath, fileChunk, cfg, gofCfg, redoPostProcessing, fromProtoSegments, lazy, scratchDir)
  
  warning('off','MATLAB:nargchk:deprecated');       % HACK because of cvx
  
  if nargin < 2 
    fileChunk             = [];
  end
  if nargin < 3 
    cfg                   = [];
  end
  if nargin < 4 
    gofCfg                = [];
  end
  if nargin < 5 || isempty(redoPostProcessing)
    redoPostProcessing    = false;
  end
  if nargin < 6 || isempty(fromProtoSegments)
    fromProtoSegments     = true;
  end
  if nargin < 7 || isempty(lazy)
    lazy                  = true;
  end
  if nargin < 7
    scratchDir            = '';
  end
  
  repository                  = [];
  
  % Parallel pool preferences
  parSettings                 = parallel.Settings;
  parSettings.Pool.AutoCreate = false;
  
  % segmentation settings
  if fromProtoSegments
    method                = { 'search_method' , 'dilate'                          ... % search locations when updating spatial components
                            , 'se'            , strel('disk',4)                   ... % morphological element for method dilate
                            };
  else
    method                = { 'search_method' , 'ellipse'                         ... % search locations when updating spatial components
                            };
  end
  cfg.options             = CNMFSetParms( 'd1', 0,'d2', 0                         ... % dimensions of datasets
                                        , 'dist'          , 3                     ... 
                                        , 'deconv_method' , 'constrained_foopsi'  ... % activity deconvolution method
                                        , 'temporal_iter' , 2                     ... % number of block-coordinate descent steps 
                                        , 'fudge_factor'  , 0.9                   ... % bias correction for AR coefficients
                                        , 'merge_thr'     , 0.8                   ... % merging threshold
                                        , 'bas_nonneg'    , true                  ...
                                        , 'block_size'    , 10                    ... for FFT preprocessing 
                                        , 'split_data'    , true                  ... for FFT preprocessing 
                                        , method{:}                               ...
                                        );

  % Get movies and associated statistics info
  outputFiles           = {};
  movieFile             = rdir(fullfile(moviePath, '*.tif'));
  movieFile             = {movieFile.name};
  if isempty(movieFile)
    movieFile           = rdir(fullfile(moviePath, '*.stats.mat'));
    movieFile           = {movieFile.name};
    [dir,name]          = parsePath(movieFile);
    [~,name]            = parsePath(name);
    movieFile           = fullfile(dir, strcat(name, '.tif'));
  end

  % Collect the desired number of files into processing chunks. Can be done
  % explictly by passing fileChunk or automatically by chunking up
  % according to max number of files per chunk, cfg.filesPerChunk
  % fileChunk an array of size chunks x 2, where rows are [firstFileIdx lastFileIdx] 
  if isempty(fileChunk)
    fileChunkTemp       = chunkIndices(1, cfg.filesPerChunk);
    numChunks           = numel(fileChunkTemp)-1;
    fileChunk           = zeros(numChunks,2);
    for iChunk = 1:numChunks
      fileChunk(iChunk,:) = [fileChunkTemp(iChunk) fileChunkTemp(iChunk+1)-1];
    end
  end
  
  [~,name]              = parsePath(movieFile);
  acquisInfo            = regexp(name, '(.+)[_-]([0-9]+)$', 'tokens', 'once');
  acquisInfo            = cat(1, acquisInfo{:});
  acquis                = unique(acquisInfo(:,1));
  acquisPrefix          = fullfile(moviePath, acquis{1});

  % Proto-segmentation
  if fromProtoSegments
    [protoROI, outputFiles]       ...
                        = getProtoSegmentation(movieFile, fileChunk, acquisPrefix, lazy, cfg, outputFiles, scratchDir);
  else
    protoROI            = [];
  end

  % Full segmentation
  nil                 = cell(1,numel(fileChunk)-1);
  chunk               = struct('movieFile', nil, 'roiFile', nil);
  for iChunk = 1:size(fileChunk,1)
    iFile                     = fileChunk(iChunk,1):fileChunk(iChunk,2);
    chunkFiles                = movieFile(iFile);
    chunk(iChunk).movieFile   = stripPath(chunkFiles);

    [cnmf, source, roiFile, summaryFile, gofCfg.timeScale, binnedY, outputFiles]  ...
                              = cnmfSegmentation(chunkFiles, acquisPrefix, iFile, protoROI, cfg, repository, lazy, outputFiles, scratchDir);
    if ~isempty(cnmf)
      chunk(iChunk).reference = source.fileMCorr.reference;
      chunk(iChunk).numFrames = size(cnmf.temporal,2);
      [chunk, outputFiles]    = postprocessROIs(chunk, iChunk, roiFile, summaryFile, cnmf, source, binnedY, gofCfg, repository, ~redoPostProcessing, outputFiles);
    end
    clear cnmf source binnedY;
  end

  chunk(cellfun(@isempty, {chunk.roiFile})) = [];
  if ~isempty(chunk)
    outputFiles     = globalRegistration(chunk, moviePath, acquisPrefix, repository, cfg, outputFiles);
  end
  
  outputFiles       = unique(outputFiles);
  
end

%% --------------------------------------------------------------------------------------------------
function [prototypes, outputFiles] = getProtoSegmentation(movieFile, fileChunk, prefix, lazy, cfg, outputFiles, scratchDir)
  
  %% Look for existing work if available
  protoFile       = [prefix, '.proto-roi.mat'];
  figFile         = [prefix, '.proto-roi.fig'];
  if ~isequal(lazy,false) && exist(protoFile, 'file')
    fprintf('====  Found existing proto-segmentation results %s\n', protoFile);
    load(protoFile);
    return;
  end

  %% Process input in chunks
  fig             = gobjects(0);
  prototypes      = struct();
  for iChunk = 1:size(fileChunk,1)
    chunkFiles                    = movieFile(fileChunk(iChunk,1):fileChunk(iChunk,2));
    prototypes(iChunk).movieFile  = stripPath(chunkFiles);
    chunkLabel                    = sprintf('%s_%d-%d', prefix, fileChunk(iChunk,1), fileChunk(iChunk,2));
    fprintf('====  Performing proto-segmentation of %s\n', chunkLabel);
    
    %% Read motion corrected statistics and crop the border to avoid correction artifacts
    [frameMCorr, fileMCorr]       = getMotionCorrection(chunkFiles, 'never', true);
    cropping      = getMovieCropping(frameMCorr);
    metric        = getActivityMetric(chunkFiles, fileMCorr, cropping.selectMask, cropping.selectSize);
    
    %% Read and temporally downsample movie
    startTime     = tic;
    fprintf('====  Reading input movie...\n');
    binning       = numel(metric.kernel);
    [binnedF, ~, ~, info]                                   ...
                  = cv.imreadsub(chunkFiles, frameMCorr, binning, cropping, 'verbose');
    if ~isempty(scratchDir)
      delete(gcp('nocreate'));
    end
    if cfg.zeroIsMinimum
      zeroLevel   = min(binnedF(:));
    else
      [~,zeroLevel] = estimateZeroLevel(binnedF, false);
    end
    fprintf('       ... %.3g s\n', toc(startTime));
    
    %% For nonlinear motion correction, replace NaNs with the zeroLevel -- FIXME probably we should crop more if necessary?
    if info.nonlinearMotionCorr
      binnedF(isnan(binnedF)) = zeroLevel;
    end
    
    
    %% Linear interpolation constants for per-file significance computation
    if numel(info.fileFrames) == 1
      metric.w1   = ones(1, size(binnedF,3));
      metric.w2   = zeros(1, size(binnedF,3));
      metric.iRef = ones(1, size(binnedF,3));
    else
      refFrame    = round( [0, cumsum(info.fileFrames(1:end-1)/binning)] + info.fileFrames/2/binning );
      frameFrac   = accumfun(2, @(x,y) (0:y-x-1) / (y-x+1), refFrame(1:end-1), refFrame(2:end));
      frameFrac   = [ones(1,refFrame(1)-1), frameFrac, zeros(1,size(binnedF,3)-refFrame(end)+1)];
      if numel(refFrame) > 1
        refIndex  = accumfun(2, @(x,y) x * ones(1,y), 1:numel(refFrame)-1, diff(refFrame));
        refIndex  = [ones(1,refFrame(1)-1), 1+refIndex, numel(refFrame)*ones(1,size(binnedF,3)-refFrame(end)+1)];
      else
        refIndex  = ones(1,refFrame(1));
      end
      metric.w1   = 1 - frameFrac;
      metric.w2   = frameFrac;
      metric.iRef = refIndex;
    end
    metric.nonlinearMotionCorr                              ...
                  = info.nonlinearMotionCorr;
    
    %% Run proto-segmentation 
    pool          = startParallelPool(scratchDir);
    [spatial, prototypes(iChunk).params, fig(end+1)]        ...
                  = estimateNeuronCount_mesoscope( binnedF, zeroLevel, metric, chunkLabel );
                
    %% Undo cropping for ease of re-registration; labels at the boundaries are replicated to minimize
    % loss of component area due to motion correction
    spatial       = reshape(full(spatial), [cropping.selectSize, size(spatial,2)]);
    spatial       = rectangularUncrop(spatial, false, cropping);

    %% Store sparse version to save on space
    prototypes(iChunk).spatial                = sparse(reshape(spatial, size(spatial,1) * size(spatial,2), size(spatial,3)));
    prototypes(iChunk).zeroLevel              = zeroLevel;
    prototypes(iChunk).registration           = cropping;
    prototypes(iChunk).registration.xGlobal   = fileMCorr.xShifts;
    prototypes(iChunk).registration.yGlobal   = fileMCorr.yShifts;
    prototypes(iChunk).registration.reference = fileMCorr.reference;
    prototypes(iChunk).metric                 = metric;
  end
  
  
  %% Save output and figures
  fprintf('====  SAVING to %s\n', protoFile);
  if ~isfile(protoFile)
    save(protoFile, 'prototypes', '-v7.3');
  end
  fprintf('====  SAVING to %s\n', figFile);
  if ~isfile(figFile)
    savefig(fig, figFile, 'compact');
  end
  close(fig);
  
  outputFiles{end+1}  = protoFile;
  outputFiles{end+1}  = figFile;
  
end

%% ---------------------------------------------------------------------------------------------------
function [cnmf, source, roiFile, summaryFile, timeScale, binnedF, outputFiles]  ...
                    = cnmfSegmentation(movieFile, prefix, fileNum, protoROI, cfg, repository, lazy, outputFiles, scratchDir)

  prefix            = sprintf('%s_%d-%d', prefix, fileNum(1), fileNum(end));
  fprintf('****  %s\n', prefix);
 

  %% Locate proto-segmentation results if so requested
  [frameMCorr, fileMCorr] = getMotionCorrection(movieFile, 'never', true);
  timeScale         = cfg.defaultTimeScale;
  cropping          = getMovieCropping(frameMCorr);
  if isempty(protoROI)
    roiFile         = sprintf('%s.cnmf-greedy%d-roi.mat', prefix, cfg.K);
    
  else
    name            = stripPath(movieFile);
    for iProto = 1:numel(protoROI)
      iFile         = find(strcmp(protoROI(iProto).movieFile, name{1}), 1, 'first');
      if isempty(iFile)
        continue;
      end
      
      for jFile = 2:numel(name)
        if ~strcmp(protoROI(iProto).movieFile{iFile-1 + jFile}, name{jFile})
          error('runNeuronSegmentation:cnmfSegmentation', 'Incommensurate input vs. proto-segmentation file chunking.');
        end
      end
      prototypes    = protoROI(iProto).spatial;
      protoCfg      = protoROI(iProto).params;
      timeScale     = numel(protoROI(iProto).metric.kernel);
      break;
    end
    roiFile         = [prefix '.cnmf-proto-roi.mat'];
  end
  summaryFile       = [prefix '.summary.mat'];
  
  
  %% Check for existing output
  if ~isequal(lazy,false) && exist(roiFile, 'file')
    fprintf('====  Existing results found:  %s\n', roiFile);
    load(summaryFile, 'binnedF');
    load(roiFile, 'cnmf', 'source');
    timeScale       = source.timeScale;
    return;
  elseif isequal(lazy,'never')
    cnmf            = [];
    source          = [];
    binnedF         = [];
    return;
  end

  
  %% Re-register proto segmentation according to this movie's local registration
  if ~isempty(protoROI)
    fprintf('====  Registering proto-segmented regions...\n');

    %% Align proto-segmentation to the input movie
    protoMCorr      = cv.motionCorrect( {protoROI(iProto).registration.reference, fileMCorr.reference}  ...
                                      , 30, 1, false, 0.3                                               ...
                                      );
    prototypes      = reshape(full(prototypes), [size(cropping.selectMask), size(prototypes,2)]);
    if any(protoMCorr.xShifts(:,end) ~= 0 | protoMCorr.yShifts(:,end) ~= 0)
      prototypes    = imtranslate(prototypes, [protoMCorr.xShifts(:,end), protoMCorr.yShifts(:,end)]);
    end
    prototypes      = rectangularSubset(prototypes, cropping.selectMask, cropping.selectSize, 1);
    prototypes      = reshape(prototypes > 0, size(prototypes,1)*size(prototypes,2), size(prototypes,3));

    %% Remove ROIs that no longer exist
    prototypes(:, sum(prototypes,1) < 1)  = [];
    prototypes      = sparse(prototypes);
  end
  

  %% Rebin temporally
  rebinFactor           = ceil(cfg.timeResolution / (1000/cfg.frameRate));
  timeScale             = timeScale / rebinFactor;
  cfg.corrRebin         = protoCfg.signalRebin * timeScale;
  cfg.baselineBins      = protoCfg.baselineBins;
  cfg.sigRectification  = protoCfg.sigRectification;
  cfg.punctaNPix        = protoCfg.punctaNPix;
  cfg.options.timeChunk = protoCfg.timeChunk;


  %% Reduce data size by collapsing pixels far from possible neurons into a single vector
  if isempty(protoROI)
    binning         = rebinFactor;
    isCondensed     = false;
  else
    [Ain,cfg.options] = aggregate_background_pixels(prototypes, cropping.selectSize, cfg.options);
    binning         = {rebinFactor, cfg.options.pixelIndex, cfg.options.bkg_only_pixels, cfg.corrRebin};
    isCondensed     = true;
    fprintf ( '====  Restricting segmentation to %d/%d = %.3g%% pixels around prototypes\n'     ...
            , numel(cfg.options.pixelIndex), prod(cropping.selectSize)                          ...
            , 100 * numel(cfg.options.pixelIndex) / prod(cropping.selectSize)                   ...
            );
  end
  
  
  %% Read motion corrected movie and crop the border to avoid correction artifacts
  startTime         = tic;
  fprintf('====  Reading input movie...\n');
  if ~isempty(scratchDir)
    delete(gcp('nocreate'));
  end
  [Y, binnedF, movieSize]       ...
                    = cv.imreadsub(movieFile, frameMCorr, binning, cropping, 'verbose');
  cfg.options.d1    = movieSize(1);
  cfg.options.d2    = movieSize(2);
  T                 = movieSize(3);
  
  
  %% Ensure that the data has nonnegative transients
  if cfg.zeroIsMinimum
    zeroLevel       = min(binnedF(:));
  else
    [~,zeroLevel]   = estimateZeroLevel(binnedF, false);
  end
  Y                 = Y - zeroLevel;
  d                 = cfg.options.d1 * cfg.options.d2;    % total number of pixels
  if ~isa(Y,'double')  && isempty(protoROI)
    Y               = double(Y);                          % convert to double
  end
  
  %% Additional binning for correlation metrics only
  binnedF           = reshape(binnedF, [], size(binnedF,3));
  if isCondensed
    binnedF         = binnedF(cfg.options.pixelIndex, :);
  end
  binnedF           = binnedF - zeroLevel;
  fprintf('       ... %.3g s\n', toc(startTime));
  

  %% Data pre-processing
  if size(Y,ndims(Y)) < cfg.minNumFrames
    warning('runNeuronSegmentation:data', 'Movie file %s is too short (%d frames), cannot perform segmentation.', movieFile{1}, size(Y,ndims(Y)));
    cnmf            = [];
    source          = [];
    return;
  end
  
  invalid           = isnan(sum(Y,ndims(Y)));
  if any(invalid(:))
    %{
    % Used to set all pixels with any NaN to zeroLevel, but this doesn't work for nonlinear motion
    % correction where a small number of frames have a large number of NaN pixels; in particular 
    % this can eliminate data entirely for some components
    ySize           = size(Y);
    Y               = reshape(Y, [], T);
    Y(invalid,:)    = 0;
    Y               = reshape(Y, ySize);
    %}
    
    Y(isnan(Y))             = 0;
    binnedF(isnan(binnedF)) = 0;
    warning('runNeuronSegmentation:data', 'Data contains %d NaN pixels, setting them to zeroLevel = %.4g.', sum(invalid(:)), zeroLevel);
  end
  clear invalid;
  
  
  %% Initialize noise estimate and component seeds (for greedy method)
  pool              = startParallelPool(scratchDir);
  [P,Y]             = preprocess_data(Y, cfg.p, cfg.options);

  if isempty(protoROI)
    %% Fast initialization of spatial components using greedyROI and HALS
    [Ain,Cin,bin,fin,center]          ...
                    = initialize_components(Y,cfg.K,cfg.tau,cfg.options);   % initialize
    prototypes      = Ain;
    protoCfg        = cfg;
    protoCfg.somaRadius   = cfg.tau;
    
    Y               = reshape(Y,d,T);
  else
    %% Proto-segmentation using spatio-temporal contiguity and morphological constraints
    Cin             = [];
    fin             = [];
    
    % HACK HACK HACK : noise estimate of average background-only pixels doesn't seem sensible, use a
    % value within the range of noise estimates for data
    P.sn(end)       = median(P.sn(1:end-1));
  end
  
  
  %-------------------------------------------------------------------------------------------------
  %% Run CNMF algorithm
  %-------------------------------------------------------------------------------------------------
  
  if isempty(Ain)
    A_px            = zeros(d, size(Ain,2));
    b_px            = zeros(d, 1);
    C               = zeros(size(Ain,2), T);
    f               = zeros(1, T);
    S               = C;
  else

    %% Update spatial components
    startTime       = tic;
    fprintf('====  Initializing spatial components...\n');
    [A,b,Cin,fin]   = update_spatial_components(Y,Cin,fin,Ain,P,cfg.options);
    fprintf('       ... %.3g s\n', toc(startTime));

    %% Update temporal components
    startTime       = tic;
    fprintf('====  Initializing temporal components...\n');
    [C,f,P,S]       = update_temporal_components(Y,A,b,Cin,fin,P,cfg.options);
    fprintf('       ... %.3g s\n', toc(startTime));

    %% Restrict to a few iterations since the algorithm is not asymptotically stable
    for iter = 2:cfg.iterations
      fprintf('====  ITERATION %d\n', iter - 1);

      %% Merge found components
      startTime       = tic;
      fprintf('====  Merging overlapping components...\n');
      if isCondensed
        [Am,Cm,K_m,merged_ROIs,Pm,Sm]      ...
                      = merge_components_adjacency(Y,A,b,C,f,P,S,binnedF,cfg.corrRebin,cfg.baselineBins,cfg.sigRectification,cfg.options);
      else
        [Am,Cm,K_m,merged_ROIs,Pm,Sm]      ...
                      = merge_components(Y,A,b,C,f,P,S,cfg.options);
      end
      fprintf('       ... %d merged in %.3g s\n', numel(cat(1,merged_ROIs{:})), toc(startTime));

      %{
      fprintf('====  Removing noisy components...\n');
      [Am,Cm,K_m,removed_ROIs,P,Sm]      ...
                      = remove_noisy_components(binnedF,Am,Cm,Pm,Sm,corrRebin,cfg);
      fprintf('       ... %d removed in %.3g s\n', numel(removed_ROIs), toc(startTime));
      %}

      %% Repeat
      startTime       = tic;
      fprintf('====  Improving spatial components...\n');
      [A,b,Cm]        = update_spatial_components(Y,Cm,f,Am,Pm,cfg.options);
      fprintf('       ... %.3g s\n', toc(startTime));

      startTime       = tic;
      fprintf('====  Improving temporal components...\n');
      [C,f,P,S]       = update_temporal_components(Y,A,b,Cm,f,Pm,cfg.options);
      fprintf('       ... %.3g s\n', toc(startTime));
    end

    %% Merge found components
    startTime       = tic;
    fprintf('====  Final check for overlapping components...\n');
    if isCondensed
      [A,C,K,merged_ROIs,P,S]       ...
                    = merge_components_adjacency(Y,A,b,C,f,P,S,binnedF,cfg.corrRebin,cfg.baselineBins,cfg.sigRectification,cfg.options);
    else
      [A,C,K,merged_ROIs,P,S]       ...
                    = merge_components(Y,A,b,C,f,P,S,cfg.options);
    end
    fprintf('       ... %d merged in %.3g s\n', numel(cat(1,merged_ROIs{:})), toc(startTime));

    %% Convert back to pixel indices
    if isCondensed
      A_px          = zeros(d, size(A,2));
      b_px          = zeros(d, 1);
      pxNoise       = nan(d,1);
      A_px(cfg.options.pixelIndex,:)        = A(1:end-1,:);
      b_px(cfg.options.pixelIndex)          = b(1:end-1);
      b_px(cfg.options.bkg_only_pixels)     = b(end);
      pxNoise(cfg.options.pixelIndex)       = P.sn(1:end-1);
      pxNoise(cfg.options.bkg_only_pixels)  = P.sn(end);
      P.sn          = pxNoise;
    else
      A_px          = A;
      b_px          = b;
    end
  end
  %-------------------------------------------------------------------------------------------------
  

  %% Organize output
  startTime         = tic;
  fprintf('====  Ordering output...\n');
  
  source            = struct();
  source.movieFile  = stripPath(movieFile);
  source.cropping   = cropping;
  source.prototypes = prototypes;
  source.protoCfg   = protoCfg;
  source.frameMCorr = frameMCorr;
  source.fileMCorr  = fileMCorr;
  source.timeScale  = timeScale;
  source.rebinFactor= rebinFactor;
  
  cnmf              = struct();
  cnmf.cfg          = cfg;
  cnmf.rebinFactor  = rebinFactor;
  cnmf.zeroLevel    = zeroLevel;
  cnmf.spatial      = sparse([A_px, b_px]);     % includes background as last column
  cnmf.temporal     = single(full([C; f]));     % includes background as last row
  cnmf.spiking      = sparse(S);
  cnmf.parameters   = P;
  cnmf.iBackground  = size(cnmf.spatial,2);
  
  %% Bounding boxes for ROIs
  region            = componentsToRegions(cnmf.spatial(:,1:end-1), cropping.selectSize);
  property          = regionprops(region, 'Area', 'BoundingBox', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'EulerNumber', 'Solidity', 'ConvexImage');
  leeway            = source.protoCfg.somaRadius;
  [cnmf.bound, cnmf.box]      ...
                    = overBoundingBox(property, leeway, cropping.selectSize);
  cnmf.region       = region;
  cnmf.property     = rmfield(property, 'BoundingBox');
  fprintf('       ... %.3g s\n', toc(startTime));

  startTime         = tic;
  fprintf('====  Collecting data sanity checks...');
  clear binnedF;
  if isCondensed
    clear Y A Am A_px C Cin Cm S Sm b b_px binnedF;
    if ~isempty(scratchDir)
      delete(gcp('nocreate'));
    end
    Y               = cv.imreadsub(movieFile, frameMCorr, rebinFactor, cropping, 'verbose');
    Y               = Y - zeroLevel;
    Y               = reshape(Y,d,T);
    invalid         = isnan(sum(Y,ndims(Y)));
    if any(invalid(:))
      Y(invalid,:)    = 0;
    end
  end 
  cnmf              = computeDataChecks(cnmf, source, Y, cfg);

  %% Store the temporally downsampled movie
  binnedF           = rebin(Y, timeScale, 2);
  clear Y;
  binnedF           = reshape(binnedF, [cropping.selectSize, size(binnedF,2)]);
  fprintf(' %.3g s\n', toc(startTime));

  fprintf('====  SAVING to %s\n', roiFile);
  if ~isfile(roiFile)
    save(roiFile, 'cnmf', 'source', 'repository', '-v7.3');
  end
  outputFiles{end+1}= roiFile;

  temp              = source;
  source            = rmfield(source, {'prototypes', 'protoCfg'});
  fprintf('====  SAVING to %s\n', summaryFile);
  if ~isfile(summaryFile)
    save(summaryFile, 'binnedF', 'source', '-v7.3');
  end
  outputFiles{end+1}= summaryFile;
  source            = temp;

end

%% --------------------------------------------------------------------------------------------------
function [info, outputFiles] = postprocessROIs(info, index, roiFile, summaryFile, cnmf, source, binnedF, cfg, repository, lazy, outputFiles)
  
  % Check for existing output
  [dir, name, ext]    = parsePath(roiFile);
  info(index).roiFile = [name, '-posthoc.mat'];
  roiFile             = fullfile(dir, info(index).roiFile);

  if lazy && exist(roiFile, 'file')
    fprintf('====  Existing post-processing found:  %s\n', roiFile);
    load(roiFile, 'cnmf');

  else
    startTime         = tic;
    fprintf('====  Computing baselines and rearranging prediction...');
    cnmf              = computeBaselines(cnmf, binnedF, cfg);
    fprintf(' %.3g s\n', toc(startTime));

    startTime         = tic;
    fprintf('====  Computing morphological and other metrics...');
    [cnmf, gof, roi]  = classifyMorphology(cnmf, binnedF, source.cropping.selectSize, cfg, source.protoCfg);
    fprintf(' %.3g s\n', toc(startTime));

    fprintf('====  SAVING to %s\n', roiFile);
    if ~isfile(roiFile)
        save(roiFile, 'cnmf', 'source', 'gof', 'roi', 'repository', '-v7.3');
    end
    outputFiles{end+1}= roiFile;
  end

  
  % Compute registration information: centers of ROIs and baseline shapes
  imgSize             = max(cnmf.bound(1:end-1,3:4), [], 1);
  shape               = zeros([imgSize, size(cnmf.spatial,2) - 1]);
  centroid            = nan(2, size(cnmf.spatial,2) - 1);
  if ~isempty(shape)
    for iComp = 1:size(shape,3)
      img             = getRegionChunk(cnmf.bound, source.cropping.selectSize, iComp, cnmf.spatial(:,iComp));
      imgX            = 1:size(img,2);
      imgY            = 1:size(img,1);
      [x,y]           = meshgrid(imgX, imgY);
      centroid(1,iComp) = sum(img(:) .* x(:));
      centroid(2,iComp) = sum(img(:) .* y(:));
      shape(imgY,imgX,iComp)  = img;      % * cnmf.baseline(iComp);
    end
  end
  
  info(index).shape           = shape;
  info(index).centroid        = centroid;
  info(index).localXY         = bsxfun(@plus, [source.cropping.xRange(1); source.cropping.yRange(1)], cnmf.bound(:,1:2)' + centroid);
  info(index).morphology      = cnmf.morphology;
  info(index).diameter        = sqrt( 4*[cnmf.property.Area]/pi );
  
end

%---------------------------------------------------------------------------------------------------
function cnmf = computeDataChecks(cnmf, source, Y, cfg)

  % Compute pixels that belong solely to one component
  cnmf.unique               = cnmf.spatial(:,1:end-1) > 0;
  hasOverlap                = sum(cnmf.unique, 2) > 1;
  cnmf.unique(hasOverlap,:) = false;
  cnmf.uniqueWeight         = full(sum(cnmf.spatial(:,1:end-1) .* cnmf.unique, 1));
  isValid                   = cnmf.uniqueWeight > 0;
  cnmf.unique(:,~isValid)   = 0;
  
  % Collect data traces within uniquely assigned pixels
  cnmf.uniqueData           = nan(numel(cnmf.uniqueWeight), size(Y,2), 'like', Y);
  for iComp = 1:size(cnmf.uniqueData,1)
    cnmf.uniqueData(iComp,:)= mean(Y(cnmf.unique(:,iComp),:), 1);
  end
  
  % Exclude all identified neural activity
  frameSize                 = source.cropping.selectSize;
  neuropilOnly              = reshape(full(~any(source.prototypes, 2)), frameSize);

  % Compute mask for pixels surrounding each component
  leewayElem                = strel('disk', cfg.pixelsSurround(1));
  surroundElem              = strel('disk', cfg.pixelsSurround(2));
  surround                  = false(size(cnmf.unique));
  cnmf.surroundData         = nan(size(cnmf.uniqueData), 'like', Y);
  for iComp = 1:size(surround,2)
    coordOffset             = cnmf.bound(iComp, 1:2) - cfg.pixelsSurround(2);
    
    % Get component shape within a bounding box with leeway for dilation
    compShape               = false(cnmf.bound(iComp, [4 3]) + 2*cfg.pixelsSurround(2));
    [row,col]               = ind2sub(frameSize, find(cnmf.spatial(:,iComp) > 0));
    row                     = row - coordOffset(2);
    col                     = col - coordOffset(1);
    pixels                  = sub2ind(size(compShape), row, col);
    compShape(pixels)       = true;
    
    % Get neuropil-only mask within the same bounding box
    isNeuropil              = getChunkInBox(coordOffset(1), coordOffset(2), size(compShape,2), size(compShape,1), neuropilOnly, 1, false);
    
                                          
    % Dilate the component shape twice to obtain an annulus
    compSurround            = imdilate(compShape, surroundElem) & ~imdilate(compShape, leewayElem);
    [row,col]               = find(compSurround & isNeuropil);
    row                     = row + coordOffset(2);
    col                     = col + coordOffset(1);
    inRange                 = row >= 1 & row <= frameSize(1)   ...
                            & col >= 1 & col <= frameSize(2)   ...
                            ;
    surround( sub2ind(frameSize, row(inRange), col(inRange)), iComp ) = true;
    
    % Collect data trace in surrounding pixels
    cnmf.surroundData(iComp,:)  = mean(Y(surround(:,iComp),:), 1);
  end
  cnmf.surround             = sparse(surround);
  
end

%% --------------------------------------------------------------------------------------------------
function outputFiles = globalRegistration(chunk, path, prefix, repository, cfg, outputFiles)
  
  [~,algoLabel]                 = parsePath(chunk(1).roiFile);
  [~,~,algoLabel]               = parsePath(algoLabel);
  
  if sum(ismember(path,prefix)) == numel(path)  
    regFile                     = [prefix algoLabel '.mat'];
  else
    regFile                     = fullfile(path, [prefix algoLabel '.mat']);
  end

  if exist(regFile,'file')
    
    for iFile = 1:numel(chunk)
      roiFile                   = fullfile(path, chunk(iFile).roiFile);
      outputFiles{end+1}        = roiFile;
    end
    outputFiles{end+1}          = regFile;
    
    fprintf('====  FOUND %s, skipping global registration\n', regFile);
    %return
  end
  
  %% Precompute the safe frame size to contain all centered components 
  maxSize                       = [0 0];
  for iFile = 1:numel(chunk)
    maxSize                     = max( maxSize, size(chunk(iFile).shape(:,:,1)) );
  end
  cfg.templateSize              = 1 + 2*maxSize;
  origin                        = ceil(cfg.templateSize / 2);
  
  %% Apply global motion correction on component centroid locations
  startTime                     = tic;
  fprintf('====  Computing global registration shifts...');
%   movieFile                     = cat(1, chunk.movieFile);
  registration                  = cv.motionCorrect(cat(3, chunk.reference), 30, 5, false, 0.1);
  fprintf(' %.3g s\n', toc(startTime));

  startTime                     = tic;
  fprintf('====  Computing component shape templates...');
  isOccupied                    = false(cfg.templateSize);
  for iFile = 1:numel(chunk)
    chunk(iFile).globalXY       = bsxfun( @plus                                                       ...
                                        , chunk(iFile).localXY                                        ...
                                        , [registration.xShifts(iFile); registration.yShifts(iFile)]  ...
                                        );
                                  
    % Create centered component shape templates by translating the centroid
    template                    = zeros([cfg.templateSize, size(chunk(iFile).shape,3)]);
    [col, row, frame]           = meshgrid( 1:size(chunk(iFile).shape, 2)     ...
                                          , 1:size(chunk(iFile).shape, 1)     ...
                                          , 1:size(chunk(iFile).shape, 3)     ...
                                          );
    iTarget                     = sub2ind ( size(template)                  ...
                                          , row + origin(1)-1               ...
                                          , col + origin(2)-1, frame        ...
                                          );
    template(iTarget)           = chunk(iFile).shape;
    if ~isempty(chunk(iFile).centroid)
      template                  = cv.imtranslatex(template, -chunk(iFile).centroid(1,:), -chunk(iFile).centroid(2,:));
      template(isnan(template)) = 0;
    end
    
    chunk(iFile).shapeSize      = size(chunk(iFile).shape);
    chunk(iFile).templateSize   = size(template);
    chunk(iFile).shape          = sparse(reshape(chunk(iFile).shape, size(chunk(iFile).shape,1)*size(chunk(iFile).shape,2), size(chunk(iFile).shape,3)));
    chunk(iFile).template       = sparse(reshape(template, size(template,1)*size(template,2), size(template,3)));
    isOccupied(any(chunk(iFile).template,2))  = true;
  end
  
  %% Crop the templates so that they occupy as little extent as possible
  isOccupied                    = reshape(full(isOccupied), cfg.templateSize);
  occupancy                     = any(isOccupied, 1);
  xRange                        = [ find(occupancy,1,'first'), find(occupancy,1,'last') ];
  occupancy                     = any(isOccupied, 2);
  yRange                        = [ find(occupancy,1,'first'), find(occupancy,1,'last') ];
  if isempty(xRange) || isempty(yRange)
    xBorder                     = 0;
    yBorder                     = 0;
  else
    xBorder                     = min(abs(xRange - [1 size(isOccupied,2)]));
    yBorder                     = min(abs(yRange - [1 size(isOccupied,1)]));
  end

  [col, row]                    = meshgrid(xBorder+1:cfg.templateSize(2)-xBorder, yBorder+1:cfg.templateSize(1)-yBorder);
  indices                       = sub2ind(cfg.templateSize, row, col);
  cfg.templateSize              = cfg.templateSize - 2*[yBorder, xBorder];
  for iFile = 1:numel(chunk)
    chunk(iFile).template       = chunk(iFile).template(indices, :);
  end
  
  fprintf(' %.3g s\n', toc(startTime));
  

  startTime                     = tic;
  fprintf('====  Registering component identities across time...');
  
  %% Initialize global components using the first movie
  localIndex                    = find( chunk(1).morphology < RegionMorphology.Noise );
  globalXY                      = chunk(1).globalXY(:,localIndex);
  template                      = chunk(1).template(:,localIndex);
  chunk(1).globalID             = zeros(size(chunk(1).morphology));
  chunk(1).globalID(localIndex) = 1:numel(localIndex);
  chunk(1).globalDistance       = zeros(size(chunk(1).globalID));
  chunk(1).globalShapeCorr      = ones(size(chunk(1).globalID));
  
  %% Iteratively match ROIs in subsequent chunks to moving targets by proximity and shape correlation
  for iFile = 2:numel(chunk)
    localIndex(end+1,:)         = 0;
    compIndex                   = find( chunk(iFile).morphology < RegionMorphology.Noise );
    chunk(iFile).globalID       = zeros(size(chunk(iFile).morphology));
    chunk(iFile).globalDistance = nan(size(chunk(iFile).morphology));
    chunk(iFile).globalShapeCorr= nan(size(chunk(iFile).morphology));
    
    % Allow matches only between high quality components within a certain distance
    distance                    = pdist2(globalXY', chunk(iFile).globalXY(:,compIndex)', 'euclidean');
    maxDistance                 = max( cfg.minDistancePixels, cfg.maxCentroidDistance * chunk(iFile).diameter(compIndex) );
    difference                  = zeros(0, 4);
    for iComp = 1:size(distance,2)
      iNearby                   = find( distance(:,iComp) <= maxDistance(iComp) );
      if isempty(iNearby)
        continue;
      end
      
%       delta                   = bsxfun(@minus, template(:,iNearby), roi(iFile).template(:,compIndex(iComp)));
%       delta                   = sum(delta.^2, 1) ./ magnitude(iNearby) / roi(iFile).magnitude(compIndex(iComp));
      correlation               = corr(template(:,iNearby), chunk(iFile).template(:,compIndex(iComp)));    
      iPair                     = size(difference,1) + (1:numel(correlation));
      difference(iPair,1)       = correlation;
      difference(iPair,2)       = iNearby;
      difference(iPair,3)       = iComp;
      difference(iPair,4)       = distance(iNearby,iComp);
    end
    difference                  = sortrows(difference, 1);

    % Greedily assign the most correlated components first
    isResolved                  = false(size(compIndex));
    for iDiff = size(difference,1):-1:1             % Highest correlation first
      iComp                     = difference(iDiff,3);
      if isResolved(iComp)
        continue;
      end
      if difference(iDiff,1) < cfg.minShapeCorr
        break;
      end
      
      % Keep track of temporal evolution of templates
      iGlobal                   = difference(iDiff,2);
      iLocal                    = compIndex(iComp);
      globalXY(:,iGlobal)       = chunk(iFile).globalXY(:,iLocal);
      template(:,iGlobal)       = chunk(iFile).template(:,iLocal);
      localIndex(end,iGlobal)   = iLocal;
      isResolved(iComp)         = true;
      chunk(iFile).globalID(iLocal)         = iGlobal;
      chunk(iFile).globalDistance(iLocal)   = difference(iDiff,4);
      chunk(iFile).globalShapeCorr(iLocal)  = difference(iDiff,1);
    end
    
    % Register new global components as they appear
    compIndex(isResolved)       = [];
    iGlobal                     = size(globalXY,2) + (1:numel(compIndex));
    globalXY(:,iGlobal)         = chunk(iFile).globalXY(:,compIndex);
    template(:,iGlobal)         = chunk(iFile).template(:,compIndex);
    localIndex(end,iGlobal)     = compIndex;
    chunk(iFile).globalID(compIndex)        = iGlobal;
  end
  
  %% Reorder global IDs by persistence across time
  [~, globalOrder]              = sort(sum(localIndex > 0, 1), 'descend');
  translation                   = 1:numel(globalOrder);
  translation(globalOrder)      = translation;
  localIndex                    = localIndex(:, globalOrder);
  globalXY                      = globalXY(:, globalOrder);
  template                      = getLocalProperty(chunk, localIndex, 'template');
  
  fprintf(' %.3g s\n', toc(startTime));
  
  %% Write global registration information to individual segmentation files
  startTime                     = tic;
  fprintf('====  Writing global registration into individual segmentation outputs...        ');
%   frameSize                     = size(registration.reference);
%   spatial                       = zeros(prod(frameSize), size(localIndex,2));
  baseline                      = zeros(1, size(localIndex,2));
  delta                         = nan(size(localIndex,2), sum([chunk.numFrames]));
  spiking                       = delta;
  dataBase                      = baseline;     % uniquely assigned pixels only
  dataDFF                       = delta;
  dataBkg                       = delta;        % annulus estimate scaled to number of pixels
  noise2                        = baseline;
  isSignificant                 = false(size(delta));
  isBaseline                    = isSignificant;
  timeChunk                     = nan(numel(chunk), 2);
  timeConstants                 = cell(size(localIndex,2), numel(chunk));
  initConcentration             = timeConstants;
  
  totalFrames                   = 0;
  chunkCfg                      = struct();
  for iFile = 1:numel(chunk)
    fprintf('\b\b\b\b\b\b\b%3d/%-3d', iFile, numel(chunk));
    drawnow;
    
    roiFile                     = fullfile(path, chunk(iFile).roiFile);
    data                        = load(roiFile);
    cnmf                        = data.cnmf;
    roi                         = data.roi;
    source                      = data.source;
    
    %{
    % Spatial translation to global image frame
    [col, row]                  = meshgrid(1:source.cropping.selectSize(2), 1:source.cropping.selectSize(1));
    col                         = col + source.cropping.xRange(1)-1;
    row                         = row + source.cropping.yRange(1)-1;
    targetPixel                 = sub2ind(frameSize, row, col);
    %}
    
    % Reduce data storage
    if isfield(cnmf.cfg.options, 'neighborhood')
      cnmf.cfg.options          = rmfield(cnmf.cfg.options, {'pixelIndex', 'spatialIndex', 'neighborhood', 'isAdjacent', 'search'});
    end
    
    % Record configuration parameters
    chunkCfg                    = mergeParameters(chunkCfg, source, iFile > 1, 'protoCfg', 'timeScale', 'rebinFactor');
    chunkCfg                    = mergeParameters(chunkCfg, cnmf  , iFile > 1, 'cfg');
    
    % Record global IDs for local components
    sel                         = chunk(iFile).globalID > 0;
    chunk(iFile).globalID(sel)  = translation(chunk(iFile).globalID(sel));
    cnmf.globalID               = chunk(iFile).globalID;
    cnmf.globalDistance         = chunk(iFile).globalDistance;
    cnmf.globalShapeCorr        = chunk(iFile).globalShapeCorr;
    
    % Record global shapes for local components
    for iROI = 1:numel(roi)
      if cnmf.globalID(iROI) < 1
        roi(iROI).global        = [];
      else
        roiGlob                 = template(:, :, cnmf.globalID(iROI));
        roiGlob(isnan(roiGlob)) = 0;
        roi(iROI).global        = reshape(single(roiGlob), [cfg.templateSize, size(roiGlob,2)]);
      end
    end
    
    % Concatenate local time series for global components
    id                          = cnmf.globalID(sel);
    baseline(id)                = baseline(id) + cnmf.baseline(sel);
    tRange                      = totalFrames + (1:size(cnmf.delta,2));
    totalFrames                 = totalFrames + size(cnmf.delta,2);
    delta(id,tRange)            = cnmf.delta(sel,:);
    spiking(id,tRange)          = cnmf.spiking(sel,:);
    noise2(id)                  = noise2(id) + cnmf.noise(sel).^2;
    isSignificant(id,tRange)    = cnmf.isSignificant(sel,:);
    isBaseline(id,tRange)       = cnmf.isBaseline(sel,:);

    timeChunk(iFile,:)          = tRange([1 end]);
    if ~isempty(timeConstants)
      [timeConstants{id,iFile}] = cnmf.parameters.gn{sel};
    end
    if ~isempty(initConcentration)
      [initConcentration{id,iFile}] = cnmf.parameters.c1{sel};
    end
    
%     compShape                   = cnmf.spatial(:, sel);
    uniqueData                  = cnmf.uniqueData(sel, :);
    surroundData                = cnmf.surroundData(sel, :);
    for iComp = 1:numel(id)
      %{
      support                   = compShape(:,iComp) > 0;
      iPixel                    = targetPixel(support);
      spatial(iPixel,id(iComp)) = spatial(iPixel,id(iComp)) + compShape(support,iComp);
      %}
      
      uniqueBase                = halfSampleMode(uniqueData(iComp,:)');
      dataBase(id(iComp))       = dataBase(id(iComp)) + uniqueBase;
      dataDFF(id(iComp),tRange) = uniqueData(iComp,:) / uniqueBase - 1;
      dataBkg(id(iComp),tRange) = surroundData(iComp,:) / uniqueBase - 1;
    end
    
    data.cnmf                   = cnmf;
    data.roi                    = roi;
    fprintf('====  SAVING to %s\n', roiFile);
    if ~isfile(roiFile)
        save(roiFile, '-struct', 'data', '-v7.3');
    end
    outputFiles{end+1}          = roiFile;
  end
  fprintf(' in %.3g s\n', toc(startTime));
  
  % Remove large data
  if isfield(chunkCfg.cfg.options, 'neighborhood')
    chunkCfg.cfg.options        = rmfield(chunkCfg.cfg.options, {'pixelIndex', 'spatialIndex', 'neighborhood', 'isAdjacent', 'search'});
  end
  
  %% Divide by number of samples for averaging
  contribWeight                 = 1 ./ sum(localIndex > 0, 1);
  cnmf                          = chunkCfg;
%   cnmf.spatial                  = sparse(bsxfun(@times, spatial, contribWeight));
  cnmf.baseline                 = bsxfun(@times, baseline, contribWeight);
  cnmf.delta                    = single(delta);
  cnmf.spiking                  = single(spiking);
  cnmf.dataBase                 = bsxfun(@times, dataBase, contribWeight);
  cnmf.dataDFF                  = single(dataDFF);
  cnmf.dataBkg                  = single(dataBkg);
  cnmf.noise                    = sqrt(bsxfun(@times, noise2, contribWeight));
  cnmf.isSignificant            = sparse(isSignificant);
  cnmf.isBaseline               = isBaseline;
  cnmf.timeChunk                = timeChunk;
  cnmf.timeConstants            = timeConstants;
  cnmf.initConcentration        = initConcentration;
  
  % Organize output
  registration.localIndex       = localIndex;
  registration.globalXY         = globalXY;
  registration.template         = template;
  registration.params           = cfg;
  

  fprintf('====  SAVING to %s\n', regFile);
  if ~isfile(regFile)
    save(regFile, 'chunk', 'registration', 'cnmf', 'repository', '-v7.3');
  end
  outputFiles{end+1}          = regFile;
  
  %% Update user-defined morphology information by considering that global IDs can have changed
  morphologyFile                = fullfile(path, [prefix algoLabel '.morphology.mat']);
  if ~exist(morphologyFile, 'file')
    return;
  end
  
  % Make a backup just in case
  backupFile                    = [morphologyFile '.old'];
  if ~copyfile(morphologyFile, backupFile, 'f')
    error('runNeuronSegmentation:globalRegistration', 'Failed to create backup morphology file %s', backupFile);
  end
  load(morphologyFile, 'morphology');
  
  % Overwrite globalIDs for all chunks
  for iChunk = 1:numel(chunk)
    morphology(iChunk).globalID = chunk(iChunk).globalID;
  end
  
  % Run combination logic for assigning a single morphology to each globally identified ROI
  combineClassifications({morphology, morphologyFile}, registration, false);
    
end

%% --------------------------------------------------------------------------------------------------
function target = mergeParameters(target, source, doCheck, varargin)
  
  if doCheck
    for iArg = 1:numel(varargin)
      target.(varargin{iArg}) = mergeIfDifferent(target.(varargin{iArg}), source.(varargin{iArg}));
    end
  else
    for iArg = 1:numel(varargin)
      target.(varargin{iArg}) = source.(varargin{iArg});
    end
  end
  
end

%% --------------------------------------------------------------------------------------------------
function target = mergeIfDifferent(target, source)

  if isstruct(source)
    for field = fieldnames(source)'
      target.(field{:}) = mergeIfDifferent(target.(field{:}), source.(field{:}));
    end
  elseif isequaln(target, source)
  elseif iscell(target) && (~iscell(source) || numel(source) > 1)
    target{end+1}       = source;
  elseif ~iscell(target) && numel(source) > 1
    target              = {target, source};
  else
    target(end+1)       = source;
  end
  
end

%---------------------------------------------------------------------------------------------------
function cnmf = computeBaselines(cnmf, binnedF, cfg)

  cnmf.morphology     = repmat(RegionMorphology.Doughnut, 1, size(cnmf.spatial,2)-1);
  
  % Normalize spatial part to have unit integral
  energy              = full(sum(cnmf.spatial, 1));
  cnmf.spatial        = bsxfun(@times, cnmf.spatial , 1./energy);
  cnmf.temporal       = bsxfun(@times, cnmf.temporal,    energy');
  cnmf.spiking        = sparse(cnmf.spiking);
  
  % Compute quantities within a nominal region of significant contribution
  cnmf.inside         = false(size(cnmf.spatial,1), size(cnmf.spatial,2)-1);
  cnmf.insideWeight   = zeros(1, size(cnmf.inside,2));
  cnmf.core           = false(size(cnmf.spatial,1), size(cnmf.spatial,2)-1);
  cnmf.coreWeight     = zeros(1, size(cnmf.inside,2));
  for iComp = 1:size(cnmf.inside,2)
    [indices, cnmf.insideWeight(iComp)]   ...
                      = getCorePixels(cnmf.spatial(:, iComp), cfg.containEnergy);
    cnmf.inside(indices, iComp) = true;

    [indices, cnmf.coreWeight(iComp)]     ...
                      = getCorePixels(cnmf.spatial(:, iComp), cfg.coreEnergy);
    cnmf.core(indices, iComp)   = true;
  end
  cnmf.inside         = sparse(cnmf.inside);
  cnmf.core           = sparse(cnmf.core);
  cnmf.uniqueWeight   = full(sum(cnmf.spatial(:,1:end-1) .* cnmf.unique, 1));

  % Identify the "baseline" state by assuming sparse(-enough) temporal activity: locate the modal
  % temporal value within a few noise level factors of the minimum
  cnmf.noise          = nan(1, size(cnmf.inside,2));
  baseline            = nan(1, size(cnmf.inside,2));
  cnmf.isBaseline     = false(size(cnmf.temporal,1)-1, size(cnmf.temporal,2));
  cnmf.isSignificant  = false(size(cnmf.temporal,1)-1, size(cnmf.temporal,2));
  for iComp = 1:numel(baseline)
    cnmf.noise(iComp) = sqrt(sum(cnmf.parameters.sn(          ... per pixel data noise level
                                  cnmf.inside(:,iComp)        ...
                                ).^2)                         ...
                            );
    binnedNoise       = cnmf.noise(iComp) / sqrt(cfg.timeScale);
    
    compTrace         = full(cnmf.temporal(iComp,:))';
    smoothTrace       = smooth(compTrace, cfg.timeScale, 'moving');
    
    % Detect baseline state as spans of time without contiguous periods above threshold
    for iter = 1:2
      mode            = halfSampleMode(compTrace);
      activity        = cnmf.insideWeight(iComp) * ( smoothTrace - mode );
      isBaseline      = ~periodsAboveSpan ( activity > cfg.maxBaseline * binnedNoise    ...
                                          , cfg.minTimeSpan * cfg.timeScale             ...
                                          );
    end
    
    % Mark transients as contiguous periods of activity above the given threshold
    isSignificant     = periodsAboveSpan ( activity > cfg.minActivation * binnedNoise   ...
                                         , cfg.minTimeSpan * cfg.timeScale              ...
                                         )                                              ...
                      | periodsAboveSpan ( activity > cfg.highActivation * binnedNoise  ...
                                         , cfg.timeScale                                ...
                                         );
                                            
    baseline(iComp)             = mode;
    cnmf.isBaseline(iComp,:)    = isBaseline;
    cnmf.isSignificant(iComp,:) = isSignificant;
    
    % Require components to have at least one contiguous chunk of time with above-threshold activity
    if ~any(isSignificant)
      cnmf.morphology(iComp)    = RegionMorphology.Noise;
    end
  end
%   cnmf.isBaseline     = sparse(cnmf.isBaseline);

  
  % Assume that the least amount of fluorescence is explained by (neuropil) background; determine
  % the zero background level using the lowest few smoothed timepoints
  bkgTrace            = full(cnmf.temporal(end,:));
  smoothSpan          = cfg.bkgTimeSpan * cfg.timeScale / numel(bkgTrace);
  bkgTrace            = smooth(bkgTrace, smoothSpan, 'loess');
  cnmf.bkgZero        = quantile(bkgTrace, 2*smoothSpan);
  

  % Estimate baseline by absorbing all of the background in uniquely owned pixels 
  isValid             = cnmf.uniqueWeight > 0;
  cnmf.morphology(~isValid) = RegionMorphology.Noise;
  bkgBase             = full( double(cnmf.bkgZero) * cnmf.spatial(:,end) )';
  bkgContrib          = zeros(1, size(cnmf.unique,2));
  dTemporal           = bsxfun(@minus, cnmf.temporal(1:end-1,:), baseline');
  cnmf.baseline       = baseline;
  cnmf.delta          = bsxfun(@times, dTemporal, 1./baseline');
  bkgContrib(isValid)       = min ( ( bkgBase * cnmf.unique(:,isValid) )                    ...
                                   ./ cnmf.uniqueWeight(:,isValid)                          ...
                                  , ( bkgBase * (cnmf.spatial(:,isValid) > 0) )             ...
                                  );
  cnmf.baseline(isValid)    = baseline(isValid) + bkgContrib(isValid);
  cnmf.delta(isValid,:)     = bsxfun(@times, dTemporal(isValid,:), 1./cnmf.baseline(isValid)');
  isSignificant             = cnmf.isSignificant(iComp,:);
  for iComp = 1:size(isSignificant,1)
    isSignificant(iComp,:)  = isSignificant(iComp,:)                                        ...
                            & periodsAboveSpan( cnmf.delta(iComp,:) >= cfg.minDeltaFoverF   ...
                                              , cfg.timeScale                               ...
                                              );
  end
  cfg.isSignificant         = sparse(isSignificant);

  
  % Rearrange the prediction to be of the form:
  %   raw data   PMT zero            shape    baseline            "dF/F"       background
  %     Y(t)   -   Y_0     ~  sum_i   s_i   *   F_i^b   * [ 1 + \Delta_i(t) ] +  G g(t)
  % and where:
  %     || s_i ||_1 = 1
  %     \Delta_i(t) ~ 0   during the baseline state of neuron-like components
  %            g(t) ~ 0   during the baseline state of the background 
  %
  % Due to the formulation of the solution (matrix factorization without a constant term) this
  % cannot be exactly observed, but we do the best we can at the cost of not really getting the
  % background component shape correct:
  %
  %     Y(t)   -   Y_0     ~  sum_i   a_i * ( b_i + c_i^b ) * [ 1 + (c_i(t) - c_i^b)/(b_i + c_i^b) ]
  %                        +  b f(t) - sum_i a_i b_i - Y_0
  %
  % For convenience we organize the matrices such that the full prediction is given by:
  %     bsxfun(@times, baseline, spatial) * (1 + delta) + background
  % where background consists of the original time-dependent piece b f(t) plus a spatially varying
  % (but constant in time) offset

  predF               = double(1 + rebin(cnmf.delta, cfg.timeScale, 2));
  cnmf.offset         = bsxfun(@times, cnmf.spatial(:,1:end-1), bkgContrib);
  cnmf.offset         = -sum(cnmf.offset, 2);         % - double(cnmf.zeroLevel);
  cnmf.bkgSpatial     = full(cnmf.spatial(:,end));
  cnmf.bkgTemporal    = full(cnmf.temporal(end,:));   % - cnmf.zeroLevel;

  
  % Recompute residual w.r.t. data using the revised baseline (bleh!)
  binnedPred          = bsxfun(@times, cnmf.baseline, cnmf.spatial(:,1:end-1)) * predF;
  binnedPred          = binnedPred + cnmf.bkgSpatial * rebin(cnmf.bkgTemporal, cfg.timeScale, 2);
  binnedPred          = bsxfun(@plus, full(cnmf.offset), binnedPred);
  movieSize           = size(binnedF);
  residual            = binnedF - reshape(single(binnedPred), movieSize);

  
  % Compute adjacency information
  pixel               = find(any(cnmf.spatial(:,1:end-1),2));     % all pixels with components
  [row, col]          = ind2sub(movieSize(1:2), pixel);
  neighborhood        = getNeighborhoodIndex(row, col, movieSize, ones(3), true(movieSize(1:2)));
  
  [pixel,component]   = find(cnmf.spatial(pixel,1:end-1));
  adjacency           = neighborhood(pixel);
  component           = cellfun(@(x,y) y*ones(1,numel(x)), adjacency, num2cell(component), 'UniformOutput', false);
  neighborhood        = sparse([adjacency{:}], [component{:}], 1, prod(movieSize(1:2)), size(cnmf.spatial,2)-1);
  cnmf.isAdjacent     = (neighborhood' * neighborhood) > 0;

  % Compute component goodness criteria
  residual            = reshape(residual, [], size(residual,3));
  cnmf.hellinger      = nan(numel(cnmf.baseline), size(residual,2));
  cnmf.shapeCorr      = nan(numel(cnmf.baseline), size(residual,2));
  for iComp = 1:numel(cnmf.baseline)
    support           = cnmf.spatial(:,iComp) > 0;
    spatial           = full(cnmf.spatial(support, iComp));
    prediction        = cnmf.baseline(iComp) * spatial * predF(iComp,:);
    dataShape         = residual(support, :) + prediction;
    cnmf.shapeCorr(iComp,:)     = corr(spatial, dataShape);
    
    dataShape(dataShape < 0)    = 0;
    dataShape         = bsxfun(@times, dataShape, saferdiv(1,sum(dataShape,1)));
    hellinger         = bsxfun(@minus, sqrt(dataShape), sqrt(spatial)).^2;
    cnmf.hellinger(iComp,:)     = sqrt( sum(hellinger,1) / 2 );
  end
    
end

%% --------------------------------------------------------------------------------------------------
function [cnmf, gof, roi] = classifyMorphology(cnmf, binnedF, frameSize, cfg, protoCfg)
  
  somaElem                      = strel('disk', protoCfg.somaRadius);
  neuriteElem                   = strel('disk', floor(protoCfg.somaRadius/2));
  meanF                         = mean(binnedF, 3);
  
  gof.cfg                       = cfg;
  gof.numPixels                 = zeros(size(cnmf.baseline), 'int32');
  gof.numCorePixels             = zeros(size(cnmf.baseline), 'int32');
  gof.perimeter                 = zeros(size(cnmf.baseline), 'int32');
  gof.xyCovariance              = zeros(size(cnmf.baseline));
  gof.majorAxis                 = zeros(size(cnmf.baseline));
  gof.minorAxis                 = zeros(size(cnmf.baseline));
  gof.activation                = zeros(size(cnmf.baseline));
  gof.shapeVariance             = zeros(size(cnmf.baseline));
  gof.shapeCorrelation          = zeros(size(cnmf.baseline));
  gof.hellingerDistance         = zeros(size(cnmf.baseline));
  gof.spatialCoherence          = zeros(size(cnmf.baseline));
  gof.numSomaPieces             = zeros(size(cnmf.baseline), 'int32');
  gof.numPunctaPieces           = zeros(size(cnmf.baseline), 'int32');
  gof.numSomaLike               = zeros(size(cnmf.baseline), 'int32');
  gof.numPunctaLike             = zeros(size(cnmf.baseline), 'int32');
  gof.punctaFraction            = zeros(size(cnmf.baseline));
  gof.skeletonFraction          = zeros(size(cnmf.baseline));
  gof.centerWeight              = zeros(size(cnmf.baseline));
  gof.ringWeight                = zeros(size(cnmf.baseline));
  
  activity                      = rebin(full(cnmf.delta .* cnmf.isSignificant), cfg.timeScale, 2);
  isBaseline                    = rebin(full(cnmf.isBaseline), cfg.timeScale, 2, @all) > 0;
  roi                           = repmat(struct(), 1, numel(cnmf.baseline));
  for iComp = 1:numel(cnmf.baseline)
    % Compute contour extents for display purposes
    [spatial,inside,core,muF]   = getRegionChunk( cnmf, frameSize, iComp, cnmf.spatial(:,iComp)     ...
                                                , cnmf.inside(:,iComp), cnmf.core(:,iComp), meanF   ...
                                                );
    [roi(iComp).support, ~, support]            = boundaryLines(spatial > 0);
    [roi(iComp).inside, gof.perimeter(iComp)]   = boundaryLines(inside);
    roi(iComp).core             = boundaryLines(core);

    % Compute ranking variable
    gof.activation(iComp)       = cnmf.baseline(iComp) * max(cnmf.delta(iComp,:)) / cnmf.noise(iComp);
    
    
    % Shape discrepancy
    [mode, sigma]               = estimateLocationScale(cnmf.hellinger(iComp, isBaseline(iComp,:)));
    sumActivity                 = sum( activity(iComp,:) );
    gof.shapeCorrelation(iComp) = sum( activity(iComp,:) .* cnmf.shapeCorr(iComp,:)          ) / sumActivity;
    gof.hellingerDistance(iComp)= sum( activity(iComp,:) .* cnmf.hellinger(iComp,:)          ) / sumActivity;
    gof.spatialCoherence(iComp) = sum( activity(iComp,:) .* (mode - cnmf.hellinger(iComp,:)) ) / sumActivity;
                        
    % Number of pixels in spatial support and around the peak
    peakHeight                  = max(cnmf.spatial(:,iComp));
    gof.numPixels(iComp)        = sum(support(:));
    gof.numCorePixels(iComp)    = full(sum(cnmf.spatial(:,iComp) > peakHeight/2));

    % Component shape
    [gof.xyCovariance(iComp), ~, gof.majorAxis(iComp), gof.minorAxis(iComp)]          ...
                                = shapeCovariance ( min ( cnmf.spatial(:,iComp)       ...
                                                        , peakHeight/2                ...
                                                        )                             ...
                                                  , frameSize                         ...
                                                  );
    gof.shapeVariance(iComp)    = var(cnmf.spatial(:,iComp)) / mean(cnmf.spatial(:,iComp));
    
    % Soma-like blobs
    somaLike                    = imerode(inside, somaElem);
    pieces                      = bwconncomp(bwmorph(somaLike, 'clean'));
    gof.numSomaPieces(iComp)    = pieces.NumObjects;
    if pieces.NumObjects > 0
      [~,iMax]                  = max(cellfun(@numel, pieces.PixelIdxList));
      gof.numSomaLike(iComp)    = numel(pieces.PixelIdxList{iMax});
    end
    
    % Puncta like spots
    punctaShape                 = spatial;
    punctaShape(punctaShape < 0.25 * peakHeight)  = 0;
    pieces                      = bwconncomp(punctaShape);
    gof.numPunctaPieces(iComp)  = pieces.NumObjects;
    if pieces.NumObjects > 0
      [~,iMax]                  = max(cellfun(@numel, pieces.PixelIdxList));
      gof.numPunctaLike(iComp)  = numel(pieces.PixelIdxList{iMax});
    end
    gof.punctaFraction(iComp)   = sum(punctaShape(:));

    % Thinness of component
    skeleton                    = imclose(inside, somaElem);
    skeleton                    = imdilate(bwmorph(skeleton, 'thin', inf), neuriteElem);
    gof.skeletonFraction(iComp) = sum(inside(:) .* skeleton(:)) / sum(inside(:));

    % Doughnut shape parameters
    shape                       = bwconvhull(inside, 'union');
    muF(~shape & spatial <= 0)  = 0;
    muF                         = muF / sum(muF(:));
    center                      = muF .* imerode(shape, somaElem);
    ring                        = muF .* (center == 0);
    gof.centerWeight(iComp)     = negativeIfNaN(quantile(center(center > 0), 0.25));
    gof.ringWeight(iComp)       = negativeIfNaN(quantile(ring(ring > 0)    , 0.75));
  end
  
end

%% --------------------------------------------------------------------------------------------------
function x = negativeIfNaN(x)

  x(isnan(x)) = -0.1;
  
end


