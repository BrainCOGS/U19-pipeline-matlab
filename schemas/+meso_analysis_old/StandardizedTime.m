%{
# time binned activity by trialStruct
-> `u19_meso_old`.`_segmentation`
-> meso_analysis_old.BinningParameters
---
standardized_time           : longblob                      # linearly interpolated behavioral epoch ID per imaging frame
binned_time                 : blob                          # 
%}


classdef StandardizedTime < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


