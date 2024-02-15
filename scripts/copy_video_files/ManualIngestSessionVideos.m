

video_dir = 'E:\VideoData\efonseca\';
real_video_dir = 'E:\VideoData\';

subjects = dir(video_dir);

subjects = subjects(3:end);


for i = 1:length(subjects)

    this_subj = subjects(i).name;
    video_dir_s = fullfile(video_dir, this_subj);
    session_videos = dir(video_dir_s);
    session_videos = session_videos(3:end);

    for j=1:length(session_videos)

        this_session = session_videos(j).name;
        final_dir = fullfile(video_dir_s, this_session);

        video_name = dir(final_dir);
        video_name = video_name(3:end);

        if ~isempty(video_name)
            final_video_name = fullfile(final_dir, video_name(1).name);
    
    
            key = struct;
            key.subject_fullname = this_subj;
            key.session_date = strcat(this_session(1:4),'-',this_session(5:6),'-',this_session(7:8));
            key.session_number = str2double(this_session(11));
            key.local_path_video_file = final_video_name;
            key.remote_path_video_file = strrep(final_video_name, real_video_dir, '');
            key.remote_path_video_file = strrep(key.remote_path_video_file, '\', '/');
            key.video_type = 'pupillometry';
            key.model_id = 2;
            insert(acquisition.SessionVideo, key, 'IGNORE')
        end

    end
end