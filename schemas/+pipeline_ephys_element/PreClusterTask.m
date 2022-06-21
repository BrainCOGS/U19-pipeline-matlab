%{
# Manual table for defining a clustering task ready to be run
-> pipeline_ephys_element.EphysRecording
-> pipeline_ephys_element.PreClusterParamList
---
precluster_output_dir       : varchar(255)                  # pre-clustering output directory relative to the root data directory
task_mode="none"            : enum('none','load','trigger') # 'none': no pre-clustering analysis
%}


classdef PreClusterTask < dj.Manual


end


