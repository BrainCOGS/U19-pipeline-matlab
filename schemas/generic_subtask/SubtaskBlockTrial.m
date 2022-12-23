%{
%{
# Trial level data for a ^package^ subtask session
-> behavior_subtask.^Package^Block
-> acquisition.SessionBlockTrial
---
%}

classdef  ^Package^BlockTrial < dj.Part
    properties(SetAccess=protected)
        master = behavior_subtask.^Package^Block;
    end
    
    methods
        
        function trial_structure = get_^package^_trial_data(self, block_key, block_data)
            % Create a trial structure from behavioral file block data ready to be inserted on the table
            %Inputs
            % block_key      = primary key information from ^Package^Block table
            % block_data     = behavioral file data for current blog
            %Outputs
            % trial_structure = structure array with trial information for the specific subtask: ^Package^
            
            total_trials = 0;
            nTrials = length([block_data.trial.choice]);
            for itrial = 1:nTrials
                
                % Get trial information
                curr_trial = block_data.trial(itrial);
                total_trials = total_trials + 1;
                
                trial_data = block_key;
                trial_data.trial_idx = itrial;
                
                %%%%%%%%%%%%%%%%%%%%%%%
                %%%% fill here read corresponding ^Package^ data for each trial
                %%%%%%%%%%%%%%%%%%%%%%%%
                
                
                trial_structure(total_trials) = trial_data;
            end
        end
        
        
    end
    
end
%}