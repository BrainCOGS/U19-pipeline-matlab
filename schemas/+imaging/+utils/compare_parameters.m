function [table_diff_params,common_params] = compare_parameters(param_table, method_key)
%COMPARE_PARAMETERS 

common_params = struct();

%Fetch all set params from method
param_struct = fetch(param_table & method_key, '*');
fields = fieldnames(param_struct);

%idx_method = contains(fields,'method');
%method_field = fields{idx_method};

% Get id of field which correspond to (set_id, parameter_name, parameter_value)
idx_set = contains(fields,'set_id');
set_id_field = fields{idx_set};

idx_param_name = contains(fields,'parameter_name');
param_name_field = fields{idx_param_name};

idx_param_value = contains(fields,'parameter_value');
param_value_field = fields{idx_param_value};
values = {param_struct.(param_value_field)};

%Get unique ids and unique params of sets
set_ids = sort(unique([param_struct.(set_id_field)]));
unique_params = unique({param_struct.(param_name_field)});

% Create pivot table for all sets for all params
table_diff_params = array2table(cell(length(set_ids), length(unique_params)+1), ...
   'VariableNames', [{'set_id'}, unique_params]);

% Set values for pivot table
for i=set_ids
    table_diff_params{i,'set_id'} = {i};
    
    for j=unique_params
        
        idx_value = [param_struct.(set_id_field)] == i & matches({param_struct.(param_name_field)},j);
        
        if sum(idx_value == 1)
            table_diff_params{i,j} = values(idx_value);
        else
            table_diff_params{i,j} = {NaN};
        end
        
    end
end

table_diff_params.set_id = cell2mat(table_diff_params.set_id);

for j=unique_params
    
    %Convert to scalar if needed
    [status, scalar_column] = check_scalar_column(table_diff_params.(j{:}));
    
    if status
        table_diff_params.(j{:}) = scalar_column;
    end
    
    %Check if all sets are matching
    all_matches = check_all_matching(table_diff_params.(j{:}));
    
    %If all sets matches, save to common_params, delete from table
    if all_matches
        common_params.(j{:}) = table_diff_params{1,j};
        table_diff_params = removevars(table_diff_params,j);
        
    end
    
end

end

