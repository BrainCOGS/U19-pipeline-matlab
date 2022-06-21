%{
# list of files per FOV
-> previousimaging.FieldOfView
file_number                 : int                           # 
---
fov_filename                : varchar(255)                  # file name of the new fov tiff file
file_frame_range            : blob                          # [first last] frame indices in this file, with respect to the whole imaging session
%}


classdef FieldOfViewFile < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


