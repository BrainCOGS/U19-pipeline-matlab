function populate_schedule_for_tomorrow()

    % This is the nightly update command for the scheduler
    %
    % Only legacy rows (rule_id IS NULL) are copied forward. Rows with a rule_id
    % are generated from scheduler.ScheduleRule by U19-pipeline-python's
    % materialize_schedule job, which must run after this script. Before the
    % ScheduleRule migration Schedule has no rule_id column and every row is legacy.

    today = datetime('now','Format','yyyy-MM-dd');
    today_str = char(today);
    query = struct;
    query.date = today_str;

    legacy_cond = legacy_schedule_condition();
    one_date = fetch(scheduler.Schedule & legacy_cond & query,'*');
    tomorrow = char(today + caldays(1));

    % Today has sessions, all of them rule-generated: nothing to copy, and today is
    % not "empty", so the look-back below must not run.
    if isempty(one_date) && count(scheduler.Schedule & 'subject_fullname IS NOT NULL' & query) > 0
        fprintf('All of today''s sessions come from schedule rules; nothing to copy.\n');
        return;
    end

    % If today's schedule is empty, look back up to 5 days for a non-empty source
    if isempty(one_date)
        found = false;
        for k = 1:5
            candidate_date = today - caldays(k);
            candidate_str = char(candidate_date);
            try
                candidate_entries = fetch(scheduler.Schedule & sprintf('date="%s"', candidate_str) & legacy_cond, '*');
                n_entries = numel(candidate_entries);
            catch
                n_entries = 0;
            end

            if n_entries > 0
                % First try to populate today from candidate
                candidate_entries = strip_rule_id(candidate_entries);
                [candidate_entries(:).date] = deal(today_str);
                candidate_entries = drop_occupied_slots(candidate_entries, today_str);
                [fcount, ~] = attempt_insert_schedule(candidate_entries);

                if fcount == 0
                    % If successful, fetch today's entries to use as source for tomorrow
                    one_date = fetch(scheduler.Schedule & sprintf('date="%s"', today_str) & legacy_cond, '*');
                else
                    % Notify Slack that insertion into today failed and fall back
                    try
                        err_msg = sprintf('Failed to populate today (%s) from %s: %d failures', today_str, candidate_str, fcount);
                        send_slack_notification('rig_scheduling', err_msg);
                    catch ME
                        warning('populate_schedule_for_tomorrow:SlackError', 'Failed sending Slack notification: %s', ME.message);
                    end
                    % Use candidate entries directly for tomorrow
                    [candidate_entries(:).date] = deal(tomorrow);
                    one_date = candidate_entries;
                end

                % Notify about re-population (regardless of whether we fell back)
                try
                    msg = sprintf('Today (%s) was empty — re-populated from %s (%d entries).', today_str, candidate_str, n_entries);
                    send_slack_notification('rig_scheduling', msg);
                catch ME
                    warning('populate_schedule_for_tomorrow:SlackError', 'Failed sending Slack notification: %s', ME.message);
                end

                found = true;
                break;
            end
        end

        if ~found
            try
                msg = sprintf('No schedule entries found for today (%s) nor in previous five days — nothing to insert for %s.', today_str, tomorrow);
                send_slack_notification('rig_scheduling', msg);
            catch ME
                warning('populate_schedule_for_tomorrow:SlackError', 'Failed sending Slack notification: %s', ME.message);
            end
            return;
        end
    end

    % Prepare entries for tomorrow
    one_date = strip_rule_id(one_date);
    [one_date(:).date] = deal(tomorrow);
    [one_date(:).level] = deal(0);
    [one_date(:).sublevel] = deal(0);

    % A slot already filled for tomorrow (booked in the web app, or generated
    % from a schedule rule) wins over the copy.
    one_date = drop_occupied_slots(one_date, tomorrow);
    if isempty(one_date)
        fprintf('Every slot for %s is already filled; nothing to copy.\n', tomorrow);
        return;
    end

    % Insert using helper which will perform bulk then individual inserts
    [failed_count, failed_entries] = attempt_insert_schedule(one_date);

    if failed_count > 0
        % Build error message with rich formatting
        if ~isempty(one_date)
            target_date = one_date(1).date;
        else
            target_date = 'unknown';
        end

        % Build main message text
        main_text = sprintf('*Schedule insertion failures for %s*\n\n', target_date);
        main_text = [main_text sprintf('Total failed entries: *%d out of %d*', failed_count, length(one_date))];

        % Build detailed sections for each failure
        sections = {};
        for i = 1:min(failed_count, 5)
            entry = failed_entries{i};
            section.title = sprintf('Entry %d - %s', entry.index, entry.subject_fullname);
            section.text = sprintf('*Date*: %s\n*Error*: %s', entry.date, entry.error_message);
            sections{end+1} = section;
        end

        if failed_count > 5
            note_section.title = '';
            note_section.text = sprintf('_... and %d more failures not shown_', failed_count - 5);
            sections{end+1} = note_section;
        end

        % Get devs group for mentions
        mention_users = {};
        try
            devs_group = fetch1(lab.SlackGroups & 'group_name="devs"', 'group_id');
            mention_users{1} = devs_group;
        catch
            % If devs group not found, continue without mentions
        end

        send_slack_notification_rich('dev_notifications', ...
            'title', 'Schedule Insertion Failures', ...
            'text', main_text, ...
            'sections', sections, ...
            'mention_users', mention_users, ...
            'emoji', ':x:');
    else
        fprintf('All entries inserted successfully.\n');
    end

