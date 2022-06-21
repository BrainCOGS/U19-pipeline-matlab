%{
# Information of a pupillometry session
-> acquisition.Session
%}

classdef PupillometrySession < dj.Imported
    
    properties
        keySource =  acquisition.Session & (acquisition.SessionVideo & struct('video_type', 'pupillometry'));
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            
          insert(self, key)
          
        end
        
    end
end
