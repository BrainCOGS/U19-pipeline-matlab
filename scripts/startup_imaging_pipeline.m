

setenv('SETUP_SCRIPT', mfilename('fullpath'));


codeDir = fullfile(fileparts(mfilename('fullpath')), 'CalciumImagingRepositories');

run (fullfile(codeDir, 'TankMouseVR', 'startup_no_datajoint.m'));
run (fullfile(codeDir, 'cvx', 'cvx_startup.m'));
 
% Calcium Imaging Repositories
addpath (genpath(fullfile(codeDir, 'sak_ci_utilities')));
 
addpath (genpath(fullfile(codeDir, 'sakfunctions')));
rmpath  (genpath(fullfile(codeDir, 'sakfunctions', '.git')));
 
addpath (genpath(fullfile(codeDir, 'CalciumImaging')));
rmpath  (genpath(fullfile(codeDir, 'CalciumImaging', '.git')));
 
addpath (genpath(fullfile(codeDir, 'ca_source_extraction')));
rmpath  (genpath(fullfile(codeDir, 'ca_source_extraction', '.git')));

addpath (genpath(fullfile(codeDir, 'SAKFunctions')));
rmpath  (genpath(fullfile(codeDir, 'SAKFunctions', '.git')));
 
setenv  ('ECS_DIR', fullfile(codeDir, 'princeton-ecs'));
addpath (genpath(getenv('ECS_DIR')));
rmpath  (genpath(fullfile(getenv('ECS_DIR'), '.git')));
 
addpath (genpath(fullfile(codeDir, 'TankMouseAnalysis')));
rmpath  (genpath(fullfile(codeDir, 'TankMouseAnalysis', '.git')));
 
addpath (genpath(fullfile(codeDir, 'MatlabProgressBar')));
rmpath  (genpath(fullfile(codeDir, 'MatlabProgressBar', '.git')));
 
addpath (genpath(fullfile(codeDir, 'SLEP')));
rmpath  (genpath(fullfile(codeDir, 'SLEP', '.git')));

% Mesoscope repositories
addpath (genpath(fullfile(codeDir, 'mesoscopeImaging')));
rmpath  (genpath(fullfile(codeDir, 'mesoscopeImaging', '.git')));

addpath (genpath(fullfile(codeDir, 'widefieldImaging')));
rmpath  (genpath(fullfile(codeDir, 'widefieldImaging', '.git')));

addpath (genpath(fullfile(codeDir, 'LPUtil')));
rmpath  (genpath(fullfile(codeDir, 'LPUtil', '.git')));

addpath (genpath(fullfile(codeDir, 'behavioralAnalysis')));
rmpath  (genpath(fullfile(codeDir, 'behavioralAnalysis', '.git')));


addpath (genpath(fullfile(codeDir, 'ImagingViewer')));

% Datajoint repositories
addpath (genpath(fullfile(codeDir, 'U19-pipeline-matlab')));
rmpath  (genpath(fullfile(codeDir, 'U19-pipeline-matlab', '.git')));

addpath (genpath(fullfile(codeDir, 'datajoint-matlab')));
rmpath  (genpath(fullfile(codeDir, 'datajoint-matlab', '.git')));


s = settings;
add_on_folder = s.matlab.addons.InstallationFolder.ActiveValue;
if ~isempty(add_on_folder)
    s = settings;
    if verLessThan('matlab', '9.2')
        mym_folder = fullfile(add_on_folder, 'Toolboxes', 'mym', 'code', 'distribution');
    else
        mym_folder = fullfile(add_on_folder, 'Toolboxes', 'mym', 'distribution');
    end
    if ispc
        mym_folder = fullfile(mym_folder, 'mexw64');
    elseif ismac
        mym_folder = fullfile(mym_folder, 'mexmaci64');
    else
        mym_folder = fullfile(mym_folder, 'mexa64');
    end
    addpath(mym_folder);
end

 
DataBasePrefix = 'u19_';
DataBaseHost = 'datajoint00.pni.princeton.edu';
setenv('DB_PREFIX', DataBasePrefix);
dj.conn(DataBaseHost)
