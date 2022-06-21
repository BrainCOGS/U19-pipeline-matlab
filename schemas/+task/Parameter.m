%{
# 
parameter                   : varchar(32)                   # 
---
-> task.ParameterCategory
parameter_description       : varchar(255)                  # info such as the unit
%}


classdef Parameter < dj.Lookup


end


