%{
# 
-> ephys_rec.CuratedClustersIteration
-> ephys_element.CuratedClusteringUnit
---
spike_counts_iteration      : longblob                      # number of spikes during each iteration. have length as the number of iterations - 1
firing_rate_before_first_iteration: float                   # 
firing_rate_after_last_iteration: float                     # 
%}


classdef CuratedClustersIterationUnit < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


