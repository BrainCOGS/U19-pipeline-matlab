function [bucket_path, local_path] =  get_path_from_official_dir(baseDir)
%Get entire bucket path location and accesible "local" path from a
%reference to buckets in u19
%
% Inputs:
% baseDir = Reference to a bucket location 
% 
% Outputs
% bucket_path = path in the bucket (as seen in spock and scotty)
% local_path  = reference path when function is run from local computer
%
% Examples
% basedir = 'Bezos/RigData/scope/bay3'
% get_path_from_official_dir(baseDir)  %  (from local mac)
% bucket_path == '/mnt/bucket/PNI-centers/Bezos/RigData/scope/bay3'
% local_path ==  '/Volumes/Bezos-center/RigData/scope/bay3''

%Get OS of the system
system = u19_dj_utils.get_OS();

%Get all path table from u19_lab.Path ("official sites")
[path_table] = lab.utils.get_path_table();

%Check the base dir corresponds to which global path 
idx_basedir = cellfun(@(s) contains(baseDir, s), path_table.global_path);

path_record = path_table(idx_basedir & path_table.system == system,:);

if isempty(path_record)
    error('The base directory is not found in official sites of u19')
elseif size(path_record,1) > 1
    error('The base directory makes reference to more than one official location of the u19')
end

%Find where in baseDir is located the globalPath
ac_global_path = path_record.global_path{:};
idx_global_path = strfind(baseDir, ac_global_path);

%Erase that part of the path (will be replaced with corresponding path of the actual system 
baseDir(1:idx_global_path+length(ac_global_path)-1) = [];


bucket_path = fullfile(path_record.bucket_path{:}, baseDir);

if ispc
    %For pc the accesible path is the net_location field
    local_path  = fullfile(path_record.net_location{:}, baseDir);
    %Correct bucket path to have "linux" slashes
    bucket_path = strrep(bucket_path,'\','/');
    bucket_path = strrep(bucket_path,'//','/');
else
    %For mac and linux the accesible path is the local_path field
    local_path = fullfile(path_record.local_path{:}, baseDir);
end

%If this system is spock, local and bucket path is the same
if u19_dj_utils.is_this_spock()
    local_path = bucket_path;
end
      
end

