
%{
# Block level data for a twolickspouts subtask session
-> behavior_subtask.TwolickspoutsSession
-> acquisition.SessionBlock
---
sublevel                  : int                           # sublevel for the block
trial_params              : blob                          # maze features of current block
%}

classdef TwolickspoutsBlock < dj.Imported

    properties
        keySource = (acquisition.SessionBlock & struct('is_bad_block', 0)) * behavior_subtask.TwolickspoutsSession;
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            
            %Get behavioral file to load
            data_dir = fetch(acquisition.SessionStarted & key, 'task', 'new_remote_path_behavior_file');
            
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
                        self.insertTwolickspoutsBlockFromFile(key, log);
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
        function insertTwolickspoutsBlockFromFile(self, key,log)
            % Insert twolickspouts subtask block record from behavioralfile
            % Input
            % key  = twolickspouts.TwolickspoutsSession key
            % log  = behavioral file as stored in Virmen
            
            tuple = key;
            iBlock = key.block;
            
            block_data = log.block(iBlock);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% fill here read corresponding Twolickspouts data for each block
            tuple.sublevel = block_data.sublevel;
            tuple.trial_params = block_data.trialParams;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            trial_data = get_twolickspouts_trial_data(behavior_subtask.TwolickspoutsBlockTrial,key, block_data);
            
            if ~isempty(trial_data)
                self.schema.conn.startTransaction()
                try
                    self.insert(tuple);
                    if ~startsWith(tuple(1).subject_fullname, 'testuser')
                        insert(behavior_subtask.TwolickspoutsBlockTrial, trial_data);
                    end
                    %self.schema.conn.commitTransaction
                    
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
