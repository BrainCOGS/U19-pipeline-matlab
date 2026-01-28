function  trial_duration_analysis()
%NUM_TRIAL_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here


researchers = {'jk', 'efo', 'jya', 'jeremy'};

for i = 4:length(researchers)

key = ['session_date>"2025-01-01" and subject_fullname like "%' researchers{i}  '%"'];

keys = fetch(acquisition.Session & key);

trials = struct2table(fetch((proj(acquisition.Session,'session_protocol','num_trials') *...
    behavior.TowersBlock * behavior.TowersBlockTrial & key), ...
    'session_protocol','level','sublevel','trial_duration','choice','trial_type','ORDER BY session_date'));

researcher = trials{1,'subject_fullname'};
researcher = strsplit(researcher{1},'_');
researcher = researcher(1);

trials = trials(trials.trial_idx>1,:);

trials.subject_fullname = string(trials.subject_fullname);
trials.correct_trial = trials.choice == trials.trial_type;

trials.session_date = string(trials.session_date);
trials.session_number = string(trials.session_number);
trials.session_id = trials.session_date+"_"+trials.session_number;

trials.session_id = categorical(trials.session_id);
trials.level = categorical(trials.level);

trials.duration_min = categorical(floor(trials.trial_duration/60));


summary_duration = groupsummary(trials(:,{'duration_min','correct_trial'}), {'duration_min'},'mean');

G = groupsummary(T,"HealthStatus","mean")

boxplot(trials.trial_duration, trials.level);
hold on;
levels = unique(trials.level);
plot([0.5 length(levels)+0.5],[600, 600],'g','LineWidth',2)
%violinplot(trials.levels, trials.trial_duration);
set(gca, 'YScale', 'log');
set(gcf, 'color', [1 1 1]);
title(['Trial times all subjects 2025' researcher])
xlabel('Level')
ylabel('Duration (s)')
legend('10 min duration')
hold off


%close all
% for i=1:height(subjects)
%     trials_subject = trials(trials.subject_fullname==subjects.subject_fullname(i),:);
%     boxplot(trials_subject.trial_duration, trials_subject.level);
%     hold on;
%     levels = unique(trials_subject.level);
%     plot([0.5 length(levels)+0.5],[180, 180],'k')
%     plot([0.5 length(levels)+0.5],[600, 600],'g','LineWidth',2)
%     %violinplot(trials_subject.session_date, trials_subject.trial_duration);
%     set(gca, 'YScale', 'log');
%     set(gcf, 'color', [1 1 1]);
%     title("Trial times "+subjects.subject_fullname(i), 'interpreter','none');
%     hold off
%
%
%
%      l = 0
%
% end





end



