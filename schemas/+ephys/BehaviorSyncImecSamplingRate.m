%{
# 
-> ephys.BehaviorSync
-> `u19_ephys_element`.`probe_insertion`
---
ephys_sampling_rate         : float                         # sampling rate of the headstage of a probe, imSampRate in imec meta file
%}


classdef BehaviorSyncImecSamplingRate < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


