%{
# Probe insertion implanted into an animal for a given session.
-> ephys_pipeline.EphysPipelineSession
insertion_number            : tinyint unsigned              # 
---
-> pipeline_probe_element.Probe
%}


classdef ProbeInsertion < dj.Manual


end


