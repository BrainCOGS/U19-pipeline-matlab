%{
# Manual table for defining a pre-processing task ready to be run
-> `u19_pipeline_scan_element`.`scan`
-> pipeline_imaging_element.PreprocessParamSteps
---
preprocess_output_dir       : varchar(255)                  # Pre-processing output directory relative
task_mode="none"            : enum('none','load','trigger') # 'none': no pre-processing
%}


classdef PreprocessTask < dj.Manual


end


