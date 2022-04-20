function compare_virmen_frequency(key1, key2, dif_plots, gauss_smoth_param)

if nargin < 3
    dif_plots = 0;
end
if nargin < 4
    gauss_smoth_param = 120;
end

[status,data] = lab.utils.read_behavior_file(key1);
if status
    times = get_trial_iteration_time_matrix(data.log);
else
    error('File not found for key1')
end

[status,data] = lab.utils.read_behavior_file(key2);
if status
    times2 = get_trial_iteration_time_matrix(data.log);
else
    error('File not found for key1')
end

figure;
freq_raw1 = 1 ./diff(times(:,1));
smooth_freq1 = smoothdata(freq_raw1,'gaussian',gauss_smoth_param);

freq_raw2 = 1 ./diff(times2(:,1));
smooth_freq2 = smoothdata(freq_raw2, 'gaussian',gauss_smoth_param);


if dif_plots == 0
    figure;
    hold on
    plot(freq_raw1,'b','LineWidth',0.5)
    plot(freq_raw2,'r','LineWidth',0.5)
    plot(smooth_freq1,'color',[0 0 0.5],'LineWidth',3)
    plot(smooth_freq2,'color',[0.5 0 0],'LineWidth',3)
    xlabel('Iteration #');
    ylabel('Virmen frequency (Hz)');
    set(gcf,'color','w')
    set(gca,'FontSize',16)
elseif dif_plots == 1
    figure;
    subplot(2,1,1);
    hold on
    plot(freq_raw1,'b','LineWidth',0.5,'LineWidth',0.5)
    plot(smooth_freq1,'color',[0 0 0.5],'LineWidth',3)
    set(gca,'FontSize',16)
    xlabel('Iteration #');
    ylabel('Virmen frequency (Hz)');
    subplot(2,1,2);
    hold on;
    plot(freq_raw2,'r','LineWidth',0.5)
    plot(smooth_freq2,'color',[0.5 0 0],'LineWidth',3)
    set(gca,'FontSize',16)
    xlabel('Iteration #');
    ylabel('Virmen frequency (Hz)');
    set(gcf,'color','w')
else
    figure;
    hold on
    plot(smooth_freq1,'color',[0 0 0.5],'LineWidth',1)
    plot(smooth_freq2,'color',[0.5 0 0],'LineWidth',1)
    xlabel('Iteration #');
    ylabel('Virmen frequency (Hz)');
    set(gcf,'color','w')
    set(gca,'FontSize',16)
end