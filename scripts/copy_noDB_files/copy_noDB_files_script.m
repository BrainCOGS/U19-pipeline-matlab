

% Script to run in cronjob to do behavior backup copying files 
try
    cd('C:/Experiments/U19-pipeline-matlab/')
    startup_scheduled_tasks
    successful_task = 1;
    
    pause(1)
    disp('After startup')
    
    [status, msg] = copy_noDB_backup_files();
    if ~status
        successful_task = 0;
        error_behavior_backup_notification_slack(RigParameters.rig, msg, "NODBFiles")
    end
catch
    successful_task = 0;
end

action.RigsScheduledTaskRegistry.insert_rig_scheduled_task_registry(...
    'copy_noDB_Files', successful_task);