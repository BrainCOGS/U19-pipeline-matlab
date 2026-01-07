function populate_schedule_for_tomorrow()

    % This is the nightly update comand for the scheduler

    today = char(datetime('now','Format','yyyy-MM-dd') + caldays(0));
    query = struct;
    query.date = today;

    one_date = fetch(scheduler.Schedule & 'subject_fullname is not NULL'& query,'*');
    tomorrow = char(datetime('now','Format','yyyy-MM-dd') + caldays(1));
    [one_date(:).date] = deal(tomorrow);
    [one_date(:).level] = deal(0);
    [one_date(:).sublevel] = deal(0);


    connection = dj.conn();

    try

        connection.startTransaction;
        insert(scheduler.Schedule,one_date);
        connection.commitTransaction;

    catch e
        disp(e.message)
        connection.cancelTransaction;

        % Attempt to insert records one at a time
        fprintf('Bulk insert failed. Attempting individual inserts...\n');
        failed_entries = cell(1, length(one_date)); % Preallocate for efficiency
        failed_count = 0;

        connection.startTransaction;
        for i = 1:length(one_date)
            try
                insert(scheduler.Schedule, one_date(i));
                fprintf('Successfully inserted entry %d/%d\n', i, length(one_date));
            catch insert_error
                fprintf('Failed to insert entry %d/%d: %s\n', i, length(one_date), insert_error.message);
                % Store the failed entry information
                failed_count = failed_count + 1;
                failed_info = struct();
                failed_info.index = i;
                failed_info.subject_fullname = one_date(i).subject_fullname;
                failed_info.date = one_date(i).date;
                failed_info.error_message = insert_error.message;
                failed_entries{failed_count} = failed_info;
            end
        end
        connection.commitTransaction;

        % Trim unused preallocated cells
        failed_entries = failed_entries(1:failed_count);

        % Send Slack notification if there are failed entries
        if failed_count > 0
            % Build error message with rich formatting
            if ~isempty(one_date)
                target_date = one_date(1).date;
            else
                target_date = 'unknown';
            end

            % Build main message text
            main_text = sprintf('*Schedule insertion failures for %s*\n\n', target_date);
            main_text = [main_text sprintf('Total failed entries: *%d out of %d*', ...
                failed_count, length(one_date))];

            % Build detailed sections for each failure
            sections = {};
            for i = 1:min(failed_count, 5)  % Limit to 5 entries to avoid message size limits
                entry = failed_entries{i};
                section.title = sprintf('Entry %d - %s', entry.index, entry.subject_fullname);
                section.text = sprintf('*Date*: %s\n*Error*: %s', ...
                    entry.date, entry.error_message);
                sections{end+1} = section;
            end

            % Add note if there are more failures than displayed
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

            % Send rich notification to rig_scheduling channel
            send_slack_notification_rich('christian_tabedzki', ...
                'title', 'Schedule Insertion Failures', ...
                'text', main_text, ...
                'sections', sections, ...
                'mention_users', mention_users, ...
                'emoji', ':x:');
        else
            fprintf('All entries inserted successfully after individual retry.\n');
        end
    end

end