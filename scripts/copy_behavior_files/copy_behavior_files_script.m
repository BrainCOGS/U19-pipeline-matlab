
% Script to run in cronjob to do behavior backup copying files 

cd('C:/Experiments/U19-pipeline-matlab/')
startup_scheduled_tasks

[final_status, msg] = copy_remote_behavior_files(RigParameters.rig);
if ~final_status
    error_behavior_backup_notification_slack(RigParameters.rig, msg)
end