function [something_failed, msg] = copy_all_remote_behavior_files()

session_info = fetch(((acquisition.SessionStarted) ),'*');
something_failed = 0;
% For each of the sessions copy corresponding files
for i=1:length(session_info)
    i
    
    [~, this_remote_filepath] = lab.utils.get_path_from_official_dir( session_info(i).remote_path_behavior_file);
    
    % Check if local file exists
    if isfile(this_remote_filepath)
        % Get full new remote filepath
        [~, new_remote_file] = lab.utils.get_path_from_official_dir(session_info(i).new_remote_path_behavior_file);
        
        [status, this_msg] = copy_single_behavior_file_cup(this_remote_filepath, new_remote_file, ...
            session_info(i).session_date, session_info(i).session_number);
        % Report when something happened while copying files
        if ~status
            something_failed = 1;
            msg = this_msg;
        end
           
    end

    if something_failed
        msg
        break
    end
    
end
