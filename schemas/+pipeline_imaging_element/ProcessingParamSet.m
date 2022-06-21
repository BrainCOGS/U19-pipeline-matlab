%{
# Parameter set used for processing of calcium imaging data
paramset_idx                : smallint                      # 
---
-> pipeline_imaging_element.ProcessingMethod
paramset_desc               : varchar(128)                  # 
param_set_hash              : uuid                          # 
params                      : longblob                      # dictionary of all applicable parameters
%}


classdef ProcessingParamSet < dj.Lookup


end


