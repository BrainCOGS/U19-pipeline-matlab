%% load database
db = AnimalDatabase;


%% insert user information
overview = db.pullOverview;

net_id_mapping = struct('ben', 'emanuele', ...
                        'edward', 'hnieh', ...
                        'joel', 'joelcf', ...
                        'jteran', 'jteran', ...
                        'lteachen', 'lteachen', ...
                        'lucas', 'lpinto', ...
                        'mioffe', 'mioffe', ...
                        'sakoay', 'koay', ...
                        'sbaptista', 'baptista', ...
                        'sbolkan', 'sbolkan', ...
                        'sstein', 'ss31', ...
                        'testuser', 'testuser', ...
                        'zhihao', 'zhihaoz', ...
			'diamanti', 'emdiamanti', ...
			'jounhong', 'jounhong', ...
			'aarusso', 'aarusso', ...
			'jjulian', 'jjulian', ...
			'egcruz', 'efonseca', ...
			'ariordan', 'ariordan');

for i = 1:length(overview.Technicians)
    tech = overview.Technicians(i);
    key_tech = struct(...
        'user_nickname', tech.ID, ...
        'user_id', net_id_mapping.(tech.ID), ...
        'full_name', tech.Name, ...
        'email', tech.Email, ...
        'phone', tech.Phone, ...
        'mobile_carrier', tech.Carrier, ...
        'slack', tech.Slack, ...
        'slack_webhook', tech.slackWebhook, ...
        'contact_via', tech.ContactVia, ...
        'presence', tech.Presence, ...
        'primary_tech', tech.primaryTech, ...
        'day_cutoff_time', tech.DayCutoffTime ...
    );
    inserti(lab.User, key_tech) 
end

for i = 1:length(overview.Researchers)
    researcher = overview.Researchers(i);
    key_researcher = struct( ...
        'user_nickname', researcher.ID, ...
        'user_id', net_id_mapping.(researcher.ID), ...
        'full_name', researcher.Name, ...
        'email', researcher.Email, ...
        'phone', researcher.Phone, ...
        'slack', researcher.Slack, ...
        'contact_via', researcher.ContactVia, ...
        'presence', researcher.Presence, ...
        'tech_responsibility', researcher.TechResponsibility, ...
        'day_cutoff_time', researcher.DayCutoffTime ...
    );
    
    if ~isempty(researcher.slackWebhook)
        key_researcher.slack_webhook = researcher.slackWebhook;
    end

    if ~isempty(researcher.wateringLogs)
        key_researcher.watering_logs = researcher.wateringLogs;
    end

    if ~isempty(researcher.Carrier)
	key_researcher.mobile_carrier = researcher.Carrier;
    end 
    inserti(lab.User, key_researcher)
    
    key_userlab.user_id = net_id_mapping.(researcher.ID);
    if ~isempty(researcher.PI)
        switch researcher.PI
            case 'D. W. Tank'
                key_userlab.lab = 'tanklab';
            case 'I. Witten'
                key_userlab.lab = 'wittenlab';
        end
        inserti(lab.UserLab, key_userlab)
    end
    
    key_userproc.user_id = net_id_mapping.(researcher.ID);
    if ~isempty(researcher.Protocol)
        key_proc.protocol = researcher.Protocol;
        inserti(lab.Protocol, key_proc)
        key_userproc.protocol = researcher.Protocol;
        inserti(lab.UserProtocol, key_userproc)
    end
    
    key_user_secondary_contact.user_id = net_id_mapping.(researcher.ID);
    if ~isempty(researcher.SecondaryContact)
        key_user_secondary_contact.secondary_contact = net_id_mapping.(researcher.SecondaryContact);
        inserti(lab.UserSecondaryContact, key_user_secondary_contact)
    end     
end

%% insert duty roaster
duty_roaster.duty_roaster_date = '2019-01-01';
duty_roaster.sunday_duty = net_id_mapping.(overview.DutyRoster(1).Technician);
duty_roaster.monday_duty = net_id_mapping.(overview.DutyRoster(2).Technician);
duty_roaster.tuesday_duty = net_id_mapping.(overview.DutyRoster(3).Technician);
duty_roaster.wednesday_duty = net_id_mapping.(overview.DutyRoster(4).Technician);
duty_roaster.thursday_duty = net_id_mapping.(overview.DutyRoster(5).Technician);
duty_roaster.friday_duty = net_id_mapping.(overview.DutyRoster(6).Technician);
duty_roaster.saturday_duty = net_id_mapping.(overview.DutyRoster(7).Technician);

inserti(lab.DutyRoaster, duty_roaster)


%% insert notification settings
notification_settings.notification_settings_date = '2019-01-01';
notification_settings.max_response_time = overview.NotificationSettings.MaxResponseTime;
notification_settings.change_cutoff_time = overview.NotificationSettings.ChangeCutoffTime;
notification_settings.weekly_digest_day = overview.NotificationSettings.WeeklyDigestDay;
notification_settings.weekly_digest_time = overview.NotificationSettings.WeeklyDigestTime;

