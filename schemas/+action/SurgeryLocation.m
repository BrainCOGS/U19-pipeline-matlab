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
phi_angle=null              : decimal(5,2)                  # (deg) - azimuth - rotation about the dv-axis [0, 360] - w.r.t the x+ axis
theta_angle=null            : decimal(5,2)                  # (deg) - elevation - rotation about the ml-axis [0, 180] - w.r.t the z+ axis
%}


classdef SurgeryLocation < dj.Manual
end
