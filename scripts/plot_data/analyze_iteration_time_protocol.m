function analyze_iteration_time_protocol(key)
% analyze_iteration_time_level_rig, plots meanframete by rig and by level
% Input
% key = key that comprises multiple behavior sessions 
 
%key = 'subject_fullname like "mioffe%" and session_protocol like "%PoissonBlocksCondensed3m%" and session_date > "2022-01-01" and session_date < "2022-11-10"';
 
%Get sessions
key2 = fetch(acquisition.Session & key,'subject_fullname', 'session_date', 'level', 'session_location');
 
%Get trial by trial data and level data
session_data = fetch(proj(acquisition.Session, 'session_location', 'session_protocol') * acquisition.SessionVideo * behavior.TowersBlock * behavior.SpatialTimeBlobs & key, ...
    'iteration_matrix', 'trial_time', 'level', 'session_location', 'session_protocol');
 session_table = struct2table(session_data, 'AsArray', true);
session_table.session_location = categorical(session_table.session_location);
session_table.session_protocol = categorical(session_table.session_protocol);
 
%Initialize variables
session_table.mean_framerate = zeros(height(session_table),1);
session_table.std_framerate = zeros(height(session_table),1);
 
% For all sessions
for sess_num=1:height(session_table)
 
    % Get data by block
    iteration_matrix = session_data(sess_num).iteration_matrix(:,1:2);
    idx_block = iteration_matrix(:,1) == session_table{sess_num, 'block'};
    
    new_iter_matrix = iteration_matrix(idx_block,2);
    new_trial_time = session_data(sess_num).trial_time(idx_block);
    
    block_trials = unique(new_iter_matrix);
    
    %Calculate mean frame rate by block
    mean_frame_rate = zeros(length(block_trials),1);
    for j=1:length(block_trials)
        idx_trial = new_iter_matrix == j;
        frame_rate_trial = 1./diff(new_trial_time(idx_trial));
        mean_frame_rate(j) = mean(frame_rate_trial);             
    end
    
    %Concatenate results
    session_table{sess_num, 'mean_framerate'} = mean(mean_frame_rate, 'omitnan');
    session_table{sess_num, 'std_framerate'} = std(mean_frame_rate, 'omitnan');
    
    %legend_data{sess_num} = [key2(sess_num).subject_fullname, '----', key2(sess_num).session_date];
end
 
 
% Average framerate by levels and rigs
levels = unique(session_table.session_protocol);
rigs   = unique(session_table.session_location);
 
framerate = zeros(length(levels), length(rigs));
framerate_std = zeros(length(levels), length(rigs));
for i=1:length(levels)
    
    for j=1:length(rigs)
        
        mean_frame_rate_final = session_table{session_table.session_protocol == levels(i) & session_table.session_location == rigs(j), 'mean_framerate'};
        
        framerate(i,j) = mean(mean_frame_rate_final);
        framerate_std(i,j) = std(mean_frame_rate_final);
    end
end
        
%Plot results
h = imagesc(framerate);       
        
set(h, 'AlphaData', 1-isnan(framerate))
 
set(gcf,'color','w');
xlabel('Rig', 'FontSize', 16);
xticks(1:length(rigs))
xticklabels(rigs)
ylabel('Level','FontSize', 16);
yticks(1:length(levels));
yticklabels(string(levels));
title("Average block frame rate per level",'FontSize', 22);
c  = colorbar();
c.Label.String = 'Mean framerate (Hz)';
set(gca,'FontSize',16);


%Plot results
figure;
h = imagesc(framerate_std);       
        
set(h, 'AlphaData', 1-isnan(framerate_std))
 
set(gcf,'color','w');
xlabel('Rig', 'FontSize', 16);
xticks(1:length(rigs))
xticklabels(rigs)
ylabel('Level','FontSize', 16);
yticks(1:length(levels));
yticklabels(string(levels));
title("Std block frame rate per level",'FontSize', 22);
c  = colorbar();
c.Label.String = 'Std framerate (Hz)';
set(gca,'FontSize',16);
