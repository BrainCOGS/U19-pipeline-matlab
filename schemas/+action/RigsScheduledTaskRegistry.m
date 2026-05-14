%{
-> lab.Location                                  # Rig that performed task
task_datetime:  datetime		                 # date time of task
---
scheduled_task:     varchar(32)                  # which schedule task typethe rig did
successful:         tinyint                      # task was successful or not

%}


classdef RigsScheduledTaskRegistry < dj.Manual
        
    methods(Static)
        
        function insert_rig_scheduled_task_registry(scheduled_task, successful)
            
            
            key.location       = RigParameters.rig;
            key.task_datetime  = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
            key.scheduled_task = scheduled_task;
            key.successful     = successful;
            
            insert(action.RigsScheduledTaskRegistry,key);
            
        end
        
        
    end
    
end

