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
    end

end