%{
# 
-> imaging_element.Processing
curation_id                 : int                           # 
---
curation_time               : datetime                      # time of generation of this set of curated results
curation_output_dir         : varchar(255)                  # output directory of the curated results, relative to root data directory
manual_curation             : tinyint                       # has manual curation been performed on this result?
curation_note               : varchar(2000)                 # 
%}


classdef Curation < dj.Manual


end


