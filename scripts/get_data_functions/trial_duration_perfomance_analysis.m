function  trial_duration_perfomance_analysis()
%NUM_TRIAL_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here


researchers = {'jk', 'efo', 'jya', 'jeremy'};

for i = 1:length(researchers)

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
    trials.choice = cellfun(@(x) choice_sel(x), trials.choice);
    trials.trial_type = cellfun(@(x) choice_sel(x), trials.trial_type);
    trials.correct_trial = trials.choice == trials.trial_type;

    trials.session_date = string(trials.session_date);
    trials.session_number = string(trials.session_number);
    trials.session_id = trials.session_date+"_"+trials.session_number;

    trials.session_id = categorical(trials.session_id);
    trials.level = categorical(trials.level);
    unique_levels = unique(trials.level);

    trials.duration_min = (floor(trials.trial_duration/60));

    trials.duration_plus_min = zeros(height(trials),1);
    trials{trials.duration_min>=1,'duration_plus_min'} = 1;
    trials.duration_min = categorical( trials.duration_min);
    trials.duration_plus_min = categorical(trials.duration_plus_min);
    

    unique_durations = unique(trials.duration_min);

    summary_duration_perf = groupsummary(trials(:,{'level', 'duration_min','correct_trial'}), {'level', 'duration_min'},'mean');
    summary_duration_min_perf = groupsummary(trials(:,{'level', 'duration_plus_min','correct_trial'}), {'level', 'duration_plus_min'},'mean');
    summary_duration_min_perf2 = groupsummary(trials(:,{'duration_plus_min','correct_trial'}), {'duration_plus_min'},'mean');
    summary_duration_min_perf2{:,'mean_correct_trial'} = summary_duration_min_perf2{:,'mean_correct_trial'}*100;
    summary_level = groupsummary(trials(:,{'level','correct_trial'}), {'level'},'mean');


    matrix_perf_plot = NaN(length(unique_durations), length(unique_levels));
    matrix_total_plot = NaN(length(unique_durations), length(unique_levels));

    for ii=1:height(summary_duration_perf)
        matrix_perf_plot(grp2idx(summary_duration_perf{ii,'duration_min'}),...
            grp2idx(summary_duration_perf{ii,'level'})) = summary_duration_perf{ii,'mean_correct_trial'};
        matrix_total_plot(grp2idx(summary_duration_perf{ii,'duration_min'}),...
            grp2idx(summary_duration_perf{ii,'level'})) = summary_duration_perf{ii,'GroupCount'};
    end

    matrix_perf_min_plot = NaN(2, length(unique_levels));
    matrix_total_min_plot = NaN(2, length(unique_levels));

    for ii=1:height(summary_duration_min_perf)
        matrix_perf_min_plot(grp2idx(summary_duration_min_perf{ii,'duration_plus_min'}),...
            grp2idx(summary_duration_min_perf{ii,'level'})) = summary_duration_min_perf{ii,'mean_correct_trial'}*100;
        matrix_total_min_plot(grp2idx(summary_duration_min_perf{ii,'duration_plus_min'}),...
            grp2idx(summary_duration_min_perf{ii,'level'})) = summary_duration_min_perf{ii,'GroupCount'};
    end
    level_legend = cell(size(unique_levels));
    for ii=1:length(unique_levels)
        level_legend{ii} = ['Level ', num2str(double(summary_level{ii,'level'})), ' N = ', num2str(summary_level{ii,'GroupCount'})];
    end

    
    %matrix_perf_plot = matrix_perf_plot';
    figure;
    colors = colormap(parula(length(unique_levels)));
    for ii=1:length(unique_levels)
        plot([1 2],[matrix_perf_min_plot(1,ii),matrix_perf_min_plot(2,ii)], 'LineWidth',3, 'Color',colors(ii,:))
        hold on
    end
    bar([summary_duration_min_perf2{1,'mean_correct_trial'} summary_duration_min_perf2{2,'mean_correct_trial'}],'k')
    hold on
    
    for ii=1:length(unique_levels)
        plot([1 2],[matrix_perf_min_plot(1,ii),matrix_perf_min_plot(2,ii)], 'LineWidth',3, 'Color',colors(ii,:))
        plot([1 2],[matrix_perf_min_plot(1,ii),matrix_perf_min_plot(2,ii)], 'o','Color',colors(ii,:),'MarkerFaceColor',colors(ii,:))
        hold on
    end
    set(gca,'FontSize',16)
    xlabel('Trial Duration')
    ylabel('Performance %')
    xticks([1 2])
    xticklabels({'< 1 min duration', '> 1 min duration'})
    set(gcf, 'color', [1 1 1]);
    title(['Trial Perfomance by duration ' researcher], 'interpreter','none');
    legend(level_legend)
    ylim([0 100])

    
    lo = 0


    % imagesc(matrix_perf_plot,[0 1]);
    % colorbar
    % set(gcf, 'color', [1 1 1]);
    % set(gca,'Ydir','normal')
    % title(['Trial Perfomance by duration ' researcher], 'interpreter','none');
    % xlabel('Level')
    % ylabel('Trial Duration (minutes)')
    % xticks([1:length(unique_levels)])
    % xticklabels((unique_levels))
    % yticks([1:length(unique_durations)])
    % yticklabels((unique_durations))
    % ylim([0.5 length(unique_durations)+0.5])
    % xlim([0.5 length(unique_levels)+0.5])
    % 
    % for ii=1:length(unique_durations)
    % for jj=1:length(unique_levels)
    %     if ~isnan(matrix_perf_plot(ii,jj))
    %         this_text = ['N=', num2str(matrix_total_plot(ii,jj)), newline, num2str(floor(matrix_perf_plot(ii,jj)*100)) '%'];
    %         text(jj,ii,this_text,'color',[1 1 1]);
    %     end
    % 
    % end
    % end

end


end

function ret_val = choice_sel(x)

if x == 'R'
    ret_val= 1;
elseif x == 'L'
    ret_val= 0;
else
    ret_val= -1;

end

end



