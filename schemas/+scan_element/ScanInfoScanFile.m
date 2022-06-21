%{
# 
-> scan_element.ScanInfo
file_path                   : varchar(255)                  # filepath relative to root data directory
%}


classdef ScanInfoScanFile < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


