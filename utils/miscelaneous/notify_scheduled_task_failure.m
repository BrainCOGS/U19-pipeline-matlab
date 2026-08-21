function notify_scheduled_task_failure(task_name, rig, message, varargin)
% NOTIFY_SCHEDULED_TASK_FAILURE Log an ERROR event and send a Slack alert for
% a failed nightly scheduled task (e.g. a copy job run from Task Scheduler).
%
% Args:
%   task_name: short identifier for the scheduled task, e.g. 'copy_Video_Files'
%   rig: name of the rig/location the task ran on (RigParameters.rig)
%   message: description of the failure
%   varargin: optional name-value pairs
%       'webhook_name' - lab.SlackWebhooks entry to post to
%                        (default: 'dev_notifications')
%       'error_info'   - struct with .message/.stack (from a caught MException)
%
% This both writes the failure to the scheduled-task log / Windows Event
% Viewer (via log_scheduled_task_event) and posts a Slack notification (via
% send_slack_notification_rich), so a failure is never silent even if one of
% the two channels is unavailable.
%
% Example:
%   notify_scheduled_task_failure('copy_Video_Files', RigParameters.rig, msg)

    p = inputParser;
    addParameter(p, 'webhook_name', 'dev_notifications', @ischar);
    addParameter(p, 'error_info', struct(), @isstruct);
    parse(p, varargin{:});

    log_scheduled_task_event(task_name, 'ERROR', ...
        sprintf('rig=%s: %s', rig, message));

    try
        send_slack_notification_rich(p.Results.webhook_name, ...
            'title', sprintf('Scheduled Task Failed: %s', task_name), ...
            'text', message, ...
            'fields', {struct('title', 'Rig', 'value', rig), ...
                       struct('title', 'Task', 'value', task_name)}, ...
            'error_info', p.Results.error_info, ...
            'emoji', ':rotating_light:');
    catch e
        % Slack notification is best-effort; the failure is already recorded
        % in the log / Event Viewer even if this fails.
        warning('notify_scheduled_task_failure:SlackFailed', ...
            'Failed to send Slack failure notification: %s', e.message);
    end
end
