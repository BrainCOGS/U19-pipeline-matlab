function [status, msg] = copy_noDBVirmen_backup_files()

conf = dj.config;
raw_dir = conf.custom.RootDataDir{1};
nodbvirmen_dir = fullfile(fileparts(fileparts(raw_dir)),'Shared','NoDBVirmenBackup');


rig_status_drive_file = fullfile(nodbvirmen_dir,GeneralParameters.rig_status_file);

extras_dir = fileparts(which('RigParameters'));
rig_status_local_file = fullfile(extras_dir,GeneralParameters.rig_status_file);


[status, msg] = copyfile(rig_status_drive_file, rig_status_local_file);








