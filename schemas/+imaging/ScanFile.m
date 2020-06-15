%{
-> imaging.Scan
acquisition_number  : int             # acquisition number of a given scan
file_number         : int             # file number of a given acquisition
---
scan_filename       : varchar(255)
%}


classdef ScanFile < dj.Computed
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            % find subject and date from acquisition.Session table
            
            patt_acq_number  = '_[0-9]{5}_';
            patt_file_number = '_[0-9]{5}\.';
            patt_tiff_file   = '\.tif$';
            
            imaging_directory = fetch1(imaging.Scan & key, 'scan_directory');
            dir_info          = dir(imaging_directory);
            dir_info          = {dir_info(:).name};
            
            tiff_idx = ~cellfun(@isempty,regexp(dir_info,patt_tiff_file),'UniformOutput',true);
            dir_info = dir_info(tiff_idx);
            
            if ~isempty(dir_info)
               for i=1:length(dir_info)
                   
                   tiff_filename = dir_info{i};
                   acq_string = regexp(tiff_filename, patt_acq_number, 'match');
                   number_string = regexp(tiff_filename, patt_file_number, 'match');
                   
                   if (length(acq_string) == 1 && length(number_string) == 1)
                                              
                       key.acquisition_number = str2double(acq_string{1}(2:end-1));
                       key.file_number        = str2double(number_string{1}(2:end-1));
                       key.scan_filename      = tiff_filename;
                       key
                       self.insert(key)
                   else
                       fprintf('imaging name does not match expected format: subject_date_???_XXXXX_YYYYY.tiff %s\n',tiff_filename)
                   end
               end
                
            else
                fprintf('no tiff files found in directory %s\n',imaging_directory)
                return
            end
            
        end
    end
end

