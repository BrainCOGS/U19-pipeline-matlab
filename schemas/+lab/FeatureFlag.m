%{
# Lab-wide switches read by the pipeline, the website and the rig GUIs.
# A missing row means the flag's default (see u19_pipeline.utils.responsibilities).
flag_name             : varchar(64)
---
flag_value            : varchar(255)
flag_description=""   : varchar(1024)
%}

classdef FeatureFlag < dj.Manual
end
