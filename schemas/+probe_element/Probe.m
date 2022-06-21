%{
# represent a physical probe
probe                       : varchar(32)                   # unique identifier for this model of probe (e.g. part number)
---
-> probe_element.ProbeType
probe_comment               : varchar(1000)                 # 
%}


classdef Probe < dj.Lookup


end


