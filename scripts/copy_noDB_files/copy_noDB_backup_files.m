function [final_status, final_msg] = copy_noDB_backup_files()


final_status = 0;
final_msg = '';

conf = dj.config;
raw_dir = conf.custom.RootDataDir{1};
nodbvirmen_dir = fullfile(fileparts(fileparts(raw_dir)),'Shared','NoDBVirmenBackup');
extras_dir = fileparts(which('RigParameters'));

files_noDBVirmen = dir(nodbvirmen_dir);
files_noDBVirmen = files_noDBVirmen(~ismember({files_noDBVirmen.name}, {'.', '..'}));
files_noDBVirmen(startsWith({files_noDBVirmen.name}, '.')) = [];

for i=1:length(files_noDBVirmen)

    drive_file = fullfile(nodbvirmen_dir, files_noDBVirmen(i).name);
    local_file = fullfile(extras_dir, files_noDBVirmen(i).name);

    [status, msg] = copyfile(drive_file, local_file);

    if status ~= 0
        final_status = status;
        final_msg = msg;
    end

end








