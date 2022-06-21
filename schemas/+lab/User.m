%{
# 
user_id                     : varchar(32)                   # username
---
user_nickname               : varchar(32)                   # same as netID for new users, for old users, this is used in the folder name etc.
full_name=null              : varchar(32)                   # first name
active_gui_user=1           : tinyint                       # 
email=null                  : varchar(64)                   # email address
phone=null                  : varchar(12)                   # phone number
-> lab.MobileCarrier
slack=null                  : varchar(32)                   # Slack username
contact_via                 : enum('Slack','text','Email')  # Preferred method of contact
presence                    : enum('Available','Away')      # 
primary_tech="N/A"          : enum('yes','no','N/A')        # 
tech_responsibility="N/A"   : enum('yes','no','N/A')        # 
day_cutoff_time             : blob                          # 
slack_webhook=null          : varchar(255)                  # 
watering_logs=null          : varchar(255)                  # 
%}

classdef User < dj.Manual
end
