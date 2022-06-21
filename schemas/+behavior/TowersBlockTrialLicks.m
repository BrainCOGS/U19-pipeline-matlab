%{
# 
-> behavior.TowersBlockTrialOld
---
lick_l_time                 : blob                          # lick left  times in trial
lick_r_time                 : blob                          # lick right times in trial
%}


classdef TowersBlockTrialLicks < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


