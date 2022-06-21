%{
# 
-> action.Surgery
-> `u19_reference`.`#virus`
---
injection_volume            : float                         # injection volume
rate_of_injection           : float                         # rate of injection
virus_dilution              : float                         # x dilution of the original virus
-> `u19_reference`.`#brain_area`
%}

classdef VirusInjection < dj.Manual
end
