%{
# table to mark the training/working schedule of the mouse 
-> subject.Subject
effective_date: date
-----
subject_status: enum('InExperiments', 'WaterRestrictionOnly', 'Missing', 'AdLibWater', 'Dead')
water_per_day=null: float   # in mL
schedule=null: varchar(255)
%}

classdef SubjectStatus < dj.Manual
end