%{
# 
-> pipeline_imaging_element.PreprocessTask
---
preprocess_time=null        : datetime                      # time of generation of pre-processing results
package_version             : varchar(16)                   # 
%}


classdef Preprocess < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


