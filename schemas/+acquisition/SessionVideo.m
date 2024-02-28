%{
# Relationship between session & videos acquired
-> acquisition.Session
-> lab.VideoType
---
local_path_video_file    : varchar(255)                  # absolute path were video file is stored in local computer
remote_path_video_file   : varchar(255)                  # relative path were video file will be stored in braininit drive
%}



classdef SessionVideo < dj.Manual
    
    properties (Constant)
        DEFAULT_VIDEO_MODEL = 2;
    end
    
    
    methods
        
        function insertSessionVideo(self,key,video_type, local_file, remote_file, model_id)
            % Insert session video record from behavioralfile in towersTask
            % Called at the end of training or when populating session
            % Input
            % self         = acquisition.Session instance
            % key          = structure with required fields: (subject_fullname, date, session_no)
            % video_type   = video_type acquired for current session (pupillometry, behavior)
            % local_file   = absolute local filepath for the video
            % remote_file  = relative remote filepath for the video
            
            key.video_type = video_type;
            key.local_path_video_file = local_file;
            key.remote_path_video_file = remote_file;
            
            % For now, hardcoded model for video TODO ALS
            if nargin < 6
                model_id = acquisition.SessionVideo.DEFAULT_VIDEO_MODEL;
            end
            key.model_id = model_id;
            insert(self, key, 'IGNORE');
            
            
        end
        
        
    end
    
    methods(Static)
        
        function video_fullname = setup_video_file(video_parent_path,video_ext, subject_fullname)
            %get full video name and create directory for it if doesn't exist
            
            [video_dir, video_name] = acquisition.SessionVideo.get_relative_filename(subject_fullname);
            video_dir = spec_fullfile('\',video_parent_path, video_dir);
            video_fullname = spec_fullfile('\',video_dir, [video_name video_ext]);
        end
        
        function [directory, filename_only] = get_relative_filename(subject_fullname)
            
            %Get canonical filename for recordings from subject_fullname
            
            if ~contains(subject_fullname,'_')
                userid = 'no_userid';
            else
                userid = strsplit(subject_fullname,'_');
                userid = userid{1};
            end
            
            date_str = datestr(now, 'yyyymmdd');
            
            filename_only = [subject_fullname, '_', [date_str '_g0']];
            directory = spec_fullfile('\', userid, subject_fullname, [date_str '_g0']);
            
        end
        
        function remote_filename = find_remote_name_from_local_name(local_filename, subject_fullname)
            %FIND_REMOTE_NAME_FROM_LOCAL_NAME find remote relative filename given a full
            %localfile name
            
            idx = strfind(local_filename, subject_fullname);
            
            subject_directory = local_filename(1:idx+length(subject_fullname));
            if isunix
                subject_directory = strrep(subject_directory,'\','/');
                subject_directory = strrep(subject_directory,':','');
                local_filename = strrep(local_filename,'\','/');
                local_filename = strrep(local_filename,':','');
            end
            user_directory = fileparts(fileparts(fileparts(subject_directory)));
            
            remote_filename = strrep(local_filename, user_directory, '');
            remote_filename = strrep(remote_filename,'\','/');
            
            if remote_filename(1) == '/'
                remote_filename = remote_filename(2:end);
            end
            
        end
        
        
        
    end
    
end