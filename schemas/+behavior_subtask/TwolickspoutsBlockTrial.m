
%{
# Trial level data for a twolickspouts subtask session
-> behavior_subtask.TwolickspoutsBlock
-> acquisition.SessionBlockTrial
---
licks                        : blob                          # all iterations with lick detected and side
trial_difficult_type         : varchar(16)                   # trial type label (easy, medium, difficult, etc)
forced_automatic_reward=null : tinyint                       # 1 if reward was forced for trial 0 otherwise
%}

classdef  TwolickspoutsBlockTrial < dj.Part
    properties(SetAccess=protected)
        master = behavior_subtask.TwolickspoutsBlock;
    end
    
    methods
        
        function trial_structure = get_twolickspouts_trial_data(self, block_key, block_data)
            % Create a trial structure from behavioral file block data ready to be inserted on the table
            %Inputs
            % block_key      = primary key information from TwolickspoutsBlock table
            % block_data     = behavioral file data for current blog
            %Outputs
            % trial_structure = structure array with trial information for the specific subtask: Twolickspouts
            
            total_trials = 0;
            %trial_structure = struct;
            nTrials = length([block_data.trial.choice]);
            for itrial = 1:nTrials
                
                % Get trial information
                curr_trial = block_data.trial(itrial);
                total_trials = total_trials + 1;
                
                trial_data = block_key;
                trial_data.trial_idx = itrial;
                
                %%%%%%%%%%%%%%%%%%%%%%%
                %%%% fill here read corresponding Twolickspouts data for each trial
                trial_data.licks = curr_trial.licks;
                if isfield(curr_trial, 'forced_automatic_reward')
                    trial_data.forced_automatic_reward = curr_trial.forced_automatic_reward;
                else
                    trial_data.forced_automatic_reward = NaN;
                end
                if isfield(curr_trial, 'trialDifficultyType')
                    trial_data.trial_difficult_type = curr_trial.trialDifficultyType;
                else
                    trial_data.trial_difficult_type = '';
                end
                %%%%%%%%%%%%%%%%%%%%%%%%
                trial_structure(total_trials) = trial_data;
            end
        end
        
        
    end
    
end
