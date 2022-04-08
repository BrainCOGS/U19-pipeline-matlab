function dj_initial_conf()
%Run this to configure needed variables for DataJoint (host, user, password, root directories and external storage)

current_dir = pwd;
if endsWith(current_dir,'U19-pipeline-matlab')
    addpath(genpath(current_dir));
end

setenv('DB_PREFIX', 'u19_')
host = 'datajoint00.pni.princeton.edu';

user = input('Enter datajoint username> ', 's');
pass = dj.lib.getpass('Enter datajoint password');

dj.conn(host, user, pass);

dj.config('databaseHost', host)
dj.config('databaseUser', user)
dj.config('databasePassword', pass)

dj.config.saveLocal()

dj_config_custom_struct = struct();
dj_config_custom_struct.databasePrefix = getenv('DB_PREFIX');


%Get imaging root data dir
key = struct();
key.recording_modality = 'imaging';
root_dir = fetch1(recording.RecordingModality & key,'root_directory');
[~,dj_config_custom_struct.imaging_root_data_dir] = lab.utils.get_path_from_official_dir(root_dir);

%Get ephys root data dir
key.recording_modality = 'electrophysiology';
root_dir = fetch1(recording.RecordingModality & key,'root_directory');
[~,dj_config_custom_struct.ephys_root_data_dir] = lab.utils.get_path_from_official_dir(root_dir);

%Get pupillometry root data dir
key = struct();
key.recording_modality = 'pupillometry';
root_dir = fetch1(recording.RecordingModality & key,'root_directory');
[~,dj_config_custom_struct.pupillometry_root_data_dir] = lab.utils.get_path_from_official_dir(root_dir);

dj.config('custom', dj_config_custom_struct)


%Get ext_storage_path
ext_storage_path = 'u19_dj/external_dj_blobs/';
[~,ext_storage_path] = lab.utils.get_path_from_official_dir(ext_storage_path);

%Configure dj dictionary
u19_storage = struct('protocol', 'file',...
    'location', ext_storage_path);
dj.config('stores.extstorage', u19_storage)


dj.config.saveLocal()








