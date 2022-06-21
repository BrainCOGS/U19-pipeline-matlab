%{
# 
subject_fullname            : varchar(64)                   # username_mouse_nickname
notification_date="current_timestamp()": datetime           # datetime when notification was automatically generated
---
notification_message        : varchar(255)                  # Notification message e.g. low bodyweight warning
valid_until_date=null       : datetime                      # datetime when notification was inactivated
%}

classdef SubjectActionAutomatic < dj.Manual
end
