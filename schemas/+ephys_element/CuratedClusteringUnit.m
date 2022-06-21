%{
# 
-> ephys_element.CuratedClustering
unit                        : int                           # 
---
-> `u19_probe_element`.`#electrode_config__electrode`
-> ephys_element.ClusterQualityLabel
spike_count                 : int                           # how many spikes in this recording for this unit
spike_times                 : longblob                      # (s) spike times of this unit, relative to the start of the EphysRecording
spike_sites                 : longblob                      # array of electrode associated with each spike
spike_depths                : longblob                      # (um) array of depths associated with each spike, relative to the (0, 0) of the probe
%}


classdef CuratedClusteringUnit < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


