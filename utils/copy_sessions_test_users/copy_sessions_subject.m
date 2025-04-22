function [missing_files_names, failed_copies_names] = copy_sessions_subject(subject_2_copy,test_subject)

if ~contains(test_subject,'test','IgnoreCase',true)
    error('Cannot copy sessions on not test subjects ')
end

subject_query.subject_fullname = subject_2_copy;
new_subject_query.subject_fullname = test_subject;

del(behavior.TowersSession & new_subject_query);
del(optogenetics.OptogeneticSession & new_subject_query);
del(acquisition.SessionStarted & new_subject_query);

ss_data = struct2table(fetch(acquisition.SessionStarted * proj(behavior.TowersSession) & subject_query, '*'),'AsArray', true);

current_user = fetch(subject.Subject & subject_query,'user_id');
current_user = current_user.user_id;
new_user = fetch(subject.Subject & new_subject_query,'user_id');
new_user = new_user.user_id;

ss_data.subject_fullname = repmat({test_subject},height(ss_data),1);

old_subject_files = ss_data.new_remote_path_behavior_file;


ss_data.local_path_behavior_file = cellfun(@(v) strrep(v,subject_2_copy,test_subject),  ss_data.local_path_behavior_file, 'un', 0);
ss_data.new_remote_path_behavior_file = cellfun(@(v) strrep(v,subject_2_copy,test_subject),  ss_data.new_remote_path_behavior_file, 'un', 0);
ss_data.new_remote_path_behavior_file = cellfun(@(v) strrep(v,current_user,new_user),  ss_data.new_remote_path_behavior_file, 'un', 0);

missing_files = 0;
missing_files_names = {};
failed_copies = 0;
failed_copies_names = {};
for i=1:length(old_subject_files)

    old_file = old_subject_files{i};
    new_file = ss_data.new_remote_path_behavior_file{i};

    [~, old_file] = lab.utils.get_path_from_official_dir(old_file);
    [~, new_file] = lab.utils.get_path_from_official_dir(new_file);

    if isfile(old_file) && ~isfile(new_file)

        new_filepath = fileparts(new_file);
        if ~isfolder(new_filepath)
            mkdir(new_filepath);
        end
        [status, msg] = copyfile(old_file, new_file);
        if ~status
            failed_copies = failed_copies + 1;
            failed_copies_names{failed_copies,1} = old_file;
        end
        
    else
        missing_files = missing_files+1;
        missing_files_names{missing_files,1} = old_file;
    end
end

if missing_files > 0 || failed_copies > 0
    warning('Some files were not copied')
    return
end


insert(acquisition.SessionStarted, table2struct(ss_data));
[~, errors_session] = populate(acquisition.Session, new_subject_query);
[~, errors_session_block] = populate(acquisition.SessionBlock, new_subject_query);
[~, errors_towers_session] = populate(behavior.TowersSession, new_subject_query);
%[keys_spatialtimeblobs, errors_spatialtimeblobs] = populate(behavior.SpatialTimeBlobs, new_subject_query);
[~, errors_block] = populate(behavior.TowersBlock, new_subject_query);



if ~isempty(errors_session) > 0 || ...
    ~isempty(errors_session_block) > 0 || ...
    ~isempty(errors_towers_session) > 0 || ...
    ~isempty(errors_block) > 0
 %   ~isempty(errors_spatialtimeblobs) > 0
    warning('Some population failed')
    errors_session
    errors_session_block
    errors_towers_session
    errors_block
%    errors_spatialtimeblobs
end


end

