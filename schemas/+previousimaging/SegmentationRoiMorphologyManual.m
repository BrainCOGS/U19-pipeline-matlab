%{
# manula curation of morphological classification of the ROIs
-> previousimaging.SegmentationRoi
curation_time="current_timestamp()": timestamp              # 
---
morphology                  : enum('Doughnut','Blob','Puncta','Filament','Other','Noise') # 
%}


classdef SegmentationRoiMorphologyManual < dj.Manual


end


