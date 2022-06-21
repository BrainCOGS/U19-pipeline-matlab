%{
# 
subject_fullname            : varchar(64)                   # username_mouse_nickname
status_date="curdate()"     : date                          # 
action_id                   : tinyint                       # id of the action
---
action                      : varchar(255)                  # 
%}


classdef HealthStatusAction < dj.Manual


end


