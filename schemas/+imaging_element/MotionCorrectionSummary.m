%{
# Summary images for each field and channel after corrections
-> imaging_element.MotionCorrection
-> `u19_scan_element`.`_scan_info__field`
---
ref_image                   : longblob                      # image used as alignment template
average_image               : longblob                      # mean of registered frames
correlation_image=null      : longblob                      # correlation map (computed during cell detection)
max_proj_image=null         : longblob                      # max of registered frames
%}


classdef MotionCorrectionSummary < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


