 select 
 
 subject_fullname,
 sum(water_amount) as water_amount,
 max(date(administration_time)) as admin_date
 
 from u19_action.water_administration_individual
 
 where administation_type = "supplement" and
 date(administration_time) > "2025-03-01"
 
 group by  subject_fullname, date(administration_time)