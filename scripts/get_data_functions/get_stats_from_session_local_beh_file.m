function [stat_struct, stat_table, animal_struct] = get_stats_from_session_local_beh_file(session_key, behavior_file, common_stats)
%GET_STATS_FROM_SESSION get VirmenLike trial by trial Behavior File stats from DB data
% Inputs
% key          = Session keys to fetch data from.
% common_stats = cell array with all desired stats names to chose from or "all" to get all: 
% StatNames =
%{'trial_idx';'trial_type';'choice';'trial_abs_start';'trial_duration';'excess_travel';'trial_id';
% 'trial_abs_start_next';'correct_trial';'good_trial';'left_trial';'trialIndex';'right_trial';
%'correct_left';'correct_right';'cum_correct_trials';'cum_good_trials';
%'cum_left_trials';'cum_right_trials';'cum_correct_left_trials';'cum_correct_right_trials';
%'performance';'goodFraction';'numPerMin';'numRewardsPerMin';'numTrials';'bias'}
% Outputs
% stat_struct  = MATLAB structure with keys and stats 

stat_struct = struct;
stat_table = table;
animal_struct = struct;

default_maxExcessTravel = 0.1;

%All neded fields for computation
fields = {'trial_type', 'choice', 'trial_abs_start', 'excess_travel', 'trial_duration', 'trial_id'};
field_types = {'cell',   'cell',      'single',         'single',       'single',         'single'};
block_keys = {'subject_fullname', 'session_date', 'session_number',    'block',   'mazeID'};
block_types = {'cell',               'cell',         'double',         'double',   'double'};
trial_field = {'trial_idx'};
trial_field_type = {'double'};
all_table_fields = [block_keys, trial_field,      fields     ];
all_table_types = [block_types, trial_field_type, field_types];
sort_keys = [block_keys, 'trial_idx'];

% Default statistics or selected ones
if nargin < 2
    common_stats = {'performance', 'bias', 'numTrials', 'numRewardsPerMin', 'numPerMin', 'goodFraction','trialIndex'};
    common_stats = [sort_keys common_stats];
elseif common_stats ~= "all"
    common_stats = [sort_keys common_stats];
elseif ischar(common_stats) && strcmp(common_stats,'all')
    common_stats = "all";
end

%Fetch data

if isempty(behavior_file)
    %behavior_file = fetch1(acquisition.SessionStarted & session_key,'local_path_behavior_file');
    [status, data] = lab.utils.read_behavior_file(session_key);
    if status == 0
        return
    end
else
    if ~exist(behavior_file,"file")
        return
    end
    data = load(behavior_file);
end

animal_struct = data.log.animal;
table_data = table('Size', [0 length(all_table_fields)], ...
    'VariableNames',all_table_fields,'VariableTypes',all_table_types);

for i=1:length(data.log.block)

    n_trials = length(data.log.block(i).trial);

    %Case when something failed that "fixed" n_trials to default value
    if n_trials ~= length([data.log.block(i).trial.trialType])
        n_trials = length([data.log.block(i).trial.trialType]);
    end
    if n_trials > 0

    % Not real behavior file, file stock in 500 trials but empty
    %if n_trials == 500 & length(reshape([data.log.block(i).trial.trialType],[],1)) ~= 500
    %    break
    %end

    this_block_table = table('Size', [n_trials length(all_table_fields)], ...
    'VariableNames',all_table_fields,'VariableTypes',all_table_types);

    this_block_table.subject_fullname = repmat({session_key.subject_fullname}, n_trials, 1);
    this_block_table.session_date = repmat({session_key.session_date}, n_trials, 1);
    this_block_table.session_number = repmat(session_key.session_number, n_trials, 1);
    this_block_table.block = repmat(i, n_trials, 1);
    this_block_table.trial_idx = reshape(1:n_trials,[],1);
    this_block_table.mazeID = repmat(data.log.block(i).mazeID, n_trials, 1);

    this_block_table.trial_type = arrayfun(@(v) Choice(v).char, reshape([data.log.block(i).trial.trialType],[],1) ,'un',0);
    this_block_table.choice = arrayfun(@(v) Choice(v).char, reshape([data.log.block(i).trial.choice],[],1),'un',0);

    start_data = [data.log.block(i).trial.start];
    duration_data = [data.log.block(i).trial.duration];
    this_block_table.trial_abs_start = reshape(start_data(1:n_trials),[],1);
    this_block_table.excess_travel = reshape([data.log.block(i).trial.excessTravel],[],1);
    this_block_table.trial_duration = reshape(duration_data(1:n_trials),[],1);
    this_block_table.trial_id = reshape([data.log.block(i).trial.trialID],[],1);

    table_data = [table_data; this_block_table];
    end

   
