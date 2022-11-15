function dj_initial_conf(save_user)
%Run this to configure needed variables for DataJoint (host, user, password, root directories and external storage)
 
if nargin < 1
    save_user = true;
end

current_dir = pwd;

u19_pipeline_dir = fileparts(mfilename('fullpath'));
cd(u19_pipeline_dir)
addpath(genpath(u19_pipeline_dir));


setenv('DB_PREFIX', 'u19_')
host = 'datajoint00.pni.princeton.edu';
 
user = input('Enter datajoint username> ', 's');
if usejava('desktop')
    pass = dj.lib.getpass('Enter datajoint password');
else
    pass = input('Enter datajoint password> ', 's');
end
 
try
    dj.conn(host, user, pass);
catch exception
    warning('Could not connect to DB. Check error');
    throw(exception)
end

dj.config('databaseHost', host)
 
if save_user
    dj.config('databaseUser', user)
    dj.config('databasePassword', pass)
end

% Clean custom because cell arrays have to be tranformed to string arrays
dj.config('custom', [])
 
dj.config.saveLocal()
 
dj_config_custom_struct = struct();
dj_config_custom_struct.databasePrefix = getenv('DB_PREFIX');
 
% Get all dj custom variables stored in DB
dj_vars = struct2table(fetch(lab.DjCustomVariables,'*'), 'AsArray',true);
dj_vars.custom_variable = categorical(dj_vars.custom_variable);
unique_dj_vars = unique(dj_vars.custom_variable);

% Store each dj var in a dj_custom structure
for i =1:length(unique_dj_vars)
    this_dj_var = unique_dj_vars(i);
    this_dj_var_camel = dj.internal.toCamelCase(char(this_dj_var));
    filtered_table = dj_vars(dj_vars.custom_variable == this_dj_var, :);
    
    % Unpack directory variables (can have more than 1 value)
    if contains(char(this_dj_var), 'dir')
        [~, this_dj_value] = cellfun(@(x) lab.utils.get_path_from_official_dir(x), ...
        filtered_table{:,'value'},'UniformOutput', false);
        this_dj_value = convertCharsToStrings(this_dj_value);
        if ispc
            this_dj_value = strrep(this_dj_value,'\','\\');
        end
    else
        this_dj_value = filtered_table{:,'value'};
    end
    
    % Format correctly variables with 1 value and vars with 2 or more
    rows = height(filtered_table);
    if rows == 1
        dj_config_custom_struct.(this_dj_var_camel) = this_dj_value{:};
    else
        dj_config_custom_struct.(this_dj_var_camel) = this_dj_value;
    end
end

dj.config('custom', dj_config_custom_struct)

%Get store info
store_vars = struct2table(fetch(lab.DjStores,'*'), 'AsArray',true);

% For each store get name, protocol and location, and save to config
for i =1:height(store_vars)
    store_name = store_vars{i, 'store_name'}{:};
    [~,store_path] = lab.utils.get_path_from_official_dir(store_vars{i, 'location'}{:});
    if ispc
        store_path = strrep(store_path,'\','\\');
    end
    store_protocol = store_vars{i, 'protocol'}{:};
    u19_storage = struct('protocol', store_protocol, 'location', store_path);
    dj.config(['stores.' store_name], u19_storage)
    
end
    

dj.config.saveLocal()

cd(current_dir);

