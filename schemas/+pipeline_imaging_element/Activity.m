%{
# inferred neural activity from fluorescence trace - e.g. dff, spikes
-> pipeline_imaging_element.Fluorescence
-> pipeline_imaging_element.ActivityExtractionMethod
%}


classdef Activity < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


