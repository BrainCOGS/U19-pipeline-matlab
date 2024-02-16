%{
# # Table for pupillometry sessions reference with model
->pupillometry.PupillometrySession
model_id: int
---
%}



classdef PupillometrySessionModel < dj.Imported
    
    properties (Constant)
        DEFAULT_VIDEO_MODEL = 2;
    end
    
    methods(Access=protected)
 
        function makeTuples(self, key)
    
            insertDefaultSessionModel(self, key)
            
        end
        
        
        
    end
    methods
 
        function insertDefaultSessionModel(self, key)
            
            key.model_id = pupillometry.PupillometrySessionModel.DEFAULT_VIDEO_MODEL;
            insert(pupillometry.PupillometrySessionModel, key);
            
        end
        
        function insertNewSessionModel(self, key, model_id)
            
            key.model_id =model_id;
            insert(pupillometry.PupillometrySessionModel, key);
            
        end
        
    end
    
end

