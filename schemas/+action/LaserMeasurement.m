%{
-> lab.Location
laser_color:            varchar(10)     # laser color
laser_cable_side:       enum('Left','Right','N/A')
measurement_date:	    date            # measurmenet date 
---
laser_power:            float           # laser power measured in mW
hardware_setting:       float           # laser hardware setting
%}

classdef LaserMeasurement < dj.Manual
    
end