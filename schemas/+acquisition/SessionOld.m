%{
# 
-> `u19_subject`.`subject`
session_date                : date                          # date of experiment
session_number              : int                           # number
---
session_start_time          : datetime                      # start time
session_end_time=null       : datetime                      # end time
 (session_location) -> `u19_lab`.`#location`
-> `u19_task`.`#task_level_parameter_set`
stimulus_bank               : varchar(255)                  # path to the function to generate the stimulus
stimulus_commit             : varchar(64)                   # git hash for the version of the function
session_performance         : float                         # percentage correct on this session
session_narrative           : varchar(512)                  # 
session_protocol=null       : varchar(255)                  # function and parameters to generate the stimulus
session_code_version=null   : blob                          # code version of the stimulus, maybe a version number, or a githash
%}


classdef SessionOld < dj.Manual


end