end


function [failed_count, failed_entries] = attempt_insert_schedule(entries)
    % Attempt a bulk insert into scheduler.Schedule; on failure try per-entry inserts.
    failed_count = 0;
    failed_entries = {};
    if isempty(entries)
        return;
    end

    conn = dj.conn();
    try
        conn.startTransaction;
        insert(scheduler.Schedule, entries);
        conn.commitTransaction;
        return;
    catch
        try
            conn.cancelTransaction;
        catch
        end
    end

    % Bulk failed — try individual inserts
    try
        conn.startTransaction;
        N = length(entries);
        failures = cell(1, N);
        fc = 0;
        for ii = 1:N
            try
                insert(scheduler.Schedule, entries(ii));
            catch insert_error
                fc = fc + 1;
                fi.index = ii;
                if isfield(entries(ii), 'subject_fullname')
                    fi.subject_fullname = entries(ii).subject_fullname;
                else
                    fi.subject_fullname = '';
                end
                if isfield(entries(ii), 'date')
                    fi.date = entries(ii).date;
                else
                    fi.date = '';
                end
                fi.error_message = insert_error.message;
                failures{fc} = fi;
            end
        end
        conn.commitTransaction;
        failed_count = fc;
        failed_entries = failures(1:fc);
    catch e2
        try
            conn.cancelTransaction;
        catch
        end
        warning('attempt_insert_schedule:TransactionError', 'Failed during individual inserts: %s', e2.message);
        failed_count = length(entries);
        failed_entries = cell(1, failed_count);
        for ii = 1:failed_count
            fi.index = ii; fi.subject_fullname = ''; fi.date = entries(min(ii,end)).date; fi.error_message = 'Transaction failure';
            failed_entries{ii} = fi;
        end
    end
end


function cond = legacy_schedule_condition()
    % Rows the copy-forward owns: a subject, and no rule_id (when the column exists).
    cond = 'subject_fullname IS NOT NULL';
    if schedule_has_rule_id()
        cond = [cond ' AND rule_id IS NULL'];
    end
end


function tf = schedule_has_rule_id()
    % Copying rule rows would be the costly mistake, so if the cheap header check
    % fails, ask the database directly rather than assuming the column is absent.
    try
        tf = ismember('rule_id', scheduler.Schedule().header.names);
    catch
        res = dj.conn().query(sprintf(['SELECT COUNT(*) AS n FROM information_schema.columns ' ...
            'WHERE table_schema="%s" AND table_name="schedule" AND column_name="rule_id"'], ...
            scheduler.getSchema().dbname));
        tf = res.n > 0;
    end
end


function entries = strip_rule_id(entries)
    % Copies are legacy rows: leave rule_id to default to NULL.
    if isfield(entries, 'rule_id')
        entries = rmfield(entries, 'rule_id');
    end
end


function entries = drop_occupied_slots(entries, target_date)
    % Remove entries whose (location, timeslot) already has a row on target_date.
    if isempty(entries)
        return;
    end
    occupied = fetch(scheduler.Schedule & sprintf('date="%s"', target_date));  % primary keys only
    if isempty(occupied)
        return;
    end
    occupied_keys = arrayfun(@(o) sprintf('%s|%d', o.location, o.timeslot), occupied, 'UniformOutput', false);
    entry_keys = arrayfun(@(e) sprintf('%s|%d', e.location, e.timeslot), entries, 'UniformOutput', false);
    entries = entries(~ismember(entry_keys, occupied_keys));
end
