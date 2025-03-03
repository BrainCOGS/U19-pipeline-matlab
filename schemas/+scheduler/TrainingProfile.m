%{
# 
training_profile_id                  : int autoincrement                          # 
---
-> lab.User
date_created                         : date                          # 
training_profile_name                : varchar(255)                  # Profile name
training_profile_description         : varchar(255)                  # Profile description
training_profile_variables           : varchar(16384)                      # Encoded for the variables
%}


classdef TrainingProfile < dj.Manual


end


