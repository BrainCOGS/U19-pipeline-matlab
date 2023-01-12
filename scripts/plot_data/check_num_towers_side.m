function check_num_towers_side(key)
% check_num_towers_side check if sessions have more towers on the "wrong side" of trial_type
% Inputs
% key = Session(s) key


%Fetch data
all_sessions = fetch((behavior.TowersSession * acquisition.Session) & key, '*');

% initialize data
correct_per = zeros(1, length(all_sessions));
wrong_per = zeros(1, length(all_sessions));
really_wrong_per = zeros(1, length(all_sessions));
for i=1:length(all_sessions)
    
    wrong_num_total = 0;
    correct_num_total = 0;
    really_wrong_num_total = 0;
    % For trial type (1 = left, 2 = right)
    for j=1:2
    
        % get left & right towers
        idx_type_trial = find(all_sessions(i).rewarded_side == j);
        left_towers_type = all_sessions(i).num_towers_l(idx_type_trial);
        right_towers_type = all_sessions(i).num_towers_r(idx_type_trial);

        % Compare left vs right
        if j==1
            idx_correct = find(right_towers_type <= left_towers_type);
            idx_wrong = find(right_towers_type == left_towers_type);
            idx_really_wrong = find(right_towers_type > left_towers_type);
        elseif j == 2
            idx_correct = find(left_towers_type <= right_towers_type);
            idx_wrong = find(left_towers_type == right_towers_type);
            idx_really_wrong = find(left_towers_type > right_towers_type);
        end
        
        % Accumulate results
        correct_num_total = correct_num_total + length(idx_correct);
        wrong_num_total = wrong_num_total +  length(idx_wrong);
        really_wrong_num_total = really_wrong_num_total + length(idx_really_wrong);

    end
    
    % Get % of trials with "wrong" number of towers on the side
    correct_per(i) =      correct_num_total*100 / length(all_sessions(i).rewarded_side);
    wrong_per(i) =        wrong_num_total*100 / length(all_sessions(i).rewarded_side);
    really_wrong_per(i) = really_wrong_num_total*100 / length(all_sessions(i).rewarded_side);
    
    
end

% Only count if 10% of less of "wrong" trials (to remove antiFraction sessions)
idx_wrong = find(wrong_per > 0 & wrong_per < 10);
total_sessions_wrong        = length(idx_wrong)*100 / length(wrong_per);

idx = find(really_wrong_per > 0 & really_wrong_per < 10);
total_sessions_really_wrong = length(idx)
total_sessions_really_wrong_per = length(idx)*100 / length(really_wrong_per)


%Just plot
figure
histogram(correct_per, 'BinWidth',1,'Normalization', 'probability')
set(gcf, 'Units', 'normalized', 'Position', [0 0 1 1])
title('historgram of sessions with % of "Correct" trials','FontSize', 16)
xlabel('% of Correct Trials');
ylabel('ratio of Sessions');
set(gcf, 'color', 'w')
set(gca, 'FontSize', 14);

%figure
%histogram(wrong_per, 'BinWidth',1,'Normalization', 'probability')

figure
histogram(really_wrong_per, 'BinWidth',1,'Normalization', 'probability')
set(gcf, 'Units', 'normalized', 'Position', [0 0 1 1])
title('historgram of sessions with % of "inorrect" trials - more towers wrong side','FontSize', 16)
xlabel('% of Incorrect Trials');
ylabel('ratio of Sessions');
set(gcf, 'color', 'w')
set(gca, 'FontSize', 14);

