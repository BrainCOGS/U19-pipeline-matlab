%{
# 
profile_id                  : int                           # 
---
-> lab.User
-> lab.User
-> lab.User
date_created                : date                          # 
profile_description         : varchar(255)                  # Profile description
profile_variables           : longblob                      # Encoded for the variables
%}


classdef RecordingProfile < dj.Manual


end


