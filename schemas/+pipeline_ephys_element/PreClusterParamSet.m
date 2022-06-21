%{
# Parameter set to be used in a clustering procedure
paramset_idx                : smallint                      # 
---
-> pipeline_ephys_element.PreClusterMethod
paramset_desc               : varchar(128)                  # 
param_set_hash              : uuid                          # 
params                      : longblob                      # dictionary of all applicable parameters
%}


classdef PreClusterParamSet < dj.Lookup


end


