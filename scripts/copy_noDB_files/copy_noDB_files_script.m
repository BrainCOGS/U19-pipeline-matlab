

% Script to run in cronjob to do behavior backup copying files 
startup_copyNODBFiles

[status, msg] = copy_noDB_backup_files();
if ~status
    error_behavior_backup_notification_slack(RigParameters.rig, msg, "NODBFiles")
end

%[out, msg] = system('shutdown /r /f /t 0');