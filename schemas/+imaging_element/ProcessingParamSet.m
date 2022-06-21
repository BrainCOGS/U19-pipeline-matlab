%{
# 
paramset_idx                : smallint                      # 
---
-> imaging_element.ProcessingMethod
paramset_desc               : varchar(128)                  # 
param_set_hash              : uuid                          # 
params                      : longblob                      # dictionary of all applicable parameters
%}


classdef ProcessingParamSet < dj.Lookup


end


