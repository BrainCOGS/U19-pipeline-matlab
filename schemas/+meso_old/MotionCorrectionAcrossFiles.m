%{
# across tif files, x-y shifts for motion registration
-> meso_old.FieldOfView
-> meso_old.McParameterSet
---
cross_files_x_shifts        : blob                          # nFrames x 2, meta file, fileMCorr-xShifts
cross_files_y_shifts        : blob                          # nFrames x 2, meta file, fileMCorr-yShifts
cross_files_reference_image : blob                          # 512 x 512, meta file, fileMCorr-reference
%}


classdef MotionCorrectionAcrossFiles < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


