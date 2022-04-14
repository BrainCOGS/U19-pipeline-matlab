%{
# # Table for pupillometry data (pupil diameter)
->pupillometry.PupillometrySession
---
pupil_diameter:              longblob               # array with pupil diameter for each video frame
%}

%stim instead laser
%add waveform support

classdef PupillometryData < dj.Imported
    
    methods(Access=protected)
        
        function makeTuples(self, key)
             
            
        end
        
    end
    
end

