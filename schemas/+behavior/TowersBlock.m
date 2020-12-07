%{
-> behavior.TowersSession
block                       : tinyint                       # block number
---
-> task.TaskLevelParameterSet
n_trials                    : int                           # number of trials in this block
first_trial                 : int                           # trial_idx of the first trial in this block
block_duration              : float                         # in secs, duration of the block
block_start_time            : datetime                      # absolute start time of the block
reward_mil                  : float                         # in mL, reward volume in this block
reward_scale                : tinyint                       # scale of the reward in this block
easy_block                  : bool                          # true if the difficulty reduces during the session
block_performance           : float                         # performance in the current block
level                       : int                           # maze number (difficulty) of this block
%}

classdef TowersBlock < dj.Imported
    properties
        %keySource = acquisition.Session & acquisition.SessionStarted
        %keySource = proj(acquisition.Session, 'level->na_level') * ...
        %         proj(acquisition.SessionStarted, 'session_location->na_location', 'remote_path_behavior_file')
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            data_dir = fetch1(acquisition.SessionStarted & key, 'remote_path_behavior_file');
            
            
            %Load behavioral file
            try
                [~, data_dir] = lab.utils.get_path_from_official_dir(data_dir);
                data = load(data_dir,'log');
                log = data.log;
                %Check if it is a real behavioral file
                if isfield(log, 'session')
                    %Insert Blocks and trails from BehFile
                    self.insertTowersBlockFromFile(key,log)
                else
                    disp(['File does not match expected Towers behavioral file: ', data_dir])
                end
            catch err
                disp(err)
                disp(['Could not open behavioral file: ', data_dir])
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
            
            for iBlock = 1:length(log.block)
                tuple = key;
                block = log.block(iBlock);
                block = fixLogs(block); % fix bug for mesoscope recordings where choice is not recorded (but view angle is)
                
                tuple.block = iBlock;
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
                tuple.level = block.mazeID;
                tuple.set_id = 1;
                tuple.easy_block = exists_helper(block,'easyBlockFlag'); %if it doesn't exist, difficulty was uniform
                correct_counter = 0;
                for itrial = 1:length(block.trial)
                    trial = block.trial(itrial);
                    correct_counter = correct_counter + strcmp(trial.trialType.char, trial.choice.char);
                end
                perf = correct_counter/length(block.trial);
                if isfinite(perf)
                    tuple.block_performance = perf;
                else
                    tuple.block_performance = 0;
                end
                self.insert(tuple);
                
                for itrial = 1:length(block.trial)
                    trial = block.trial(itrial);
                    
                    tuple = key; %% Start with an emty tube to trial data
                    tuple.block = iBlock;
                    tuple_trial = tuple;
                    
                    tuple_trial.trial_idx = itrial;
                    tuple_trial.trial_type = trial.trialType.char;
                    tuple_trial.choice = trial.choice.char;
                    tuple_trial.trial_time = trial.time;
                    tuple_trial.trial_abs_start = trial.start;
                    tuple_trial.collision = trial.collision;
                    tuple_trial.cue_presence_left = trial.cueCombo(1, :);
                    tuple_trial.cue_presence_right = trial.cueCombo(2, :);
                    
                    if ~isempty(trial.cueOnset{1})
                        tuple_trial.cue_onset_left = trial.cueOnset{1};
                    end
                    
                    if ~isempty(trial.cueOnset{2})
                        tuple_trial.cue_onset_right = trial.cueOnset{2};
                    end
                    
                    if ~isempty(trial.cueOffset{1})
                        tuple_trial.cue_offset_left = trial.cueOffset{1};
                    end
                    
                    if ~isempty(trial.cueOffset{2})
                        tuple_trial.cue_offset_right = trial.cueOffset{2};
                    end
                    
                    if ~isempty(trial.cuePos{1})
                        tuple_trial.cue_pos_left = trial.cuePos{1};
                    end
                    
                    if ~isempty(trial.cuePos{2})
                        tuple_trial.cue_pos_right = trial.cuePos{2};
                    end
                    
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
                    if length(trial.trialProb) == 1
                        tuple_trial.trial_prior_p_left = trial.trialProb;
                    else
                        % For not 50:50 trials, take only one of the
                        % probabilities (they add up to 1)
                        tuple_trial.trial_prior_p_left = trial.trialProb(1);
                    end
                    tuple_trial.vi_start = trial.viStart;
                    insert(behavior.TowersBlockTrial, tuple_trial)
                end
            end
        end
    end
end

function [s] = exists_helper(trial, fieldname)
if isfield(trial, fieldname)
    s = trial.(fieldname);
else
    s = 0;
end
end

%% fix logs where trial type and choice are not recorded due to bug
function block = fixLogs(block)

for iBlock = 1:numel(block)
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

