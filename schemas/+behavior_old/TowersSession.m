%{
# 
-> acquisition.SessionOld
---
stimulus_set                : tinyint                       # an integer that describes a particular set of stimuli in a trial
ball_squal                  : float                         # quality measure of ball data
rewarded_side               : blob                          # Left or Right X number trials
chosen_side                 : blob                          # Left or Right X number trials
maze_id                     : blob                          # level X number trials
num_towers_r                : blob                          # Number of towers shown to the right x number of trials
num_towers_l                : blob                          # Number of towers shown to the left x tumber of trials
%}


classdef TowersSession < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


