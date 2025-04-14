function insert_test_schedule(rigname)

delete_test_schedule(rigname);

query_schedule.location = rigname;
query_schedule.date = char(datetime("now", 'Format', 'uuuu-MM-dd'));

schedule_today = struct2table(fetch(scheduler.Schedule & query_schedule, '*'),'AsArray', true);
max_timeslot = max(schedule_today.timeslot);
[~,idx_schedule] = unique(schedule_today.training_profile_id);

schedule_today_abv = schedule_today(idx_schedule, :);


for i=1:height(schedule_today_abv)
    this_subject = schedule_today_abv{i,'subject_fullname'}{:};
    new_subject = create_test_subject(this_subject);

    schedule_today_abv{i,'subject_fullname'} = {new_subject};
    schedule_today_abv{i,'timeslot'} = max_timeslot+1;
    schedule_today_abv{i,'experimenters_instructions'} = {'FOR TESTING PURPOSES'};
    max_timeslot = max_timeslot +1;

    %delete_sessions_subject(new_subject);
    %delete_behavior_parent_dir_subject(new_subject);
    copy_sessions_subject(this_subject, new_subject);

end
schedule_today_abv_struct = table2struct(schedule_today_abv);
insert(scheduler.Schedule, schedule_today_abv_struct, 'IGNORE');

tomorrow = char(datetime("now", 'Format', 'uuuu-MM-dd')+1);
schedule_today_abv.date = repmat({tomorrow},height(schedule_today_abv),1);
schedule_today_abv_struct = table2struct(schedule_today_abv);
insert(scheduler.Schedule, schedule_today_abv_struct, 'IGNORE');


end

