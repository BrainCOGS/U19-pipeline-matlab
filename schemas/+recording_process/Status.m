%{
# 
status_processing_id        : tinyint                       # Status in the automatic processing pipeline
---
status_processing_definition: varchar(256)                  # Status definition
%}


classdef Status < dj.Lookup


end


