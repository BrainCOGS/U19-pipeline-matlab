

keys = 'subject_fullname like "efonseca%"';
possible_sublevel_sessions = fetch(acquisition.Session & keys);

for i=1:length(possible_sublevel_sessions)
    
    disp(i)
    disp(length(possible_sublevel_sessions))
    
    [status,data] = lab.utils.read_behavior_file(possible_sublevel_sessions(i));
    
    if status
        log = data.log;
        % Split data for each block
        for iBlock = 1:length(log.block)

            this_block = log.block(iBlock);
            
            block_key = possible_sublevel_sessions(i);
            block_key.block = iBlock;

            if isfield(this_block, 'sublevel')
                block_key
                this_block.sublevel
                this_block_table_key = fetch(behavior.TowersBlock & block_key);
                if ~isempty(this_block_table_key)
                    update(behavior.TowersBlock & block_key, 'sublevel', this_block.sublevel);
                end
            end

        end
    end
    
end