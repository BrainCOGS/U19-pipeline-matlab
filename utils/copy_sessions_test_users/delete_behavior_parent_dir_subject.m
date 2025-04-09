function delete_behavior_parent_dir_subject(test_subject)


if ~contains(test_subject,'test','IgnoreCase',true)
    error('Cannot delete not test subjects ')
end

new_subject_query.subject_fullname = test_subject;

new_user = fetch(subject.Subject & new_subject_query,'user_id');
new_user = new_user.user_id;

parent_dir = fullfile('braininit/Data/Raw/behavior/',new_user,test_subject);
[~, parent_dir] = lab.utils.get_path_from_official_dir(parent_dir)
[status, ~] = rmdir(parent_dir, 's')

 