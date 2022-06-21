%{
# Mean waveform across spikes for a given unit at its representative electrode
-> pipeline_ephys_element.WaveformSet
-> pipeline_ephys_element.CuratedClusteringUnit
---
peak_electrode_waveform     : longblob                      # (uV) mean waveform for a given unit at its representative electrode
%}


classdef WaveformSetPeakWaveform < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


