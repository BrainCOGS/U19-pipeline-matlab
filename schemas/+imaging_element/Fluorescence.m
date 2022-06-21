%{
# fluorescence traces before spike extraction or filtering
-> imaging_element.Segmentation
%}


classdef Fluorescence < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


