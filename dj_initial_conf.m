function dj_initial_conf(save_user)
%Run this to configure needed variables for DataJoint (host, user, password, root directories and external storage)
 
if nargin < 1
    save_user = false;
end

current_dir = pwd;

u19_pipeline_dir = fileparts(mfilename('fullpath'));
cd(u19_pipeline_dir)
addpath(genpath(u19_pipeline_dir));


setenv('DB_PREFIX', 'u19_')
host = 'datajoint00.pni.princeton.edu';
 
user = input('Enter datajoint username> ', 's');
pass = dj.lib.getpass('Enter datajoint password');
 
dj.conn(host, user, pass);
dj.config('databaseHost', host)
 
if save_user
    dj.config('databaseUser', user)
    dj.config('databasePassword', pass)
end
 
 
dj.config.saveLocal()
 
dj_config_custom_struct = struct();
dj_config_custom_struct.databasePrefix = getenv('DB_PREFIX');
 
 
%Get imaging root data dir
key = struct();
key.recording_modality = 'imaging';
try
    root_dir = fetch1(recording.RecordingModality & key,'root_directory');
    [~,dj_config_custom_struct.imaging_root_data_dir] = lab.utils.get_path_from_official_dir(root_dir);
    if ispc
       dj_config_custom_struct.imaging_root_data_dir = strrep(dj_config_custom_struct.imaging_root_data_dir,'\','\\');
    end
catch
    disp('Could not find imaging root directory')
end
 
%Get ephys root data dir
key.recording_modality = 'electrophysiology';
try
    root_dir = fetch1(recording.RecordingModality & key,'root_directory');
    [~,dj_config_custom_struct.ephys_root_data_dir] = lab.utils.get_path_from_official_dir(root_dir);
    if ispc
       dj_config_custom_struct.ephys_root_data_dir = strrep(dj_config_custom_struct.ephys_root_data_dir,'\','\\');
    end
catch
    disp('Could not find electrophysiology root directory')
end
 
%Get pupillometry root data dir
key = struct();
key.recording_modality = 'video_acquisition';
try
    root_dir = fetch1(recording.RecordingModality & key,'root_directory');
    [~,dj_config_custom_struct.pupillometry_root_data_dir] = lab.utils.get_path_from_official_dir(root_dir);
    if ispc
       dj_config_custom_struct.pupillometry_root_data_dir = strrep(dj_config_custom_struct.pupillometry_root_data_dir,'\','\\');
    end
catch
    disp('Could not find electrophysiology root directory')
end
 
dj.config('custom', dj_config_custom_struct)
 
 
%Get ext_storage_path
ext_storage_path = 'u19_dj/external_dj_blobs';
[~,ext_storage_path] = lab.utils.get_path_from_official_dir(ext_storage_path);
if ispc
   ext_storage_path = strrep(ext_storage_path,'\','\\');
end
 
 
%Configure dj dictionary
u19_storage = struct('protocol', 'file',...
    'location', ext_storage_path);
dj.config('stores.extstorage', u19_storage)
 
 
dj.config.saveLocal()

cd(current_dir);

