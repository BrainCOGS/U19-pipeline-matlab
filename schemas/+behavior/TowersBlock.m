%{
-> acquisition.SessionBlock
-> behavior.TowersSession
---
main_level                  : int                           # main level on current block
-> task.TaskLevelParameterSet
sublevel=null               : int                           # sublevel info of current block     
n_trials                    : int                           # number of trials in this block
first_trial                 : int                           # trial_idx of the first trial in this block
block_duration              : float                         # in secs, duration of the block
block_start_time            : datetime                      # absolute start time of the block
reward_mil                  : float                         # in mL, reward volume in this block
reward_scale                : tinyint                       # scale of the reward in this block
easy_block                  : tinyint                          # true if the difficulty reduces during the session
block_performance           : float                         # performance in the current block
trial_duration_median       : float                         # median duriation of all the trials in the block
%}

classdef TowersBlock < dj.Imported
    properties
        keySource = (acquisition.SessionBlock & struct('is_bad_block', 0)) * behavior.TowersSession;
        %keySource = acquisition.Session & acquisition.SessionStarted
        %keySource = proj(acquisition.Session, 'level->na_level') * ...
        %         proj(acquisition.SessionStarted, 'session_location->na_location', 'new_remote_path_behavior_file')
    end
    methods(Access=protected)
        function makeTuples(self, key)

            data_dir = fetch1(acquisition.SessionStarted & key, 'new_remote_path_behavior_file');


            %Load behavioral file
            try
                [~, data_dir] = lab.utils.get_path_from_official_dir(data_dir);
                data = load(data_dir,'log');
                log = data.log;
                status = 1;
            catch
                disp(['Could not open behavioral file: ', data_dir])
                status = 0;
            end
            if status
                try
                    %Check if it is a real behavioral file
                    if isfield(log, 'session')
                        %Insert Blocks and trails from BehFile
                        self.insertTowersBlockFromFile(key,log)
                    else
                        disp(['File does not match expected Towers behavioral file: ', data_dir])
                    end
                catch err
                    disp(err.message)
                    sprintf('Error in here: %s, %s, %d',err.stack(1).file, err.stack(1).name, err.stack(1).line )
                end
            end

        end

    end

    % Public methods
    methods
        function insertTowersBlockFromFile(self, key,log)
            % Insert blocks and blocktrials record from behavioralfile
            % Called at the end of training or when populating towersBlock
            % Input
            % self = behavior.TowersBlock instance
            % key  = behavior.TowersSession key (subject_fullname, date, session_no)
            % log  = behavioral file as stored in Virmen

            %for iBlock = 1:length(log.block)
            iBlock = key.block;
            tuple = key;
            block = log.block(iBlock);
            block = fixLogs(block); % fix bug for mesoscope recordings where choice is not recorded (but view angle is)

            %tuple.block = iBlock;
            tuple.task = 'Towers';
            tuple.n_trials = length(block.trial);
            tuple.first_trial = block.firstTrial;
            tuple.block_duration = block.duration;
            tuple.block_start_time = sprintf('%d-%02d-%02d %02d:%02d:00', ...
                block.start(1), block.start(2), block.start(3), ...
                block.start(4), block.start(5));
            tuple.reward_mil = block.rewardMiL;
            try
                tuple.reward_scale = block.trial(1).rewardScale;
            catch
                tuple.reward_scale = 0;
            end
            tuple.main_level = block.mainMazeID;
            tuple.level      = block.mazeID;
            if isfield(block, 'sublevel')
                tuple.sublevel = block.sublevel;
            end
            tuple.set_id = 1;
            tuple.trial_duration_median = median([block.trial.duration]);
            tuple.easy_block = exists_helper(block,'easyBlockFlag'); %if it doesn't exist, difficulty was uniform
            correct_counter = 0;
            nTrials = length([block.trial.choice]);
            for itrial = 1:nTrials
                trial = block.trial(itrial);
                if isnumeric(trial.choice)
                    correct_counter = correct_counter + double(single(trial.trialType) == single(trial.choice));
                else
                    correct_counter = correct_counter + strcmp(trial.trialType.char, trial.choice.char);
                end
            end
            perf = correct_counter/nTrials;
            if isfinite(perf)
                tuple.block_performance = perf;
            else
                tuple.block_performance = 0;
            end

            nTrials = length([block.trial.choice]);
            for itrial = 1:nTrials
                trial = block.trial(itrial);
                tuple_trial = key;
                tuple_trial.trial_idx = itrial;

                if isnumeric(trial.trialType)
                    tuple_trial.trial_type = Choice(trial.trialType).char;
                else
                    tuple_trial.trial_type = trial.trialType.char;
                end
                if isnumeric(trial.choice)
                    tuple_trial.choice = Choice(trial.choice).char;
                else
                    tuple_trial.choice = trial.choice.char;
                end

                tuple_trial.trial_time = trial.time;
                tuple_trial.trial_abs_start = trial.start;
                tuple_trial.collision = trial.collision;
                if ~isfield(trial, 'cueCombo')
                    tuple_trial.cue_presence_left = trial.cuePos(1);
                    tuple_trial.cue_presence_right = trial.cuePos(2);
                else
                    if iscell(trial.cueCombo)
                        if all(cellfun(@isempty, trial.cueCombo))
                            tuple_trial.cue_presence_left = {[]};
                            tuple_trial.cue_presence_right = {[]};
                        else
                            tuple_trial.cue_presence_left = trial.cueCombo(1);
                            tuple_trial.cue_presence_right = trial.cueCombo(2);
                        end
                    else
                        tuple_trial.cue_presence_left = {trial.cueCombo(1, :)};
                        tuple_trial.cue_presence_right = {trial.cueCombo(2, :)};
                    end
                end
                tuple_trial.cue_onset_left = trial.cueOnset(1);
                tuple_trial.cue_onset_right = trial.cueOnset(2);
                if isfield(trial, 'cueOffset')
                    tuple_trial.cue_offset_left = trial.cueOffset(1);
                    tuple_trial.cue_offset_right = trial.cueOffset(2);
                else
                    tuple_trial.cue_offset_left = repmat({NaN},size(trial.cueOnset(1)));
                    tuple_trial.cue_offset_right = repmat({NaN},size(trial.cueOnset(2)));
                end
                tuple_trial.cue_pos_left = trial.cuePos(1);
                tuple_trial.cue_pos_right = trial.cuePos(2);

                tuple_trial.trial_duration = trial.duration;
                tuple_trial.excess_travel = trial.excessTravel;
                tuple_trial.i_arm_entry = exists_helper(trial,'iArmEntry');
                tuple_trial.i_blank = exists_helper(trial,'iBlank');
                tuple_trial.i_turn_entry = exists_helper(trial,'iTurnEntry');
                tuple_trial.i_cue_entry = exists_helper(trial,'iCueEntry');
                tuple_trial.i_mem_entry = exists_helper(trial,'iMemEntry');
                tuple_trial.iterations = trial.iterations;
                tuple_trial.position = trial.position;
                tuple_trial.velocity = trial.velocity;
                tuple_trial.sensor_dots = trial.sensorDots;
                tuple_trial.trial_id = trial.trialID;
                if isempty(trial.trialID) || isnan(trial.trialID)
                    tuple_trial.trial_id = -1;
                else
                    tuple_trial.trial_id = trial.trialID;
                end
                
                if length(trial.trialProb) == 1
                    tuple_trial.trial_prior_p_left = trial.trialProb;
                elseif isempty(trial.trialProb)
                    tuple_trial.trial_prior_p_left = -1;
                else
                    % For not 50:50 trials, take only one of the
                    % probabilities (they add up to 1)
                    tuple_trial.trial_prior_p_left = trial.trialProb(1);
                end

                tuple_trial.vi_start = trial.viStart;
                struct_trials(itrial) = tuple_trial;

            end

            if exist('struct_trials')
            
                %"Unnest" cells to match previous way of inserting data
                fields_blob = {'cue_presence_left', 'cue_presence_right', 'cue_onset_left', ...
                    'cue_onset_right', 'cue_offset_left', 'cue_offset_right', ...
                    'cue_pos_left', 'cue_pos_right'};
                for f=1:length(fields_blob)
                    field = fields_blob{f};
                    for s = 1:length(struct_trials)
                        struct_trials(s).(field) = struct_trials(s).(field){:};
                    end
                end
                tic

                self.schema.conn.startTransaction()
                try
                    self.insert(tuple);
                    if ~startsWith(tuple(1).subject_fullname, 'testuser')
                        insert(behavior.TowersBlockTrial, struct_trials);
                    end
                    %self.schema.conn.commitTransaction
                    toc
                catch err
                    %Cancel previous transaction but start a new one to prevent DJ to fail
                    self.schema.conn.cancelTransaction
                    self.schema.conn.startTransaction()
                    throw(err); 
                end
            end

            %end
        end
        
        function update_main_level_blocks(self)
            %Update main level for previous inserted blocks
            
            
            %Fetch all blocks with main_level = 0
            block_info = fetch(proj(self, 'task->ts', 'main_level') * acquisition.SessionStarted & 'main_level = 0', ...
                'task', 'new_remote_path_behavior_file');
            
            
            for i=1:length(block_info)
                
                [i length(block_info)]
                
                %Read behavior file
                [status, data] = lab.utils.read_behavior_file(0, block_info(i));
                if status
                    %Get current block
                    log = data.log;
                    current_block = log.block(block_info(i).block);
                    main_level = current_block.mainMazeID;
                    
                    %Remove unnecesary fields for key and update
                    block_key = rmfield(block_info(i), 'task');
                    block_key = rmfield(block_key, 'new_remote_path_behavior_file');
                    update(self & block_key, 'main_level', main_level);
                end
            end
                
        end
        
    end
