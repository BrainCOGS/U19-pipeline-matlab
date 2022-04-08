%{
# Relationship between session & videos acquired
-> acquisition.Session
-> lab.VideoType
---
local_path_video_file    : varchar(255)                  # absolute path were video file is stored in local computer
remote_path_video_file   : varchar(255)                  # relative path were video file will be stored in braininit drive
%}

classdef SessionVideo < dj.Manual
    
    
    methods
        
        function insertSessionVideo(self,key,video_type, local_file, remote_file)
            % Insert session video record from behavioralfile in towersTask
            % Called at the end of training or when populating session
            % Input
            % self         = acquisition.Session instance
            % key          = structure with required fields: (subject_fullname, date, session_no)
            % video_type   = video_type acquired for current session
            % local_file   = absolute local filepath for the video
            % remote_file  = relative remote filepath for the video
            
            key.video_type = video_type;
            key.local_path_video_file = local_file;
            key.remote_path_video_file = remote_file;
            insert(self, key, 'IGNORE');
            
            
        end
        
        %function ingest_previous_video_sessions(self, query)            
            
        %end
    end
    
    
end