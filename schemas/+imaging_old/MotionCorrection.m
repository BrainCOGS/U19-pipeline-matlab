%{
# 
-> imaging_old.FieldOfView
-> imaging_old.McParameterSet
---
mc_results_directory=null   : varchar(255)                  # 
%}


classdef MotionCorrection < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


