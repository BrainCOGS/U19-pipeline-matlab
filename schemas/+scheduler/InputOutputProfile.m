%{
# Input/Outuput profile registry table
input_output_profile_id     : int AUTO_INCREMENT            # numeric_id for Input/Output profile
---
-> lab.User
input_output_profile_name   : varchar(32)                   # Input/Output profile name
input_output_profile_description: varchar(255)              # Input/Output profile description
input_output_profile_date   : date                          # Input/Output profile creation date
%}


classdef InputOutputProfile < dj.Manual


end


