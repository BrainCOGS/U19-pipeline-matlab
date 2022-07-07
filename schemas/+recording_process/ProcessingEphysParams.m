%{
# 
-> recording_process.Processing
---
-> pipeline_ephys_element.PreClusterParamSteps
-> pipeline_ephys_element.ClusteringParamSet
%}


classdef ProcessingEphysParams < dj.Part
    properties(SetAccess=protected)
        master = recording_process.Processing
    end


end


