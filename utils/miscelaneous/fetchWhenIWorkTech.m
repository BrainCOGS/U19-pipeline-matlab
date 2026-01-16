function tech = fetchWhenIWorkTech(date_to_check)
% fetchWhenIWorkTech - Fetch technician on duty from WhenIWork iCal feed
%
% Usage: tech = fetchWhenIWorkTech(date_to_check)
%
% Inputs:
%   date_to_check - Date to check for technician schedule (MATLAB date number or datetime)
%                   If not provided, uses today's date
%
% Outputs:
%   tech - Structure containing technician information with fields:
%          .Name - Full name of technician
%          .Duties - Description of duties (e.g., 'VR Train', 'Regular VR')
%          .ID - User ID (empty by default, can be populated from lab.User)
%
% Example:
%   tech = fetchWhenIWorkTech(datetime('today'))
%   tech = fetchWhenIWorkTech()  % Uses today's date

if nargin < 1
    date_to_check = datetime('today');
else
    % Convert to datetime if it's a date number
    if isnumeric(date_to_check)
        date_to_check = datetime(date_to_check, 'ConvertFrom', 'datenum');
    end
end

% Get the WhenIWork URL from lab.SlackWebhooks
try
    wheniwork_config = fetch(lab.SlackWebhooks & 'webhook_name="wheniwork_ical_url"', 'webhook_url');
    if isempty(wheniwork_config)
        error('fetchWhenIWorkTech:NoConfig', 'WhenIWork iCal URL not configured in lab.SlackWebhooks');
    end
    wheniwork_url = wheniwork_config.webhook_url;
catch ME
    warning('fetchWhenIWorkTech:ConfigError', 'Could not fetch WhenIWork URL from database: %s', ME.message);
    % Fallback: You could hardcode the URL here as a last resort, but it's not recommended
    tech = struct('Name', 'Unknown', 'Duties', '', 'ID', '');
    return;
end

% Fetch the iCal data
try
    ical_data = webread(wheniwork_url);
catch ME
    warning('fetchWhenIWorkTech:FetchError', 'Could not fetch iCal data: %s', ME.message);
    tech = struct('Name', 'Unknown', 'Duties', '', 'ID', '');
    return;
end

% Parse the iCal data
events = parseICalEvents(ical_data);

% Filter events for the specified date
% Remove timezone for date comparison
target_date = dateshift(date_to_check, 'start', 'day');
target_year = year(target_date);
target_month = month(target_date);
target_day = day(target_date);

matching_events = {};
for i = 1:length(events)
    event = events{i};
    % Compare year, month, and day components
    if year(event.start) == target_year && ...
       month(event.start) == target_month && ...
       day(event.start) == target_day
        matching_events{end+1} = event; %#ok<AGROW>
    end
end

% Return the first matching technician
if ~isempty(matching_events)
    event = matching_events{1};
    tech = struct(...
        'Name', event.personnel, ...
        'Duties', event.duties, ...
        'ID', '' ...  % Will be populated later by matching to lab.User
    );
    
    % Try to match the name to a user ID
    try
        user_query = lab.User & sprintf('full_name = "%s"', event.personnel);
        user_data = fetch(user_query, 'user_id', 'LIMIT 1');
        if ~isempty(user_data)
            tech.ID = user_data.user_id;
        end
    catch
        % Ignore errors in user lookup
    end
else
    % No technician found for this date
    tech = struct('Name', 'No tech scheduled', 'Duties', '', 'ID', '');
end

end


function events = parseICalEvents(ical_text)
% parseICalEvents - Parse iCal text format and extract VR-related events
%
% This function parses iCalendar format text and extracts events related to
% VR duties (training, watering, etc.)

events = {};

% Split into lines
lines = strsplit(ical_text, '\n');

