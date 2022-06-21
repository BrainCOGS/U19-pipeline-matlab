%{
# 
-> behavior.TowersBlockTrial
---
video_path                  : varchar(511)                  # the absolute directory created for this video
%}

classdef TowersBlockTrialVideo < dj.Imported
   % properties(SetAccess=protected)
   %     master = behavior.TowersBlock
   % end
   methods(Access=protected)
        function makeTuples(self, key)
        end
   end
end
