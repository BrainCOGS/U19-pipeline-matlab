# Slack Notification Utilities

This directory contains utilities for sending rich, formatted Slack notifications from U19-pipeline-matlab. These utilities are inspired by and compatible with the notification system used in ViRMEn.

## Overview

The notification system supports:
- **Rich message formatting** with Slack blocks, markdown, and emojis
- **User and group mentions** to tag specific Slack users or user groups
- **Error notifications** with formatted stack traces
- **Context sections** for structured information display
- **On-duty technician lookup** for automatic notifications

## Core Functions

### `send_slack_notification.m`
Simple text-based notification (legacy/basic use).

```matlab
send_slack_notification('rig_scheduling', 'Schedule updated successfully');
```

### `send_slack_notification_rich.m`
Rich formatted notifications with Slack blocks, sections, and markdown.

```matlab
% Basic rich notification
send_slack_notification_rich('rig_scheduling', ...
    'title', 'Schedule Updated', ...
    'text', 'Successfully inserted 25 entries', ...
    'emoji', ':white_check_mark:');

% With sections and user mentions
sections{1}.title = 'Details';
sections{1}.text = 'All rigs are now scheduled';
send_slack_notification_rich('rig_scheduling', ...
    'title', 'Schedule Complete', ...
    'text', 'Daily schedule ready', ...
    'sections', sections, ...
    'mention_users', {'U12345678'}, ...
    'emoji', ':calendar:');

% With user group mentions
devs_group = fetch1(lab.SlackGroups & 'group_name="devs"', 'group_id');
send_slack_notification_rich('rig_scheduling', ...
    'title', 'Critical Alert', ...
    'text', 'Immediate attention required', ...
    'mention_users', {devs_group}, ...
    'emoji', ':rotating_light:');

% With fields (displayed in columns)
fields{1}.title = 'Total Entries';
fields{1}.value = '25';
fields{2}.title = 'Failed';
fields{2}.value = '0';
send_slack_notification_rich('rig_scheduling', ...
    'title', 'Schedule Summary', ...
    'fields', fields);
% With error information
try
    % Your code here
    insert(scheduler.Schedule, data);
catch e
    error_info.message = e.message;
    error_info.stack = e.stack;
    
    context{1}.title = 'Subject';
    context{1}.text = 'mouse123';
    
    send_slack_notification_rich('alerts', ...
        'title', 'Database Insert Failed', ...
        'sections', context, ...
        'error_info', error_info, ...
        'mention_users', {'U12345678'}, ...
        'emoji', ':x:');
end
```

### `get_on_duty_tech.m`
Fetch Slack member IDs of technicians currently on duty.

```matlab
tech_ids = get_on_duty_tech();
send_slack_notification_rich('alerts', ...
    'title', 'Urgent Issue', ...
    'text', 'Need tech assistance', ...
    'mention_users', tech_ids);
```

## Parameters Reference

### `send_slack_notification_rich` Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | string | Title text with optional emoji |
| `text` | string | Main message text (supports markdown) |
| `sections` | cell array | Sections with `.title` and `.text` fields |
| `fields` | cell array | Fields with `.title` and `.value` (displayed in columns) |
| `error_info` | struct | Error with `.message` and `.stack` fields |
| `emoji` | string | Emoji for title (default: `:rotating_light:`) |
| `mention_users` | cell array | Slack member IDs (U...) or group IDs (S...) to mention |

### Emoji Reference

Common emojis for notifications:
- `:rotating_light:` - Errors/alerts
- `:x:` - Failures
- `:white_check_mark:` - Success
- `:warning:` - Warnings
- `:calendar:` - Schedule-related
- `:bell:` - General notifications
- `:bar_chart:` - Statistics/reports

## Database Setup

### SlackWebhooks Table
The `lab.SlackWebhooks` table stores webhook URLs:

```matlab
% Example insert
webhook.webhook_name = 'rig_scheduling';
webhook.webhook_url = 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL';
insert(lab.SlackWebhooks, webhook);
```

### SlackGroups Table
The `lab.SlackGroups` table stores user group IDs for mentions:

```matlab
% Example insert
group.group_name = 'devs';
group.group_id = 'S0A39NY71RQ';  % Your actual Slack group ID
insert(lab.SlackGroups, group);

% To find your Slack group ID:
% 1. In Slack, go to the user group
% 2. Click the group name to open settings
% 3. The ID is in the URL or use Slack API
```

### User Slack IDs
User Slack member IDs are stored in `lab.User.slack`:

```matlab
% Example update
user_key.user_id = 'researcher1';
update(lab.User & user_key, 'slack', 'U12345678');
```

