function analyze_iteration_time(key)
% analyze_iteration_time, plots framerate by trial of all sessions defined by key
% Input
% key = key that comprises 1 or multiple behavior sessions

%Get all sessions corresponsing to key and spatial time info
key = fetch(acquisition.Session & key);
session_data = fetch(behavior.SpatialTimeBlobs & key,'*');


trials_session = zeros(1,length(session_data));
legend_data = cell(length(session_data),1);
mean_frame_rate = nan(1000, length(session_data));
for sess_num=1:length(session_data)
    session_data(sess_num)

    %Get unique blocks from current session
    block_trial_unique = unique(session_data(sess_num).iteration_matrix(:,1:2),'rows');
    %Get # of trials from current block
    trials_session(sess_num) = size(block_trial_unique,1); 
    
    % For all trials get mean frame rate
    for j=1:trials_session(sess_num)
        idx_trial = all((session_data(sess_num).iteration_matrix(:,1:2) == block_trial_unique(j,:))');
        frame_rate_trial = 1./diff(session_data(sess_num).trial_time(idx_trial));
        mean_frame_rate(j,sess_num) = mean(frame_rate_trial);
              
    end
    %Build legend
    legend_data{sess_num} = [key(sess_num).subject_fullname, '--', key(sess_num).session_date,  '_', num2str(key(sess_num).session_number)];
end
%Crop mean_frame_rate to max trials of all sessions
max_trials_session = max(trials_session);
mean_frame_rate = mean_frame_rate(1:max_trials_session, :);

%Plot results
set(gcf,'color','w');
plot(mean_frame_rate)
xlabel('Trial #', 'FontSize', 16)
ylabel('Mean frame rate (hz)', 'FontSize', 16)
ylim([0,140])

legend(legend_data, 'FontSize', 14, 'Location','northeastoutside','Interpreter','none')
set(gca,'FontSize',16);


