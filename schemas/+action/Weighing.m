%{
# 
-> `u19_subject`.`subject`
weighing_time="current_timestamp()": datetime               # 
---
 (weigh_person) -> `u19_lab`.`user`
-> `u19_lab`.`#location`
weight                      : float                         # in grams
%}

classdef Weighing < dj.Manual
end
