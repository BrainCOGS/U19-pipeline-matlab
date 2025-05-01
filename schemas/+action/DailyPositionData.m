%{
-> subject.Subject
capture_time:  datetime		  # date time
---
ml_position:        float                     # mediolateral position for motor
ap_position:        float                     # anterioposterior position for motor
dv_position:        float                     # dorsoventral position for motor
lateral_image=null: blob@old_dailyposition    # lateral photo taken for reference
top_image=null:     blob@old_dailyposition    # top     photo taken for reference
%}

% AX1 ML Mediolateral
% AX2 AP Anteroposterior
% AX3 DV Dorsoventral

classdef DailyPositionData < dj.Manual
    
    properties (Constant = true)
        
        axis_struct = struct('ml_position',1, 'ap_position', 2, 'dv_position', 3);
        
    end
    
    methods(Static)
        
        function insert_motor_reference_position(subject_fullname, motor_position, lateral_image, top_image)
            
            
            key.subject_fullname = subject_fullname;
            key.capture_time     = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
            key.ml_position      = motor_position.ml_position;
            key.ap_position      = motor_position.ap_position;
            key.dv_position      = motor_position.dv_position;
            
            if nargin >= 3 && ~isempty(lateral_image)
                key.lateral_image = lateral_image;
            end
            if nargin >= 4 && ~isempty(top_image)
                key.top_image = top_image;
            end
            
            insert(action.DailyPositionData,key);
            
        end
        
        
    end
    
end

