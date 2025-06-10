function  num_trial_analysis()
%NUM_TRIAL_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here

key = 'session_date>"2025-04-01" and subject_fullname like "%jk%"';


keys = fetch(acquisition.Session & key);

trials = struct2table(fetch((proj(acquisition.Session,'session_protocol','num_trials') *...
    behavior.TowersBlock * behavior.TowersBlockTrial & key), ...
    'session_protocol','level','sublevel','trial_duration','ORDER BY session_date'));


trials = trials(trials.trial_idx>1,:);

trials.subject_fullname = string(trials.subject_fullname);
trials.session_date = string(trials.session_date);
trials.session_number = string(trials.session_number);
trials.session_id = trials.session_date+"_"+trials.session_number;

trials.session_id = categorical(trials.session_id);

subjects = groupsummary(trials, 'subject_fullname');

subject_dates = groupsummary(trials, {'subject_fullname','session_date','session_number'});

close all
for i=1:height(subjects)
    trials_subject = trials(trials.subject_fullname==subjects.subject_fullname(i),:);
    boxplot(trials_subject.trial_duration, trials_subject.session_id);
    hold on;
    dates = unique(trials_subject.session_id);
    plot([0.5 length(dates)+0.5],[180, 180],'k')
    plot([0.5 length(dates)+0.5],[300, 300],'g','LineWidth',2)
    %violinplot(trials_subject.session_date, trials_subject.trial_duration);
    set(gca, 'YScale', 'log');
    set(gcf, 'color', [1 1 1]);
    title("Trial times "+subjects.subject_fullname(i), 'interpreter','none');
    hold off



     l = 0

end





end



