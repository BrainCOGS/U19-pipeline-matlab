%{
# Recurring booking of a subject on a rig slot, expanded into Schedule rows by
# U19-pipeline-python u19_pipeline.utils.schedule_rules.materialize_schedule.
# Declared from Python; this class mirrors that definition.
rule_id                     : int auto_increment
---
-> subject.Subject
-> lab.Location
timeslot                    : int                           # same numbering as Schedule.timeslot
-> scheduler.TrainingProfile
-> scheduler.RecordingProfile
-> scheduler.InputOutputProfile
experimenters_instructions='' : varchar(4096)
level=0                     : int                           # 0 means derive from past performance
sublevel=0                  : int                           # 0 means derive from past performance
start_date                  : date                          # first date the rule may run, inclusive
end_date=null               : date                          # last date, inclusive; NULL is open-ended
status='active'             : enum('active','ended','cancelled')
(created_by) -> lab.User(user_id)
created_at=CURRENT_TIMESTAMP : timestamp
%}


classdef ScheduleRule < dj.Manual


end
