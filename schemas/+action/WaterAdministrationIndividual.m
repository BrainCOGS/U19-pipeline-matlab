%{
-> subject.Subject
administration_time:      datetime
---
administation_type:       enum("earned","supplement","extra_supplement")
water_amount:             float
%}

classdef WaterAdministrationIndividual < dj.Manual
    
    methods
        
        function insertWaterEarnedFromFile(self, log)
            
            % Check if earned water was already on the database
            water_key.subject_fullname    = log.animal.name;
            water_key.administration_time = char(datetime(log.session.start,'Format','uuuu-MM-dd HH:mm:ss'));
            
            %Earned water from behavioral file
            water_key.water_amount     = sum([log.block(:).rewardMiL]);
            water_key.administation_type = 'earned';
            insert(self, water_key,'IGNORE');
            
        end

        function insertWaterEarnedFromFile_subject_out(self, log,subject_fullname)

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
            sessions = fetch(acquisition.SessionStarted * proj(acquisition.Session),'ORDER BY subject_fullname desc');
            for i =1:numel(sessions)
                   sessions(i)
                   try
                   [status, data] = lab.utils.read_behavior_file(sessions(i));
                   if status
                       insertWaterEarnedFromFile(self, data.log);
                   end
                   catch err
                   end
            end
                
            
        end

        % function insert_previous_earned_from_all_files_subject_out(self)
% 
%          fname = 'missing_wai.json'; 
%          fid = fopen(fname); 
%          raw = fread(fid,inf); 
%          str = char(raw'); 
%          fclose(fid); 
%          sessions = jsondecode(str);
%          for i =1:numel(sessions)
%              this_session = struct;
%              this_session.subject_fullname = sessions(i).subject_fullname;
%              this_session.session_date = sessions(i).administration_date;
%              this_session
%                 try
%                     [status, data] = lab.utils.read_behavior_file(this_session);
%                     if status
%                         insertWaterEarnedFromFile_subject_out(self, data.log, this_session.subject_fullname);
%                     end
%                 catch err
%                     err
%                     err.stack
%                 end
%          end
%         end

        function insert_previous_supplement_from_db(self)
            
            % Check if earned water was already on the database
            was = fetch(action.WaterAdministration,'*');
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