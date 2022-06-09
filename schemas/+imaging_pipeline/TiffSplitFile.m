%{
# list of files per tiff split
-> imaging_pipeline.TiffSplit
file_number                 : int                           # 
---
tiff_split_filename         : varchar(255)                  # file name of the new tiff file
file_frame_range            : blob                          # [first last] frame indices in this file, with respect to the whole imaging session
%}


classdef TiffSplitFile < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


