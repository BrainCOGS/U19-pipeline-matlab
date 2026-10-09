%{
# History of action.ResponsibilitiesAlt, one row per subject and save date
-> subject.Subject
effective_date          : date
---
subject_status          : enum('InExperiments','WaterRestrictionOnly','AdLibWater','Dead')
water_per_day=null      : float                         # in mL
responsibilities        : varchar(4096)                 # JSON
%}

classdef ResponsibilitiesAltHistoric < dj.Manual
end
