%{
-> lab.Location
laser_color:            varchar(10)     # laser color
measurement_date:	    date            # measurmenet date 
---
laser_power:            float           # laser power measured in mW
hardware_setting:       float           # laser hardware setting
%}

classdef LaserMeasurement < dj.Manual
    
end