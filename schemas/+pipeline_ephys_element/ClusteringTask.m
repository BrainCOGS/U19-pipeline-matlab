%{
# Manual table for defining a clustering task ready to be run
-> pipeline_ephys_element.PreCluster
-> pipeline_ephys_element.ClusteringParamSet
---
clustering_output_dir       : varchar(255)                  # clustering output directory relative to the clustering root data directory
task_mode="load"            : enum('load','trigger')        # 'load': load computed analysis results, 'trigger': trigger computation
%}


classdef ClusteringTask < dj.Manual


end


