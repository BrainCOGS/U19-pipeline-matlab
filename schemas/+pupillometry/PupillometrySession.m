%{
# Information of a pupillometry session
->acquisition.Session
---
is_bad_video=0            : tinyint                       # Flag that indicates if this session had a failed video
%}

classdef PupillometrySession < dj.Imported
    
    properties
        keySource =  acquisition.Session & struct('is_bad_session', 0) & (acquisition.SessionVideo & struct('video_type', 'pupillometry'));
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
          
           % Only populate Pupillometry Session if video is already in cup
          conf = dj.config;
          video_key = fetch(acquisition.SessionVideo & key,'*');
          raw_dir = conf.custom.PupillometryRootDataDir{1};  
          new_video_file = fullfile(raw_dir, video_key.remote_path_video_file);
          if isfile(new_video_file)
            key.is_bad_video = 0;
            insert(self, key)
          end
            
          
        end
        
    end
end
