function create_new_subtask_classes(new_subtask)

%Get package and Package names
package_name = lower(new_subtask);
Package_name = dj.internal.toCamelCase(package_name);

%Insert new subrask in DB
record.subtask        = Package_name;
record.subtask_description = ['Extra fields for ' Package_name ' subtask'];
insert(task.Subtask, record, 'IGNORE');

% Get schemas and "subtask" base code directories
this_dir = fileparts(mfilename('fullpath'));
schema_dir = fullfile(fileparts(this_dir), 'schemas');
gen_subtask_dir = fullfile(schema_dir, 'generic_subtask');

files_gen_subtask = dir(gen_subtask_dir);

subtask_package_dir = fullfile(schema_dir, '+behavior_subtask');

%For each file substitute ^package^ text with real new package name
for i=1:length(files_gen_subtask)
    
    %Base code files
    filename = files_gen_subtask(i).name;
    new_filename = strrep(filename, 'Subtask', Package_name);
    
    %New code files
    filepath = fullfile(gen_subtask_dir, filename);
    new_filepath = fullfile(subtask_package_dir, new_filename);
    
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

end
