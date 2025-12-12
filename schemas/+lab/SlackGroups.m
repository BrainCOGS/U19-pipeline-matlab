%{
# Slack user groups for mentions in notifications
group_name                  : varchar(64)                   # Name of the Slack user group (e.g., 'devs', 'admins')
---
group_id                    : varchar(64)                   # Slack group ID for mentions (e.g., 'S12345678')
%}


classdef SlackGroups < dj.Lookup


end
