%{
# Represent a physical probe with unique identification
probe                       : varchar(32)                   # unique identifier for this model of probe (e.g. serial number)
---
-> pipeline_probe_element.ProbeType
probe_comment               : varchar(1000)                 # 
%}


classdef Probe < dj.Lookup


end


