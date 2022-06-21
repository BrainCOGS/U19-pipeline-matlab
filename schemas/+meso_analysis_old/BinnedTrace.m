%{
# time binned activity by trial
-> `u19_meso_old`.`_segmentation`
-> meso_analysis_old.BinningParameters
-> meso_analysis_old.TrialSelectionParameters
global_roi_idx              : int                           # roi_idx in SegmentationRoi table
trial_idx                   : int                           # trial number as in meso_analysis.Trialstats
---
binned_dff                  : blob                          # binned Dff, 1 row per neuron per trialStruct
%}


classdef BinnedTrace < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


