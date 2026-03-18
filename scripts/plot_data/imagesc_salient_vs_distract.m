function imagesc_salient_vs_distract(key)
% check_num_towers_side check if sessions have more towers on the "wrong side" of trial_type
% Inputs
% key = Session(s) key


%Fetch data
all_sessions = fetch((behavior.TowersSession * acquisition.Session) & key, '*');

% initialize data
max_towers = 16;
matrix_salient_vs_distract = zeros(max_towers+1,max_towers+1);
triangular_mat = tril(ones(max_towers+1,max_towers+1));
triangular_mat(triangular_mat==1) = -1;
%triangular_mat(triangular_mat==0) = 0;

hist_edges = [-0.5:1:max_towers+0.5];
lims = [1 max_towers+1];
ticks = [1:1:max_towers+1];
lims_labels_num = [0:1:max_towers];
lims_labels = string(lims_labels_num);


for i=1:length(all_sessions)
    
    wrong_num_total = 0;
    correct_num_total = 0;
    really_wrong_num_total = 0;
    % For trial type (1 = left, 2 = right)
    for j=1:2
    
        % get left & right towers
        idx_type_trial = find(all_sessions(i).rewarded_side == j);
        if j==1
            salient_towers = all_sessions(i).num_towers_l(idx_type_trial);
            distract_towers = all_sessions(i).num_towers_r(idx_type_trial);
        else
            salient_towers = all_sessions(i).num_towers_r(idx_type_trial);
            distract_towers = all_sessions(i).num_towers_l(idx_type_trial);
        end

        ho = histogram2(salient_towers,distract_towers,hist_edges,hist_edges);

        matrix_salient_vs_distract = matrix_salient_vs_distract + ho.Values'; 


    end
    
end

matrix_salient_vs_distract = round(matrix_salient_vs_distract./length(all_sessions));

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
