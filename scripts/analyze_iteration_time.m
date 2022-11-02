

close all
key = struct('subject_fullname', 'jjulian_jk008', 'session_location', '185A-Rig1');
key2 = fetch(acquisition.Session & key,'subject_fullname', 'session_date');


session_data = fetch(behavior.SpatialTimeBlobs & key2,'*');


trials_session = zeros(1,length(session_data));
legend_data = cell(length(session_data),1);
for sess_num=1:length(session_data)

    block_trial_unique = unique(session_data(sess_num).iteration_matrix(:,1:2),'rows');
    trials_session(sess_num) = size(block_trial_unique,1); 
    
    for j=1:trials_session(sess_num)
        idx_trial = all((session_data(sess_num).iteration_matrix(:,1:2) == block_trial_unique(j,:))');
        frame_rate_trial = 1./diff(session_data(sess_num).trial_time(idx_trial));
        mean_frame_rate(j,sess_num) = mean(frame_rate_trial);
        std_frame_rate(j,sess_num) = std(frame_rate_trial);
        
        
    end
    legend_data{sess_num} = [key2(sess_num).subject_fullname, '----', key2(sess_num).session_date];
end
for sess_num=1:length(session_data)
   mean_frame_rate(trials_session(sess_num)-1:end, sess_num) = NaN;
    
end

set(gcf,'color','w');

plot(mean_frame_rate)
xlabel('Trial #', 'FontSize', 16)
ylabel('Mean frame rate (hz)', 'FontSize', 16)
ylim([0,140])

legend(legend_data, 'FontSize', 14, 'Location','southwest','Interpreter','none')
set(gca,'FontSize',16);


