%{
# Processing Procedure
-> pipeline_imaging_element.ProcessingTask
---
processing_time             : datetime                      # time of generation of this set of processed, segmented results
package_version             : varchar(16)                   # 
%}


classdef Processing < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


