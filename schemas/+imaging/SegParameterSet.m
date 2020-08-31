%{
# pointer for a pre-saved set of parameter values
-> imaging.SegmentationMethod
seg_parameter_set_id:   int    # parameter set id
%}

classdef SegParameterSet < dj.Manual
    methods
        function insert(self, key)
            
            insert@dj.Manual(self, key);
            make(imaging.SegParameterSetParameter, key)
            
        end
    end
end
