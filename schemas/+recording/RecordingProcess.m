%{
# 
recording_process_id        : int AUTO_INCREMENT            # Unique number assigned to each processing job for a recording unit
---
-> recording.Recording
-> recording.StatusProcessDefinition
-> recording.PreprocessParamSet
-> recording.ProcessParamSet
fragment_number             : tinyint                       # fov# or probe#, etc. reference from the corresponding modality
recording_process_pre_path=null: varchar(200)               # relative path for raw data recording subdirectory that will be processed (ephys-> probe, imaging->fieldofview)
recording_process_post_path=null: varchar(200)              # relative path for processed data recording
task_copy_id_pre=null       : UUID                          # id for globus transfer task raw file cup->tiger
task_copy_id_post=null      : UUID                          # id for globus transfer task sorted file tiger->cup
slurm_id=null               : varchar(16)                   # id for slurm process in tiger
%}


classdef RecordingProcess < dj.Manual


end


