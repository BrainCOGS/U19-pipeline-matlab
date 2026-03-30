function [bar_logs, bar_difs, edges_logs] = plot_salient_vs_distract(session_key, block_key,plot_dif)
% check_num_towers_side check if sessions have more towers on the "wrong side" of trial_type
% Inputs
% key = Session(s) key


if nargin < 2
    block_key = '';
end
if nargin < 3
    plot_dif = false;
end

close all
subfigure(1,1,1)


if ~isempty(block_key)
    tic

    % get session fields to project the ones that conflict with block tabel
    session_table = acquisition.Session;
    session_fields = session_table.nonKeyFields;
    session_fields = setdiff(session_fields, {'level', 'set_id', 'task'}, 'stable');
    session_fields = [session_fields {'level->session_level'}, ...
        {'set_id->session_set_id'}, {'task->session_task'}];

    % Fetch all trials
    all_trials = struct2table(fetch(behavior.TowersBlockTrial * ...
        proj(acquisition.Session,session_fields{:}) * ...
        behavior.TowersBlock & session_key & block_key, ...
        'trial_type', 'cue_presence_left', 'cue_presence_right'));
    toc
else

    %Fetch all trials without block query
    all_trials = struct2table(fetch(behavior.TowersBlockTrial * ...
        acquisition.Session & session_key, ...
        'trial_type', 'cue_presence_left', 'cue_presence_right'));
end

%Calculate trial stats
all_trials.num_towers_l = cellfun(@sum, all_trials.cue_presence_left);
all_trials.num_towers_r = cellfun(@sum, all_trials.cue_presence_right);

all_trials.num_towers = all_trials.num_towers_l + all_trials.num_towers_r;

%Salient and distract
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


all_trials.no_distractors = zeros(height(all_trials),1);

all_trials{all_trials.num_towers_distract == 0, 'no_distractors'} = ...
    ones(height(all_trials(all_trials.num_towers_distract == 0,:)),1);

all_trials.log_cues = log(all_trials.num_towers_salient./all_trials.num_towers_distract);

% "Arbitrary Difficulty for trials" 
all_trials.difficulty_num = ones(height(all_trials),1)*3;
all_trials{all_trials.log_cues >= 1, 'difficulty_num'} = ....
    repmat(2, height(all_trials(all_trials.log_cues >= 1,:)),1);
all_trials{all_trials.log_cues >= 2, 'difficulty_num'} = ....
    ones(height(all_trials(all_trials.log_cues >= 2,:)),1);


max_towers = max(all_trials.num_towers_salient);
triangular_mat = tril(ones(max_towers+1,max_towers+1),-1);
triangular_mat(triangular_mat==1) = -1;
%triangular_mat(triangular_mat==0) = 0;

hist_edges = -0.5:1:max_towers+0.5;
lims = [0.5 max_towers+1.5];
ticks = 1:1:max_towers+1;
lims_labels_num = 0:1:max_towers;
lims_labels = string(lims_labels_num);

%Get histogram anc calulate percent of type of trials
ho = histogram2(all_trials.num_towers_salient,all_trials.num_towers_distract,hist_edges,hist_edges);
matrix_salient_vs_distract = ho.Values';
matrix_salient_vs_distract = (matrix_salient_vs_distract./height(all_trials))*100;

%Get number of colors of matrix to use it for colormap and black, white values
lo = matrix_salient_vs_distract(matrix_salient_vs_distract>0);
minimum_value = min(lo(:));
maximum_value = max(lo(:));
num_samples_arrive = round(maximum_value/minimum_value);
triangular_mat = triangular_mat*minimum_value;
matrix_salient_vs_distract = matrix_salient_vs_distract+triangular_mat;


%% Plot imagesc salient vs distract
subplot(2,2,[1 3]);
imagesc(matrix_salient_vs_distract)
hold on;


if plot_dif

%Plot difficult trials boundaries    
x = .5:max_towers+1.5;
y = x+1;
stairs(x,y,'r','LineWidth',3)

%Plot Medium and East trials boundaries
[~,zdif] =plot_salient_distract_contours(max_towers,false);
stairplot_aux = nan(3,size(zdif,1)+1);
for j=[1,2]
    for i=1:size(zdif,1)

        idx = find(zdif(i,:)==j,1);

        if(~isempty(idx))
            stairplot_aux(j,i) = idx-0.5;
        end
    end
idxo = find(isnan(stairplot_aux(j,2:end)),1);
if(~isempty(idxo))
    stairplot_aux(j,idxo+1) = max_towers+1.5;
end
end

stairs(stairplot_aux(1,:)-0.1,y+0.1,'y','LineWidth',3)
stairs(stairplot_aux(1,:),y,'g','LineWidth',3)
plot([1.5, 1.5],[0.5,1.5],'g','LineWidth',3)
plot([1.5 max_towers+1.5],[0.5 0.5],'g','LineWidth',3)


