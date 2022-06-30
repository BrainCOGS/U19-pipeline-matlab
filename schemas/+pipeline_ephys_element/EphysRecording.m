%{
# Ephys recording from a probe insertion for a given session.
-> pipeline_ephys_element.ProbeInsertion
---
-> pipeline_probe_element.ElectrodeConfig
-> pipeline_ephys_element.AcquisitionSoftware
sampling_rate               : float                         # (Hz)
recording_datetime          : datetime                      # datetime of the recording from this probe
recording_duration          : float                         # (seconds) duration of the recording from this probe
%}


classdef EphysRecording < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


