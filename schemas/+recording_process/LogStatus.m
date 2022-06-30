%{
# 
log_id                      : int AUTO_INCREMENT            # Unique number assigned to each change
---
-> recording_process.Processing
 (status_processing_id_old) -> recording_process.Status
 (status_processing_id_new) -> recording_process.Status
status_timestamp            : datetime                      # Timestamp when status change ocurred
error_message=null          : varchar(256)                  # Error message if status now is failed
error_exception=null        : varchar(4096)                 # Error exception if status now is failed
%}


classdef LogStatus < dj.Manual


end


