
% Script to run in cronjob to do behavior backup copying files 

%[status, msg] = copy_noDBVirmen_backup_files();
%if ~status
%    error_behavior_backup_notification_slack(RigParameters.rig, msg, "NODBFiles")
%end
[final_status, msg] = copy_remote_behavior_files(RigParameters.rig);
if ~final_status
    error_behavior_backup_notification_slack(RigParameters.rig, msg)
end