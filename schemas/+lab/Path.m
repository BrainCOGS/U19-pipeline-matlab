%{
# 
global_path                 : varchar(255)                  # global path name
system                      : enum('windows','mac','linux') # 
---
local_path                  : varchar(255)                  # local computer path
net_location                : varchar(255)                  # location on the network
bucket_path=null            : varchar(255)                  # 
description=null            : varchar(255)                  # 
%}

classdef Path < dj.Lookup
end


