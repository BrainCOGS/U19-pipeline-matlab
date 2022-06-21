%{
# segmentation method parameter
-> meso.SegmentationMethod
seg_parameter_name          : varchar(64)                   # parameter name of segmentation parameter
%}

classdef SegParameter < dj.Lookup
  properties
    contents = {
                'cnmf', 'cnmfParameters'
                }
  end
end
