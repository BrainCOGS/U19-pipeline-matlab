function duty_tech_slack = get_on_duty_tech()

duty_tech_slack = {};

% Fetch technician info from WhenIWork iCal feed
tech_info = fetchWhenIWorkTech(datetime('today'));

% If a technician was found and has an ID, get their slack handle
if ~isempty(tech_info) && isfield(tech_info, 'ID') && ~isempty(tech_info.ID)
    try
        user_data = fetch(lab.User & sprintf('user_id = "%s"', tech_info.ID), 'slack');
        if ~isempty(user_data)
            duty_tech_slack = {user_data.slack};
        end
    catch ME
        warning('get_on_duty_tech:SlackLookupError', 'Could not fetch slack info: %s', ME.message);
    end
elseif ~isempty(tech_info) && isfield(tech_info, 'Name')
    % Try to lookup by full name if ID not available
    try
        user_data = fetch(lab.User & sprintf('full_name = "%s"', tech_info.Name), 'slack');
        if ~isempty(user_data)
            duty_tech_slack = {user_data.slack};
        end
    catch ME
        warning('get_on_duty_tech:SlackLookupError', 'Could not fetch slack info: %s', ME.message);
    end
end

% def fetch_tech_today() -> list[dict]:
%     tech_today = (scheduler.TechSchedule * lab.User & f"date = '{date.today().isoformat()}'").fetch(
%         "date", "user_id", "tech_duties", "full_name", "start_time", "end_time", as_dict=True
%     )
%     for tech in tech_today:
%         tech["start_time"] = tech["start_time"].astimezone(ZoneInfo("America/New_York"))
%         tech["end_time"] = tech["end_time"].astimezone(ZoneInfo("America/New_York"))
%     return tech_today
% 
% 
% def determine_on_duty() -> str | None:
%     tech_today = fetch_tech_today()
%     now = datetime.now(tz=ZoneInfo("America/New_York"))
%     for tech in tech_today:
%         if tech["start_time"] < now and now < tech["end_time"]:
%             return tech