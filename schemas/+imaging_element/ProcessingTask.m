%{
# 
-> `u19_scan_element`.`scan`
-> imaging_element.ProcessingParamSet
---
processing_output_dir       : varchar(255)                  # output directory of the processed scan relative to root data directory
task_mode="load"            : enum('load','trigger')        # 'load': load computed analysis results, 'trigger': trigger computation
%}


classdef ProcessingTask < dj.Manual


end


