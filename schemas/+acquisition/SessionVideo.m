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
        
        function ingest_previous_video_sessions(self, query)
            % Ingest previous optogenetics session manipulation records
            % Read through all behavior files and search for optogenetic data fields.
            
            % All sessions not previously inserted
            if nargin < 2
                sess_started = acquisition.SessionStarted;
            else
                sess_started = acquisition.SessionStarted & query;
            end
            prev_sessions = fetch(sess_started - self);
            
            video_sessions = 0;
            for i=1:length(prev_sessions)
                [video_sessions i length(prev_sessions)]
                [status, data] = lab.utils.read_behavior_file(prev_sessions(i));
                if status
                    log = data.log;
                    %Check if block has field named lsrepoch
                    if isfield(log.animal, 'video_acq_struct') && isfield(log.animal, 'videoAcquisition')
                        video_sessions = video_sessions + 1;
                        session_key = prev_sessions(i);
                        
                        %self.insertSessionVideo(session_key,log.animal.videoAcquisition, ...
                        %log.animal.video_acq_struct.local_video_name, ...
                        %log.animal.video_acq_struct.remote_video_name)
                        
                    end
                end
            end
            
            
        end
        
        function ingest_previous_video_sessions_no_info(self, query)
            % Ingest previous video puppilometry sessions with no file data
            
            % All sessions not previously inserted
            if nargin < 2
                sess_started = acquisition.SessionStarted;
            else
                sess_started = acquisition.SessionStarted & query;
            end
            prev_sessions = fetch(sess_started - self);
            
            video_sessions = 0;
            for i=1:length(prev_sessions)
                [video_sessions i length(prev_sessions)]
                prev_sessions(i)
                [status, data] = lab.utils.read_behavior_file(prev_sessions(i));
                if status
                    log = data.log;
                    %Check if block has field named lsrepoch
                    if isfield(log, 'timeElapsedVideoStart') && ~isempty(log.timeElapsedVideoStart)
                        video_sessions = video_sessions + 1;
                        session_key = prev_sessions(i);
                        
                        parent_path = 'D:\VideoData';
                        video_ext   =   '.mj2';
                        
                        
                        video_fullname = self.setup_video_file(parent_path, video_ext, session_key.subject_fullname);
                        remote_video_name = self.find_remote_name_from_local_name(video_fullname, session_key.subject_fullname);
                        
                        self.insertSessionVideo(session_key, 'pupillometry', video_fullname,remote_video_name)
                        
                    end
                end
            end
            
            
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