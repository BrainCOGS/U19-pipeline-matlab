%{
# handles motion correction
-> meso.FieldOfView
-> meso.McParameterSet
%}


classdef MotionCorrection < dj.Imported
  methods (Access=protected)
    function makeTuples(self, key)
      
      %% analysis params
      params         = fetch(meso.McParameterSetParameter & key, ...
                             'mc_max_shift', 'mc_max_iter', 'mc_stop_below_shift', 'mc_black_tolerance', 'mc_median_rebin');
      if params.mc_black_tolerance < 0; params.mc_black_tolerance = nan; end   
      
      if contains(params.mcorr_method,'NonLinear')
        cfg.mcorr    = {params.mc_max_shift, params.mc_max_iter, params.mc_stop_below_shift, ...
                        params.mc_black_tolerance, params.mc_median_rebin};
      else
        cfg.mcorr    = {params.mc_max_shift, params.mc_max_iter, false, ...
                        params.mc_stop_below_shift, params.mc_black_tolerance, params.mc_median_rebin};
      end
      
      %% insert key
      self.insert(key);

      % path
      fov_directory  = formatFilePath(fetch1(meso.FieldOfView & key,'fov_directory'),true,true);

      %% call functions to compute motioncorrectionWithinFile and AcrossFiles and insert into the tables
      fprintf('==[ PROCESSING ]==   %s\n', fov_directory);

      % Determine whether or not we need to use frame skipping to select only the first channel
      [order,movieFiles]            = fetchn(meso.FieldOfViewFile & key, 'file_number', 'fov_filename');
      movieFiles                    = cellfun(@(x)([fov_directory x]),movieFiles(order),'uniformoutput',false); % full path
      info                          = cv.imfinfox(movieFiles{1}, true);
      if numel(info.channels) > 1
        cfg.mcorr{end+1}            = [0, numel(info.channels)-1];
      end

      % run motion correction
      if isempty(gcp('nocreate')); poolobj = parpool; end
      
      [frameMCorr, fileMCorr]       = getMotionCorrection(movieFiles, false, 'off', cfg.mcorr{:});

      %% insert within file correction meso.motioncorrectionWithinFile
      within_key                        = key;
      within_key.file_number            = [];
      within_key.within_file_x_shifts   = [];
      within_key.within_file_y_shifts   = [];
      within_key.within_reference_image = [];
      within_key                        = repmat(within_key,[1 numel(frameMCorr)]);

      for iFile = 1:numel(frameMCorr)
        within_key(iFile).file_number                   = iFile;
        within_key(iFile).within_file_x_shifts          = frameMCorr(iFile).xShifts;
        within_key(iFile).within_file_y_shifts          = frameMCorr(iFile).yShifts;
        within_key(iFile).within_reference_image        = frameMCorr(iFile).reference; 
      end

      insert(meso.MotionCorrectionWithinFile, within_key)

      %% insert within file correction meso.motioncorrectionAcrossFile
      across_key                             = key;
      across_key.cross_files_x_shifts        = fileMCorr.xShifts;
      across_key.cross_files_y_shifts        = fileMCorr.yShifts;
      across_key.cross_files_reference_image = fileMCorr.reference; 

      inserti(meso.MotionCorrectionAcrossFiles, across_key)

      %% compute and save some stats as .mat files, intermediate step used downstream in the segmentation code
      movieName                     = stripPath(movieFiles);
      parfor iFile = 1:numel(movieFiles)
        computeStatistics(movieName{iFile}, movieFiles{iFile}, frameMCorr(iFile), false);
      end
      
%       if ~isempty(gcp('nocreate'))
%         if exist('poolobj','var')
%           delete(poolobj)
%         else
%           delete(gcp('nocreate'))
%         end
%       end
    end
  end 
end

%%
%---------------------------------------------------------------------------------------------------
function [statsFile, activity] = computeStatistics(movieName, movieFile, frameMCorr, recomputeStats)
  
  fprintf(' :   %s\n', movieName);

  % Fluorescence activity raw statistics
  statsFile                   = regexprep(movieFile, '[.][^.]+$', '.stats.mat');
  if recomputeStats ||  ~exist(statsFile, 'file')
    % Load raw data with per-file motion correction
    F                         = cv.imreadsub(movieFile, {frameMCorr,false});
    [stats,metric,tailProb]   = highTailActivityMetric(F);
    clear F;
    
    info                      = cv.imfinfox(movieFile);
    info.movieFile            = stripPath(movieFile);
    outputFile                = statsFile;
    parsave(outputFile, info, stats, metric, tailProb);
  else
    metric                    = load(statsFile, 'metric');
    tailProb                  = metric.metric.tailProb;
  end
  activity                    = tailProb;

end
