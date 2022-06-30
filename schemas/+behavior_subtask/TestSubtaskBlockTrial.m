
%{
# Trial level data for a test_subtask subtask session
-> behavior_subtask.TestSubtaskBlock
-> acquisition.SessionBlockTrial
---
trial_type                  : enum('L','R')                 # answer of this trial, left or right
%}

classdef  TestSubtaskBlockTrial < dj.Part
    properties(SetAccess=protected)
        master = behavior_subtask.TestSubtaskBlock;
    end
    
    methods
        
        function trial_structure = get_subtask_trial_data(self, block_key, block_data)
            % Create a trial structure from behavioral file block data ready to be inserted on the table
            %Inputs
            % block_key      = primary key information from TestSubtaskBlock table
            % block_data     = behavioral file data for current blog
            %Outputs
            % trial_structure = structure array with trial information for the specific subtask: TestSubtask
                        
            total_trials = 0;
            nTrials = length([block_data.trial.choice]);
            for itrial = 1:nTrials
                
                % Get trial information
                curr_trial = block_data.trial(itrial);
                total_trials = total_trials + 1;
                
                trial_data = block_key;
                trial_data.trial_idx = itrial;

                %%%%%%%%%%%%%%%%%%%%%%%
                %%%% fill here read corresponding TestSubtask data for each trial
                if isnumeric(curr_trial.trialType)
                    trial_data.trial_type = Choice(curr_trial.trialType).char;
                else
                    trial_data.trial_type = curr_trial.trialType.char;
                end                
                %%%%%%%%%%%%%%%%%%%%%%%%
                
                trial_structure(total_trials) = trial_data;
            end
        end
        
        
    end
    
end
