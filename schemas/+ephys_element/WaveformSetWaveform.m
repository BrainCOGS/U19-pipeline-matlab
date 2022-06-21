%{
# Spike waveforms and their mean across spikes for the given unit
-> ephys_element.WaveformSet
-> ephys_element.CuratedClusteringUnit
-> `u19_probe_element`.`#electrode_config__electrode`
---
waveform_mean               : longblob                      # (uV) mean waveform across spikes of the given unit
waveforms=null              : longblob                      # (uV) (spike x sample) waveforms of a sampling of spikes at the given electrode for the given unit
%}


classdef WaveformSetWaveform < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


