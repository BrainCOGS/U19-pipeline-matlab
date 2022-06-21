%{
# time binned behavior by trial
-> meso_analysis_old.Trialstats
---
binned_position_x           : blob                          # 1 row per trial
binned_position_y           : blob                          # 1 row per trial
binned_position_theta       : blob                          # 1 row per trial
binned_dx                   : blob                          # 1 row per trial
binned_dy                   : blob                          # 1 row per trial
binned_dtheta               : blob                          # 1 row per trial
binned_cue_l=null           : blob                          # 1 row per trial
binned_cue_r=null           : blob                          # 1 row per trials
%}


classdef BinnedBehavior < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


