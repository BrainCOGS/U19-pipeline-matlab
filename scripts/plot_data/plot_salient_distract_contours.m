function [z,zdif] =plot_salient_distract_contours(max_towers,plot_on)

if nargin <2
    plot_on = true;
end

z = zeros(max_towers+1,max_towers+1);
zdif = zeros(max_towers+1,max_towers+1);
for y=0:max_towers

    for x=y+1:max_towers

        if y > 0
            z(y+1,x+1) = log(x/y);
        else
            z(y+1,x+1) = inf;
        end

    end

end


triangular_mat = tril(ones(max_towers+1,max_towers+1),-1);
triangular_mat(triangular_mat==1) = -1;


%Get number of colors of matrix to use it for colormap and black, white values

lo = z(z>0);
lo2 = z(~isinf(z));
minimum_value = min(lo(:));
maximum_value = max(lo2(:));
z(isinf(z)) = maximum_value+ minimum_value;
num_samples_arrive = ceil(maximum_value/minimum_value)+1;
triangular_mat = triangular_mat*minimum_value;

z = z+triangular_mat;

lims = [0.5 max_towers+1.5];
ticks = 1:max_towers+1;
lims_labels_num = 0:1:max_towers;
lims_labels = string(lims_labels_num);

z(1,1) =-1*minimum_value;

%Calculate zdif
zdif(z>=0)=3;
zdif(z>=1)=2;
zdif(z>=2)=1;


if plot_on

    close all
    subfigure(1,1,1)

    %% Plot log(salient/distractors)
    ha = tight_subplot(1, 2, 0.1);
    axes(ha(1));
    %subplot(1,2,1);
    imagesc(z)
    hold on;
    plot([0,max_towers+1.5],[0,max_towers+1.5],'r');
    plot([0,max_towers+1.5],[1.5,1.5],'m');
    this_colormap = parula(num_samples_arrive+1);
    this_colormap = [[0 0 0]; this_colormap;];
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
    cb = colorbar;
    cb.Label.String = "log (salient/distractors)";
    cb.FontSize = 12;

    tickos = cb.Ticks;
    tickos = [tickos max(z(:))];
    cb.Ticks = tickos;

    tickos = cb.TickLabels;
    tickos{end} = "Inf";
    cb.TickLabels = tickos;
    %tickos = [tickos max(z(:))];
    %cb.Ticks = tickos;


    xlabel('# Salient Towers')
    ylabel('# Distract Towers')
    title('Log (salient/distractor) value for each trial type');

    z2 = z;
    z2(z2==-minimum_value) = -99;
    z2(z2==maximum_value+minimum_value) = 99;


    textStrings = num2str(z2(:), '%0.1f');
    mino = '-99.0';
    maxo = '99.0';
    % 2. Create strings from matrix values

    textStrings = strtrim(cellstr(textStrings)); % Remove space padding


    mask = strcmp(textStrings, mino); % Find where values are 'condi3'
    textStrings(mask) = {''};

    mask = strcmp(textStrings, maxo); % Find where values are 'condi3'
    textStrings(mask) = {'Inf'};


    % 3. Create x and y coordinates for the strings
    [x, y] = meshgrid(1:size(z,2), 1:size(z,1));

    % 4. Plot the strings
    hStrings = text(x(:), y(:), textStrings(:), ...
        'HorizontalAlignment', 'center');

    % 5. (Optional) Adjust text color based on background
    midValue = mean(get(gca, 'CLim'));
    textColors = repmat(z(:) < midValue, 1, 3);
    set(hStrings, {'Color'}, num2cell(textColors, 2));
    axis square


    %% Plot difficulties
    axes(ha(2));
    %subplot(1,2,2);
    imagesc(zdif)
    hold on;
    this_colormap = [[0 0 0]; [0 1 0]; [1 1 0]; [1 0 0]];
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
    cb = colorbar;
    cb.Label.String = "Difficulty";
    cb.FontSize = 12;


    cb.Ticks = 1.1250:0.75:2.6250;

    tickos = {"Easy", "Medium", "Hard"};
    cb.TickLabels = tickos;

    xlabel('# Salient Towers')
    ylabel('# Distract Towers')
    title('Difficulty value for each trial type');


    axis square
end



