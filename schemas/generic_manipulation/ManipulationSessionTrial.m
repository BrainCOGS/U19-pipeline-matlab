%{
%{
# Information of a themal trial
-> acquisition.SessionBlockTrial
-> ^package^.^Package^Session
---
%}

classdef ^Package^SessionTrial < dj.Part
    properties(SetAccess=protected)
        master = ^package^.^Package^Session
    end
           
    methods
        
        function trial_structure = get_manipulation_trial_data(~,session_key, log)
           % Create a trial structure from behavioral file data ready to be inserted on the table
           %Inputs
           % session_key          = primary key information from "manipulation"Session table 
           % log                  = behavioral file data 
           %Outputs
           % trial_structure = structure array with trial information for the specific manipulation

            total_trials = 0;
            for iBlock = 1:length(log.block)
                              
                nTrials = length([log.block(iBlock).trial.choice]);
                for itrial = 1:nTrials
                    
                    % Get trial information
                    curr_trial = log.block(iBlock).trial(itrial);
                    total_trials = total_trials + 1;
                    
                    trial_data = session_key;
                    trial_data.trial_idx = itrial;
                    
                    %%%%%%%%%%%%%%%%%%%%%%%
                    %%%% fill here read corresponding manipulation data for each trial
                    %%%%%%%%%%%%%%%%%%%%%%%%
                    

                    trial_structure(total_trials) = trial_data;
                end
            end
            
            
        end
            
   
        
    end
        
end
%}
