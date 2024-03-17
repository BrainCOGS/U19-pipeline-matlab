 
function plot_velocity_session(key)
% plot_velocity_session Plots mean velocity for all trials in sessions from key
% Inputs
% key = Session key
 
% Get all needed data
key = fetch(acquisition.Session & key);
trials = struct2table(get_full_trial_data(key));
 
if ~isempty(trials)
    sess = acquisition.Session();
    primary_key = sess.primaryKey;
    % Construct a "superkey" from composite keys
    trials.super_key = get_superkey_from_table_data(trials, primary_key);
    
    
    mean_vel = zeros(1, height(trials));
    mean_fr = zeros(1, height(trials));
    std_vel = zeros(1, height(trials));
    for i = 1:height(trials)
        %Calculate velocity from position from start to arm_entry
        i_arm_entry = trials{i,'i_arm_entry'};
        position = trials{i,'position'}{:};
        time = trials{i,'trial_time'}{:};
        diff_pos = diff(position(1:i_arm_entry,2));
        diff_time = diff(time(1:i_arm_entry));
        calc_vel = diff_pos ./ diff_time;
        calc_fr = 1 ./ diff_time;
        mean_fr(i) = mean(calc_fr);
        mean_vel(i) = mean(calc_vel);
        std_vel(i) = 0;
    end
    
    % Identify sessions and build xticklabels
    subjects = string(unique(trials.subject_fullname))';
    sessions = unique(trials.super_key);
    if length(subjects) == 1
        sub_length = length(subjects{1});
        cell_sessions = cellstr(nominal(sessions))
        sessions_label = cellfun(@(x) x(sub_length+3:end), cell_sessions, 'Un', 0);
    else
        sessions_label = sessions;
    end
    
    mean_mean_vel = zeros(1, length(sessions));
    min_mean_vel = zeros(1, length(sessions));
    max_mean_vel = zeros(1, length(sessions));
    std_mean_vel = zeros(1, length(sessions));
    
    mean_mean_fr = zeros(1, length(sessions));
    min_mean_fr = zeros(1, length(sessions));
    max_mean_fr = zeros(1, length(sessions));
    std_mean_fr = zeros(1, length(sessions));
    
    %Calculate mean, min, max & std velocity for each session
    for j = 1:length(sessions)
        current_session = sessions(j);
        idx = trials.super_key == current_session;
        mean_mean_vel(j) =  mean(mean_vel(idx));
        std_mean_vel(j) =  std(mean_vel(idx));
        min_mean_vel(j)  =  min(mean_vel(idx));
        max_mean_vel(j)  =  min(mean_vel(idx));
        
        mean_mean_fr(j) =  mean(mean_fr(idx));
        std_mean_fr(j) =  std(mean_fr(idx));
        min_mean_fr(j)  =  min(mean_fr(idx));
        max_mean_fr(j)  =  min(mean_fr(idx));
        
    end
    
    %Plot results
    close all
    f = figure;
    set(f, 'Units', 'normalized', 'Position', [0.05 0.05 0.85 0.85])
    
    
    plot(1:length(sessions),mean_mean_vel, 'o', 'MarkerFaceColor', 'r', 'MarkerSize',10)
    hold on
    errorbar(1:length(sessions), mean_mean_vel, [], max_mean_vel-mean_mean_vel,'linewidth',2);
    set(gcf, 'color', 'w')
    
    ylabel('mean velocity per trial (cm/s) min-max range', 'Fontsize', 14)
    xlabel('Date', 'Fontsize', 14)
    title(char(['Velocity for: ', string(unique(trials.subject_fullname))']), 'FontSize', 16, 'Interpreter', 'none')
    
    xticks(1:length(sessions_label))
    set(gca,'TickLabelInterpreter','none');
    set(gca,'FontSize',14);
    xticklabels(sessions_label)
    xtickangle(45)
    
    f2 = figure;
    set(f2, 'Units', 'normalized', 'Position', [0.05 0.05 0.85 0.85])
    
    
    plot(1:length(sessions),mean_mean_fr, 'o', 'MarkerFaceColor', 'r', 'MarkerSize',10)
    hold on
    errorbar(1:length(sessions), mean_mean_fr, [], max_mean_fr-mean_mean_fr,'linewidth',2);
    set(gcf, 'color', 'w')
    
    ylabel('mean frame rate per trial (1/s) min-max range', 'Fontsize', 14)
    xlabel('Date', 'Fontsize', 14)
    title(char(['Frame Rate for: ', string(unique(trials.subject_fullname))']), 'FontSize', 16, 'Interpreter', 'none')
    
    xticks(1:length(sessions_label))
    set(gca,'TickLabelInterpreter','none');
    set(gca,'FontSize',14);
    xticklabels(sessions_label)
    xtickangle(45)
    
    
end
 
end

