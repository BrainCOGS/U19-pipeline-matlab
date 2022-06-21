%{
# 
-> recording.Recording
---
-> `u19_acquisition`.`session`
%}
 
classdef RecordingBehaviorSession < dj.Part
    properties(SetAccess=protected)
        master = recording.Recording
    end
     
end
