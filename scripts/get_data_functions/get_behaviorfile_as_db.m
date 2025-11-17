function data_struct = get_behaviorfile_as_db(key)
%get_behaviorfile_as_db rearrange behavior file to output as Behavior tables
% Inputs
% key = = Session keys to fetch data from
% Outputs
% data_struct = Output Structure as fetching from Behavior DB. 

% Get individual sessions from key
key = fetch(acquisition.Session & key);

data_struct = [];
all_data_table = [];
for i=1:length(key)
    
    %Read behavior file
    [status,data] = lab.utils.read_behavior_file(key(i));
    
    if status
        log = data.log;
        % Split data for each block
        for iBlock = 1:length(log.block)
            
            block_key = key(i);
            block_key.block = iBlock;            
            nTrials = length([log.block(iBlock).trial.choice]);
            
            if nTrials > 0
                %Get trial by trail data
                block_key_rep = repmat(block_key,1,nTrials);
                block_key_table = struct2table(block_key_rep, 'AsArray', true);
                block_key_table.trial_idx = transpose(1:size(block_key_table,1));
                 
                session_data = struct2table(log.block(iBlock).trial(1:nTrials), 'AsArray', true);
                
                %Fix trialProb variable (if multiple sessions in a single file
                if iscell(session_data.trialProb)
                    session_data.trialProb = cellfun(@(x) x(1),session_data.trialProb);
                end
                
                %Concatenate data
                session_data = [block_key_table, session_data];
                
                %Non concatenable varialbe
                noncat_vars = {'finalchoice', 'state_ports', 'trial_bank_session'};
                for jj=1:length(noncat_vars)
                    if ismember(noncat_vars{jj}, session_data.Properties.VariableNames);
                        session_data= removevars(session_data,noncat_vars(jj));
                    end
                end
                    
                %Concatenate sessions
                if isempty(all_data_table)
                    all_data_table = session_data;
                else
                    all_data_table = concatenate_tables(all_data_table, session_data);
                end
            end
            
        end
    end
end

% Change2 structure output
if ~isempty(all_data_table)
    data_struct = table2struct(all_data_table);
end
 
            