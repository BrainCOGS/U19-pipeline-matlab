function dj_custom_variables = get_dj_custom_variables()
persistent djCustomVariables


if ~isa(djCustomVariables, 'struct')
    djCustomVariables = struct();
    dj_vars = struct2table(fetch(lab.DjCustomVariables,'*'), 'AsArray',true);
    dj_vars.custom_variable = categorical(dj_vars.custom_variable);
    unique_dj_vars = unique(dj_vars.custom_variable);

% Store each dj var in a dj_custom structure
for i =1:length(unique_dj_vars)
    this_dj_var = unique_dj_vars(i);
    this_dj_var_camel = dj.internal.toCamelCase(char(this_dj_var));
    filtered_table = dj_vars(dj_vars.custom_variable == this_dj_var, :);
    
    this_dj_value = filtered_table{:,'value'};
    
    % Format correctly variables with 1 value and vars with 2 or more
    rows = height(filtered_table);
    if rows == 1
        djCustomVariables.(this_dj_var_camel) = this_dj_value{:};
    else
        djCustomVariables.(this_dj_var_camel) = this_dj_value;
    end
end
 
end

dj_custom_variables = djCustomVariables;
    
end