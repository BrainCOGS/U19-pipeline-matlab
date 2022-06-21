%{
# 
-> behavior_old.TowersSession
block                       : tinyint                       # block number
---
-> `u19_task`.`#task_level_parameter_set`
n_trials                    : int                           # number of trials in this block
first_trial                 : int                           # trial_idx of the first trial in this block
block_duration              : float                         # in secs, duration of the block
block_start_time            : datetime                      # absolute start time of the block
reward_mil                  : float                         # in mL, reward volume in this block
reward_scale                : tinyint                       # scale of the reward in this block
easy_block                  : tinyint                       # true if the difficulty reduces during the session
block_performance           : float                         # performance in the current block
%}


classdef TowersBlock < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


