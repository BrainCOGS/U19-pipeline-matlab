%{
# parameter definition for a motion correction method
-> imaging_old.McMethod
mc_parameter_name           : varchar(64)                   # 
---
mc_parameter_description    : varchar(255)                  # description of this parameter
%}


classdef McParameter < dj.Lookup


end


