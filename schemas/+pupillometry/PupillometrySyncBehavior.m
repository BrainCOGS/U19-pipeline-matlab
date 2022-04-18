%{
# Matrix to sync behavior and pupillometry videos
->pupillometry.PupillometrySession
---
sync_video_frame_matrix:     longblob               # matrix with corresponding iteration for each video frame
sync_behavior_matrix:        longblob               # matrix with corresponding video frame for each iteration
%}

classdef PupillometrySyncBehavior < dj.Imported
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            %Get behavior filepath
            behavior_filepath = fetch1(acquisition.SessionStarted & key, 'remote_path_behavior_file');
            [~, behavior_filepath] = lab.utils.get_path_from_official_dir(behavior_filepath);
            
            %Get video filepath
            conf = dj.config;
            video_root_dir    = conf.custom.pupillometry_root_data_dir;
            video_filepath    = fetch1(acquisition.SessionVideo & key, 'remote_path_video_file');
            video_filepath    = fullfile(video_root_dir, video_filepath);
            [~, video_filepath] = lab.utils.get_path_from_official_dir(video_filepath);

            %Load behavioral file and video
            try
                data = load(behavior_filepath,'log');
                log = data.log;
                v = VideoReader(video_filepath);
                status = 1;
            catch
                disp(['Could not open behavioral file or video file: ', behavior_filepath, video_filepath])
                status = 0;
            end
            if status
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

