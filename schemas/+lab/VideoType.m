%{
# Types of video that can be acquired in a behavior session
video_type                  : varchar(64)                   # 
---
video_type_description      : varchar(2555)                 # 
%}

classdef VideoType < dj.Lookup
    properties
        contents = {
            'pupillometry', '';
            'behavior',  '';
            }
    end
end
