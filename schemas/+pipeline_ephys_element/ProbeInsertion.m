%{
# Probe insertion implanted into an animal for a given session.
-> ephys_pipeline.EphysPipelineSession
insertion_number            : tinyint unsigned              # 
---
-> `u19_pipeline_probe_element`.`#probe`
%}


classdef ProbeInsertion < dj.Manual


end


