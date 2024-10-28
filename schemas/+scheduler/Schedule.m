%{
# 
date                        : date                          # Full date
-> lab.Location
timeslot                    : int                           # timeslot by number
---
-> subject.Subject
-> scheduler.BehaviorProfile
-> scheduler.RecordingProfile
-> scheduler.InputOutputProfile
%}


classdef Schedule < dj.Manual


end


