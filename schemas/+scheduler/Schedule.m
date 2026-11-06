%{
# 
date                        : date                          # Full date
-> lab.Location
timeslot                    : int                           # timeslot by number
---
-> subject.Subject
-> scheduler.TrainingProfile
-> scheduler.RecordingProfile
-> scheduler.InputOutputProfile
experimenters_instructions : varchar(64532)
level: int
sublevel: int
-> [nullable] scheduler.ScheduleRule                      # rule that generated this row; NULL for manual or copy-forward rows
%}


classdef Schedule < dj.Manual


end


