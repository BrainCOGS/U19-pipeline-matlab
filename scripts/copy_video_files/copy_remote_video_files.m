function [final_status, msg] = copy_remote_video_files(location, video_type)

if nargin == 1
    video_type = 'pupillometry';
end

conf = dj.config;

%Get sessions that are not yet in pupillometry DB (most probable not being copied yet)
key = struct();
key.session_location = location;
key.video_type = video_type;

if strcmp(video_type,'pupillometry')
    raw_dir = conf.custom.PupillometryRootDataDir{1};
    session_info = fetch(((acquisition.SessionStarted * acquisition.SessionVideo) - pupillometry.PupillometrySession) & key,'*');
    
else
   error('Video copy not implemented for this video_type yet'); 
end

final_status = 1;
msg = '';
% For each of the sessions copy corresponding files
for i=1:length(session_info)
    
    % Check if local file exists
    if isfile(session_info(i).local_path_video_file)
        new_video_file = fullfile(raw_dir, session_info(i).remote_path_video_file);
        [status, this_msg] = copy_delete_single_video_file_cup_robocopy(session_info(i).local_path_video_file, ...
            new_video_file);
        % Report when something happened while copying files
        if ~status
            final_status = 0;
            msg = this_msg;
        end
    end
    
end
