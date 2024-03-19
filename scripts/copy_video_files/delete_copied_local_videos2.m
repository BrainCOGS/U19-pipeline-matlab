function  delete_copied_local_videos2()

dj_config = dj.config;
pupillometry_raw_video_dir = dj_config.custom.PupillometryRootDataDir{1};

video_dir = 'E:\VideoData\';

users = dir(video_dir);
users = users(3:end);

for u_idx = 1:length(users)

    this_user = users(u_idx).name;
    video_dir_s1 = fullfile(video_dir, this_user);

    subjects = dir(video_dir_s1);
    subjects = subjects(3:end);


    for i = 1:length(subjects)

        this_subj = subjects(i).name;
        video_dir_s = fullfile(video_dir_s1, this_subj);
        session_videos = dir(video_dir_s);
        session_videos = session_videos(3:end);

        for j=1:length(session_videos)

            this_session = session_videos(j).name;
            final_dir = fullfile(video_dir_s, this_session);

            if numel(dir(final_dir)) <= 2
                rmdir(final_dir)
                continue
            end

            video_name = dir(final_dir);
            video_name = video_name(3:end);

            if ~isempty(video_name)
                final_video_name = fullfile(final_dir, video_name(1).name);


                key = struct;
                key.subject_fullname = this_subj;
                key.session_date = strcat(this_session(1:4),'-',this_session(5:6),'-',this_session(7:8));
                key.session_number = str2double(this_session(11));

                key
                session_video_key =  fetch(acquisition.SessionVideo & key,'*')
                

                if ~isempty(session_video_key)

                    video_remote_path = fullfile(pupillometry_raw_video_dir, session_video_key.remote_path_video_file);
                    
                    %command = ['certutil -hashfile ',  video_remote_path];
                    %[status_remote,hash_remote] = system(command);
                    %if status_remote ~= 0
                    %    continue
                    %end

                    %hash_remote = splitlines(hash_remote);
                    %hash_remote = hash_remote{2};
                    size_remote = dir(video_remote_path);

                    size_remote
                    if isempty(size_remote)
                        del(pupillometry.PupillometrySession & session_video_key)
                        continue
                    end

                    size_remote = size_remote.bytes;

                    video_local_path = final_video_name;
                    %command = ['certutil -hashfile ',  video_local_path];
                    %[status_local,hash_local] = system(command);
                    %hash_local = splitlines(hash_local);
                    %hash_local = hash_local{2};
                    size_local = dir(video_local_path);
                    size_local = size_local.bytes;

                    size_remote
                    size_local
                    
                     if (size_remote - size_local) == 0
                        video_local_path
                        delete(video_local_path)
                        if numel(dir(final_dir)) <= 2
                            rmdir(final_dir)
                        end
                     end

                    %if status_remote == 0 && ...
                    %        status_local == 0 && ...
                    %        strcmp(hash_remote, hash_local) && ...
                    %        (size_remote - size_local) == 0
                    %    video_local_path
                    %    delete(video_local_path)
                    %end

                end

            end

        end

    end
end