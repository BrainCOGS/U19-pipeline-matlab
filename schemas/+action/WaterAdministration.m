%{
-> subject.Subject
administration_date:	    date		    # date time
---
earned=null:    float			# water administered
supplement=null: float
received=null: float
-> action.WaterType                         # unknown now
%}

classdef WaterAdministration < dj.Manual
    
    methods
        
        function updateWaterEarnedFromFile(self, key, log)
            
            % Check if earned water was already on the database
            water_key.subject_fullname    = key.subject_fullname;
            water_key.administration_date = key.session_date;
            past_water = fetch(action.WaterAdministration & water_key);
            
            %Earned water from behavioral file
            earned     = sum([log.block(:).rewardMiL]);
            
            %If not insert it
            if isempty(past_water)
                insertWaterEarned(self, water_key, earned);
                
                %If it was already there, update it
            else
                updateWaterEarned(self, water_key, earned);
            end
            
            
            
        end
        
        
        function   insertWaterEarned(self, key, earned)
            % insertWaterEarned, insert record for waterAdministration table (earned in training)
            % Inputs
            % key     = structure with fields (subject_fullname, administration_date)
            % earned  = amount of ml earned during training
            
            % insert water administration information
            key.watertype_name = 'Unknown';
            key.earned    = earned;
            key.supplement = 0;
            key.received = key.earned + key.supplement;
            insert(action.WaterAdministration, key)
            
            
        end
        
        function  updateWaterEarned(self, key, earned)
            % updateWaterEarned, update record for waterAdministration table (earned in training)
            % Inputs
            % key     = structure with fields (subject_fullname, administration_date)
            % earned  = amount of ml earned during training
            
            
            %Get supplement water in database
            supplement_water = fetch1(action.WaterAdministration & key, 'supplement');
            
            % update water administration information
            received = earned + supplement_water;
            update(action.WaterAdministration & key, 'earned', earned)
            update(action.WaterAdministration & key, 'received', received)
            
            
        end

        function insert_previous_supplement_from_db_missing_wa(self)

            % Check if earned water was already on the database
            query_file = fullfile(fileparts(mfilename('fullpath')),'water_admin_individual_supplement_query.sql');
            subjectwater_admin_ind_query= char(join(readlines(query_file),newline));
            curr_conn = dj.conn();
            water_ind_sup_data = curr_conn.query(subjectwater_admin_ind_query);
            water_ind_sup_data = dj.struct.fromFields(water_ind_sup_data);
            
            for i =1:numel(water_ind_sup_data)
                

                check_wa = struct;
                check_wa.subject_fullname = water_ind_sup_data(i).subject_fullname;
                check_wa.administration_date = water_ind_sup_data(i).admin_date;

                previous_record = fetch(self & check_wa,'*');

                if isempty(previous_record)
                    water_key = struct;
                    water_key.subject_fullname = water_ind_sup_data(i).subject_fullname;
                    water_key.administration_date = water_ind_sup_data(i).admin_date;
                    water_key.earned = 0;
                    water_key.supplement = water_ind_sup_data(i).water_amount;
                    water_key.received = water_ind_sup_data(i).water_amount;
                    water_key.watertype_name = 'Unknown';

                    insert(self, water_key,'IGNORE');
                elseif previous_record.supplement == 0 && water_ind_sup_data(i).water_amount ~= 0
                    water_key = struct;
                    water_key.subject_fullname = water_ind_sup_data(i).subject_fullname;
                    water_key.administration_date = water_ind_sup_data(i).admin_date;
                    update(self & water_key,'supplement',water_ind_sup_data(i).water_amount);
                    update(self & water_key,'received',water_ind_sup_data(i).water_amount+previous_record.earned);
                end

            end
        end
        
    end
    
end