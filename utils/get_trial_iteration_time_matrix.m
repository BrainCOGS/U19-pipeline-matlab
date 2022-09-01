function session_time_matrix = get_trial_iteration_time_matrix(log)
% Get relative time from session start for all iterations for a given session
% Input
% log = behavioral file as stored by Virmen

%Check if timeElapsedFirstTrial is stored on behavior file
timeElapsedFirstTrial = 0;
offset_time = 0;
if isfield(log,'timeElapsedFirstTrial') && ~isempty(log.timeElapsedFirstTrial)
    timeElapsedFirstTrial = log.timeElapsedFirstTrial;
end


session_time_matrix = [];
for i = 1:length(log.block)
    
    trials = log.block(i).trial;
    nTrials = length([trials.choice]);
        
    for j = 1:nTrials
        
        current_trial = trials(j);
        
        % For 2nd block onwards
        if i > 1
            %Check if it's a restart case scenario
            if j==1
                if current_trial.start < end_block_relative_time
                    offset_time = seconds(datetime(log.block(i).start) - datetime(log.block(1).start));
                else
                    offset_time = 0;
                end
            end
        end
            
                
        %Get time for each iteration of current trial
        time_trial =  current_trial.start+current_trial.time+ timeElapsedFirstTrial + offset_time;
        iteration_num = [1:length(time_trial)]';
        %Block and trial number for the current trial
        block_num = ones(size(iteration_num))*i;
        trial_num = ones(size(iteration_num))*j;
        

        if j==nTrials
            end_block_relative_time = time_trial(end);
        end
        
        current_trial_data = [time_trial block_num trial_num iteration_num];
        session_time_matrix = [session_time_matrix; current_trial_data];
        
    end
    
end

