%{
# Spike waveforms and their mean across spikes for the given unit
-> pipeline_ephys_element.WaveformSet
-> pipeline_ephys_element.CuratedClusteringUnit
-> pipeline_probe_element.ElectrodeConfigElectrode
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


