% Example Script to make a new field, and update the field



%% Make new field
addAttribute(acquisition.TowersBlock, 'block_performance: float  # performance in the current block')

%% update one field in TowersBlock
allBlocks = fetch(acquisition.TowersBlock); % Get the primary keys of all Blocks
reverseStr = '';
for key_idx = 1:length(allBlocks)           % Use of index to indicate progress
    key = allBlocks(key_idx);
    trials = fetch(acquisition.TowersBlockTrial & key, '*'); % Get trials in blocks
    correct_counter = sum(strcmp({trials.trial_type}, {trials.choice}));
    performance = correct_counter / length(trials);          % Calculate performance
    if length(trials)>0
        update(acquisition.TowersBlock & key, 'block_performance', performance); % Update entry
    else
        update(acquisition.TowersBlock & key, 'block_performance', 0);
    end
    
    % Nice progress indicator
    percentDone = 100*key_idx/length(allBlocks);
    msg = sprintf('Percent done: %3.1f', percentDone);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
