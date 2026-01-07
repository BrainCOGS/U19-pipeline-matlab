function send_slack_notification_rich(webhook_name, varargin)
% SEND_SLACK_NOTIFICATION_RICH Send a rich formatted message to Slack with blocks
%
% Args:
%   webhook_name: Name of the webhook in lab.SlackWebhooks table
%   varargin: Name-value pairs for message configuration
%       'title' - Title text (with optional emoji icon)
%       'text' - Main message text (supports markdown)
%       'sections' - Cell array of section structures with .title and .text fields
%       'error_info' - Structure with .message and .stack fields for error formatting
%       'emoji' - Emoji to use in title (default: ':rotating_light:')
%       'mention_users' - Cell array of slack member IDs to mention
%       'color' - Color for message accent (not used in blocks API)
%
% Example:
%   send_slack_notification_rich('rig_scheduling', ...
%       'title', 'Schedule Insertion Failed', ...
%       'text', 'Failed to insert 3 entries', ...
%       'sections', {struct('title', 'Subject', 'text', 'mouse123')}, ...
%       'emoji', ':x:');
%
% Example with error:
%   error_info.message = 'Database connection failed';
%   error_info.stack = dbstack;
%   send_slack_notification_rich('alerts', ...
%       'title', 'Critical Error', ...
%       'error_info', error_info);

    % Constants
    HTTP_TIMEOUT_SECONDS = 10;

    % Parse input arguments
    p = inputParser;
    addParameter(p, 'title', '', @ischar);
    addParameter(p, 'text', '', @ischar);
    addParameter(p, 'sections', {}, @iscell);
    addParameter(p, 'error_info', struct(), @isstruct);
    addParameter(p, 'emoji', ':rotating_light:', @ischar);
    addParameter(p, 'mention_users', {}, @iscell);
    addParameter(p, 'color', 'danger', @ischar);
    addParameter(p, 'fields', {}, @iscell);
    parse(p, varargin{:});

    % Fetch the webhook URL from the database
    try
        webhook_query = struct('webhook_name', webhook_name);
        webhook_data = fetch(lab.SlackWebhooks & webhook_query, 'webhook_url');
    catch e
        warning('SlackNotification:FetchFailed', 'Failed to fetch webhook from database: %s', e.message);
        return;
    end

    if isempty(webhook_data)
        warning('Webhook "%s" not found in lab.SlackWebhooks table', webhook_name);
        return;
    end

    webhook_url = webhook_data.webhook_url;

    % Build message blocks
    blocks = {};

    % Add title section with emoji and user mentions
    if ~isempty(p.Results.title)
        title_section.type = 'section';
        title_text.type = 'mrkdwn';

        title_str = [p.Results.emoji ' *' p.Results.title '*'];
        if ~isempty(p.Results.mention_users)
            for i = 1:length(p.Results.mention_users)
                mention_id = p.Results.mention_users{i};
                % Format differently for user groups (start with S) vs users (start with U)
                if startsWith(mention_id, 'S')
                    % User group mention format
                    title_str = [title_str ' <!subteam^' mention_id '>'];
                else
                    % Individual user mention format
                    title_str = [title_str ' <@' mention_id '>'];
                end
            end
        end
        title_str = [title_str ' on ' char(datetime('now'))];

        title_text.text = title_str;
        title_section.text = title_text;
        blocks{end+1} = title_section;

        % Add divider after title
        divider.type = 'divider';
        blocks{end+1} = divider;
    end

    % Add main text section
    if ~isempty(p.Results.text)
        text_section.type = 'section';
        text_content.type = 'mrkdwn';
        text_content.text = p.Results.text;
        text_section.text = text_content;
        blocks{end+1} = text_section;
    end

    % Add custom sections
    if ~isempty(p.Results.sections)
        for i = 1:length(p.Results.sections)
            section = p.Results.sections{i};

            sec.type = 'section';
            sec_text.type = 'mrkdwn';

            if isfield(section, 'title') && ~isempty(section.title)
                sec_text.text = ['*' section.title '*: ' newline section.text];
            else
                sec_text.text = section.text;
            end

            sec.text = sec_text;
            blocks{end+1} = sec;
        end
    end

    % Add fields (displayed in two columns)
    if ~isempty(p.Results.fields)
        fields_section.type = 'section';
        field_list = {};

        for i = 1:length(p.Results.fields)
            field = p.Results.fields{i};
            field_item.type = 'mrkdwn';
            field_item.text = ['*' field.title '*' newline field.value];
            field_list{end+1} = field_item;
        end

        fields_section.fields = field_list;
        blocks{end+1} = fields_section;
    end

    % Add error information if provided
    if ~isempty(fieldnames(p.Results.error_info))
        divider.type = 'divider';
        blocks{end+1} = divider;

        error_section.type = 'section';
        error_text.type = 'mrkdwn';
        error_str = ['*Error Information:*' newline];

        if isfield(p.Results.error_info, 'message')
            error_str = [error_str '*Message*: ' p.Results.error_info.message newline];
        end

        if isfield(p.Results.error_info, 'stack') && ~isempty(p.Results.error_info.stack)
            error_str = [error_str '*Stack Trace*:' newline];
            for i = 1:min(length(p.Results.error_info.stack), 5)  % Limit to 5 entries
                stack_entry = p.Results.error_info.stack(i);
                error_str = [error_str '`' stack_entry.file filesep stack_entry.name '`' ...
                           ' line ' num2str(stack_entry.line) newline];
            end
        end

        error_text.text = error_str;
        error_section.text = error_text;
        blocks{end+1} = error_section;
    end

    % Build the final message payload
    message.blocks = blocks;

    % Fallback text for notifications
    if ~isempty(p.Results.title)
        message.text = p.Results.title;
    elseif ~isempty(p.Results.text)
        message.text = p.Results.text;
    else
        message.text = 'Notification from U19-pipeline-matlab';
    end

    % Convert to JSON
    message_json = jsonencode(message);

    % Set up HTTP options for JSON POST request
    options = weboptions('MediaType', 'application/json', ...
                        'RequestMethod', 'post', ...
                        'Timeout', HTTP_TIMEOUT_SECONDS);

    try
        % Send the POST request to Slack webhook
        webwrite(webhook_url, message_json, options);
        fprintf('Rich Slack notification sent successfully to %s\n', webhook_name);
    catch e
        warning('SlackNotification:SendFailed', 'Failed to send rich Slack notification: %s', e.message);
    end
end
