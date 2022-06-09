%{
# General information of an imaging session
-> `u19_recording`.`recording`
%}


classdef ImagingPipelineSession < dj.Computed
    
    properties (Constant)
        
        keySource =  recording.Recording & struct('recording_modality', 'imaging');
        
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
           
            disp('Ingestion not done in matlab for this table')
            disp(key)
            %self.insert(key)
            
        end
    end
    
end


