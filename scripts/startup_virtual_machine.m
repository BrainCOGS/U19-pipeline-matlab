
%Startup script for cluster machines 

curr_dir = pwd;
u19_pipeline_dir = fileparts(fileparts(mfilename('fullpath')));
dj_lib_dir = fullfile(fileparts(u19_pipeline_dir), 'datajoint_matlab_libs');
virmen_dir = fullfile(fileparts(u19_pipeline_dir), 'ViRMEn');

%Try to pull latest changes on repo (Virmen)
cd(virmen_dir);
virmen_dir
try
    [status,info] = system('git pull');
catch err
    displayException(err);
    warning('Pulling latest changes was not possible')
end

addpath (genpath(fullfile(virmen_dir)));
rmpath  (genpath(fullfile(virmen_dir, '.git')));

%Try to pull latest changes on repo
cd(u19_pipeline_dir);
try
    [status,info] = system('git pull');
catch err
    displayException(err);
    warning('Pulling latest changes was not possible')
end


%Add to path all neded libraries
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


% Try to connect to DB
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


