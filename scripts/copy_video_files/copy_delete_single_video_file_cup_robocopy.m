function [status, msg] = copy_delete_single_video_file_cup_robocopy(local_path_behavior_file, new_remote_file)
% Copy a single video file to cup

status = 1;
msg = '';

% Check if local file exists
if isfile(local_path_behavior_file)
    
    local_dir = fileparts(local_path_behavior_file);
    remote_dir = fileparts(new_remote_file);

    copy_command = ['robocopy ' local_dir ' ' remote_dir ' /E /move /r:5 /w:10'];
    [status,msg] = system(copy_command);

end


