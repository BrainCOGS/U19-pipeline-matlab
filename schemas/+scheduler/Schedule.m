%{
# 
date                        : date                          # Full date
-> lab.Location
-> lab.Location
-> lab.Location
timeslot                    : int                           # timeslot by number
---
-> subject.Subject
-> subject.Subject
-> subject.Subject
-> scheduler.BehaviorProfile
-> scheduler.RecordingProfile
-> scheduler.BehaviorProfile
-> scheduler.RecordingProfile
-> scheduler.BehaviorProfile
-> scheduler.RecordingProfile
-> scheduler.InputOutputProfile
-> scheduler.InputOutputProfile
-> scheduler.InputOutputProfile
%}


classdef Schedule < dj.Manual


end


