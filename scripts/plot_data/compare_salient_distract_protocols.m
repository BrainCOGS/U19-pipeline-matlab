function compare_salient_distract_protocols()

%% Regular towers protocols
session_protocols = ["poisson_blocks.m poisson_blocks_reboot_3m.mat PoissonBlocksCondensed3m", ...
"poisson_blocks.m poisson_blocks_reboot_3m.mat PoissonBlocksCondensed3m_manuel"];
session_protocol_key = join(session_protocols, '", "');
session_protocol_key = ['session_protocol in ("' char(session_protocol_key) ,'")'];

protocol_block_key = 'level =11';

[bar_logs, bar_difs, ~] = plot_salient_vs_distract(session_protocol_key, protocol_block_key,true);


%% LSTT PRotocol
session_key = 'subject_fullname like "%efonseca%" and session_date > "2026-01-01"';
block_key = 'level >=4';

[bar_logs2, bar_difs2, edges_logs] = plot_salient_vs_distract(session_key, block_key,true);


close all;

%% Plot difficultes comparison
subfigure(1,1,1)
subplot(1, 2, 1);

bar(edges_logs, bar_logs,1,'FaceAlpha', 0.5);
hold on
bar(edges_logs, bar_logs2,1,'FaceAlpha', 0.5);
plot([1,1],[0,max(bar_logs2)],'r')
plot([2,2],[0,max(bar_logs2)],'r')

set(gcf,'color',[1 1 1]);
set(gca,'FontSize',12);
xlabel('log(salient/distract)')
ylabel('% Trials')
title('% of Trial type log(salient/distract)');

tickos = [0:0.5:3 4];
tickoslabels = compose("%1.1f", tickos);
tickoslabels(end) = "Inf";
xlim([-0.5,4.5])
xticks(tickos);
xticklabels(tickoslabels);

legend({'Regular Tower Task','LSTT'})


%% Plot histogram of difficulties
subplot(1,2,2)

bar([1,2,3],[bar_difs; bar_difs2],0.8);
set(gcf,'color',[1 1 1]);
set(gca,'FontSize',12);
xlabel('Difficulty trials')
ylabel('% Trials')
title('% of Trial type (difficulty)');

xticklabels(["Easy", "Medium", "Hard"]);

legend({'Regular Tower Task','LSTT'})












