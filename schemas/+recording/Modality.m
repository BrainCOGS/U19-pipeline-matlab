%{
# 
recording_modality          : varchar(64)                   # recording modalities
---
modality_description        : varchar(255)                  # description for the modality
root_directory              : varchar(255)                  # root directory where modality is stored
default_preprocess_param_steps_id=null: int                 # 
default_paramset_idx=null   : int                           # 
recording_file_extensions   : blob                          # file extensions for this modality
recording_file_pattern      : blob                          # directory pattern to find recordings in path
process_unit_file_pattern   : blob                          # process "unit" pattern to find in path
process_unit_dir_fieldname  : varchar(64)                   # FieldName that stores process unit
process_unit_fieldname      : varchar(32)                   # FieldName that stores process unit for
process_repository          : varchar(64)                   # Name of the repository that handles the
%}


classdef Modality < dj.Lookup


end


