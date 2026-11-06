%{
# One-off deviation from a ScheduleRule on a single date
-> scheduler.ScheduleRule
date                        : date
---
action                      : enum('skip','override')       # skip: no session that day; override: row edited by hand, generator leaves it
reason=''                   : varchar(255)
-> lab.User
created_at=CURRENT_TIMESTAMP : timestamp
%}


classdef ScheduleRuleException < dj.Manual


end
