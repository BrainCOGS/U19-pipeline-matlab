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
%}


classdef Schedule < dj.Manual


end


