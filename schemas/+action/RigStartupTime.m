%{
-> lab.Location
startup_datetime:         datetime      # When startup occured
---
startup_type:   enum("Training Flow GUI","Rig Tester","No Schedule") 
num_subj_scheduled:       tinyint               # how many subjects scheduled in rig
startup_time:             float             # How much time in seconds did startup take
%}

classdef RigStartupTime < dj.Manual

 
end