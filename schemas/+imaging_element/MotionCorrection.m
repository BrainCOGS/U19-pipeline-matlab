%{
# Results of motion correction performed on the imaging data
-> imaging_element.Curation
---
 (motion_correct_channel) -> `u19_scan_element`.`#channel`
%}


classdef MotionCorrection < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


