function compare_virmen_frequency(keys, dif_plots, gauss_smoth_param, legends)

if nargin < 2
    dif_plots = 0;
end
if nargin < 3
    gauss_smoth_param = 120;
end
if nargin < 4
    legends = struct2string(keys);
end

for i=1:length(keys)
    [status,data] = lab.utils.read_behavior_file(keys(i));
    if status
        times = get_trial_iteration_time_matrix(data.log);
        freq_raw{i} = 1 ./diff(times(:,1));
        smooth_freq{i} = smoothdata(freq_raw{i},'gaussian',gauss_smoth_param);
    else
        keys_str = struct2string(keys(i));
        error(char(["Couldn't open file for: ", keys_str]))
    end
end

close all
f = figure;
set(f, 'Units', 'normalized', 'Position', [0 0 1 1])
set(f, 'Units', 'pixels')

pos = get(gcf, 'Position'); %// gives x left, y bottom, width, height
[rows, cols] = get_rows_cols_figure(length(keys), pos(3:4));
colors= get(gca, 'ColorOrder');
darkcolors= brighten(colors, -.5);


if dif_plots == 0
    hold on
    %just for legend purposes
    for i=1:length(keys)
        plot([-1 -2],'color',darkcolors(i,:),'LineWidth',3)
    end
    for i=1:length(keys)
        plot(freq_raw{i},'color',colors(i,:),'LineWidth',0.5)
    end
    for i=1:length(keys)
        plot(smooth_freq{i},'color',darkcolors(i,:),'LineWidth',3)
    end
    legend(legends,'Interpreter', 'none');
    set(gca,'FontSize',20)
    xlabel('Iteration #');
    ylabel('Virmen frequency (Hz)');
    ylim([0 200])
    
elseif dif_plots == 1
    for i=1:length(keys)
        subplot(rows,cols,i)
        hold on
        %legend purposes
        plot([-1, -2],'color',darkcolors(i,:),'LineWidth',3)
        
        plot(freq_raw{i},'color',colors(i,:),'LineWidth',0.5)
        plot(smooth_freq{i},'color',darkcolors(i,:),'LineWidth',3)
        legend(legends{i}, 'Interpreter', 'none');
        set(gca,'FontSize',20)
        xlabel('Iteration #');
        ylabel('Virmen frequency (Hz)');
        ylim([0 200])
    end
    
end

set(gcf,'color','w')


end