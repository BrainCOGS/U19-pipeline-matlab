%{
# Explicit technician and researcher responsibilities, written by the scheduling
# website. The JSON layout is described in u19_pipeline.utils.responsibilities.
-> subject.Subject
---
subject_status          : enum('InExperiments','WaterRestrictionOnly','AdLibWater','Dead')
water_per_day=null      : float                         # in mL
responsibilities        : varchar(4096)                 # JSON
%}

classdef ResponsibilitiesAlt < dj.Manual
end
