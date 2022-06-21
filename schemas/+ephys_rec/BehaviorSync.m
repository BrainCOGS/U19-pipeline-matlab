%{
# 
-> ephys_rec.EphysRecording
---
nidq_sampling_rate          : float                         # sampling rate of behavioral iterations niSampRate in nidq meta file
iteration_index_nidq        : longblob                      # Virmen index time series. Length of this longblob should be the number of samples in the nidaq file.
trial_index_nidq=null       : longblob                      # Trial index time series. length of this longblob should be the number of samples in the nidaq file.
%}


classdef BehaviorSync < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


