
%{
# Session level data for a twolickspouts subtask session
-> acquisition.SessionSubtask
---
%}

classdef TwolickspoutsSession < dj.Imported
    
    properties
        keySource = acquisition.Session * acquisition.SessionSubtask & struct('subtask', 'Twolickspouts');
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            %Get behavioral file to load
            data_dir = fetch(acquisition.SessionStarted & key, 'task', 'new_remote_path_behavior_file');
            
            %Load behavioral file
            [status, data] = lab.utils.read_behavior_file(key, []);
            if status
                log = data.log;
            else
                disp(['Could not open behavioral file: ', data_dir.new_remote_path_behavior_file])
            end
            if status
                try
                    %Check if it is a real behavioral file
                    if isfield(log, 'session')
                        %Insert Blocks and trails from BehFile (new and old versions)
                        self.insertTwolickspoutsSessionFromFile(key, log);
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
    
    methods
        
        function insertTwolickspoutsSessionFromFile(self, key,  log)
            % Insert twolickspouts subtask session record from behavioralfile
            % Called at the end of training or when populating TowersSession
            % Input
            % key  = acquisition.Session key (subject_fullname, date, session_no)
            % log  = behavioral file as stored in Virmen
            
            
            %%%%%%%%%%%%%%%%%%%%
            %%%% fill here read corresponding Twolickspouts data for each Session
            %%%%%%%%%%%%%%%%%%%%


            self.insert(key);

        end
        
    end
    
end
