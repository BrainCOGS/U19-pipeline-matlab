%{
# Manual table for defining a processing task ready to be run
-> pipeline_scan_element.Scan
-> pipeline_imaging_element.ProcessingParamSet
---
processing_output_dir       : varchar(255)                  # output directory of the processed scan relative to root data directory
task_mode="load"            : enum('load','trigger')        # 'load': load computed analysis results, 'trigger': trigger computation
%}


classdef ProcessingTask < dj.Manual


end


