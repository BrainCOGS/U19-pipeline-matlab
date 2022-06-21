%{
# 
-> `u19_subject`.`subject`
restriction_start_time      : datetime                      # start time
---
restriction_end_time=null   : datetime                      # end time
restriction_narrative       : varchar(1024)                 # comment
%}


classdef WaterRestriction < dj.Manual
end
