function delete_testuser_schedule_rig(rigname)

query_schedule.location = rigname;
query_schedule.date = char(datetime("now", 'Format', 'uuuu-MM-dd'));

del(scheduler.Schedule & query_schedule & 'subject_fullname like "testuser%"');

query_schedule.date = char(datetime("now", 'Format', 'uuuu-MM-dd')+1);
del(scheduler.Schedule & query_schedule & 'subject_fullname like "testuser%"');

end

