%{
%{
# Parameters related to ^package^ manipulation software during session
software_parameter_set_id   : int AUTO_INCREMENT            # 
---
software_parameter_description: varchar(256)                # string that describes parameter set
software_parameter_hash     : UUID                          # uuid hash that encodes parameter dictionary
software_parameters         : longblob                      # structure of all parameters
%}

classdef ^Package^SoftwareParameter < dj.Lookup
    
     methods
        function try_insert(self, key)
            %Insert a new record on software parameters table (additional check for repeated params)
            % Inputs
            % key = structure with information of the record (software_parameter_description, software_parameters)
            % e.g.:
            %key.software_parameter_description = 'params for manipulation 6/6/2022'
            %key.software_parameters = struct;
            %key.software_parameters.param1 = 1;
            %key.software_parameters.param2 = 'x';
            %try_insert(^package^.^Package^SoftwareParameter, key)
            
            %Check minimum field
            if ~isfield(key, 'software_parameters')
                    error('Structure to insert need a field named: software_parameters')
            end
            
            %Convert parameters to uuid
            uuidParams = struct2uuid(key.software_parameters);
            
            %Check if uuid already in database
            params_UUID = get_uuid_params_db(self, 'software_parameter_hash', uuidParams);
            if ~isempty(params_UUID)
                 error(['This set of parameters were already inserted:' newline, ...
                          'software_parameter_set_id = ' num2str(params_UUID.software_parameter_set_id), newline, ...
                          'software_parameter_description = ' params_UUID.software_parameter_description]);
            end
            
            %Finish key data
            key.software_parameter_hash        = uuidParams;
            if ~isfield(key, 'software_parameter_description')
                key.software_parameter_description = ['Soft Parames inserted on: ' datestr(now)];
            end
            
            insert(self, key);
            last_id = fetch(self, 'ORDER BY software_parameter_set_id desc LIMIT 1');
        end
    end
    
end
%}