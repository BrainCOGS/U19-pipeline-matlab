%{
# parameter set for a segmentation method
-> meso.SegmentationMethod
seg_parameter_set_id        : int                           # parameter set of a method
%}

classdef SegParameterSet < dj.Lookup
  properties
    contents = { 
                'cnmf', 1 
               }
  end
end
