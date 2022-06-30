
%{
# Session level data for a test_subtask subtask session
-> acquisition.Session
---
stimulus_set: tinyint                       # an integer that describes a particular set of stimuli in a trial
%}

classdef TestSubtaskSession < dj.Imported
    
    properties
        keySource = acquisition.Session * acquisition.SessionSubtask & struct('subtask', 'test_subtask');
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)

            %remove subtask field from key
            key = rmfield(key, 'subtask');
            
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
                        self.insertSubtaskSessionFromFile(key, log);
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
        
        function insertSubtaskSessionFromFile(self, key,  log)
            % Insert test_subtask subtask session record from behavioralfile
            % Called at the end of training or when populating TowersSession
            % Input
            % key  = acquisition.Session key (subject_fullname, date, session_no)
            % log  = behavioral file as stored in Virmen
            
            
            %%%%%%%%%%%%%%%%%%%%
            %%%% fill here read corresponding TestSubtask data for each Session
            %%%%%%%%%%%%%%%%%%%%
            if isstruct(log.animal) && isfield(log.animal, 'stimulusSet') && ~isnan(log.animal.stimulusSet)
                key.stimulus_set = log.animal.stimulusSet;
            else
                key.stimulus_set = -1;
            end
            
            self.insert(key);
        
        end
        
    end
    
end
