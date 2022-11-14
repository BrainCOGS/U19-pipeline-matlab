function [final_status, msg] = copy_remote_behavior_files(location)

%Get sessions that are not yet in behavior DB (most probable not being copied yet
key = struct();
key.session_location = location;
key.invalid_session = 0;
%key.session_date = '2021-09-29'
%session_info = fetch(((acquisition.SessionStarted) ) & key,'*');
%session_keys = fetch(((acquisition.SessionStarted) ) & key);
session_info = fetch(((acquisition.SessionStarted) - behavior.TowersSession) & key,'*');
session_keys = fetch(((acquisition.SessionStarted) - behavior.TowersSession) & key);

final_status = 1;
msg = '';
% For each of the sessions copy corresponding files
for i=1:length(session_info)
    
    % Check if local file exists
    if isfile(session_info(i).local_path_behavior_file)
        % Get full new remote filepath
        [~, new_remote_file] = lab.utils.get_path_from_official_dir(session_info(i).new_remote_path_behavior_file);
        [status, this_msg] = copy_single_behavior_file_cup(session_info(i).local_path_behavior_file, new_remote_file, ...
            session_info(i).session_date, session_info(i).session_number);
        % Report when something happened while copying files
        if ~status
            final_status = 0;
            msg = this_msg;
        end
        
    else
        % if local file does not exist then it is invalid session
        update(acquisition.SessionStarted & session_keys(i), 'invalid_session', 1)
    end
    
end