end

function [s] = exists_helper(trial, fieldname)
if isfield(trial, fieldname) && ~isempty(trial.(fieldname))
    s = trial.(fieldname);
else
    s = 0;
end
end

%% fix logs where trial type and choice are not recorded due to bug
function block = fixLogs(block)

for iBlock = 1:numel(block)

    %Correct number of trials when there are empty trials in block
    nTrials = length([block(iBlock).trial.choice]);
    block(iBlock).trial = block(iBlock).trial(1:nTrials);

    nTrials = numel(block(iBlock).trial);
    for iTrial = 1:nTrials
        if isempty(block(iBlock).trial(iTrial).trialType)
            if numel(block(iBlock).trial(iTrial).cuePos{1}) > numel(block(iBlock).trial(iTrial).cuePos{1})
                block(iBlock).trial(iTrial).trialType = Choice.L;
            else
                block(iBlock).trial(iTrial).trialType = Choice.R;
            end
        end
        if isempty(block(iBlock).trial(iTrial).choice)
            pos = block(iBlock).trial(iTrial).position;
            if pos(end,2) < 300
                block(iBlock).trial(iTrial).choice   = Choice.nil;
            else
                if pos(end,3) > 0
                    block(iBlock).trial(iTrial).choice = Choice.L;
                else
                    block(iBlock).trial(iTrial).choice = Choice.R;
                end
            end
        end
    end
    block(iBlock).trialType      = [block(iBlock).trial(:).trialType];
    block(iBlock).medianTrialDur = median([block(iBlock).trial(:).duration]);
end


end  
        

