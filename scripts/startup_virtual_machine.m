
u19_pipeline_dir = fileparts(fileparts(mfilename('fullpath')));
dj_lib_dir = fullfile(fileparts(u19_pipeline_dir), 'datajoint_matlab_libs');

addpath (genpath(fullfile(u19_pipeline_dir)));
rmpath  (genpath(fullfile(u19_pipeline_dir, '.git')));


if ispc
    addpath (genpath(fullfile(dj_lib_dir, 'mym', 'distribution', 'mexw64')));
elseif ismac
    addpath (genpath(fullfile(dj_lib_dir, 'mym', 'distribution', 'mexmaci64')));
else
    addpath (genpath(fullfile(dj_lib_dir, 'mym', 'distribution', 'mexa64')));
end

addpath (genpath(fullfile(dj_lib_dir, 'datajoint-matlab')));
rmpath  (genpath(fullfile(dj_lib_dir, 'datajoint-matlab', '.git')));

addpath (genpath(fullfile(dj_lib_dir, 'GHToolbox')));
rmpath  (genpath(fullfile(dj_lib_dir, 'GHToolbox', '.git')));

addpath (genpath(fullfile(dj_lib_dir, 'compareVersions')));
rmpath  (genpath(fullfile(dj_lib_dir, 'compareVersions', '.git')));

rmpath  (genpath(fullfile(dj_lib_dir, 'datajoint-matlab', 'mym')));

curr_dir = pwd;
cd(u19_pipeline_dir)
if isfile('dj_local_conf.json')
    dj.config.load();
    conf = dj.config;
    setenv('DB_PREFIX', conf.custom.databasePrefix);
    cd(curr_dir);
    dj.conn();
else
    cd(curr_dir)
    error('Configuration file not found, run dj_initial_conf')
end


