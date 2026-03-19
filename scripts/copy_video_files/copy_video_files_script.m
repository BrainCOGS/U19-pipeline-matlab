
% Script to run in cronjob to do behavior backup copying files 
[final_status, msg] = copy_remote_video_files(RigParameters.rig);
if ~final_status
    error_video_backup_notification_slack(RigParameters.rig, msg)
end

[final_status, msg] = copy_remote_video_files(RigParameters.rig,'posture_tracking');
if ~final_status
    error_video_backup_notification_slack(RigParameters.rig, msg)
end