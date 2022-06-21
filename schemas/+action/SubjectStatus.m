%{
# 
-> `u19_subject`.`subject`
effective_date="curdate()"  : date                          # 
---
subject_status=null         : enum('InExperiments','WaterRestrictionOnly','Missing','AdLibWater','Dead') # 
water_per_day=null          : float                         # in mL
schedule=null               : varchar(255)                  # 
%}

classdef SubjectStatus < dj.Manual
end
