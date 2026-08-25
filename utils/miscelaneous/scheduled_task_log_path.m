function [log_path, log_dir] = scheduled_task_log_path(for_date)
% SCHEDULED_TASK_LOG_PATH Path of the structured scheduled-task log file.
%
% The log rotates daily: each day's events go to scheduled_tasks_YYYYMMDD.log
% so a file never mixes runs from different days and file sizes stay bounded.
% Within a day the file is appended to, which keeps a whole day's activity
% greppable with a single command -- every line already carries its own
% [timestamp] [level] [task] prefix.
%
% Args:
%   for_date: optional datetime selecting which day's log to name
%             (default: now). Useful for locating an older log.
%
% Returns:
%   log_path: full path to the log file for that day
%   log_dir:  directory holding the scheduled-task logs
%
% Example:
%   f = scheduled_task_log_path();                       % today's log
%   f = scheduled_task_log_path(datetime('yesterday'));  % yesterday's

    if nargin < 1 || isempty(for_date)
        for_date = datetime('now');
    end

    % On the rigs the logs live next to the pipeline; elsewhere (tests, dev
    % machines) fall back to a temp dir so this is always callable.
    if ispc && exist(fullfile('C:', 'Experiments'), 'dir')
        log_dir = fullfile('C:', 'Experiments', 'scheduled_task_logs');
    else
        log_dir = fullfile(tempdir, 'u19_scheduled_task_logs');
    end

    day_stamp = char(datetime(for_date, 'Format', 'yyyyMMdd'));
    log_path = fullfile(log_dir, sprintf('scheduled_tasks_%s.log', day_stamp));
end
