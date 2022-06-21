%{
# 
-> ephys_element.LFP
-> `u19_probe_element`.`#electrode_config__electrode`
---
lfp                         : longblob                      # (uV) recorded lfp at this electrode
%}


classdef LFPElectrode < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


