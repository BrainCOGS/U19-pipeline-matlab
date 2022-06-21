%{
# 
duty_roaster_date           : date                          # date from which this assignment is valid.
---
 (monday_duty) -> lab.User
 (tuesday_duty) -> lab.User
 (wednesday_duty) -> lab.User
 (thursday_duty) -> lab.User
 (friday_duty) -> lab.User
 (saturday_duty) -> lab.User
 (sunday_duty) -> lab.User
%}

classdef DutyRoaster < dj.Manual
end
