 
function plot_intertrial_histogram(key)
% plot_velocity_session Plots mean velocity for all trials in sessions from key
% Inputs
% key = Session key
 
% Get all needed data
key = fetch(acquisition.Session & key);
trials = struct2table(get_full_trial_data(key));

%trials.idx_iter_intertrial = repmat(NaN, height(trials),1);
%trials.time_intertrial = repmat(NaN, height(trials),1);

trials.idx_end_trial = cellfun(@(x) size(x,1),[trials.position]);
trials.time_intertrial = cellfun(@(x,y,z) double(z(x)) - double(z(y)),...
    num2cell([trials.idx_end_trial]), num2cell([trials.iterations]), [trials.trial_time]);
trials.time_bef_intertrial = cellfun(@(x,y) y(x),...
num2cell([trials.iterations]), [trials.trial_time]);
trials.correct_trial = cellfun(@(x,y) equals_cells(x,y),...
[trials.trial_type], [trials.choice]);



figure;
plot(trials{trials.correct_trial ==1, 'time_bef_intertrial'}, trials{trials.correct_trial ==1, 'time_intertrial'},'ro')
hold on;
plot(trials{trials.correct_trial ==0, 'time_bef_intertrial'}, trials{trials.correct_trial ==0, 'time_intertrial'},'bo')


end


function ret = equals_cells(x,y)
    if x==y 
        ret =1;
    else
        ret = 0; 
    end
end