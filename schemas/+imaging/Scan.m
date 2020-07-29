%{
-> acquisition.Session
---
scan_directory      : varchar(255)
%}

classdef Scan < dj.Imported
    
    properties (Constant)
        
        % Acquisition types for 2,3 photon and mesoscope
        photon_micro_acq       = {'2photon' '3photon'};
        mesoscope_acq          = {'mesoscope'};
        
        % Base directory for for 2,3 photon and mesoscope
        photon_micro_base_dir  = fullfile('Bezos', 'RigData', 'scope' ,'bay3');
        mesoscope_base_dir     = fullfile('braininit', 'RigData', 'mesoscope', 'imaging');
        
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            % find subject and date from acquisition.Session table
            subj                 = lower(fetch1(subject.Subject & key, 'subject_nickname'));
            session_date         = erase(fetch1(acquisition.Session & key, 'session_date'), '-');
            
            % get acquisition type of session (differentiate mesoscope and 2_3 photon
            acq_type             = fetch1(proj(acquisition.Session, 'session_location->location') * ...
                lab.Location & key, 'acquisition_type');
            
            %If is mesoscope
            if any(contains(self.mesoscope_acq, acq_type))
                %Get mesoscope scan_directory if exists
                [status, scan_directory]   = self.get_mesoscope_scan(subj, session_date);
              
            %If is 2photon or 3photon
            elseif any(contains(self.photon_micro_acq, acq_type))
                %Get user nickname to locate scan_directory
                user_nick = fetch1(subject.Subject * lab.User & key, 'user_nickname');
                %Get imaging directory if exists
                [status, scan_directory] = self.get_photonmicro_scan(subj, session_date, user_nick);
              
            %If no real "acquisition" was made
            else
                disp(key)
                warning(['This session with acquisition_type: ' acq_type ' should not be processed in this pipeline'])
                return
            end
            
            %If a non empty scan directory was found
            if status
                fprintf('directory with files %s found !!\n',scan_directory)
                key.scan_directory = scan_directory;
            else
                fprintf('directory %s not found\n',scan_directory)
                return
            end
            
            %Insert key in Scan table
            self.insert(key)
        end
        
        function [status, scan_directory] = get_mesoscope_scan(self, subj, session_date)
            % get mesoscope scan directory
            %
            % Inputs
            % subj           = subject nickname
            % session_date   = date from the acquisition in format YYYYMMDD
            %
            % Outputs
            % status         = true if scan_directory found false otherwise
            % scan_directory = directory with tiff imaging files
            
            %get main dir for acquisition files
            [bucket_path, local_path] = get_path_from_official_dir(self.mesoscope_base_dir);
            
            %If running locally, check if it is connected
            if ~isThisSpock
                status = check_mounted_location(local_path);
                if ~status
                    error ([local_path ' is not mounted in your system'])
                end
            end
            
            %complete local and bucket path for scan directory
            local_path = fullfile(local_path, subj, session_date);
            scan_directory = [bucket_path '/' subj '/' session_date];
            
            %Check if directory exists and is not empty
            if isempty(dir(local_path))
                status = false;
            else
                status = true;
            end
           
        end
        
        
        function [status, scan_directory] = get_photonmicro_scan(self, subj, session_date, user_nick)
            % get 2photon or 3photon scan directory
            %
            % Inputs
            % subj           = subject nickname
            % session_date   = date from the acquisition in format YYYYMMDD
            % user_nick      = user nickname (parent folder for scan dir)
            %
            % Outputs
            % status         = true if scan_directory found false otherwise
            % scan_directory = directory with tiff imaging files
            
            status = true;
            scan_directory = '';
            
            %get main dir for acquisition files
            [bucket_path, local_path] = get_path_from_official_dir(self.photon_micro_base_dir);
            
            %If running locally, check if it is connected
            if ~isThisSpock
                status = check_mounted_location(local_path);
                if ~status
                    error ([local_path ' is not mounted in your system'])
                end
            end
            
            %Parent folder starts with user nicknames
            userDir        =  fullfile(local_path, user_nick);
            
            %Get all child directories from user
            disp('start genpath')
            tic
            dirInfo = genpath(userDir);
            toc
            dirInfo = split(dirInfo,':');
            
            %Remove final entry (0x0 char)
            dirInfo = dirInfo(1:end-1);
            
            %Search directories that "end" with subject nickname
            indexSubjDir = cellfun(@(x) strcmpi(x(end-length(subj)+1:end),subj),...
                dirInfo, 'UniformOutput',true);
            
            % If only one path "ends" with subject nickname
            if sum(indexSubjDir) == 1
                dirSubj = dirInfo{indexSubjDir};
                dirSession = fullfile(dirSubj, session_date);
                
            % If no path "ends" with subject nickname    
            elseif sum(indexSubjDir) == 0
                status = false;
                return
            
            % If more than one path "ends" with subject nickname 
            else
                dirInfo = dirInfo(indexSubjDir);
                
                %Check every path, first directory with files will make it stop
                for j=1:length(dirInfo)
                    dirSubj = dirInfo{j};
                    dirSession = fullfile(dirSubj, session_date);
                    
                    if ~isempty(dir(dirSession))
                        break
                    end
                end
            end
            
            %Check if "candidate" directory is empty
            if ~isempty(dir(dirSession))
                %Get scan directory from bucket
                scan_directory = strrep(dirSession, local_path, bucket_path);
                %Change filesep if we are in windows
                if ispc
                    scan_directory = strrep(scan_directory, '\', '/');
                end
            else
                status = false;
            end
            
            
        end
    end
    
end



