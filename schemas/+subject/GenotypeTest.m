%{
# 
subject_fullname            : varchar(64)                   # username_mouse_nickname
sequence                    : varchar(63)                   # informal name
genotype_test_id            : varchar(63)                   # 
---
test_result                 : enum('Present','Absent')      # 
%}

classdef GenotypeTest < dj.Manual
end