end


%If there is data
if ~isempty(table_data)
    
    %table_data = struct2table(stat_struct, 'AsArray', true);
    
    %% Get auxiliar stats for all table
    
    table_data.trialIndex = table_data.trial_id;
    
    % Start time for next trial
    table_data.trial_abs_start_next = table_data.trial_abs_start + table_data.trial_duration;
    
    table_data.correct_trial = cellfun(@(x,y) strcmp(x,y), ...
        table_data.trial_type, table_data.choice);
    
    table_data.good_trial = table_data.excess_travel < default_maxExcessTravel;

    table_data.left_trial = cellfun(@(x) strcmp(x,"L"), table_data.trial_type); 
    table_data.right_trial = cellfun(@(x) strcmp(x,"R"), table_data.trial_type);
    
    table_data.correct_left = (table_data.left_trial == 1 & table_data.correct_trial == 1);
    table_data.correct_right = (table_data.right_trial == 1 & table_data.correct_trial == 1);
    
    %% Get index of fields for blocks_keys and trial_idx_keys
    idx_sort_keys  = find_idx_fields_table(table_data, sort_keys);
    idx_block_keys = find_idx_fields_table(table_data, block_keys);
    
    %Sort table
    key_data = unique(table_data(:, block_keys), 'rows');
    key_data = sortrows(key_data,idx_block_keys);
    table_data = sortrows(table_data,idx_sort_keys);
    table_data.total_trial_idx = [1:height(table_data)]';
    
    %% Calculate stats for each block
    for i=1:size(key_data,1)
        
        block_key_data = key_data(i,:);
        
        %Get only data for this block
        block_data = innerjoin(table_data,block_key_data);
        last_time_trial = block_data.trial_abs_start(1);
        
        % Cumulative stats
        block_data.cum_correct_trials = cumsum(block_data.correct_trial);
        block_data.cum_good_trials = cumsum(block_data.good_trial);
        
        block_data.cum_left_trials = cumsum(block_data.left_trial);
        block_data.cum_right_trials = cumsum(block_data.right_trial);
        block_data.cum_correct_left_trials = cumsum(block_data.correct_left);
        block_data.cum_correct_right_trials = cumsum(block_data.correct_right);
        block_data.performance_left = block_data.cum_correct_left_trials ./ block_data.cum_left_trials;
        block_data.performance_right = block_data.cum_correct_right_trials ./ block_data.cum_right_trials;
        
        block_data.performance = block_data.cum_correct_trials ./ block_data.trial_idx;
        block_data.goodFraction = block_data.cum_good_trials ./ block_data.trial_idx;
        
        %numTrialsPerMinute
        block_data.trial_abs_start_next = block_data.trial_abs_start_next - last_time_trial;
        block_data.numPerMin = (block_data.trial_idx*60) ./ block_data.trial_abs_start_next;
        block_data.numRewardsPerMin = block_data.numPerMin .* block_data.performance;
        
        block_data.numTrials = [block_data.cum_left_trials block_data.cum_right_trials];
        
        block_data.bias      = abs (block_data.cum_correct_right_trials ./ block_data.cum_right_trials     ...
            - block_data.cum_correct_left_trials ./ block_data.cum_left_trials      ...
            );
        
        
        % Replace common_stats "all" to all needed stats
        if i == 1
            if isstring(common_stats) && common_stats == "all"
                common_stats = block_data.Properties.VariableNames;
            end
        end
        
        %Concatenate table with stats
        if i == 1
            stat_table = block_data(:, common_stats);
        else
            stat_table = [stat_table; block_data(:, common_stats)];
        end
        
    end
    stat_table.performance_session = cumsum(stat_table.correct_trial) ./ stat_table.total_trial_idx;
    %Output as structure 
    stat_struct = table2struct(stat_table);
end


end


