%{
# Relationship between session & manipulation performed
-> acquisition.Session
-> task.Subtask
------
%}

classdef SessionSubtask < dj.Manual
    
    methods
        
        function insertSessionSubtask(self,key,log)
            % Insert session manipulation record from behavioralfile in towersTask
            % Called at the end of training or when populating session
            % Input
            % self         = acquisition.Session instance
            % key          = structure with required fields: (subject_fullname, date, session_no)
            % log          = behavioral file as stored in Virmen
            
            if isfield(log.animal, 'subtask') && ~strcmp(log.animal.subtask,'standard')
                key.subtask = log.animal.subtask;
                insert(self, key, 'IGNORE');
            end   
        end
        
    end
    
end
