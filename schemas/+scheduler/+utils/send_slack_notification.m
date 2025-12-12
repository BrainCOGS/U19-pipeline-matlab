function send_slack_notification(webhook_name, message)
% SEND_SLACK_NOTIFICATION Send a message to a Slack channel via webhook
%
% Args:
%   webhook_name: Name of the webhook in lab.SlackWebhooks table
%   message: Text message to send to Slack channel
%
% Example:
%   send_slack_notification('rig_scheduling', 'Schedule insertion failed')

    % Constants
    HTTP_TIMEOUT_SECONDS = 10;

    % Fetch the webhook URL from the database
    try
        webhook_query = struct('webhook_name', webhook_name);
        webhook_data = fetch(lab.SlackWebhooks & webhook_query, 'webhook_url');
    catch e
        warning('Failed to fetch webhook from database: %s', e.message);
        return;
    end
    
    if isempty(webhook_data)
        warning('Webhook "%s" not found in lab.SlackWebhooks table', webhook_name);
        return;
    end
    
    webhook_url = webhook_data.webhook_url;
    
    % Prepare the JSON payload for Slack
    payload = struct('text', message);
    
    % Set up HTTP options for JSON POST request
    options = weboptions('MediaType', 'application/json', ...
                        'RequestMethod', 'post', ...
                        'Timeout', HTTP_TIMEOUT_SECONDS);
    
    try
        % Send the POST request to Slack webhook
        % webwrite with 'application/json' MediaType automatically encodes the struct
        webwrite(webhook_url, payload, options);
        fprintf('Slack notification sent successfully to %s\n', webhook_name);
    catch e
        warning('Failed to send Slack notification: %s', e.message);
    end
end