## Message Formatting

### Markdown Support
Slack blocks support markdown formatting:
- `*bold text*` - Bold
- `_italic text_` - Italic
- `` `code` `` - Inline code
- `` ```code block``` `` - Code block
- `<https://example.com|link text>` - Links

### User and Group Mentions

**Individual Users:**
- Format: `<@USER_ID>` (automatically handled)
- User IDs start with 'U' (e.g., 'U12345678')
- Stored in `lab.User.slack`
- To find: Click profile in Slack → "More" → "Copy member ID"

**User Groups:**
- Format: `<!subteam^GROUP_ID>` (automatically handled)
- Group IDs start with 'S' (e.g., 'S0A39NY71RQ')  
- Stored in `lab.SlackGroups` table
- The function auto-detects groups (S...) vs users (U...)

**Channel Mentions:**
- `<!channel>` - Notify all channel members
- `<!here>` - Notify active channel members
- `<!everyone>` - Notify entire workspace (use sparingly)

## Examples

### Schedule Insertion Success
```matlab
send_slack_notification_rich('rig_scheduling', ...
    'title', 'Schedule Updated for Tomorrow', ...
    'text', sprintf('Inserted %d entries successfully', count), ...
    'emoji', ':white_check_mark:');
```

### Schedule Insertion with Failures and Group Mention
```matlab
% Get devs group for mention
devs_group = fetch1(lab.SlackGroups & 'group_name="devs"', 'group_id');

sections{1}.title = sprintf('Entry %d - %s', i, subject);
sections{1}.text = sprintf('*Date*: %s\n*Error*: %s', date, error_msg);

send_slack_notification_rich('rig_scheduling', ...
    'title', 'Schedule Insertion Failures', ...
    'text', sprintf('Failed %d of %d entries', failed, total), ...
    'sections', sections, ...
    'mention_users', {devs_group}, ...
    'emoji', ':x:');
```

### Training Error with Tech Notification
```matlab
% Get on-duty technicians
tech_ids = get_on_duty_tech();

% Build context
context{1}.title = 'Session Info';
context{1}.text = sprintf('Subject: %s\nRig: %s', subject, rig);

% Build error info
error_info.message = error.message;
error_info.stack = error.stack;

% Send notification
send_slack_notification_rich('rig_training_error_notification', ...
    'title', 'Training Failed', ...
    'sections', context, ...
    'error_info', error_info, ...
    'mention_users', tech_ids, ...
    'emoji', ':rotating_light:');
```

## Migration from ViRMEn

If you have existing ViRMEn notification code, you can adapt it:

### ViRMEn Code
```matlab
% ViRMEn style
message.blocks = {title_block, divider, info_block};
message.text = 'Fallback text';
message_json = jsonencode(message);

query.webhook_name = 'rig_training_error_notification';
webhook = fetch1(lab.SlackWebhooks & query, 'webhook_url');
SendSlackNotificationJson(webhook, message_json);
```

### U19-pipeline-matlab Equivalent
```matlab
% U19-pipeline-matlab style
sections{1}.title = 'Info';
sections{1}.text = 'Information text';

send_slack_notification_rich('rig_training_error_notification', ...
    'title', 'Notification Title', ...
    'sections', sections);
```

## Troubleshooting

### Webhook Not Found
Ensure the webhook exists in `lab.SlackWebhooks`:
```matlab
fetch(lab.SlackWebhooks, '*')
```

### Group Not Found
Ensure the group exists in `lab.SlackGroups`:
```matlab
fetch(lab.SlackGroups, '*')
```

### Message Not Appearing
- Check webhook URL is valid
- Verify Slack workspace integration is enabled
- Check message size (Slack has limits ~40KB)

### Users/Groups Not Mentioned
- Verify Slack member/group IDs are correct
- Ensure users are in the channel where webhook posts
- Check `lab.User.slack` or `lab.SlackGroups` fields have correct IDs
- User IDs start with 'U', group IDs start with 'S'

## Best Practices

1. **Use appropriate webhooks** - Don't spam general channels with debug messages
2. **Limit sections** - Keep messages concise (max 5 sections for readability)
3. **Include context** - Always provide enough information to act on
4. **Test first** - Use a test channel when developing new notifications
5. **Handle errors** - All functions fail gracefully with warnings
6. **Rate limiting** - Don't send too many messages too quickly
7. **Group mentions** - Use for urgent issues requiring team attention

## See Also

- Slack Block Kit Builder: https://app.slack.com/block-kit-builder
- Slack API Documentation: https://api.slack.com/messaging/webhooks
- Markdown formatting: https://api.slack.com/reference/surfaces/formatting
