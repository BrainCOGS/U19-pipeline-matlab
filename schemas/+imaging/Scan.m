%{
-> acquisition.Session
---
scan_directory      : varchar(255)
gdd=null            : float
wavelength=920      : float           # in nm
pmt_gain=null       : float
(imaging_area) -> reference.BrainArea(brain_area)
frame_time          : longblob
%}

classdef Scan < dj.Imported
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            % find subject and date from acquisition.Session table
            subj                 = lower(fetch1(subject.Subject & key, 'subject_nickname'));
            session_date         = erase(fetch1(acquisition.Session & key, 'session_date'), '-');
            ba = fetch1(reference.BrainArea & "brain_area = 'EC'", 'brain_area');
            
            %get main dir for acquisition files
            rigDir               = fullfile('/jukebox', 'Bezos', 'RigData', 'scope' ,'bay3');
            key.imaging_area = ba;
            key.frame_time = {0};
            
            % list of users to search sessions
            users = {'edward', 'lucas'};
            
            %for each user
            for i=1:length(users)
                % make list of all directories for this user
                userDir =  fullfile(rigDir, users{i});
                dirInfo = genpath(userDir);
                
                % get directories with length > subject
                dirInfo = split(dirInfo,':');
                %Remove final entry (0x0 char)
                dirInfo = dirInfo(1:end-1);
                
                %Search directories that "end" with subject name
                lowerDirInfo = lower(dirInfo);
                indexSubjDir = cellfun(@(x) strcmp(x(end-length(subj)+1:end),subj),...
                    lowerDirInfo, 'UniformOutput',true);
                
                if sum(indexSubjDir) == 1
                    dirSubj = dirInfo(indexSubjDir);
                    dirSession = fullfile(dirSubj, session_date);
                elseif sum(indexSubjDir) == 0
                    fprintf('directory for subject %s not found\n', subj);
                    return
                else
                    dirInfo = dirInfo(indexSubjDir);
                    dirInfo
                    for j=1:length(dirInfo)
                        dirSubj = dirInfo{j};
                        dirSubj
                        dirSession = fullfile(dirSubj, session_date);
                        dirSession
                        if ~isempty(dir(dirSession))
                            break
                        end
                    end
                end
                
                dirSession
                if isempty(dir(dirSession))
                    fprintf('directory %s not found\n',dirSession)
                    return
                end
                
                % write full directory where raw tifs are
                key.scan_directory   = dirSession;
                
                self.insert(key)
            end
        end
    end

end
