function  get_write_time_live_stats()




query = 'select distinct subject_fullname, session_date, session_number from u19_acquisition.live_session_stats';

curr_conn = dj.conn();
sessions_write_live_stats = curr_conn.query(query);

sessions_write_live_stats = dj.struct.fromFields(sessions_write_live_stats);

beh_files = struct2table(get_behaviorfile_as_db(sessions_write_live_stats),'AsArray',true);

close all;
beh_files.timeWriteLiveStats = beh_files.timeWriteLiveStats*1000;
histogram(beh_files.timeWriteLiveStats);
set(gcf, 'Color', [1 1 1]);
set(gca, 'FontSize',16)
title('Histogram of times to write LiveStats to DB');
xlabel('Time (ms)', 'FontSize',18);
ylabel('# Trials', 'FontSize',18);

text(max(beh_files.timeWriteLiveStats)-20,100,['Max time' newline num2str(max(beh_files.timeWriteLiveStats)) ' ms']);


end

