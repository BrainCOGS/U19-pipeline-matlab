%{
# 
-> action.Surgery
device_idx                  : int                           # 
---
-> lab.InsertionDevice
hemisphere                  : enum('L','R','Bilateral')     # 
real_ap_coordinates         : decimal(5,2)                  # anteroposterior coordinates in mm
real_dv_coordinates         : decimal(5,2)                  # dorsoventral coordinates in mm
real_ml_coordinates         : decimal(5,2)                  # mediolateral coordinates in mm
phi_angle=null              : decimal(5,2)                  # phi angle for insertion
theta_angle=null            : decimal(5,2)                  # theta angle for insertion
%}


classdef SurgeryLocation < dj.Manual
end
