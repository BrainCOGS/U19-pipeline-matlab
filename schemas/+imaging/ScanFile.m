%{
-> acquisition.Scan
file_number    : int             # file number of a given scan
---
scan_filename  : varchar(255)
%}


classdef ScanFile < dj.Computed
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            % find subject and date from acquisition.Session table
            key.file_number   = 0;
            
            self.insert(key)
            
        end
    end
end

