%{
# 
-> acquisition.SessionStarted
---
data_dir                    : varchar(255)                  # data directory for each session
file_name                   : varchar(255)                  # file name
combined_file_name          : varchar(255)                  # combined filename
%}


classdef DataDirectory < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


