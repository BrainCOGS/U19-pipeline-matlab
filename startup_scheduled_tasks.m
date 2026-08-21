parent_path = 'C:/Experiments';
projects_update = {'ViRMEn', 'U19-pipeline-matlab'};
pipeline_path = fullfile(parent_path, 'U19-pipeline-matlab');

% Collected here (rather than thrown) so callers can report git-pull
% problems separately from other startup/copy failures, e.g. via
% notify_scheduled_task_failure. Empty means all pulls succeeded/were
% up to date.
startup_git_pull_warnings = {};

% Update Virmen and pipeline projects
for i=1:length(projects_update)
    project_path = fullfile(parent_path, projects_update{i});


    if ~exist(project_path,'dir')
        error([project_path ...
            ' directory does not exist, please downlowad repository'])
    else
        cd(project_path);

        % Try to pull latest changes on repo; do not fail startup if this
        % is not possible (e.g. no network, local changes, detached HEAD).
        % Any problem is recorded in startup_git_pull_warnings instead of
        % just emitting a MATLAB warning, so callers can surface it
        % distinctly from other failures.
        try
            [git_status, git_info] = system('git pull');
            if git_status ~= 0
                git_pull_msg = ['Pulling latest changes for ' project_path ...
                    ' failed: ' strtrim(git_info)];
                warning(git_pull_msg);
                startup_git_pull_warnings{end+1} = git_pull_msg; %#ok<SAGROW>
            end
        catch err
            git_pull_msg = ['Pulling latest changes for ' project_path ...
                ' was not possible: ' err.message];
            warning(git_pull_msg);
            startup_git_pull_warnings{end+1} = git_pull_msg; %#ok<SAGROW>
        end

        addpath(genpath(project_path));
        rmpath(genpath(fullfile(project_path, '.git')));

    end

end



tbxlist = com.mathworks.addons_toolbox.ToolboxManagerForAddOns().getInstalled();

%Add new mym
path = 'C:\Experiments\mym-mariadbconn';
mym_folder = fullfile(char(path), 'distribution', 'mexw64');
addpath(mym_folder);

%Add other toolboxes to path
toolbox_load = {'DataJoint', 'GHToolbox', 'compareVersions'};
for i =1:length(toolbox_load)
    idx = arrayfun(@(x)startsWith(x.getName(),toolbox_load{i}),tbxlist);
    folder = char(tbxlist(idx).getInstalledFolder());
    addpath(folder);
end

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

clearvars -except startup_git_pull_warnings;




