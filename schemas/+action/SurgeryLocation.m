%{
# 
-> action.Surgery
device_idx                  : int                           # 
---
-> `u19_lab`.`#insertion_device`
hemisphere                  : enum('L','R','Bilateral')     # 
-> `u19_reference`.`#brain_location`
real_ap_coordinates         : decimal(5,2)                  # anteroposterior coordinates in mm
real_dv_coordinates         : decimal(5,2)                  # dorsoventral coordinates in mm
real_ml_coordinates         : decimal(5,2)                  # mediolateral coordinates in mm
%}


classdef SurgeryLocation < dj.Manual
end
