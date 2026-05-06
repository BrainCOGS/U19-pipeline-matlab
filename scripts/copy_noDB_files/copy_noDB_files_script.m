

% Script to run in cronjob to do behavior backup copying files 
cd('C:/Experiments/U19-pipeline-matlab/')
startup_scheduled_tasks

pause(1)
disp('After startup')

[status, msg] = copy_noDB_backup_files();
if ~status
    error_behavior_backup_notification_slack(RigParameters.rig, msg, "NODBFiles")
end

disp('After copy files')
pause(1)


%[out, msg] = system('shutdown /r /f /t 0');