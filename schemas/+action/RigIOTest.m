%{
# 
-> `u19_lab`.`#location`
io_test_date="curdate()"    : date                          # date IO test
io_test_time="curtime()"    : time                          # time IO test
---
io_type                     : varchar(64)                   # string that correspond to a certain combination of input and outputs tested
rig_test_parameters=null    : blob                          # 
%}

classdef RigIOTest < dj.Manual
end
