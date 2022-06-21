%{
# The electrode configuration setting on a given probe
electrode_config_hash       : uuid                          # 
---
-> probe_pipeline.ProbeType
electrode_config_name       : varchar(4000)                 # user friendly name
%}


classdef ElectrodeConfig < dj.Lookup


end


