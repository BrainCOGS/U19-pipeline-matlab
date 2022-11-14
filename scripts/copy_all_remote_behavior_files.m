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
        remote_dir = fileparts(new_remote_file);
        % If remote file is not there copy it
        if ~isfile(new_remote_file)
            % If remote folder is not there create it
            if ~isfolder(remote_dir)
                mkdir(remote_dir)
            end
            [status, msg] = copyfile(this_remote_filepath, new_remote_file);
            if ~status
                something_failed = 1;
            end
            %Copy fig files as well
            local_dir = fileparts(this_remote_filepath);
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
                    something_failed = 1;
                end
            end
                
        end
    end

    if something_failed
        msg
        break
    end
    
end
