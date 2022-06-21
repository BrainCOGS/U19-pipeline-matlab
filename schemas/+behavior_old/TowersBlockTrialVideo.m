%{
# 
-> behavior_old.TowersBlockTrial
---
video_path                  : varchar(511)                  # the absolute directory created for this video
%}


classdef TowersBlockTrialVideo < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


