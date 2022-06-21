%{
# 
-> recording.Recording
fragment_number             : tinyint                       # probe/field_of_view # if not always the same
---
default_same_preparams_all=1: tinyint                       # by default all probes/fields of view have same preparameters
preprocess_param_steps_id   : int                           # preparams index for recording (could be imaging/ephys)
default_same_params_all=1   : tinyint                       # by default all probes/fields of view have same parameters
paramset_idx                : int                           # params index for recording (could be imaging/ephys)
%}


classdef DefaultParams < dj.Manual


end


