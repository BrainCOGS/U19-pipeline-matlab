%{
# available motion correction method
mc_method                   : varchar(128)                  # 
---
correlation_type="Normalized": enum('Normalized','NonNormalized') # 
tranformation_type="Linear" : enum('Linear','NonLinear')    # 
%}


classdef McMethod < dj.Lookup


end


