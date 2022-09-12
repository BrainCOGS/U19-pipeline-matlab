function trial_data = get_full_trial_data(trial_table, blob_session_table, key)

non_required_trial_blobs = {'position', 'velocity', 'collision', 'trial_time', 'sensor_dots'};
remaining_trial_fields = setdiff(trial_table.nonKeyFields, non_required_trial_blobs);

%remaining_trial_fields = remaining_trial_fields(1:2);

trial_data        = struct2table(fetch(trial_table & key, remaining_trial_fields{:}),'AsArray', true);
blob_session_data = struct2table(fetch(blob_session_table & key, '*'), 'AsArray', true);
primary_key = blob_session_table.primaryKey;

trial_data.super_key = get_superkey_from_table_data(trial_data, primary_key);
blob_session_data.super_key = get_superkey_from_table_data(blob_session_data, primary_key);

vars_to_translate = {'trial_time' 'cumulative_session_time', 'collision' 'position' 'velocity', 'sensor_dots'};

for idx_trial = 1:height(trial_data)
    
    this_trial_key = trial_data(idx_trial, {'super_key', 'block', 'trial_idx'});
    idx_session = blob_session_data.super_key == this_trial_key.super_key;
    
    this_iteration_matrix = blob_session_data{idx_session, 'iteration_matrix'}{:};
    
    idx_var_blobs = (this_iteration_matrix(:,1) == this_trial_key.block) & ...
                (this_iteration_matrix(:,2) == this_trial_key.trial_idx);
            
    for idx_var = 1:length(vars_to_translate)
        
        this_var = blob_session_data{idx_session, vars_to_translate{idx_var}}{:};
        this_var = this_var(idx_var_blobs, :);
        
        trial_data{idx_trial, (vars_to_translate{idx_var})} = {this_var};
    end
    
end
 
trial_data = table2struct(trial_data);

    
end


