
% Script to run in cronjob to do video backup copying files

task_name = 'copy_Video_Files';

try
    cd('C:/Experiments/U19-pipeline-matlab/')
    startup_scheduled_tasks
    successful_task = 1;
    rig = RigParameters.rig;

    % Report a stale/failed git pull separately from copy failures: it is
    % a warning, not a task failure, since the job still runs against
    % whatever code was already on disk.
    for i = 1:numel(startup_git_pull_warnings)
        notify_scheduled_task_failure(task_name, rig, ...
            sprintf('git pull warning: %s', startup_git_pull_warnings{i}));
    end

    log_scheduled_task_event(task_name, 'INFO', ...
        sprintf('rig=%s: starting video backup copy', rig));

    [final_status, msg] = copy_remote_video_files(rig);
    if ~final_status
        successful_task = 0;
        notify_scheduled_task_failure(task_name, rig, ...
            sprintf('copy_remote_video_files failed: %s', msg));
    else
        log_scheduled_task_event(task_name, 'INFO', ...
            sprintf('rig=%s: copy_remote_video_files completed successfully', rig));
    end

    [final_status, msg] = copy_remote_video_files(rig, 'posture_tracking');
    if ~final_status
        successful_task = 0;
        notify_scheduled_task_failure(task_name, rig, ...
            sprintf('copy_remote_video_files (posture_tracking) failed: %s', msg));
    else
        log_scheduled_task_event(task_name, 'INFO', ...
            sprintf('rig=%s: copy_remote_video_files (posture_tracking) completed successfully', rig));
    end
catch err
    successful_task = 0;
    try
        rig = RigParameters.rig;
    catch
        rig = 'unknown';
    end
    error_info.message = err.message;
    error_info.stack = err.stack;
    notify_scheduled_task_failure(task_name, rig, ...
        sprintf('Unhandled error: %s', err.message), 'error_info', error_info);
end

if successful_task
    log_scheduled_task_event(task_name, 'INFO', ...
        sprintf('rig=%s: video backup copy task completed successfully', rig));
end

action.RigsScheduledTaskRegistry.insert_rig_scheduled_task_registry(...
    task_name, successful_task);

% Propagate failure as a nonzero exit code so Task Scheduler's "Last Run
% Result" / History reflect whether the task actually succeeded.
if ~successful_task
    exit(1);
end
