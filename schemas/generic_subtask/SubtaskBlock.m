%{
%{
# Block level data for a ^package^ subtask session
-> behavior_subtask.^Package^Session
-> acquisition.SessionBlock
---
%}

classdef ^Package^Block < dj.Imported
    
    methods(Access=protected)
        function makeTuples(self, key)
            
            %Get behavioral file to load
            data_dir = fetch(acquisition.SessionStarted & key, 'task', 'remote_path_behavior_file');
            
            %Load behavioral file
            [status, data] = lab.utils.read_behavior_file(key, data_dir);
            if status
                log = data.log;
            else
                disp(['Could not open behavioral file: ', data_dir])
            end
            if status
                try
                    %Check if it is a real behavioral file
                    if isfield(log, 'session')
                        %Insert Blocks and trails from BehFile (new and old versions)
                        self.insertSubtaskBlockFromFile(key, log);
                    else
                        disp(['File does not match expected Towers behavioral file: ', data_dir])
                    end
                catch err
                    disp(err.message)
                    sprintf('Error in here: %s, %s, %d',err.stack(1).file, err.stack(1).name, err.stack(1).line )
                end
            end
            
        end
        
    end
    
    % Public methods
    methods
        function insertSubtaskBlockFromFile(self, key,log)
            % Insert ^package^ subtask block record from behavioralfile
            % Input
            % key  = ^package^.^Package^Session key
            % log  = behavioral file as stored in Virmen
            
            tuple = key;
            iBlock = key.block;
            
            block_data = log.block(iBlock);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% fill here read corresponding ^Package^ data for each block
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            trial_data = get_subtask_trial_data(behavior_subtask.^Package^BlockTrial,key, block_data);
            
            if ~isempty(trial_data)
                self.schema.conn.startTransaction()
                try
                    self.insert(tuple);
                    insert(behavior_subtask.^Package^BlockTrial, trial_data);
                    %self.schema.conn.commitTransaction
                    toc
                catch err
                    %Cancel previous transaction but start a new one to prevent DJ to fail
                    self.schema.conn.cancelTransaction
                    self.schema.conn.startTransaction()
                    throw(err);
                end
            end
        end
        
    end
    
end
%}

