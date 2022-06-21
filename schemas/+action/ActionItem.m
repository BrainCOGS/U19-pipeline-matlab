%{
# action item performed every day on each subject
-> `u19_subject`.`subject`
action_date                 : date                          # date of action
action_id                   : tinyint                       # action id
---
action                      : varchar(255)                  # 
%}


classdef ActionItem < dj.Manual


end


