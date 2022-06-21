%{
# 
litter                      : varchar(63)                   # 
---
breeding_pair               : varchar(63)                   # name
line                        : varchar(128)                  # name
litter_descriptive_name     : varchar(255)                  # descriptive name
litter_description          : varchar(255)                  # description
litter_birth_date=null      : date                          # 
%}

classdef Litter < dj.Manual
end
