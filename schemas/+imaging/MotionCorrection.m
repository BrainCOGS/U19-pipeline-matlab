%{
-> imaging.ScanFile
-> imaging.McParameterSet       # meta file, frameMCorr-method
---
x_shifts                        : longblob      # nFrames x 2, meta file, frameMCorr-xShifts
y_shifts                        : longblob      # nFrames x 2, meta file, frameMCorr-yShifts
reference_image                 : longblob      # 512 x 512, meta file, frameMCorr-reference
motion_corrected_average_image  : longblob      # 512 x 512, meta file, activity
mcorr_metric                    : varchar(64)   # frameMCorr-metric-name
%}

classdef MotionCorrection < dj.Imported
    methods (Access=protected)
        function makeTuples(self, key)
            
            key
            
            %%Get structure for searching in McParameterSetParameter table
            paramKey.mcorr_method = key.mcorr_method;
            paramKey.mc_parameter_set_id = key.mc_parameter_set_id;
            
            %Get Parameters from McParameterSetParameter table
            params         = fetch(imaging.McParameterSetParameter & paramKey, '*');
            %Convert struct 2 table (easier to index)
            paramTable     = struct2table(params,'AsArray',true);
            
            %Convert table as a single entry params structure
            params = struct();
            for i=1:size(paramTable,1)
                %get name of parameter
                paramName = paramTable.mc_parameter_name{i};
                %get value of parameter
                paramValue = paramTable.value(i);
                if iscell(paramValue)
                    params.(paramName) = paramValue{1};
                else
                    params.(paramName) = paramValue;
                end
            end
            
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
            
            cfg
            
            %%Get structure for searching in Scan Table
            scanKey.acquisition_number = key.acquisition_number;
            scanKey.session_number = key.session_number;
            scanKey.session_date = key.session_date;
            scanKey.subject_fullname = key.subject_fullname;
            
            %Get scan directory
            scan_directory  = fetch1(imaging.Scan & scanKey,'scan_directory');
            
            %% call functions to compute motioncorrectionWithinFile and AcrossFiles and insert into the tables
            fprintf('==[ PROCESSING ]==   %s\n', scan_directory);
            
            % Determine whether or not we need to use frame skipping to select only the first channel
            [order,movieFiles]            = fetchn(imaging.ScanFile & scanKey, 'file_number', 'scan_filename');
            movieFiles                    = cellfun(@(x)([scan_directory x]),movieFiles(order),'uniformoutput',false); % full path
            info                          = cv.imfinfox(movieFiles{1}, true);
            if numel(info.channels) > 1
                cfg.mcorr{end+1}            = [0, numel(info.channels)-1];
            end
            
            movieFiles
            
        end
    end
end