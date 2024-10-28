%{
# 
behavior_profile_id                  : int autoincrement                          # 
---
-> lab.User
date_created                : date                          # 
behavior_profile_name         : varchar(255)                  # Profile name
behavior_profile_description         : varchar(255)                  # Profile description
behavior_profile_variables           : longblob                      # Encoded for the variables
%}


classdef BehaviorProfile < dj.Manual


end


