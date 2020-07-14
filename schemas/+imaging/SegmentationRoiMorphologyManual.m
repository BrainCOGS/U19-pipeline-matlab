%{
# manula curation of morphological classification of the ROIs
-> imaging.SegmentationRoi
curation_time=CURRENT_TIMESTAMP: timestamp
---
morphology:  enum('Doughnut', 'Blob', 'Puncta', 'Filament', 'Other', 'Noise')
%}

classdef SegmentationRoiMorphologyManual < dj.Manual
  methods(Access=protected)
    function makeTuples(self, key)
      self.insert(key)
    end
  end
end

% inserted by the GUI of curation of morphology: viewSegmentation_dj()