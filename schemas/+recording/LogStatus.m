%{
# 
recording_log_id            : int AUTO_INCREMENT            # Unique number assigned to each change
---
-> recording.Recording
 (status_recording_id_old) -> recording.Status
 (status_recording_id_new) -> recording.Status
recording_status_timestamp  : datetime                      # Timestamp when status change ocurred
recording_error_message=null: varchar(256)                  # Error message if status now is failed
recording_error_exception=null: varchar(4096)               # Error exception if status now is failed
%}


classdef LogStatus < dj.Manual


end


