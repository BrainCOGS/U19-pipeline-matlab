%{
# 
paramset_idx                : smallint                      # 
---
-> ephys_element.ClusteringMethod
paramset_desc               : varchar(128)                  # 
param_set_hash              : uuid                          # 
params                      : longblob                      # dictionary of all applicable parameters
%}


classdef ClusteringParamSet < dj.Lookup


end


