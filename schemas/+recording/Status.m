%{
# 
status_recording_id         : tinyint                       # Status in the automatic processing pipeline
---
status_recording_definition : varchar(256)                  # Status definition
%}


classdef Status < dj.Lookup


end


