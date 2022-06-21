%{
# The electrode configuration setting on a given probe
electrode_config_hash       : uuid                          # 
---
-> pipeline_probe_element.ProbeType
electrode_config_name       : varchar(4000)                 # user friendly name
%}


classdef ElectrodeConfig < dj.Lookup


end


