%{
# 
notification_settings_date  : date                          # date from which this is valid.
---
max_response_time           : float                         # in minutes, e.g. 30
change_cutoff_time          : blob                          # time of day, e.g. [5,0] (=5pm)
weekly_digest_day           : varchar(5)                    # weekday, e.g. Mon
weekly_digest_time          : blob                          # time of day, e.g. [5,0] (=5pm)
%}

classdef NotificationSettings < dj.Manual
end
