
% Script to run in cronjob to do behavior backup copying files

try
    cd('C:/Experiments/U19-pipeline-matlab/')
    startup_scheduled_tasks
    successful_task = 1;

    [final_status, msg] = copy_remote_behavior_files(RigParameters.rig);
    if ~final_status
        successful_task = 0;
        error_behavior_backup_notification_slack(RigParameters.rig, msg)
    end
catch
    successful_task = 0;
end



action.RigsScheduledTaskRegistry.insert_rig_scheduled_task_registry(...
    'copy_Behavior_Files', successful_task);