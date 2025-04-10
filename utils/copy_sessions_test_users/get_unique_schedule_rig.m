function get_unique_schedule_rig(rigname)

query_schedule.location = rigname;
query_schedule.date = char(datetime("now", 'Format', 'uuuu-MM-dd'));

schedule_today = struct2table(fetch(scheduler.Schedule & query_schedule, '*'),'AsArray', true);

query_schedule.date = char(datetime("now", 'Format', 'uuuu-MM-dd')+1);
schedule_tomorrow = struct2table(fetch(scheduler.Schedule & query_schedule, '*'),'AsArray', true);

end

