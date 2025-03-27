%{
-> subject.Subject
administration_time:      datetime
---
administation_type:       enum("earned","supplement","extra_supplement")
water_amount:             float
%}

classdef WaterAdministrationIndividual < dj.Manual
    
    methods
        
        function insertIndividualWaterEarnedFromFile(self, log)
            
            % Check if earned water was already on the database
            water_key.subject_fullname    = log.animal.name;
            water_key.administration_time = char(datetime(log.session.start,'Format','uuuu-MM-dd HH:mm:ss'));
            
            %Earned water from behavioral file
            water_key.water_amount     = sum([log.block(:).rewardMiL]);
            water_key.administation_type = 'earned';
            insert(self, water_key,'IGNORE');
            
        end

        function updateIndividualWaterEarnedFromFile(self, log)
            
            % Check if earned water was already on the database
            water_key.subject_fullname    = log.animal.name;
            water_key.administration_time = char(datetime(log.session.start,'Format','uuuu-MM-dd HH:mm:ss'));
            water_key.administation_type = 'earned';
            
            water_record = fetch(self & water_key);

           
            if ~isempty(water_record)
                water_amount = sum([log.block(:).rewardMiL]);
                update(self & water_key, 'water_amount', water_amount)
            else
                water_key.water_amount     = sum([log.block(:).rewardMiL]);
                insert(self, water_key,'IGNORE');
            end

            
            %Earned water from behavioral file
            
           
            
            
        end

        function insertIndividualWaterEarnedFromFile_subject_out(self, log,subject_fullname)

            % Check if earned water was already on the database
            water_key.subject_fullname    = subject_fullname;
            water_key.administration_time = char(datetime(log.session.start,'Format','uuuu-MM-dd HH:mm:ss'));

            %Earned water from behavioral file
            water_key.water_amount     = sum([log.block(:).rewardMiL]);
            water_key.administation_type = 'earned';
            insert(self, water_key);

        end


        function insert_previous_earned_from_all_files(self)
            
            % Check if earned water was already on the database
            sessions = fetch(acquisition.SessionStarted * proj(acquisition.Session) & 'session_date>"2025-03-10"','ORDER BY subject_fullname desc');
            for i =1:numel(sessions)
                   sessions(i)
                   try
                   [status, data] = lab.utils.read_behavior_file(sessions(i));
                   if status
                       updateIndividualWaterEarnedFromFile(self, data.log);
                   end
                   catch err
                   end
            end
                
            
        end


        function insert_previous_supplement_from_db(self)
            
            % Check if earned water was already on the database
            was = fetch(action.WaterAdministration & 'administration_date>"2025-01-01"','*');
            for i =1:numel(was)
                   water_key = struct;
                   water_key.subject_fullname = was(i).subject_fullname;
                   water_key.administration_time = [was(i).administration_date ' 00:00:00'];
                   water_key.administation_type = 'supplement';
                   water_key.water_amount = was(i).supplement;

                   insert(self, water_key,'IGNORE');
            end
                
            
        end

        
    end
    
end