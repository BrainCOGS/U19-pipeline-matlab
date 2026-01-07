function tech_slack_ids = get_on_duty_tech()
% GET_ON_DUTY_TECH Get slack member IDs of technicians currently on duty
%
% Returns:
%   tech_slack_ids: Cell array of slack member IDs for on-duty technicians
%
% Example:
%   techs = get_on_duty_tech();
%   send_slack_notification_rich('alerts', 'title', 'Issue', 'mention_users', techs);

    tech_slack_ids = {};

    try
        % Get current date and time
        current_date = char(datetime('now', 'Format', 'yyyy-MM-dd'));
        current_time = datetime('now');

        % Query for technicians on duty today
        schedule_query = sprintf('date = "%s"', current_date);
        tech_schedule = fetch(scheduler.TechSchedule & schedule_query, '*');

        if isempty(tech_schedule)
            warning('No technicians found on duty for %s', current_date);
            return;
        end

        % Filter by current time if start_time and end_time are available
        for i = 1:length(tech_schedule)
            entry = tech_schedule(i);

            % Check if technician is on duty now
            is_on_duty = true;
            if isfield(entry, 'start_time') && isfield(entry, 'end_time')
                try
                    start_time = datetime(entry.start_time);
                    end_time = datetime(entry.end_time);
                    is_on_duty = current_time >= start_time && current_time <= end_time;
                catch
                    % If time parsing fails, include them anyway
                    is_on_duty = true;
                end
            end

            if is_on_duty && isfield(entry, 'tech_id')
                % Fetch user's slack ID
                try
                    user_query.user_id = entry.tech_id;
                    user_info = fetch(lab.User & user_query, 'slack');
                    if ~isempty(user_info) && ~isempty(user_info.slack)
                        % Only add if not already in list
                        if ~ismember(user_info.slack, tech_slack_ids)
                            tech_slack_ids{end+1} = user_info.slack;
                        end
                    end
                catch
                    % Skip if user not found
                    continue;
                end
            end
        end

    catch e
        warning('GetOnDutyTech:Error', 'Error getting on-duty technicians: %s', e.message);
    end
end
