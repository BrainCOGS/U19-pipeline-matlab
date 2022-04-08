function session_time_matrix = get_trial_iteration_time_matrix(log)
% Get relative time from session start for all iterations for a given session
% Input
% log = behavioral file as stored by Virmen

%Check if timeElapsedFirstTrial is stored on behavior file
timeElapsedFirstTrial = 0;
if isfield(log,'timeElapsedFirstTrial') && ~isempty(log.timeElapsedFirstTrial)
    timeElapsedFirstTrial = log.timeElapsedFirstTrial;
end


session_time_matrix = [];
for i = 1:length(log.block)
    
    trials = log.block(i).trial;
    nTrials = length([trials.choice]);
    
    for j = 1:nTrials
        
        current_trial = trials(j);
        
        %Get time for each iteration of current trial
        time_trial =  current_trial.start+current_trial.time+ timeElapsedFirstTrial;
        iteration_num = [1:length(time_trial)]';
        %Block and trial number for the current trial
        block_num = ones(size(iteration_num))*i;
        trial_num = ones(size(iteration_num))*j;
        
        current_trial_data = [time_trial block_num trial_num iteration_num];
        session_time_matrix = [session_time_matrix; current_trial_data];
        
    end
    
end