inserti(lab.NotificationSettings, notification_settings)

%% insert subject information
animals = db.pullAnimalList;

for igroup = 1:length(animals)
    animal_group = animals{igroup};
   
    if ~isempty(animal_group)
        for ianimal = 1:length(animal_group)
            animal = animal_group(ianimal);
            key_subj = struct( ...
                'user_id', net_id_mapping.(animal.owner), ...
                'subject_nickname', animal.ID, ...
                'subject_fullname', [net_id_mapping.(animal.owner), '_', animal.ID],...
                'location', animal.whereAmI ...
            );
            
            if ~isempty(animal.sex)
                key_subj.sex = animal.sex.char;
            end
            
            if ~isempty(animal.image)
                key_subj.head_plate_mark = animal.image;
            end
        
            if ~isempty(animal.dob)
                key_subj.dob = sprintf('%d-%02d-%02d', animal.dob(1), animal.dob(2), animal.dob(3));
            end
            
            if ~isempty(animal.protocol)
                key_subj.protocol = animal.protocol;
            end
            
            if ~isempty(animal.initWeight)
                key_subj.initial_weight = animal.initWeight;
            end
            inserti(subject.Subject, key_subj)
            
            
            if ~isempty(animal.actItems)
                for i_act = 1:length(animal.actItems)
                    key_act = struct(...
                        'subject_fullname', [animal.owner '_' animal.ID]);
                    
                    key_act.act_item = animal.actItems{i_act};
                    inserti(subject.SubjectActionManual, key_act)
                end
            end
            if ~isempty(animal.genotype)
                key_subj.line = animal.genotype;
            else
                key_subj.line = 'Unknown';
            end
            
            available_genotypes = fetch(subject.Line, 'line');
            if sum(strcmp({available_genotypes.line}, animal.genotype)) == 0
                linestruct.line = animal.genotype;
                linestruct.binomial = 'Mus musculus';
                linestruct.strain_name = 'C57BL6/J';
                inserti(subject.Line, linestruct)
            end
            update(subject.Subject & ['subject_fullname = "', key_subj.subject_fullname, '"'], 'line', key_subj.line)
            
            % death information
           
            if ~isempty(animal.status) && strcmp(animal.status{end}, 'Dead')
                key_death.subject_fullname= [animal.owner '_' animal.ID];
                death_date = animal.effective{end};
                key_death.death_date = sprintf('%d-%02d-%02d', death_date(1), death_date(2), death_date(3));
                inserti(subject.Death, key_death)
            end
            
            % caging information
            key_cage.cage = animal.cage;
            if contains(animal.cage, 'Ben')
                key_cage.cage_owner = net_id_mapping.ben;
            elseif contains(animal.cage, 'SK')
                key_cage.cage_owner = net_id_mapping.sakoay;
            elseif contains(animal.cage, 'EN')
                key_cage.cage_owner = net_id_mapping.edward;
            elseif contains(animal.cage, 'LP')
                key_cage.cage_owner = net_id_mapping.lucas;
            elseif contains(animal.cage, 'Test')
                key_cage.cage_owner = net_id_mapping.testuser;
            else
                key_cage.cage_owner = 'unknown';
            end
            inserti(subject.Cage, key_cage)
            
            key_caging_status = struct(...
                'subject_fullname', [net_id_mapping.(animal.owner) '_' animal.ID], ...
                'cage', animal.cage);
            inserti(subject.CagingStatus, key_caging_status)
            
            % ingest SubjectStatus
            key_status = struct(...
                'subject_fullname', [net_id_mapping.(animal.owner) '_' animal.ID]);

            if ~isempty(animal.status)
                for istatus = 1:length(animal.status)
                    
                    key_status.subject_status = animal.status{istatus}.string;
                    
                    date = animal.effective{istatus};
                    key_status.effective_date = sprintf('%d-%02d-%02d', date(1), date(2), date(3));
                    key_status.water_per_day = animal.waterPerDay{istatus};
                    key_status.schedule = strjoin(animal.techDuties{istatus}.string, '/');
                    inserti(action.SubjectStatus, key_status)
                end
            end
            
            %ingest subject.SubjectActionAutomatic
            key_status = struct(...
                'subject_fullname', [net_id_mapping.(animal.owner) '_' animal.ID]);
            
            if ~isempty(animal.actItems)
                for i_act = 1:length(animal.actItems)
                    action_string = char(animal.actItems(i_act));
                    if strfind(action_string, 'Weight')
                        da = strsplit(action_string,'on ');
                        date = datevec(da{2});
                        date_time = datetime(date, 'InputFormat', 'dd-MMM-yyyy- HH:mm:ss');
                        [y,mo,d,h,mi,s] = datevec(date_time);
                        key_status.notification_date = sprintf('%d-%02d-%02d %2d:%2d:%2d', y, mo, d, h, mi, s);
                        key_status.notification_message = action_string;
                        inserti(subject.SubjectActionAutomatic, key_status)
                    end
                end
            end
            
        end
    end
end