stairs(stairplot_aux(2,:)-0.1,y+0.1,'r','LineWidth',3)
stairs(stairplot_aux(2,:),y,'y','LineWidth',3)
else
    plot([0,max_towers+1.5],[0,max_towers+1.5],'r');
    plot([0,max_towers+1.5],[1.5,1.5],'m');
end



this_colormap = parula(num_samples_arrive);
this_colormap = [[0 0 0]; [1 1 1]; this_colormap];
colormap(gca, this_colormap);

set(gca,'Ydir','normal');
set(gcf,'color',[1 1 1]);
set(gca,'FontSize',12);

xlim(lims)
xticks(ticks)
xticklabels(lims_labels)
ylim(lims)
yticks(ticks)
yticklabels(lims_labels)
cb = colorbar;
cb.Label.String = "% of trials";
cb.FontSize = 12;
xlabel('# Salient Towers')
ylabel('# Distract Towers')
title('% of each Trial Type for all trials');

%for i=1:size(zdif,1)-1
%    for j=1:size(zdif,2)-1
%
%        if zdif(i,j) == 3 && zdif(i,j) == 2
%            plot()


%Auxiliar variable for text boxes
z2 = matrix_salient_vs_distract;
z2(z2==-minimum_value) = -90;
z2(z2==0) = 90;

textStrings = num2str(z2(:), '%0.1f');
mino = '-90.0';
zerapio = '90.0';
% 2. Create strings from matrix values
textStrings = strtrim(cellstr(textStrings)); % Remove space padding
mask = strcmp(textStrings, mino); % Find where values are 'condi3'
textStrings(mask) = {''};
mask = strcmp(textStrings, zerapio); % Find where values are 'condi3'
textStrings(mask) = {''};

% 3. Create x and y coordinates for the strings
[x, y] = meshgrid(1:size(matrix_salient_vs_distract,2), 1:size(matrix_salient_vs_distract,1));

% 4. Plot the strings
hStrings = text(x(:), y(:), textStrings(:), ...
    'HorizontalAlignment', 'center');

% 5. (Optional) Adjust text color based on background
midValue = mean(get(gca, 'CLim'));
textColors = repmat(matrix_salient_vs_distract(:) < midValue, 1, 3);
set(hStrings, {'Color'}, num2cell(textColors, 2));
axis square 


%% Plot histogram of log (salient/distract)
if plot_dif
    subplot(2,2,2);
else
    subplot(2,2,[2 4]);
end
no_distractors_trials = sum(all_trials.no_distractors==1);
no_distractors_trials = (no_distractors_trials/height(all_trials))*100;
distractor_trials = all_trials{all_trials.no_distractors==0, 'log_cues'};
bins = -.05:0.1:3.05;
bins_ext = -0.05:0.1:4.05;

h = histogram(distractor_trials, bins);

bars = h.Values;
bars = (bars/height(all_trials))*100;
bars = [bars, 0 0 0 0 0 0 0 0 0 0 no_distractors_trials];

bar_logs = bars;
edges_logs = bins_ext;

bar(bins_ext, bars,1);
hold on
plot([1,1],[0,max(bars)],'r')
plot([2,2],[0,max(bars)],'r')

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

if plot_dif

text(0.5,max(bars)-2,'Hard','BackgroundColor', [1 0 0],'HorizontalAlignment','center');
text(1.5,max(bars)-2,'Medium','BackgroundColor', [1 1 0],'HorizontalAlignment','center');
text(2.5,max(bars)-2,'Easy','BackgroundColor', [0 1 0],'HorizontalAlignment','center');
end


%% Plot histogram of difficulties
if plot_dif
subplot(2,2,4);
h = histogram(all_trials.difficulty_num, 0.5:1:3.5);

bars = h.Values;
bars = (bars/height(all_trials))*100;
bar_difs = bars;

this_colormap = [[0 1 0];[1 1 0];[1 0 0]];

b = bar([1,2,3], bars,0.8,'FaceColor', 'flat');
b.CData = this_colormap; 
colormap(gca,this_colormap);

set(gcf,'color',[1 1 1]);
set(gca,'FontSize',12);
xlabel('Difficulty trials')
ylabel('% Trials')
title('% of Trial type (difficulty)');
xticklabels(["Easy", "Medium", "Hard"]);


% Get coordinates
xtips = b.XEndPoints;
ytips = b.YData/2;

% Create labels as strings
barlabels = num2str(bars(:), '%0.1f%%');

% Add the text labels to the plot
text(xtips, ytips, barlabels, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10); % Adjust font size if necessary

end













