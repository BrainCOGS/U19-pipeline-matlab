%{
-> subject.Subject
-> lab.Location
---
ml_position:      float        # mediolateral default position for motor
ap_position:      float        # anterioposterior default position for motor
dv_position:      float        # dorsoventral default position for motor
%}

% AX1 ML Mediolateral
% AX2 AP Anteroposterior
% AX3 DV Dorsoventral

classdef HeadMotorPosition < dj.Manual
    
    properties (Constant = true)
       
        axis_struct = struct('ml_position',1, 'ap_position', 2, 'dv_position', 3);
        
    end
    
    
end