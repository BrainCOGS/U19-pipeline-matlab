function populate_technician_schedule
    % Updating the tech schedule based off the last full week of this month
    
    today = datetime('now','Format','yyyy-MM-dd');
    eom = dateshift(today,'end','month');
    next_month = today + calmonths(1);
    
    check_if_next_month_exists = sprintf('date >= "%s"', next_month);
    
    if ~isempty(fetch(scheduler.TechSchedule & check_if_next_month_exists))
        return;
    end
    
    
    
    reference_point = eom - caldays(13);
    temp1 = dateshift(reference_point,'dayofweek','Saturday');
    Sunday = dateshift(temp1,'dayofweek','Sunday');
    Saturday = dateshift(Sunday,'dayofweek','Saturday');
    
    condition1 = sprintf('date >= "%s"', Sunday);
    condition2 = sprintf('date <= "%s"', Saturday);
    
    days_of_week = fetch(scheduler.TechSchedule & condition1 & condition2,'*');
    
    
    temp_calendar = repmat(days_of_week,8,1);
    
    
    
    shifted_dates = Sunday + caldays(0:length(temp_calendar)-1);
    
    
    next_month_start = dateshift(next_month,'start','month');
    next_month_end = dateshift(next_month,'end','month');
    
    needed_dates = shifted_dates >= next_month_start & shifted_dates <= next_month_end;
    
    temp_calendar = temp_calendar(needed_dates);
    subset_shifted = shifted_dates(needed_dates);
    
    days_next_month = nnz(calendar(next_month));
    for i = 1:days_next_month 
    
        temp_calendar(i).date = char(datetime(subset_shifted(i),'Format','yyyy-MM-dd'));
    
    end


    connection = dj.conn();
    
    try 
    
        connection.startTransaction;
        insert(scheduler.TechSchedule,temp_calendar);    
        connection.commitTransaction;
    
    catch e
        disp(e.message)
        connection.cancelTransaction;
    end