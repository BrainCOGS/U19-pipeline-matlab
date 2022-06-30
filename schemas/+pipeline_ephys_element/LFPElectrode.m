%{
# 
-> pipeline_ephys_element.LFP
-> pipeline_probe_element.ElectrodeConfigElectrode
---
lfp                         : longblob                      # (uV) recorded lfp at this electrode
%}


classdef LFPElectrode < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


