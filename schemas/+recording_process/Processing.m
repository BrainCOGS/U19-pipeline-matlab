%{
# 
job_id                      : int AUTO_INCREMENT            # 
---
-> recording.Recording
-> recording_process.Status
fragment_number             : tinyint                       # fov# or probe#, etc. reference
recording_process_pre_path=null: varchar(200)               # relative path for raw data
recording_process_post_path=null: varchar(200)              # relative path of processed
task_copy_id_pre=null       : UUID                          # id for globus transfer task raw
task_copy_id_post=null      : UUID                          # id for globus transfer task
slurm_id=null               : varchar(16)                   # id for slurm process in tiger
%}


classdef Processing < dj.Manual


end


