%{
# 
-> pipeline_imaging_element.Segmentation
-> pipeline_imaging_element.MaskClassificationMethod
%}


classdef MaskClassification < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


