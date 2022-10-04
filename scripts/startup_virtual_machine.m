
u19_pipeline_dir = fileparts(fileparts(mfilename('fullpath')));
dj_lib_dir = fullfile(u19_pipeline_dir, 'datajoint_matlab_libs');

addpath (genpath(fullfile(u19_pipeline_dir)));
rmpath  (genpath(fullfile(u19_pipeline_dir, '.git')));

addpath (genpath(fullfile(dj_lib_dir, 'mym', 'distribution', 'mexa64')));

addpath (genpath(fullfile(dj_lib_dir, 'datajoint-matlab')));
rmpath  (genpath(fullfile(dj_lib_dir, 'datajoint-matlab', '.git')));

addpath (genpath(fullfile(dj_lib_dir, 'GHToolbox')));
rmpath  (genpath(fullfile(dj_lib_dir, 'GHToolbox', '.git')));

addpath (genpath(fullfile(dj_lib_dir, 'compareVersions')));
rmpath  (genpath(fullfile(dj_lib_dir, 'compareVersions', '.git')));

rmpath  (genpath(fullfile(dj_lib_dir, 'datajoint-matlab', 'mym')));

curr_dir = pwd;
cd(u19_pipeline_dir)
dj.config.load();

cd(curr_dir)
dj.conn();