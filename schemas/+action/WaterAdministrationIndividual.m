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
            insert(self, water_key);
            
        end

        
    end
    
end