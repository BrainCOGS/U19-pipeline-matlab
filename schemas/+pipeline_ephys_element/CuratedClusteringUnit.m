%{
# Properties of a given unit from a round of clustering (and curation)
-> pipeline_ephys_element.CuratedClustering
unit                        : int                           # 
---
-> pipeline_probe_element.ElectrodeConfigElectrode
-> pipeline_ephys_element.ClusterQualityLabel
spike_count                 : int                           # how many spikes in this recording for this unit
spike_times                 : longblob                      # (s) spike times of this unit, relative to the start of the EphysRecording
spike_sites                 : longblob                      # array of electrode associated with each spike
spike_depths=null           : longblob                      # (um) array of depths associated with each spike, relative to the (0, 0) of the probe
%}


classdef CuratedClusteringUnit < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


