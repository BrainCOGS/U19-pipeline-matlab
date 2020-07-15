%{
# scan meta information from the tiff file
-> imaging.Scan
---
nframes                 : int               # number of recorded frames
frame_rate                : float         # imaging frame rate
%}

%----------------------missing
%nfields
% nfields=1               : tinyint           # number of fields
% nchannels               : tinyint           # number of channels
% nframes                 : int               # number of recorded frames
% nframes_requested       : int               # number of requested frames (from header)
% px_height               : smallint          # lines per frame
% px_width                : smallint          # pixels per line
% um_height=null          : float             # height in microns
% um_width=null           : float             # width in microns
% x=null                  : float             # (um) center of scan in the motor coordinate system
% y=null                  : float             # (um) center of scan in the motor coordinate system
% fps                     : float             # (Hz) frames per second
% zoom                    : decimal(5,2)      # zoom factor
% bidirectional           : boolean           # true = bidirectional scanning
% usecs_per_line          : float             # microseconds per scan line
% fill_fraction_temp      : float             # raster scan temporal fill fraction (see scanimage)
% fill_fraction_space     : float             # raster scan spatial fill fraction (see scanimage)
%check
%nchannels                  :header ImageDescription.scanimage.SI.hChannels.channelSave

classdef ScanInfo < dj.Computed
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            patt_acq_number  = '_[0-9]{5}_';
            patt_file_number = '_[0-9]{5}\.';
            patt_tiff_file   = '\.tif$';
            
            %Get imaging directory
            imaging_directory = fetch1(imaging.Scan & key, 'scan_directory');
            dir_info          = dir(imaging_directory);
            dir_info          = {dir_info(:).name};
            
            %Filter tiff files
            tiff_idx = ~cellfun(@isempty,regexp(dir_info,patt_tiff_file),'UniformOutput',true);
            fl = dir_info(tiff_idx);
            
                            
            %Dummy values to insert in FieldOFView
            insert_FieldOfView(key, imaging_directory);    
                
            
            % If there is at least one tif file in directory
            if(~isempty(fl))
                prefile_frame_range = 0;
                for iF = 1:numel(fl)
                    filekey = key;
                    %Get header and imageDescription
                     header = imfinfo(fullfile(imaging_directory, fl{iF}));
                     imageDesc = getImageDescriptionTiff(header);
                    
                    acq_string = regexp(fl{iF}, patt_acq_number, 'match');
                    number_string = regexp(fl{iF}, patt_file_number, 'match');
                   
                   if (length(acq_string) == 1 && length(number_string) == 1)
                       filekey.file_number   = str2double(number_string{1}(2:end-1));
                       filekey.scan_filename   = fl{iF};
                   end
                   
                   filekey.file_frame_range = [prefile_frame_range+1 prefile_frame_range+numel(header)];
                   prefile_frame_range = filekey.file_frame_range(2);
                   
                   inserti(imaging.ScanFile, filekey)
                   
                   filekey.fov_filename = filekey.scan_filename;
                   filekey = rmfield(filekey, 'scan_filename');
                   filekey
                   inserti(imaging.FieldOfViewFile, filekey)
                                              
                end

                
                % insert record on scaninfo
                key.frame_rate = imageDesc.scanimage.SI.hRoiManager.scanFrameRate;
                %Last frame range (from last file) is our nframes
                key.nframes = filekey.file_frame_range(2);
                self.insert(key)
            end
            
        end
    end
end


function insert_FieldOfView(key, imaging_directory)

key.fov = 1;
key.fov_directory = imaging_directory;
key.fov_depth = 0;
key.fov_center_xy = 0;
key.fov_size_xy = 0;
key.fov_rotation_degrees = 0;
key.fov_pixel_resolution_xy = 0;
key.fov_discrete_plane_mode = 0;

insert(imaging.FieldOfView, key)

end

