%{
# 
recording_id                : int AUTO_INCREMENT            # Unique number assigned to recording
---
-> recording.Modality
-> `u19_lab`.`#location`
-> recording.Status
task_copy_id_pni=null       : int                           # globus transfer task raw file local->cup
inherit_params_recording=1  : tinyint                       # all RecordingProcess from a recording will have same paramSets
recording_directory         : varchar(255)                  # relative directory on cup
local_directory             : varchar(255)                  # local directory where the recording is stored on system
%}

classdef Recording< dj.Manual
    
end
