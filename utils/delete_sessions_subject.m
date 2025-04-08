function [failed_del_folders_names] = delete_sessions_subject(test_subject)


if ~contains(test_subject,'test','IgnoreCase',true)
    error('Cannot delete not test subjects ')
end

new_subject_query.subject_fullname = test_subject;

ss_data = struct2table(fetch(acquisition.SessionStarted & new_subject_query, '*'),'AsArray', true);

failed_del_folders = 0;
failed_del_folders_names = {};
for i=1:height(ss_data)
    beh_file = ss_data.new_remote_path_behavior_file{i};
    [~, beh_file] = lab.utils.get_path_from_official_dir(beh_file);
    folder = fileparts(beh_file);
    if isfolder(folder)
        [status, ~] = rmdir(folder, 's');
        if ~status
            failed_del_folders = failed_del_folders +1;
            failed_del_folders_names{failed_del_folders} = folder;
        end
    end
end




del(behavior.TowersSession & new_subject_query);
del(acquisition.SessionStarted & new_subject_query);

