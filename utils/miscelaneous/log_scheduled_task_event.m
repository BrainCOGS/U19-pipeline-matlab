function log_scheduled_task_event(task_name, level, message)
% LOG_SCHEDULED_TASK_EVENT Record a scheduled-task event to the Windows
% Application Event Log so it can be tracked from Event Viewer.
%
% Args:
%   task_name: short identifier for the scheduled task, e.g. 'copy_Video_Files'
%   level: one of 'INFO', 'WARNING', 'ERROR'
%   message: human-readable message describing the event
%
% On non-Windows platforms this is a no-op aside from echoing to stdout,
% since Event Viewer is Windows-only; stdout is still captured by whatever
% invokes MATLAB (e.g. Task Scheduler's action log).
%
% Example:
%   log_scheduled_task_event('copy_Video_Files', 'ERROR', 'robocopy failed: ...')

    valid_levels = {'INFO', 'WARNING', 'ERROR'};
    if ~ismember(level, valid_levels)
        error('log_scheduled_task_event:InvalidLevel', ...
            'level must be one of: %s', strjoin(valid_levels, ', '));
    end

    timestamp = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
    fprintf('[%s] [%s] [%s] %s\n', timestamp, level, task_name, message);

    if ispc
        write_windows_event_log(task_name, level, message);
    end
end


function write_windows_event_log(task_name, level, message)
    switch level
        case 'ERROR'
            event_type = 'ERROR';
        case 'WARNING'
            event_type = 'WARNING';
        otherwise
            event_type = 'INFORMATION';
    end

    % eventcreate requires a single-line description without embedded quotes
    safe_message = strrep(message, '"', '''');
    safe_message = strrep(safe_message, newline, ' | ');
    description = sprintf('%s: %s', task_name, safe_message);

    cmd = sprintf(['eventcreate /T %s /ID 1 /L APPLICATION /SO U19-pipeline-matlab ' ...
        '/D "%s"'], event_type, description);

    [status, cmd_out] = system(cmd);
    if status ~= 0
        warning('log_scheduled_task_event:EventLogFailed', ...
            'Failed to write to Windows Event Log: %s', cmd_out);
    end
end
