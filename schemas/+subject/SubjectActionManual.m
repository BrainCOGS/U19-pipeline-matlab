%{
# 
subject_fullname            : varchar(64)                   # username_mouse_nickname
act_item                    : varchar(64)                   # possible act item
notification_date="current_timestamp()": datetime           # datetime when notification was generated
---
valid_until_date=null       : datetime                      # datetime when notification was inactivated
%}

classdef SubjectActionManual < dj.Manual
end
