%{
# pointer for a pre-saved set of parameter values
-> previousimaging.SegmentationMethod
seg_parameter_set_id:   int    # parameter set id
%}

classdef SegParameterSet < dj.Manual
    methods
        function insert(self, key)
            
            insert@dj.Manual(self, key);
            make(previousimaging.SegParameterSetParameter, key)
            
        end
    end
end
