%{
# 
-> pipeline_imaging_element.Activity
-> pipeline_imaging_element.FluorescenceTrace
---
activity_trace              : longblob                      # 
%}


classdef ActivityTrace < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


