function create_schema_from_DB(schema_name, sync_schema)
%Creata a whole schema if it does not exist, if already exists sync definitions

if nargin < 2
    sync_schema = 0;
end
%To not be asked by syncDef over and over
if sync_schema
    safemode_now = dj.config('safemode');
    dj.config('safemode', false);
end

curr_dir = pwd;

this_dir = fileparts(mfilename('fullpath'));
schemas_dir = fullfile(fileparts(fileparts(this_dir)), 'schemas');

%Create this schema directory
curr_schema_dir = fullfile(schemas_dir, ['+' schema_name]);

if ~isfolder(curr_schema_dir)
    mkdir(curr_schema_dir);
end

%Create getSchema.m
getSchema_file = fullfile(curr_schema_dir, 'getSchema.m');

if ~isfile(getSchema_file)
    fileID = fopen(getSchema_file,'w');
    getschema_text = get_getSchema_text(schema_name);
    fprintf(fileID,getschema_text);
    fclose(fileID);
end

cd(curr_schema_dir);
getSchema_fun = str2func([schema_name '.getSchema']);
try
    schemaObject = getSchema_fun();
catch err
    disp([schema_name, ' directory not found '])
    %Go back to original directory
    cd(curr_dir)
    dj.config('safemode', safemode_now)
    return
end

%Check every table and create file for each of them if missing
for i =1:length(schemaObject.classNames)
    this_class = schemaObject.classNames{i};
    class_name = strrep(this_class, [schema_name '.'],'');
    this_class_file = fullfile(curr_schema_dir, [class_name '.m']);
    try
        plain_table_name = schemaObject.v.(class_name).plainTableName;
    catch err
         lo = 0 
    end
    {schema_name class_name}
    
    if ~startsWith(plain_table_name,'~')
        %Create file for this table if does not exist yet
        if ~isfile(this_class_file)
            fileID = fopen(this_class_file,'w');
            tier = schemaObject.v.(class_name).info.tier;
            tablefile_text = get_tablefile_text(class_name, tier);
            fprintf(fileID,tablefile_text);
            fclose(fileID);
        end
        
        if sync_schema
            syncDef(schemaObject.v.(class_name));
        end
    end
    
end

%Go back to original directory
cd(curr_dir)
dj.config('safemode', safemode_now)

end


%getSchema generator function
function getschema_text = get_getSchema_text(schema_name)

schema_line = sprintf('schemaObject = dj.Schema(dj.conn, %s, [prefix %s]);',['''' schema_name ''''],['''' schema_name '''']);

getschema_text = sprintf('%s\n', ...
    'function obj = getSchema', ...
    'prefix = getenv("DB_PREFIX");', ...
    'persistent schemaObject', ...
    'if isempty(schemaObject)', ...
    schema_line, ...
    'end', ...
    'obj = schemaObject;', ...
    'end');

end

function tablefile_text = get_tablefile_text(class_name, tier)

tier = [upper(tier(1)) tier(2:end)];

table_line = ['classdef ' class_name ' < dj.' tier];

if string(tier) == "Imported" || string(tier) == "Computed"

    class_body = sprintf('%s\n', ...
        '\tmethods(Access=protected)', ...
        '\t\tfunction makeTuples(self, key)', ...
        '\t\tend', ...
        '\tend');

else
    class_body = '\n';
end
    
tablefile_text = sprintf('%s\n', ...
    '\n\n', ...
    table_line, ...
    class_body, ...
    'end', ...
    '\n');


end



