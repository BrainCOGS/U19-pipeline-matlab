function log_scheduled_task_event(task_name, level, message)
% LOG_SCHEDULED_TASK_EVENT Record a scheduled-task event to the Windows
% Application Event Log so it can be tracked from Event Viewer.
%
% Args:
%   task_name: short identifier for the scheduled task, e.g. 'copy_Video_Files'
%   level: one of 'INFO', 'WARNING', 'ERROR'
%   message: human-readable message describing the event
%
% Every event is echoed to stdout, which Task Scheduler captures, and
% mirrored to a local fallback log file (see scheduled_task_log_path) so
% there is always a durable record even when Event Viewer is unavailable.
%
% On Windows the event is additionally written to the Application event log
% via eventcreate. That requires the "U19-pipeline-matlab" event source to
% be registered, which needs Administrator rights and is done once per rig
% by scripts/register_event_log_source.BAT. If the source is missing the
% write fails with "Access is denied"; this is not fatal, and it is reported
% only once per MATLAB session rather than on every call, so a nightly run
% is not flooded with identical warnings.
%
% Note: none of this writes to Task Scheduler's History tab. That tab is a
% read-only view of the Microsoft-Windows-TaskScheduler/Operational channel,
% which only the Task Scheduler service can write to. History reflects
% whether a run succeeded, via the exit code the .BAT wrappers propagate;
% the details of why live here.
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

    write_fallback_log(timestamp, task_name, level, message);

    if ispc
        write_windows_event_log(task_name, level, message);
    end
end


function write_fallback_log(timestamp, task_name, level, message)
% Append the event to a local log file. Best-effort: logging must never be
% the reason a copy job fails, so any problem here is swallowed.
    try
        log_path = scheduled_task_log_path();
        log_dir = fileparts(log_path);
        if ~isempty(log_dir) && ~exist(log_dir, 'dir')
            mkdir(log_dir);
        end

        fid = fopen(log_path, 'a');
        if fid == -1
            return;
        end
        cleanup = onCleanup(@() fclose(fid));

        single_line = strrep(message, newline, ' | ');
        single_line = strrep(single_line, sprintf('\r'), '');
        fprintf(fid, '[%s] [%s] [%s] %s\n', timestamp, level, task_name, single_line);
    catch
        % Deliberately silent; stdout already carries the event.
    end
end


function log_path = scheduled_task_log_path()
% Location of the fallback log. Kept alongside the pipeline on the rigs, with
% a temp-dir fallback so this also works off-rig (e.g. in tests).
    default_dir = fullfile('C:', 'Experiments', 'scheduled_task_logs');
    if ispc && exist(fullfile('C:', 'Experiments'), 'dir')
        log_dir = default_dir;
    else
        log_dir = fullfile(tempdir, 'u19_scheduled_task_logs');
    end
    log_path = fullfile(log_dir, 'scheduled_tasks.log');
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
        report_event_log_failure(cmd_out);
    end
end


function report_event_log_failure(cmd_out)
% Warn only once per MATLAB session. Without this the same "Access is denied"
% warning repeats for every logged event, burying the actual job output.
    persistent already_warned
    if isempty(already_warned)
        already_warned = false;
    end

    if already_warned
        return;
    end
    already_warned = true;

    detail = strtrim(cmd_out);
    if contains(upper(detail), 'ACCESS IS DENIED')
        warning('log_scheduled_task_event:EventLogFailed', ...
            ['Failed to write to Windows Event Log: %s\n' ...
             'The "U19-pipeline-matlab" event source is probably not registered. ' ...
             'Run scripts/register_event_log_source.BAT once as Administrator on ' ...
             'this machine to enable Event Viewer logging. Events are still being ' ...
             'written to stdout and to %s.\n' ...
             '(Further Event Log warnings are suppressed for this session.)'], ...
            detail, scheduled_task_log_path());
    else
        warning('log_scheduled_task_event:EventLogFailed', ...
            ['Failed to write to Windows Event Log: %s\n' ...
             'Events are still being written to stdout and to %s.\n' ...
             '(Further Event Log warnings are suppressed for this session.)'], ...
            detail, scheduled_task_log_path());
    end
end
