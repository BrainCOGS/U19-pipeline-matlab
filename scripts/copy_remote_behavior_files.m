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
        remote_dir = fileparts(new_remote_file);
        % If remote file is not there copy it
        if ~isfile(new_remote_file)
            % If remote folder is not there create it
            if ~isfolder(remote_dir)
                mkdir(remote_dir)
            end
            [status, msg] = copyfile(session_info(i).local_path_behavior_file, new_remote_file);
            if ~status
                final_status = 0;
            end
            %Copy fig files as well
            local_dir = fileparts(session_info(i).local_path_behavior_file);
            % Locate same date fig files
            filesList = dir(local_dir);
            fileNames = {filesList.name};
            session_str = strrep(session_info(i).session_date,'-','');
            fig_files = regexpi(fileNames, ['\w*' session_str '_[0-9].fig'], 'match');
            idx_fig_files = cellfun(@(x) ~isempty(x), fig_files);
            
            % Also look for fig files that are from multiple sessions on the same day
            session_str2 = [session_str '_' num2str(session_info(i).session_number)];
            fig_files2 = regexpi(fileNames, ['\w*' session_str2 '_[0-9].fig'], 'match');
            idx_fig_files2 = cellfun(@(x) ~isempty(x), fig_files2);
            idx_fig_files = idx_fig_files | idx_fig_files2;

            fig_files = fileNames(idx_fig_files);
            %For each same date fig file, copy it to new location
            for j=1:length(fig_files)
                new_fig_file = fullfile(remote_dir, fig_files{j});
                local_fig_file = fullfile(local_dir, fig_files{j});
                [status, msg] = copyfile(local_fig_file, new_fig_file);
                if ~status
                    final_status = 0;
                end
            end
            
            
                
        end
    else
        % if local file does not exist then it is invalid session
        update(acquisition.SessionStarted & session_keys(i), 'invalid_session', 1)
    end

end
