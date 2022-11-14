function [status, msg] = copy_single_behavior_file_cup(local_path_behavior_file, new_remote_file, session_date, session_number)
% Copy a single behavior file to cup (including fig files)

status = 1;
msg = '';

% Check if local file exists
if isfile(local_path_behavior_file)
    
    remote_dir = fileparts(new_remote_file);
    % If remote file is not there copy it
    if ~isfile(new_remote_file)
        % If remote folder is not there create it
        if ~isfolder(remote_dir)
            mkdir(remote_dir)
        end
        [status, msg] = copyfile(local_path_behavior_file, new_remote_file);
        
        %Copy fig files as well
        local_dir = fileparts(local_path_behavior_file);
        % Locate same date fig files
        filesList = dir(local_dir);
        fileNames = {filesList.name};
        session_str = strrep(session_date,'-','');
        fig_files = regexpi(fileNames, ['\w*' session_str '_[0-9].fig'], 'match');
        idx_fig_files = cellfun(@(x) ~isempty(x), fig_files);
        
        % Also look for fig files that are from multiple sessions on the same day
        session_str2 = [session_str '_' num2str(session_number)];
        fig_files2 = regexpi(fileNames, ['\w*' session_str2 '_[0-9].fig'], 'match');
        idx_fig_files2 = cellfun(@(x) ~isempty(x), fig_files2);
        idx_fig_files = idx_fig_files | idx_fig_files2;
        
        fig_files = fileNames(idx_fig_files);
        %For each same date fig file, copy it to new location
        for j=1:length(fig_files)
            new_fig_file = fullfile(remote_dir, fig_files{j});
            local_fig_file = fullfile(local_dir, fig_files{j});
            [status, msg] = copyfile(local_fig_file, new_fig_file);
        end
        
    end
end

end
