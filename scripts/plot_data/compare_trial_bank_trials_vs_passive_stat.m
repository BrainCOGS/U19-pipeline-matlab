 
function table_trial_comparison = compare_trial_bank_trials_vs_passive_stat(session_key)
% compare_trial_bank_trials_vs_passive_stat Compare position, velocity and frame rate from active vs passive and stationart
% Inputs
% session_key = passive/stationary key
 
% Get all needed data
[~, beh_file_passive] = lab.utils.read_behavior_file(session_key);

% Table for comparison
varTypes = ["cell",                     "cell",        "uint16","  uint16",  "uint16",  ...
    "double",    "double",          "double",      "double",   "double",  "double",        "double",       "double", ...
    "double",    "double"];
varNames = ["subject_fullname", "session_date", "session_number",  "block",   "trial", ...
    "mean_freq", "std_freq", "mean_freq_tbt", "std_freq_tbt", "mean_vel", "std_vel", "mean_vel_tbt",  "std_vel_tbt", ...
    "trial_time", "tbt_time"];
size_table = [beh_file_passive.log.numTrials, length(varNames)];
table_trial_comparison = table('Size',size_table,'VariableTypes',varTypes,'VariableNames',varNames);

num_trial_comparison = 1;
for iblock = 1:length(beh_file_passive.log.block)
    
    this_block = beh_file_passive.log.block(iblock);
    base_key = session_key;
    base_key.block = iblock;
    
    for itrial = 1:length(this_block.trial)
        this_trial = this_block.trial(itrial);
        base_key.trial = itrial;
        
        trial_bank_trial = this_trial.trial_bank_session;
        if ~isempty(trial_bank_trial)
            trial_bank_session_ref = table2struct(trial_bank_trial(:, {'subject_fullname','session_date','session_number'}));
            trial_bank_block_ref = trial_bank_trial{:,'block'};
            trial_bank_trial_ref = trial_bank_trial{:,'num_trial_block'};
            
            [~, trial_bank_session] = lab.utils.read_behavior_file(trial_bank_session_ref);
            trial_bank_trial_data = trial_bank_session.log.block(trial_bank_block_ref).trial(trial_bank_trial_ref);
            
            base_key.mean_freq = nanmean(1./diff(this_trial.time(2:this_trial.iArmEntry)));
            base_key.std_freq = nanstd(1./diff(this_trial.time(2:this_trial.iArmEntry)));
            
            base_key.mean_freq_tbt = nanmean(1./diff(trial_bank_trial_data.time(1:trial_bank_trial_data.iArmEntry)));
            base_key.std_freq_tbt = nanstd(1./diff(trial_bank_trial_data.time(1:trial_bank_trial_data.iArmEntry)));
            
            base_key.mean_vel = nanmean(this_trial.velocity(2:this_trial.iArmEntry,2));
            base_key.std_vel = nanstd(this_trial.velocity(2:this_trial.iArmEntry,2));
            
            base_key.mean_vel_tbt = nanmean(trial_bank_trial_data.velocity(1:trial_bank_trial_data.iArmEntry,2));
            base_key.std_vel_tbt = nanstd(trial_bank_trial_data.velocity(1:trial_bank_trial_data.iArmEntry,2));
            
            base_key.trial_time = this_trial.time(this_trial.iArmEntry)-this_trial.time(2);
            base_key.tbt_time = trial_bank_trial_data.time(trial_bank_trial_data.iArmEntry);
                        
            table_trial_comparison(num_trial_comparison,:) = struct2table(base_key, 'AsArray',true);
            
            num_trial_comparison = num_trial_comparison + 1;
            
            if num_trial_comparison > 1
            figure('units','normalized','outerposition',[0 0 1 1])
            subplot(2,2,1)
            plot(this_trial.velocity(2:this_trial.iArmEntry,2))
            hold on
            plot(trial_bank_trial_data.velocity(1:trial_bank_trial_data.iArmEntry,2),'r')
            set(gca, 'FontSize', 14);
            xlabel('Iteration #');
            ylabel('Velocity cm/s');
            title('Velocity vs Iteration')
            legend({'Passive/stat trial', 'Trial bank trial (Active)'})
            
            subplot(2,2,2)
            plot(this_trial.position(2:this_trial.iArmEntry,2))
            hold on
            plot(trial_bank_trial_data.position(1:trial_bank_trial_data.iArmEntry,2),'r')
            set(gca, 'FontSize', 14);
            xlabel('Iteration #');
            ylabel('Position (cm)');
            title('Position vs Iteration')
            legend({'Passive/stat trial', 'Trial bank trial (Active)'},'Location', 'southeast')
            
            subplot(2,2,3)
            plot(this_trial.position(2:this_trial.iArmEntry,2),this_trial.velocity(2:this_trial.iArmEntry,2))
            hold on
            plot(trial_bank_trial_data.position(1:trial_bank_trial_data.iArmEntry,2),trial_bank_trial_data.velocity(1:trial_bank_trial_data.iArmEntry,2),'r')
            set(gca, 'FontSize', 14);
            xlabel('Position (cm)');
            ylabel('Velocity (cm/s)');
            title('Velocity vs Position')
            legend({'Passive/stat trial', 'Trial bank trial (Active)'},'Location', 'southeast')
                
            subplot(2,2,4)
            plot(1./diff(this_trial.time(2:this_trial.iArmEntry)))
            hold on
            plot(1./diff(trial_bank_trial_data.time(1:trial_bank_trial_data.iArmEntry)),'r');
            set(gca, 'FontSize', 14);
            xlabel('Iteration #');
            ylabel('Refresh rate (hz)');
            title('Refresh rate vs Iteration')
            legend({'Passive/stat trial', 'Trial bank trial (Active)'},'Location', 'southeast')
            
            
            set(gcf, 'color', 'w')
            set(gca, 'FontSize', 14);
            keyboard
            close all
            
            end
                   
        else
            table_trial_comparison(num_trial_comparison,:) = [];
            
            
        end
    end
end
        
