%{
# automatic morphological classification of the ROIs
-> meso.SegmentationRoi
---
morphology                  : enum('Doughnut','Blob','Puncta','Filament','Other','Noise') # shape classification
%}

classdef SegmentationRoiMorphologyAuto < dj.Part
  properties(SetAccess=protected)
    master = meso.Segmentation
  end
end

% inserted by Segmentation 
