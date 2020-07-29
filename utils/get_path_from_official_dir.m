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
system = get_OS();

%Get all path table from u19_lab.Path ("official sites")
path_struct = fetch(lab.Path, '*');
path_table = struct2table(path_struct);
path_table.system = categorical(path_table.system);

%Change bezos-center global path to just bezos to match base_dir more easily
path_table.global_path(contains(path_table.global_path, 'Bezos')) = {'Bezos'};
path_table.global_path = strrep(path_table.global_path, '/', '');

%Check the base dir corresponds to which global path 
idx_basedir = cellfun(@(s) contains(baseDir, s), path_table.global_path);

record_table = path_table(idx_basedir & path_table.system == system,:);

if isempty(record_table)
    error('The base directory is not found in official sites of u19')
elseif size(record_table,1) > 1
    error('The base directory makes reference to more than one official location of the u19')
end

%Find where in baseDir is located the globalPath
ac_global_path = record_table.global_path{:};
idx_global_path = strfind(baseDir, ac_global_path);

%Erase that part of the path (will be replaced with corresponding path of the actual system 
baseDir(1:idx_global_path+length(ac_global_path)-1) = [];


bucket_path = fullfile(record_table.bucket_path{:}, baseDir);

if ispc
    %For pc the accesible path is the net_location field
    local_path  = fullfile(record_table.net_location{:}, baseDir);
    %Correct bucket path to have "linux" slashes
    bucket_path = strep(bucket_path,'\','/');
    bucket_path = strep(bucket_path,'//','/');
else
    %For mac and linux the accesible path is the local_path field
    local_path = fullfile(record_table.local_path{:}, baseDir);
end

%If this system is spock, local and bucket path is the same
if isThisSpock
    local_path = bucket_path;
end
    
    
   
end

