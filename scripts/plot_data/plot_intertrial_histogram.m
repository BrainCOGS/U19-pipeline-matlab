
function plot_intertrial_histogram(key)
% plot_velocity_session Plots mean velocity for all trials in sessions from key
% Inputs
% key = Session key

% Get all needed data
key = fetch((acquisition.Session * proj(acquisition.SessionStarted, 'local_path_behavior_file')) & key);
trials = struct2table(get_full_trial_data(key));

%trials.idx_iter_intertrial = repmat(NaN, height(trials),1);
%trials.time_intertrial = repmat(NaN, height(trials),1);


trials = convertvars(trials,["session_date"],"categorical");


if ~isempty(trials)

    trials.idx_end_trial = cellfun(@(x) size(x,1),[trials.position]);
    trials.time_intertrial = cellfun(@(x,y,z) double(z(x)) - double(z(y)),...
        num2cell([trials.idx_end_trial]), num2cell([trials.iterations]), [trials.trial_time]);

    trials.time_iterations = cellfun(@(x) length(x), [trials.trial_time]);
    trials.time_less_length_iterations =  trials.iterations > trials.time_iterations;

    trials.time_bef_intertrial = cellfun(@(x,y) double(y(x)),...
        num2cell([trials.iterations]), [trials.trial_time]);

    trials.correct_trial = cellfun(@(x,y) equals_cells(x,y),...
        [trials.trial_type], [trials.choice]);



    figure('units','normalized','outerposition',[0 0 1 1])
    set(gcf, 'color', 'w')
    plot(trials{trials.correct_trial ==1, 'time_bef_intertrial'}, trials{trials.correct_trial ==1, 'time_intertrial'},'o', ...
        'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor',[0,0,0], 'MarkerSize',8)
    hold on;
    plot(trials{trials.correct_trial ==0, 'time_bef_intertrial'}, trials{trials.correct_trial ==0, 'time_intertrial'},'o', ...
        'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor',[0,0,0], 'MarkerSize',8)

    set(gca, 'FontSize', 14);
    xlabel('Time bef intertrial');
    ylabel('Time intertrial');
    title('Time before intertrial vs Time Intertrail')
    legend({'Correct Trials', 'Incorrect Trials'},'Location', 'northeast')



    min_time = min(trials.time_intertrial);
    max_time = max(trials.time_intertrial);



    figure('units','normalized','outerposition',[0 0 1 1])
    set(gcf, 'color', 'w')
    histogram(trials{trials.correct_trial ==1, 'time_intertrial'},linspace(min_time,max_time,40))
    hold on;
    histogram(trials{trials.correct_trial ==0, 'time_intertrial'},linspace(min_time,max_time,40))


    xlabel('Time intertrial');
    ylabel('# Trials');
    title('Time intertrial histogram')
    legend({'Correct Trials', 'Incorrect Trials'},'Location', 'northeast')
    set(gca, 'FontSize', 14);

    group_trials = groupsummary(trials,"session_date","max",["time_intertrial"]);



    figure('units','normalized','outerposition',[0 0 1 1])

    bar(1:height(group_trials), group_trials.max_time_intertrial)
    xticklabels(group_trials.session_date)
    xtickangle(30)
    xlabel('Date');
    ylabel('Max intertrial time');
    title('Intertrial time per date')
    set(gca, 'FontSize', 14);
    set(gcf, 'color', 'w')



    trials2 = trials(trials)

end




end


function ret = equals_cells(x,y)
if x==y
    ret =1;
else
    ret = 0;
end
end