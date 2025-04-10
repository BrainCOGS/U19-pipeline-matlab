function delete_test_schedule(rigname)

query_schedule.location = rigname;
query_schedule.date = char(datetime("now", 'Format', 'uuuu-MM-dd'));

schedule_today = struct2table(fetch(scheduler.Schedule & query_schedule & 'subject_fullname like "testuser%"', '*'),'AsArray', true);

for i=1:height(schedule_today)
    test_subject = schedule_today{i,'subject_fullname'}{:};
    disp(['Proceed to delete sessions for: ' test_subject, newline])

    delete_sessions_subject(test_subject);
    delete_behavior_parent_dir_subject(test_subject);


end

disp(['Proceed to delete schedule for test subjects in rig: ' rigname, newline])
delete_testuser_schedule_rig(rigname);


end

