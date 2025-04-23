function duty_tech_slack = get_on_duty_tech()

duty_tech_slack = {};
tech_schedule_query.date =  char(datetime('now','Format','yyyy-MM-dd'));
tech_today = fetch(scheduler.TechSchedule * lab.User & tech_schedule_query,'slack');

if ~isempty(tech_today)
    duty_tech_slack = {tech_today.slack};
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