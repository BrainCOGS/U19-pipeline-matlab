function delete_all_testuser_TXX_subjects()


query_test_Txx_subjects = 'subject_fullname like "testuser%"';
query_test_Txx_subjects2 = 'subject_fullname REGEXP ".*T[0-9][0-9]$"';
%query_test_Txx_subjects2 = 'subject_fullname REGEXP ".*T$"';


txx_subjects = fetch(subject.Subject & query_test_Txx_subjects & query_test_Txx_subjects2);

dj.config('safemode',0)

for i=1:length(txx_subjects)
    this_subject = txx_subjects(i).subject_fullname;
    num_underscore = strfind(this_subject,'_');

    if length(num_underscore) >=2
        delete_behavior_parent_dir_subject(this_subject)
        delete_sessions_subject(this_subject);
        action.WaterAdministration;
        del(action.DailySubjectPositionData & txx_subjects(i))
        del(subject.Subject & txx_subjects(i));
    end

end

