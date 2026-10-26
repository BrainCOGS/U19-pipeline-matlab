%{
# Lab-wide dates on which no ScheduleRule produces sessions (holidays, shutdowns)
date                        : date
---
reason                      : varchar(255)
-> lab.User
%}


classdef LabClosure < dj.Manual


end
