%{
# Information of a posture_tracking session
->acquisition.Session
---
is_bad_video=0            : tinyint                       # Flag that indicates if this session had a failed video
%}

classdef PostureTrackingSession < dj.Imported

    properties
        keySource =  acquisition.Session & struct('is_bad_session', 0) & (acquisition.SessionVideo & struct('video_type', 'posture_tracking'));
    end

    methods(Access=protected)

        function makeTuples(self, key)

            % Only populate posture_tracking Session if video is already in cup
            conf = dj.config;
            video_key = fetch(acquisition.SessionVideo & key,'*');
            raw_dir = conf.custom.PostureTrackingRootDataDir{1};
            new_video_file = fullfile(raw_dir, video_key.remote_path_video_file);
            if isfile(new_video_file)
                key.is_bad_video = 0;
                insert(self, key)
            else
                days_from_session = days(datetime('now') - datetime(key.session_date));
                if days_from_session > 10
                    key.is_bad_video = 1;
                    insert(self, key)
                end
            end

        end

    end
end
