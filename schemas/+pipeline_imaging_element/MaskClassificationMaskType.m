%{
# 
-> pipeline_imaging_element.MaskClassification
-> pipeline_imaging_element.SegmentationMask
---
-> pipeline_imaging_element.MaskType
confidence=null             : float                         # 
%}


classdef MaskClassificationMaskType < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


