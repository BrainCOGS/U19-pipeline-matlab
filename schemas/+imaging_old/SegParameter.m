%{
# segmentation method parameter
-> imaging_old.SegmentationMethod
seg_parameter_name          : varchar(64)                   # parameter name of segmentation parameter
---
seg_parameter_description   : varchar(255)                  # description of this parameter
%}


classdef SegParameter < dj.Lookup


end


