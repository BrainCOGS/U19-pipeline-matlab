%{
# pointer for a pre-saved set of parameter values
-> imaging.MotionCorrectionMethod
mc_parameter_set_id:   int    # parameter set id
%}

classdef McParameterSet < dj.Lookup
    properties
        contents = {
            'LinearNormalized', 1
            'NonLinearNormalized', 1
            }
    end
end
