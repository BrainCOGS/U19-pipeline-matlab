%{
# 
-> acquisition.SessionOld
---
scan_directory              : varchar(255)                  # 
%}


classdef Scan < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


