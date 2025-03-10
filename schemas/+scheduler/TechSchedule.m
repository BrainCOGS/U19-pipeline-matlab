%{
#
shift_index: int auto_increment
---
date                 : date
-> Shift
-> lab.User
-> TechDuties
start_time : datetime          # Datetime of when the shift ends
end_time : datetime          # Datetime of when the shift ends
%}

classdef TechSchedule < dj.Manual
end


