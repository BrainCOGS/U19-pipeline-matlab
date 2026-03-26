function imagesc_salient_vs_distract(session_key, block_key)
% check_num_towers_side check if sessions have more towers on the "wrong side" of trial_type
% Inputs
% key = Session(s) key

if nargin < 2
    block_key = '';
end

all_sessions = fetch(acquisition.Session & session_key);

if ~isempty(block_key)
    all_blocks = fetch(behavior.TowersBlock & all_sessions & block_key);
else
    all_blocks = fetch(behavior.TowersBlock & all_sessions);
end

all_blocks_sessions = struct2table(all_blocks);
all_blocks_sessions = ...
    unique(all_blocks_sessions(:, {'subject_fullname', 'session_date', 'session_number'}), 'rows');

%all_trials = struct2table(fetch(behavior.TowersBlockTrial & all_blocks,...
%    'trial_type', 'cue_presence_left', 'cue_presence_right'));


all_trials = struct2table(fetch(behavior.TowersBlockTrial & all_blocks,...
    'trial_type', 'cue_presence_left', 'cue_presence_right','cue_pos_left','cue_pos_right'));

all_trials.num_towers_l = cellfun(@sum, all_trials.cue_presence_left);
all_trials.num_towers_r = cellfun(@sum, all_trials.cue_presence_right);

all_trials.num_towers = all_trials.num_towers_l + all_trials.num_towers_r;


all_trials.num_towers_salient = zeros(height(all_trials),1);
all_trials.num_towers_distract = zeros(height(all_trials),1);


all_trials(strcmp(all_trials.trial_type,'L'),'num_towers_salient') = ...
    all_trials(strcmp(all_trials.trial_type,'L'),'num_towers_l'); 
all_trials(strcmp(all_trials.trial_type,'L'),'num_towers_distract') = ...
    all_trials(strcmp(all_trials.trial_type,'L'),'num_towers_r'); 

all_trials(strcmp(all_trials.trial_type,'R'),'num_towers_salient') = ...
    all_trials(strcmp(all_trials.trial_type,'R'),'num_towers_r'); 
all_trials(strcmp(all_trials.trial_type,'R'),'num_towers_distract') = ...
    all_trials(strcmp(all_trials.trial_type,'R'),'num_towers_l'); 

max_towers = max(all_trials.num_towers_salient);
triangular_mat = tril(ones(max_towers+1,max_towers+1));
triangular_mat(triangular_mat==1) = -1;
%triangular_mat(triangular_mat==0) = 0;

hist_edges = -0.5:1:max_towers+0.5;
lims = [1 max_towers+1];
ticks = 1:1:max_towers+1;
lims_labels_num = 0:1:max_towers;
lims_labels = string(lims_labels_num);


ho = histogram2(all_trials.num_towers_salient,all_trials.num_towers_distract,hist_edges,hist_edges);
matrix_salient_vs_distract = ho.Values';


matrix_salient_vs_distract = ceil(matrix_salient_vs_distract./height(all_blocks_sessions));

matrix_salient_vs_distract = matrix_salient_vs_distract+triangular_mat;

imagesc(matrix_salient_vs_distract)
this_colormap = parula(max(matrix_salient_vs_distract(:)));
this_colormap = [[0 0 0]; [1 1 1]; this_colormap];
set(gca,'Ydir','normal');
set(gcf,'color',[1 1 1]);
set(gca,'FontSize',12);
colormap(gca, this_colormap);
xlim(lims)
xticks(ticks)
xticklabels(lims_labels)
ylim(lims)
yticks(ticks)
yticklabels(lims_labels)
colorbar
xlabel('# Salient Towers')
ylabel('# Distract Towers')
title('Average # "trial type" per session')
