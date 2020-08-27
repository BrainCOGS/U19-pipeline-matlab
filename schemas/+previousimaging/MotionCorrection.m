%{
-> previousimaging.FieldOfView
-> previousimaging.McParameterSet       # meta file, frameMCorr-method
---
%}

classdef MotionCorrection < dj.Imported
    methods (Access=protected)
        function makeTuples(self, key)
            
            
            %Get Parameters from McParameterSetParameter table
            params        = imaging.utils.getParametersFromQuery(previousimaging.McParameterSetParameter & key, ...
                                                                'mc_parameter_value');
            
            %Correct mc_black_tolerance parameter
            if params.mc_black_tolerance < 0
                params.mc_black_tolerance = nan;
            end
            
            %Define cfg.mcorr with parameters (as in meso pipeline)
            if contains(key.mcorr_method,'NonLinear')
                cfg.mcorr    = {params.mc_max_shift, params.mc_max_iter, params.mc_stop_below_shift, ...
                    params.mc_black_tolerance, params.mc_median_rebin};
            else
                cfg.mcorr    = {params.mc_max_shift, params.mc_max_iter, params.mc_extra_param, ...
                    params.mc_stop_below_shift, params.mc_black_tolerance, params.mc_median_rebin};
            end
                        
            %Get scan directory
            fov_directory  = fetch1(previousimaging.FieldOfView & key,'fov_directory');
            fov_directory = lab.utils.format_bucket_path(fov_directory);
            
            %Check if directory exists in system
            lab.utils.assert_mounted_location(fov_directory)
            
            %% call functions to compute motioncorrectionWithinFile and AcrossFiles and insert into the tables
            fprintf('==[ PROCESSING ]==   %s\n', fov_directory);
            
            % Determine whether or not we need to use frame skipping to select only the first channel
            [order,movieFiles]            = fetchn(previousimaging.FieldOfViewFile & key, 'file_number', 'fov_filename');
            movieFiles                    = cellfun(@(x)(fullfile(fov_directory,x)),movieFiles(order),'uniformoutput',false); % full path

            info                          = cv.imfinfox(movieFiles{2}, true);
            info
            %file                          = cv.imreadx(movieFiles{1});
            %size(file)
            %class(file)
            if numel(info.channels) > 1
                cfg.mcorr{end+1}            = [0, numel(info.channels)-1];
            end
            
            % run motion correction
            if isempty(gcp('nocreate')); poolobj = parpool; end
            
            movieFiles
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
            
            
            %% insert within file correction meso.motioncorrectionAcrossFile
            across_key                             = key;
            across_key.cross_files_x_shifts        = fileMCorr.xShifts;
            across_key.cross_files_y_shifts        = fileMCorr.yShifts;
            across_key.cross_files_reference_image = fileMCorr.reference;
            
            class(fileMCorr.reference)
            size(fileMCorr.reference)
            
            %% compute and save some stats as .mat files, intermediate step used downstream in the segmentation code
            movieName                     = stripPath(movieFiles);
            parfor iFile = 1:numel(movieFiles)
                computeStatistics(movieName{iFile}, movieFiles{iFile}, frameMCorr(iFile), false);
            end
            
            %% insert key
            self.insert(key);
            insert(previousimaging.MotionCorrectionWithinFile, within_key)
            insert(previousimaging.MotionCorrectionAcrossFiles, across_key)
            
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
    if ~isfile(outputFile)
        parsave(outputFile, info, stats, metric, tailProb);
    end
else
    metric                    = load(statsFile, 'metric');
    tailProb                  = metric.metric.tailProb;
end
activity                    = tailProb;

end