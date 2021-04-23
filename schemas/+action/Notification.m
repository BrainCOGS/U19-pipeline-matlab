%{
# This table documents whether a notification has been sent to the users. 
-> subject.Subject                    # Mouse concerned
notification_date     : date           # Date of notification
---
notification_time = null           : datetime       # Exact time of notification
cage_notice = ''      : varchar(255)   # Cage-notice. Cage not returned
health_notice = ''    : varchar(255)   # Health-notice. missed action Items
weight_notice = ''    : varchar(255)   # Weight-notice. mouse too light
%}

classdef Notification < dj.Manual
end