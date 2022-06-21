%{
# Different modalities for recordings across BRAINCoGS
recording_modality          : varchar(64)                   # modalities for recording (ephys, imaging, video_recording, etc.)
---
modality_description        : varchar(255)                  # description for the modality
root_directory              : varchar(255)                  # root directory where that modality is stored (e.g. ephys = /braininit/Data/eletrophysiology)
default_preprocessing_param_steps_id=null: int              # 
default_paramset_idx=null   : int                           # 
recording_file_extensions   : blob                          # file extensions specific for this modality
recording_file_pattern      : blob                          # 
process_unit_file_pattern   : blob                          # 
process_unit_dir_fieldname  : varchar(64)                   # 
process_repository          : varchar(64)                   # Name of the repository that handles the processing of these modality
%}


classdef RecordingModality < dj.Lookup
    properties (Constant = true)
       

    end
    
end