% VR event patterns and their classifications
vr_patterns = {
    'as\s*vr\s*water\s*at',  'VR Water', 'VR Watering only';
    'as\s*vr\s*train\s*at',  'VR Train', 'VR Onboarding';
    'as\s*vr\s*at',          'Regular VR', 'All VR Duties';
    'as\s*vr.*brody.*at',    'VR Brody Mice', 'VR with Brody (Mice)';
    'as\s*lab.*clean.*up',   'Lab Cleanup', 'Lab Cleanup'
};

% Parse events
in_event = false;
current_event = struct();

for i = 1:length(lines)
    line = strtrim(lines{i});
    
    % Start of event
    if startsWith(line, 'BEGIN:VEVENT')
        in_event = true;
        current_event = struct('summary', '', 'start', '', 'end', '', 'uid', '');
        continue;
    end
    
    % End of event
    if startsWith(line, 'END:VEVENT')
        in_event = false;
        
        % Process the event if it matches VR patterns
        if ~isempty(current_event.summary)
            summary_lower = lower(current_event.summary);
            
            for j = 1:size(vr_patterns, 1)
                pattern = vr_patterns{j, 1};
                event_type = vr_patterns{j, 2};
                duties = vr_patterns{j, 3};
                
                if ~isempty(regexp(summary_lower, pattern, 'once'))
                    % Extract person name (before the first parenthesis)
                    person = strtrim(regexp(current_event.summary, '^[^(]+', 'match', 'once'));
                    
                    % Parse datetime
                    try
                        start_dt = parseICalDateTime(current_event.start);
                        end_dt = parseICalDateTime(current_event.end);
                    catch
                        continue;  % Skip if datetime parsing fails
                    end
                    
                    % Add to events
                    events{end+1} = struct(... %#ok<AGROW>
                        'start', start_dt, ...
                        'end', end_dt, ...
                        'personnel', person, ...
                        'duties', duties, ...
                        'type', event_type, ...
                        'uid', current_event.uid ...
                    );
                    break;  % Only match the first pattern
                end
            end
        end
        continue;
    end
    
    % Parse event properties
    if in_event
        if startsWith(line, 'SUMMARY:')
            current_event.summary = strtrim(line(9:end));
        elseif startsWith(line, 'DTSTART')
            % Extract datetime value (after the colon)
            colon_idx = strfind(line, ':');
            if ~isempty(colon_idx)
                current_event.start = strtrim(line(colon_idx(1)+1:end));
            end
        elseif startsWith(line, 'DTEND')
            colon_idx = strfind(line, ':');
            if ~isempty(colon_idx)
                current_event.end = strtrim(line(colon_idx(1)+1:end));
            end
        elseif startsWith(line, 'UID:')
            current_event.uid = strtrim(line(5:end));
        end
    end
end

end


function dt = parseICalDateTime(ical_datetime)
% parseICalDateTime - Parse iCalendar datetime format to MATLAB datetime
%
% iCal format: 20250116T140000Z (YYYYMMDDTHHmmssZ)

% Remove any timezone info or property parameters
ical_datetime = strtrim(ical_datetime);

% Check for TZID or other parameters (e.g., "TZID=America/New_York:20250116T140000")
if contains(ical_datetime, ':')
    parts = strsplit(ical_datetime, ':');
    ical_datetime = parts{end};
end

% Remove 'T' and 'Z' to get just the numbers
datetime_str = strrep(strrep(ical_datetime, 'T', ''), 'Z', '');

% Parse: YYYYMMDDHHmmss
if length(datetime_str) >= 14
    year = str2double(datetime_str(1:4));
    month = str2double(datetime_str(5:6));
    day = str2double(datetime_str(7:8));
    hour = str2double(datetime_str(9:10));
    minute = str2double(datetime_str(11:12));
    second = str2double(datetime_str(13:14));
    
    dt = datetime(year, month, day, hour, minute, second, 'TimeZone', 'UTC');
else
    error('parseICalDateTime:InvalidFormat', 'Invalid iCal datetime format: %s', ical_datetime);
end

end
