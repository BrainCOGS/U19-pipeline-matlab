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
%}


classdef Schedule < dj.Manual


end


