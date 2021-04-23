%{
# parameter definition for a motion correction method
-> meso.MotionCorrectionMethod
mc_parameter_name:  varchar(64)
---
mc_parameter_description: varchar(255) # description of this parameter
%}

classdef McParameter < dj.Lookup
  properties
    contents = {
               'LinearNormalized','LinearNormalizedParams', 'set of parameters for linear, normalized x-corr motion correction'
               }
  end
end