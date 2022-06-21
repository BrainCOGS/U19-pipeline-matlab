%{
# 
-> puffs.PuffsCohort
-> puffs.Rig
h5_filename                 : varchar(256)                  # The full path name, e.g. "data.h5" or "data_compressed_XX.h5" for the h5 behavior data file
---
unable_to_ingest=null       : tinyint                       # 
ingested                    : tinyint                       # A flag for whether this file has already been ingested.
%}


classdef PuffsFileAcquisition < dj.Manual
end
