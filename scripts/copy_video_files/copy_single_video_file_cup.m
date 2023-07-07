function [status, msg] = copy_single_video_file_cup(local_path_behavior_file, new_remote_file)
% Copy a single video file to cup

status = 1;
msg = '';

% Check if local file exists
if isfile(local_path_behavior_file)
    
    local_directory = fileparts(local_path_behavior_file);
    remote_dir = fileparts(new_remote_file);
    % If remote file is not there copy it
    if ~isfile(new_remote_file)
        % If remote folder is not there create it
        if ~isfolder(remote_dir)
            mkdir(remote_dir)
        end
        copy_command = ['ROBOCOPY ' local_directory ' ' remote_dir ' /E'];
        [status,msg] = system(copy_command);

        %[status, msg] = copyfile(local_path_behavior_file, new_remote_file);
           
    end
end

