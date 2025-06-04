%{
# Matrix to sync behavior and pupillometry videos
->pupillometry.PupillometrySession
---
sync_video_frame_matrix:     longblob               # matrix with corresponding iteration for each video frame
sync_behavior_matrix:        longblob               # matrix with corresponding video frame for each iteration
%}

classdef PupillometrySyncBehavior < dj.Imported

    properties
        keySource =  pupillometry.PupillometrySession & struct('is_bad_video', 0);
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            %Get behavior filepath
            behavior_filepath = fetch1(acquisition.SessionStarted & key, 'new_remote_path_behavior_file');
            [~, behavior_filepath] = lab.utils.get_path_from_official_dir(behavior_filepath);
            
            %Get video filepath
            conf = dj.config;
            video_root_dir    = conf.custom.PupillometryRootDataDir{1};
            video_filepath    = fetch1(acquisition.SessionVideo & key, 'remote_path_video_file');
            video_filepath    = fullfile(video_root_dir, video_filepath);
            [~, video_filepath] = lab.utils.get_path_from_official_dir(video_filepath);

            %Load behavioral file and video
            try
                data = load(behavior_filepath,'log');
                log = data.log;
                status_b = 1;
            catch
                disp(['Could not open behavioral file ', behavior_filepath])
                status_b = 0;
            end
            try 
                v = VideoReader(video_filepath);
                status_v = 1;
            catch 
                disp(['Could not open video file: ', video_filepath])
                status_v = 0;
                days_from_session = days(datetime('now') - datetime(key.session_date));
                if days_from_session > 3
                    update(pupillometry.PupillometrySession & key, 'is_bad_video', 1);
                end
            end

            if status_v && status_b
                %Check if it is a real behavioral file
                if isfield(log, 'session')
                    
                    %Get sync matrices
                    [key.sync_video_frame_matrix, key.sync_behavior_matrix] = sync_pupillometry_video(log, v);
                    insert(self, key);
                end
                
            end
            
        end
        
    end
    
end

