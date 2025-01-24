function [status,data] = read_behavior_file(key, data_dir)
%read_behavior_file, read information from behavioral file
% Inputs
% key      = Session key (must be only one session)
% data_dir = Not used, directory where behavior file is located, leave empty
% Outputs
% status   = 1 if read was successfull 0 otherwise
% data     = beahvior file data structure 



data = [];
status = 0;

%Get data directory
if nargin < 2
    data_dir = fetch(acquisition.SessionStarted & key, 'task', 'new_remote_path_behavior_file');
end

%Check if key references too many or too few sessions.
if length(data_dir) > 1
   warning('Multiple behavior files from given key');
   return
end

if isempty(data_dir)
   warning('No session found from given key'); 
   return
end

%Load behavioral file
try
    % Get final path for this specific system
    [~, filepath] = lab.utils.get_path_from_official_dir(data_dir.new_remote_path_behavior_file);
    % All towers task behavior files have a log variable
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

