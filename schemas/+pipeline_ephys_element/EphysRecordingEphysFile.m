%{
# Paths of files of a given EphysRecording round.
-> pipeline_ephys_element.EphysRecording
file_path                   : varchar(255)                  # filepath relative to root data directory
%}


classdef EphysRecordingEphysFile < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


