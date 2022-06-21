%{
# 
subject_fullname            : varchar(64)                   # username_mouse_nickname
status_date="curdate()"     : date                          # 
---
normal_behavior=1           : tinyint                       # 
bcs=-1                      : tinyint                       # Body Condition Score, from 1 (emaciated i.e. very malnourished) to 5 (obese), 3 being normal
activity=-1                 : tinyint                       # score from 0 (moves normally) to 3 (does not move) -1 unknown
posture_grooming=-1         : tinyint                       # score from 0 (normal posture + smooth fur) to 3 (hunched + scruffy) -1 unknown
eat_drink=-1                : tinyint                       # score from 0 (normal amounts of feces and urine) to 3 (no evidence of feces or urine) -1 unknown
turgor=-1                   : tinyint                       # score from 0 (skin retracts within 0.5s) to 3 (skin retracts in more than 2 s) -1 unknown
comments=null               : varchar(255)                  # 
%}

classdef HealthStatus < dj.Manual
end
