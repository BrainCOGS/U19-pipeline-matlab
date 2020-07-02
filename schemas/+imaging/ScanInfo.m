%{
# scan meta information from the tiff file
-> imaging.Scan
---
frame_rate
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
            
            patt_tiff_file   = '\.tif$';
            
            %Get imaging directory
            imaging_directory = fetch1(imaging.Scan & key, 'scan_directory');
            dir_info          = dir(imaging_directory);
            dir_info          = {dir_info(:).name};
            
            tiff_idx = ~cellfun(@isempty,regexp(dir_info,patt_tiff_file),'UniformOutput',true);
            fl = dir_info(tiff_idx);
            
            for iF = 1:numel(fl)
                header = imfinfo(fl{iF});
                imageDesc = getImageDescriptionTiff(header);                
            end
            
            key.frame_rate = imageDesc.scanimage.SI.hRoiManager.scanFrameRate;
            self.insert(key)
            
        end
    end
end 