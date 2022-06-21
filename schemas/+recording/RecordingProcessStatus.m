%{
# 
recording_process_status_id : int AUTO_INCREMENT            # Unique number assigned to each change of status for all processing jobs
---
-> recording.RecordingProcess
 (status_pipeline_idx_old) -> recording.StatusProcessDefinition
 (status_pipeline_idx_new) -> recording.StatusProcessDefinition
status_timestamp            : datetime                      # timestamp when status change ocurred
error_message=null          : varchar(4096)                 # Error message if status now is failed
error_exception=null        : blob                          # Error exception if status now is failed
%}


classdef RecordingProcessStatus < dj.Manual


end


