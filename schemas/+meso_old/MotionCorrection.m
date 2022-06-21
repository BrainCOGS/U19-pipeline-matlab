%{
# handles motion correction
-> meso_old.FieldOfView
-> meso_old.McParameterSet
%}


classdef MotionCorrection < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


