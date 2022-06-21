%{
# available motion correction method
mcorr_method                : varchar(128)                  # 
---
correlation_type="Normalized": enum('Normalized','NonNormalized') # 
tranformation_type="Linear" : enum('Linear','NonLinear')    # 
%}


classdef MotionCorrectionMethod < dj.Lookup


end


