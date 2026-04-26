parent_path = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
projects_update = {'ViRMEn', 'U19-pipeline-matlab'};

pipeline_path = fullfile(parent_path, 'U19-pipeline-matlab');

% Update Virmen and pipeline projects
for i=1:length(projects_update)
    project_path = fullfile(parent_path, projects_update{i});
    
    
    if ~exist(project_path,'dir')
        error([project_path ...
            ' directory does not exist, please downlowad repository'])
    else
        cd(project_path);
        addpath(genpath(project_path));
        rmpath(genpath(fullfile(project_path, '.git')));
           
    end
    
end


% If matlab version < 2016 add datajoint matlab folder to path
tbxlist = com.mathworks.addons_toolbox.ToolboxManagerForAddOns().getInstalled();
idx = arrayfun(@(x)startsWith(x.getName(),'mym'),tbxlist);
path = tbxlist(idx).getInstalledFolder();
mym_folder = fullfile(char(path), 'distribution', 'mexw64');
addpath(mym_folder);


setenv('DB_PREFIX', 'u19_')
cd(pipeline_path)
try
    dj.config.load()
catch
end

%Check if external storage was set up, if not, set it.
if ~isfield(dj.config,'stores') || ~isfield(dj.config('stores'),'extstorage')
    dj_initial_conf()
end


clearvars;

for i=1:3
    [status,out]    = system('mount_network_drives.BAT');
    if status == 0
        break
    end
    pause(1)
end



