%{
# automatic morphological classification of the ROIs
-> previousimaging.SegmentationRoi
---
morphology:  enum('Doughnut', 'Blob', 'Puncta', 'Filament', 'Other', 'Noise') # shape classification
%}

classdef SegmentationRoiMorphologyAuto < dj.Part
  properties(SetAccess=protected)
    master = previousimaging.Segmentation
  end
end

% inserted by Segmentation 