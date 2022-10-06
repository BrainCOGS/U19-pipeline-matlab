function trial_data = get_full_trial_data(key, trial_table, blob_session_table)
% Get trial data from blob_session_table and not from trial_table external storage (performance increased)
% Regularly 
% blob_session_table == behavior.SpatialTimeBlobs;
% trial_table        == behavior.TowersBlockTrial;
% Input
% key = query reference for a subset of trials
% Ouput
% Structure with all trial data
tic
warning('off','MATLAB:table:RowsAddedNewVars');

if nargin < 3
    blob_session_table = behavior.SpatialTimeBlobs;
end
if nargin < 2
    trial_table = behavior.TowersBlockTrial;
end

% Fields that will be replaced by blob_session_table
non_required_trial_blobs = {'position', 'velocity', 'collision', 'trial_time', 'sensor_dots'};
remaining_trial_fields = setdiff(trial_table.nonKeyFields, non_required_trial_blobs);

% Fetch trial by trial data and blob_session_table data
trial_data        = struct2table(fetch(trial_table & key, remaining_trial_fields{:}),'AsArray', true);
blob_session_data = struct2table(fetch(blob_session_table & key, '*'), 'AsArray', true);
primary_key = blob_session_table.primaryKey;

% Construct a "superkey" from composite keys
trial_data.super_key = get_superkey_from_table_data(trial_data, primary_key);
blob_session_data.super_key = get_superkey_from_table_data(blob_session_data, primary_key);

% Fields in blob_session_table blob
vars_to_translate = {'trial_time' 'cumulative_session_time', 'collision' 'position' 'velocity', 'sensor_dots'};

idx_previous_session = -1;
%For each trial found
for idx_trial = 1:height(trial_data)

    % Get key and filter blob_session_table corresponding data
    this_trial_key = trial_data(idx_trial, {'super_key', 'block', 'trial_idx'});
    idx_session = blob_session_data.super_key == this_trial_key.super_key;
    
    % If we have session_blob_data for the session of the trial:
    if sum(idx_session) == 1
    
        % Only read data if it is a different session than before
        if idx_session ~= idx_previous_session
            this_iteration_matrix = blob_session_data{idx_session, 'iteration_matrix'}{:};
            this_blob_session_data = blob_session_data(idx_session, :);
            blob_vars = this_blob_session_data{:, vars_to_translate};
        end
        
        %Get iteration idxs for the specific trial in the session
        idx_var_blobs = (this_iteration_matrix(:,1) == this_trial_key.block) & ...
            (this_iteration_matrix(:,2) == this_trial_key.trial_idx);
        
        
        % Filter blob data for the specific trial and append it to trial table
        this_trial_blobs = cellfun(@(x) x(idx_var_blobs,:),blob_vars,'Un',0);
        trial_data{idx_trial, vars_to_translate} = this_trial_blobs;
        
        
    idx_previous_session = idx_session;
    end
    
end
 
trial_data = table2struct(trial_data);
warning('on','MATLAB:table:RowsAddedNewVars');
toc
end


