%{
# 
subject_fullname            : varchar(64)                   # username_mouse_nickname
---
subject_nickname            : varchar(16)                   # 
user_id                     : varchar(32)                   # username
genomics_id=null            : int                           # number from the facility
sex="Unknown"               : enum('Male','Female','Unknown') # sex
dob=null                    : date                          # birth date
head_plate_mark=null        : blob                          # little drawing on the head plate for mouse identification
location                    : varchar(32)                   # 
protocol=null               : varchar(16)                   # protocol number
line=null                   : varchar(128)                  # name
subject_description         : varchar(255)                  # description
initial_weight=null         : float                         # 
notification_enabled=1      : tinyint                       # 
need_reweight=0             : tinyint                       # 
%}

classdef Subject < dj.Manual
end
