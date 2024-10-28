%{
# 
recording_profile_id                  : int  AUTO_INCREMENT                         # 
---
date_created                          : date                          # 
recording_profile_name         : varchar(255)                  # Profile name
recording_profile_description         : varchar(255)                  # Profile description
recording_profile_variables           : longblob                      # Encoded for the variables
%}


classdef RecordingProfile < dj.Manual


end


