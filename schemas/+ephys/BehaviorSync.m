%{
# 
-> ephys.EphysSession
---
nidq_sampling_rate          : float                         # sampling rate of behavioral iterations niSampRate in nidq meta file
iteration_index_nidq        : longblob                      # length of this longblob should be the number of iterations in the behavior recording
trial_index_nidq=null       : longblob                      # length of this longblob should be the number of iterations in the behavior recording
%}


classdef BehaviorSync < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


