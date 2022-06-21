%{
# General information of an ephys session
-> ephys_rec.EphysRecording
probe                       : tinyint                       # probe number for the recording
---
probe_directory             : varchar(255)                  # probe specific directory
%}


classdef EphysRecordingProbes < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


