
function data = plot_pupillometry_data(key)


data = fetch(pupillometry.PupillometryData & key,'*');

close all
f = figure;
set(f, 'Units', 'normalized', 'Position', [0 0 1 1])
set(f, 'Units', 'pixels')
set(gcf,'color','w')
hold on;
set(gca,'FontSize',20)


legends = cell(1,1);
all_data = [];
sessions = [];
valid_sessions = 0;
for i =1:length(data)
    
    this_session_data = data(i).pupil_diameter';
    
    legends2{i} = [data(i).session_date];
    all_data = [all_data this_session_data];
    sessions = [sessions repmat(i,1,length(data(i).pupil_diameter))];
    
    if nanmean(this_session_data) < 45 && nanmean(this_session_data) > 25
        valid_sessions = valid_sessions + 1;
        legends{valid_sessions} = [data(i).subject_fullname '_' data(i).session_date '_' num2str(data(i).session_number)];
        plot(data(i).pupil_diameter)
    end
    
end

legend(legends, 'Interpreter', 'none');
xlabel('Frame #');
ylabel('Pupil diameter (pixels)');


f = figure;
set(f, 'Units', 'normalized', 'Position', [0.1 0.1 0.7 0.7])
set(f, 'Units', 'pixels')
set(gcf,'color','w')
hold on;
set(gca,'FontSize',16)

boxplot(all_data, sessions);

xticks(1:length(data))
xticklabels(legends2)
xtickangle(45)
xlabel('Session #');
ylabel('Pupil diameter (pixels)');



