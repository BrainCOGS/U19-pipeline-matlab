%{
# 
subject_fullname            : varchar(64)                   # username_mouse_nickname
allele                      : varchar(63)                   # informal name
---
zygosity                    : enum('Present','Absent','Homozygous','Heterozygous') # 
%}

classdef Zygosity < dj.Manual
end
