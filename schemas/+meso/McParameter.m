%{
# 
-> meso.MotionCorrectionMethod
mc_parameter_name           : varchar(32)                   # 
---
mc_parameter_description    : varchar(255)                  # 
%}

classdef McParameter < dj.Lookup
  properties
    contents = {
               'LinearNormalized','LinearNormalizedParams', 'set of parameters for linear, normalized x-corr motion correction'
               }
  end
end
