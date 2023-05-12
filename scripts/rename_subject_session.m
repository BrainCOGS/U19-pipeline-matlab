function rename_subject_session(original_key, new_key)
    % Rename session from (Can be old subject to new subject)
    
   
   %Check if beahvior file is already uploaded
   [status,~] = lab.utils.read_behavior_file(original_key);
   
   if ~status
       error('Behavior file not found on cup; make sure braininit is mounted or wait for the file to be copied')
      
   %Get original record
   else
       original_data = fetch(acquisition.SessionStarted & original_key, '*');
   end
       
   % Replace key and insert
   new_data = original_data;
   new_data.subject_fullname = new_key.subject_fullname;
   new_data.session_number = new_key.session_number;
   new_data.session_date = new_key.session_date;
   insert(acquisition.SessionStarted, new_data, 'IGNORE');
   
   %Create new remote path accordingly 
   new_data = fetch(acquisition.SessionStarted & new_key, '*');
   new_remote_path_behavior_file = ...
        lab.utils.create_new_behavior_filename(new_data.local_path_behavior_file, ...
        new_data.subject_fullname, new_data.session_date, new_data.session_number);
    update(acquisition.SessionStarted & new_key, 'new_remote_path_behavior_file', new_remote_path_behavior_file);
    
    %Copy behavior file to new location
    [~, old_file] = lab.utils.get_path_from_official_dir(original_data.new_remote_path_behavior_file);
    [~, new_file] = lab.utils.get_path_from_official_dir(new_remote_path_behavior_file);
    
    
    new_dir = fileparts(new_file);
    if ~isfolder(new_dir)
        mkdir(new_dir);
    end
   [status, msg] = copyfile(old_file, new_file);
   
   if ~status
       msg
       error('Behavior file could not be copied to new location');
   else
       %Delete original session
       disp('Deleting original session from DB, answer yes to next questions')
       del(behavior.TowersSession & original_key)
       del(optogenetics.OptogeneticSession & original_key)
       del(acquisition.SessionStarted & original_key)
   end
       
   

   
   