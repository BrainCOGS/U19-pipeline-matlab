%{
# Ephys recording from a probe insertion for a given session.
-> ephys_element.ProbeInsertion
---
-> `u19_probe_element`.`#electrode_config`
-> ephys_element.AcquisitionSoftware
sampling_rate               : float                         # (Hz)
%}


classdef EphysRecording < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


