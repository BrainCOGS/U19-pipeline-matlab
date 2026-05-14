
% Script to run in cronjob to do video backup copying files

try
    cd('C:/Experiments/U19-pipeline-matlab/')
    startup_scheduled_tasks
    successful_task = 1;


    [final_status, msg] = copy_remote_video_files(RigParameters.rig);
    if ~final_status
        successful_task = 0;
        error_video_backup_notification_slack(RigParameters.rig, msg)
    end

    [final_status, msg] = copy_remote_video_files(RigParameters.rig,'posture_tracking');
    if ~final_status
        successful_task = 0;
        error_video_backup_notification_slack(RigParameters.rig, msg)
    end
catch
    successful_task = 0;
end


action.RigsScheduledTaskRegistry.insert_rig_scheduled_task_registry(...
    'copy_Video_Files', successful_task);