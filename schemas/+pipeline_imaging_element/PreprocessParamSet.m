%{
# Parameter set used for pre-processing of calcium imaging data
paramset_idx                : smallint                      # 
---
-> pipeline_imaging_element.PreprocessMethod
paramset_desc               : varchar(128)                  # 
param_set_hash              : uuid                          # 
params                      : longblob                      # dictionary of all applicable parameters
%}


classdef PreprocessParamSet < dj.Lookup


end


