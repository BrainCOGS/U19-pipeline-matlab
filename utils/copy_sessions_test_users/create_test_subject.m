function new_name = create_test_subject(subject_fullname)

query_subject.subject_fullname = subject_fullname;
subject_info = fetch(subject.Subject & query_subject,'*');

subject_info.subject_fullname = strrep(subject_info.subject_fullname,subject_info.user_id,'testuser');
subject_info.subject_fullname = [subject_info.subject_fullname,'_T'];
new_name = subject_info.subject_fullname;
subject_info.user_id = 'testuser';

subject_info = rmfield(subject_info,'head_plate_mark');

insert(subject.Subject, subject_info, 'IGNORE');