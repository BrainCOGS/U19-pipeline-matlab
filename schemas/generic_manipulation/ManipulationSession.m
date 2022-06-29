%{
%{
# Information of a optogenetic session
-> acquisition.Session
---
-> acquisition.SessionManipulation
-> [nullable] ^package^.^Package^Protocol
-> [nullable] ^package^.^Package^SoftwareParameter
%}

classdef ^Package^Session < dj.Imported
    
    properties
        keySource =  acquisition.Session & (acquisition.SessionManipulation & struct('manipulation_type', '^package^'));
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            %Get behavioral file to load
            data_dir = fetch1(acquisition.SessionStarted & key, 'remote_path_behavior_file');
            
            
            %Load behavioral file
            [status, data_dir] = lab.utils.read_behavior_file(data_dir);
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
                        self.insertSessionFromFile(key, log);
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
        
        function insertSessionFromFile(self, key, log)
            %insert ^package^ manipulation session record based on behavioral file
            %Inputs
            % key      = session info structure (subject_fullname, session_date, session_number)
            % log      = loaded information from behavioral file
            
            key.manipulation_type = '^package^';
            
            %Get ^package^ manipulation protocol from behavioral file
            if isfield(log.animal, 'stimulationProtocol') && isstruct(log.animal.stimulationProtocol)
                key.^package^_protocol_id = log.animal.stimulationProtocol.^package^_optogenetic_protocol_id;
            end

            %Get software params from behavioral file (check if they exist on db)
            if isfield(log.animal, 'softwareParams') && isstruct(log.animal.softwareParams)
                key.software_parameter_set_id = log.animal.softwareParams.software_parameter_set_id;
            end

            %%%% Code to get extra variables from behavior file
            %% key.var1 = log......
            %% key.var2 = log......
            %%%%

            %Get trial by trial info
            trial_structure = get_manipulation_trial_data(^package^.^Package^SessionTrial,key, log);
            
            conn = dj.conn;
            conn.startTransaction()
            try
                insert(self, key);
                insert(^package^.^Package^SessionTrial, trial_structure);
                
            catch err
                conn.cancelTransaction
                disp(err.message)
            end
            
            
        end
        
    end
    
end
%}
