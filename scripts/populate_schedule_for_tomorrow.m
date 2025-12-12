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
        failed_entries = {};
        
        for i = 1:length(one_date)
            try
                connection.startTransaction;
                insert(scheduler.Schedule, one_date(i));
                connection.commitTransaction;
                fprintf('Successfully inserted entry %d/%d\n', i, length(one_date));
            catch insert_error
                connection.cancelTransaction;
                fprintf('Failed to insert entry %d/%d: %s\n', i, length(one_date), insert_error.message);
                % Store the failed entry information
                failed_info = struct();
                failed_info.index = i;
                failed_info.subject_fullname = one_date(i).subject_fullname;
                failed_info.date = one_date(i).date;
                failed_info.error_message = insert_error.message;
                failed_entries{end+1} = failed_info;
            end
        end
        
        % Send Slack notification if there are failed entries
        if ~isempty(failed_entries)
            message = sprintf('Schedule insertion failures for %s:\n', tomorrow);
            for i = 1:length(failed_entries)
                entry = failed_entries{i};
                message = sprintf('%s- Entry %d: Subject %s, Date %s\n  Error: %s\n', ...
                    message, entry.index, entry.subject_fullname, entry.date, entry.error_message);
            end
            message = sprintf('%sTotal failed entries: %d out of %d', ...
                message, length(failed_entries), length(one_date));
            
            % Send notification to rig_scheduling channel
            scheduler.utils.send_slack_notification('rig_scheduling', message);
        else
            fprintf('All entries inserted successfully after individual retry.\n');
        end
    end

end