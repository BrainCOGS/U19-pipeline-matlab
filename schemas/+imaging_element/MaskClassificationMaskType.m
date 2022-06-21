%{
# 
-> imaging_element.MaskClassification
-> imaging_element.SegmentationMask
---
-> imaging_element.MaskType
confidence=null             : float                         # 
%}


classdef MaskClassificationMaskType < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


