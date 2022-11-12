function [status,data] = read_behavior_file(key, data_dir)
%READ_BEHAVIORAL_FILE, read information from behavioral file

data = [];
status = 0;

if nargin < 2
    data_dir = fetch(acquisition.SessionStarted & key, 'task', 'new_remote_path_behavior_file');
end

if length(data_dir) > 1
   error('Multiple behavior files from given key'); 
end

if isempty(data_dir)
   error('No session found from given key'); 
end

%Load behavioral file
try
    [~, filepath] = lab.utils.get_path_from_official_dir(data_dir.new_remote_path_behavior_file);
    if data_dir.task == "Towers"
        data = load(filepath,'log');
        status = 1;
    else
        data = load(filepath);
        status = 1;
    end
catch
    disp(['Could not open behavioral file: ', filepath])
end

end

