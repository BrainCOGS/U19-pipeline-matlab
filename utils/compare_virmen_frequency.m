function compare_virmen_frequency(key1, key2)

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
smooth_freq1 = smoothdata(freq_raw1,'gaussian',120);

freq_raw2 = 1 ./diff(times2(:,1));
smooth_freq2 = smoothdata(freq_raw2, 'gaussian',120);


figure;
hold on
plot(freq_raw1,'b','LineWidth',0.5)
plot(freq_raw2,'r','LineWidth',0.5)
plot(smooth_freq1,'color',[0 0 0.5],'LineWidth',0.5)


plot(smooth_freq2,'color',[0.5 0 0],'LineWidth',0.5)

xlabel('Iteration #');
ylabel('Virmen frequency (Hz)');


set(gcf,'color','w')
set(gca,'FontSize',16)