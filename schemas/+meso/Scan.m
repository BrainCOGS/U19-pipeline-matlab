%{
# existence of an imaging session
-> acquisition.Session
---
scan_directory              : varchar(255)                  # 
gdd=null                    : float                         # 
wavelength=940              : float                         # in nm
pmt_gain=null               : float                         # 
%}


classdef Scan < dj.Imported
  methods(Access=protected)
    
    function makeTuples(self, key)
      
      % find subject and date from acquisition.Session table
      subj                 = lower(fetch1(subject.Subject & key, 'subject_nickname'));
      session_date         = erase(fetch1(acquisition.Session & key, 'session_date'), '-');
      base_dir             = formatFilePath('/braininit/RigData/mesoscope/imaging/',true,true);
      folder_path          = [base_dir subj '/' session_date];
      
%       if isThisSpock
%         folder_path = ['/jukebox' folder_path];
%       else
%         folder_path = ['/Volumes' folder_path];
%       end
      
      if isempty(dir(folder_path))
        fprintf('directory %s not found\n',folder_path)
        return
      end
      
      % write full directory where raw tifs are
      key.scan_directory   = folder_path;   
      
      self.insert(key)
      
    end
  end
end
