%{
# Acquired local field potential (LFP) from a given Ephys recording.
-> pipeline_ephys_element.PreCluster
---
lfp_sampling_rate           : float                         # (Hz)
lfp_time_stamps             : longblob                      # (s) timestamps with respect to the start of the recording (recording_timestamp)
lfp_mean                    : longblob                      # (uV) mean of LFP across electrodes - shape (time,)
%}


classdef LFP < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


