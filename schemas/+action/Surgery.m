%{
# 
-> `u19_subject`.`subject`
surgery_start_time          : datetime                      # surgery start time
---
surgery_end_time=null       : datetime                      # surgery end time
-> `u19_lab`.`user`
-> `u19_lab`.`#location`
-> action.SurgeryType
surgery_outcome_type        : enum('success','death')       # outcome type
surgery_narrative=null      : varchar(1024)                 # narrative
angle                       : decimal(5,2)                  # (degrees) tilt angle for insertion device (if applicable)
tilt_axis                   : enum('AP','ML','N/A')         # from which axis angle was measured
%}

classdef Surgery < dj.Manual
end
