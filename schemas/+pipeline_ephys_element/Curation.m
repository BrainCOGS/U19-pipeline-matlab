%{
# Manual curation procedure
-> pipeline_ephys_element.Clustering
curation_id                 : int                           # 
---
curation_time               : datetime                      # time of generation of this set of curated clustering results
curation_output_dir         : varchar(255)                  # output directory of the curated results, relative to root data directory
quality_control             : tinyint                       # has this clustering result undergone quality control?
manual_curation             : tinyint                       # has manual curation been performed on this clustering result?
curation_note               : varchar(2000)                 # 
%}


classdef Curation < dj.Manual


end


