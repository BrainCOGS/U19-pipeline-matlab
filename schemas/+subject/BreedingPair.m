%{
# 
breeding_pair               : varchar(63)                   # name
---
line                        : varchar(128)                  # name
subject_fullname            : varchar(64)                   # username_mouse_nickname
bp_description              : varchar(2047)                 # description
bp_start_date=null          : date                          # start date
bp_end_date=null            : date                          # 
%}

classdef BreedingPair < dj.Manual
end
