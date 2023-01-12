
function plot_velocity_session(key)
% plot_velocity_session Plots mean velocity for all trials in sessions from key
% Inputs
% key = Session key

% Get all needed data
trials = struct2table(get_full_trial_data(key));

if ~isempty(trials)
    sess = acquisition.Session();
    primary_key = sess.primaryKey;
    % Construct a "superkey" from composite keys
    trials.super_key = get_superkey_from_table_data(trials, primary_key);
    
    
    mean_vel = zeros(1, height(trials));
    std_vel = zeros(1, height(trials));
    for i = 1:height(trials)
        %Calculate velocity from position from start to arm_entry
        i_arm_entry = trials{i,'i_arm_entry'};
        position = trials{i,'position'}{:};
        calc_vel = diff(position(2:i_arm_entry,2))*120;
        mean_vel(i) = mean(calc_vel);
        std_vel(i) = 0;
    end
    
     
    sessions = unique(trials.super_key);
    
    mean_mean_vel = zeros(1, length(sessions));
    min_mean_vel = zeros(1, length(sessions));
    max_mean_vel = zeros(1, length(sessions));
    std_mean_vel = zeros(1, length(sessions));
    %Calculate mean, min, max & std velocity for each session
    for j = 1:length(sessions)
        current_session = sessions(j);
        idx = trials.super_key == current_session;
        mean_mean_vel(j) =  mean(mean_vel(idx));
        std_mean_vel(j) =  std(mean_vel(idx));
        min_mean_vel(j)  =  min(mean_vel(idx));
        max_mean_vel(j)  =  min(mean_vel(idx));
        
    end
    
    %Plot results
    close all
    f = figure;
    set(f, 'Units', 'normalized', 'Position', [0 0 1 1])
    
    
    plot(1:length(sessions),mean_mean_vel, 'o', 'MarkerFaceColor', 'r', 'MarkerSize',10)
    hold on
    errorbar(1:length(sessions), mean_mean_vel, mean_mean_vel-min_mean_vel, max_mean_vel-mean_mean_vel,'linewidth',2);
    set(gcf, 'color', 'w')
    
    ylabel('mean velocity per trial (cm/s) min-max range', 'Fontsize', 14)
    xlabel('Date', 'Fontsize', 14)
    title(['Velocity for: ', string(unique(trials.subject_fullname))], 'FontSize', 16, 'Interpreter', 'none')
    
    xticks(1:length(sessions))
    set(gca,'TickLabelInterpreter','none');
    set(gca,'FontSize',14);
    xticklabels(sessions)
    xtickangle(45)
    
    
end

end
