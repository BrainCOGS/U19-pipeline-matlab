function data_struct = get_behaviorfile_as_db(key)
%GET_STATS_FROM_SESSION get Virmen Behavior File stats from DB data

data_struct = [];
all_data_table = [];
for i=1:length(key)
    current_key = fetch(acquisition.Session & key(i));
    [status,data] = lab.utils.read_behavior_file(current_key);
    
    if status
        log = data.log;
        for iBlock = 1:length(log.block)
            
            block_key = current_key
            block_key.block = iBlock;            
            nTrials = length([log.block(iBlock).trial.choice]);
            
            if nTrials > 0
                
                block_key_rep = repmat(block_key,1,nTrials);
                block_key_table = struct2table(block_key_rep, 'AsArray', true);
                block_key_table.trial_idx = transpose(1:size(block_key_table,1));
                 
                session_data = struct2table(log.block(iBlock).trial(1:nTrials), 'AsArray', true);
                
                if iscell(session_data.trialProb)
                    session_data.trialProb = cellfun(@(x) x(1),session_data.trialProb);
                end
                
                session_data = [block_key_table, session_data];
            
                if isempty(all_data_table)
                    all_data_table = session_data;
                else
                    all_data_table = [all_data_table; session_data];
                end
            end
            
        end
    end
end

if ~isempty(all_data_table)
    data_struct = table2struct(all_data_table);
end

            
