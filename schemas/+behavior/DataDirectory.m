%{
# 
-> acquisition.Session
---
data_dir                    : varchar(255)                  # data directory for each session
file_name                   : varchar(255)                  # file name
combined_file_name          : varchar(255)                  # combined filename
%}

classdef DataDirectory < dj.Computed
    
    properties
        popRel = acquisition.Session & 'session_location != "wide-field"'
    end

	methods(Access=protected)

		function makeTuples(self, key)
            
            [rig, subj, session_date] = fetch1(...
                subject.Subject * acquisition.Session & key, 'session_location', 'subject_nickname', 'session_date');
            user = fetch1(lab.User*subject.Subject & key, 'user_nickname');
            session_date = erase(session_date, '-');  

            if strcmp('Bezos3', rig)
                % Or on the scope in bezos
                base_dir = '/braininit/RigData/scope/bay3/';
            	file = dir(getLocalPath([base_dir '/' user '/*/data/' subj '/*_' session_date '.mat']));
            else
                % Training rigs 1 to 7
                rig_number = rig(regexp(rig, '[0-9]'));
                base_dir = '/braininit/RigData/training/';
                if strcmp(subj, 'E86')
                    subj = 'e86';
                end
            	file = dir(getLocalPath([base_dir 'rig' rig_number '/' user '/*/data/' subj '/*_' session_date '.mat']));
            end
            if strcmp('VRLaser', rig)
                base_dir = '/braininit/RigData/VRLaser/behav/lucas/blocksReboot/data/';
                file = dir(getLocalPath([base_dir '/' subj '/*_' session_date '.mat']));
            end
            
            if strcmp('BezosMeso', rig)
                base_dir = '/braininit/RigData/mesoscope/behavior/lucas/blocksReboot/data';
                file = dir(getLocalPath([base_dir '/' lower(subj) '/*_' session_date '.mat']));
            end
            
            if strcmp('VRwidefield', rig)
                base_dir = '/braininit/RigData/VRwidefield/behavior/lucas/blocksReboot/data';
                file = dir(getLocalPath([base_dir '/' lower(subj) '/*_' session_date '.mat']));
            end
            
            if isempty(file)
                disp([rig, '  -file not found.'])
                return
            end
            key.data_dir = getLocalPath(file.folder, 'global');
            key.file_name = file.name;
            key.combined_file_name = getLocalPath([file.folder '/' file.name], 'global');
            
			self.insert(key)
		end
	end

end
