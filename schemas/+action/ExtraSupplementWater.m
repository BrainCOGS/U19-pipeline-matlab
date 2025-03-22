%{
-> subject.Subject
extra_supplement_water_date:	      date		    # date
---
prescribed_extra_supplement_amount:   float         # amount if subjecttoo thin from weighingGUI
extra_supplement_amount=null:         float			# amount given
already_received=0:                   tinyint       # if this has been already received on that day
%}

classdef ExtraSupplementWater < dj.Manual
    
    methods
    
        
    end
    
end