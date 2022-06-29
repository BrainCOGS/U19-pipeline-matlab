function create_new_manipulation_schema(new_manipulation, create_db)

if nargin < 2
    create_db = 0;
end


%Get package and Package names
package_name = lower(new_manipulation);
Package_name = dj.internal.toCamelCase(package_name);

%Insert new manipulation in DB
record.manipulation_type        = package_name;
record.manipulation_description = ['description for ' package_name ' manipulation'];
insert(lab.ManipulationType, record, 'IGNORE');

% Get schemas and "manipulation" base code directories
this_dir = fileparts(mfilename('fullpath'));
schema_dir = fullfile(fileparts(this_dir), 'schemas');
gen_manipulation_dir = fullfile(schema_dir, 'generic_manipulation');

files_gen_manipulation = dir(gen_manipulation_dir);

new_package_dir = fullfile(schema_dir, ['+' package_name]);

if ~isfolder(new_package_dir)
    mkdir(new_package_dir);
    addpath(schema_dir)
else
    error([new_manipulation ' package already exists']);
end


%For each file substitute ^package^ text with real new package name
for i=1:length(files_gen_manipulation)
    
    %Base code files
    filename = files_gen_manipulation(i).name
    new_filename = strrep(filename, 'Manipulation', Package_name);
    
    %New code files
    filepath = fullfile(gen_manipulation_dir, filename);
    new_filepath = fullfile(new_package_dir, new_filename);
    
    if isfile(filepath)
        %Read and replace
        code_text = fileread(filename);
        code_text = strrep(code_text, '^package^', package_name);
        code_text = strrep(code_text, '^Package^', Package_name);
        
        %remove first and last comment line
        idx_open = strfind(code_text, '%{');
        code_text = code_text(idx_open(1)+2:end);
        idx_close = strfind(code_text, '%}');
        code_text = code_text(1:idx_close(end)-1);
        
        %Write new file
        fid = fopen(new_filepath,'w');
        fprintf(fid, '%s', code_text);
        fclose(fid);
    end
    
end

%Create new tables in DB
if create_db
    conn = dj.conn;
    conn.query(['CREATE SCHEMA IF NOT EXISTS ' getenv('DB_PREFIX') package_name]);
    
    new_tables_order = {'SoftwareParameter', 'Protocol', 'Session', 'SessionTrial'};
    for i = 1:length(new_tables_order)
        new_table = str2func([package_name '.' Package_name new_tables_order{i}]);
        new_table()
        pause(2);
    end
    
    %Insert a test "no protocol" record
    
    test_protocol.protocol_description = ' -- No protocol -- ';
    protocol_table = str2func([package_name '.' Package_name 'Protocol']);
    protocol_table_obj = protocol_table();
    insert(protocol_table_obj, test_protocol);
    
end


end
