%{
# time binned behavior by trial
-> behavior.TowersBlockTrial
-> meso_analysis.BinParamSet
---

binned_position_x             : blob  # 1 row per trial
binned_position_y             : blob  # 1 row per trial
binned_position_theta    : blob  # 1 row per trial
binned_dx                : blob  # 1 row per trial
binned_dy                : blob  # 1 row per trial
binned_dtheta             : blob  # 1 row per trial
binned_run_speed        : blob  # 1 row per trial
binned_cue_R            : blob  # 1 row per trial
binned_cue_L            : blob  # 1 row per trial

%}


classdef BinnedBehavior < dj.Computed
  methods(Access=protected)
    function makeTuples(self, key)
      
      bin_size       = fetch(meso_analysis.BinParamSet & key, 'bin_size');
      
      result = key;
      
      result.binned_dff = bin_trial(dff,bin_size);
      
      
      
      self.insert(result)
    end
  end
end

function bin_trial(dff,bin_size)
end