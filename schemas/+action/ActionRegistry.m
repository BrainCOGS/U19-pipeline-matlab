%{
-> subject.Subject              # 
action_datetime:        datetime       # At what datetime action was performed
action:                 varchar(255)   # Which action was performed
-----
(action_person) -> lab.User
%}

classdef ActionRegistry < dj.Manual
end