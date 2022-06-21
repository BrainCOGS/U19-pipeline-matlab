%{
# 
-> ephys_rec.BehaviorSync
-> ephys_element.ProbeInsertion
---
ephys_sampling_rate         : float                         # sampling rate of the headstage of a probe, imSampRate in imec meta file
%}


classdef BehaviorSyncImecSamplingRate < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


