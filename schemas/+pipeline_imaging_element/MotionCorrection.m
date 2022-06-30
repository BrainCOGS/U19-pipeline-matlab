%{
# Results of motion correction performed on the imaging data
-> pipeline_imaging_element.Curation
---
 (motion_correct_channel) -> pipeline_scan_element.Channel
%}


classdef MotionCorrection < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


