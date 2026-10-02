%{
# Days of the week on which the rule runs
-> scheduler.ScheduleRule
weekday                     : enum('Mon','Tue','Wed','Thu','Fri','Sat','Sun')
%}


classdef ScheduleRuleDay < dj.Part
    properties(SetAccess=protected)
        master = scheduler.ScheduleRule
    end
end
