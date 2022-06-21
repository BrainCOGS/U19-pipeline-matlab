%{
# automatic morphological classification of the ROIs
-> previousimaging.SegmentationRoi
---
morphology                  : enum('Doughnut','Blob','Puncta','Filament','Other','Noise') # shape classification
%}


classdef SegmentationRoiMorphologyAuto < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


