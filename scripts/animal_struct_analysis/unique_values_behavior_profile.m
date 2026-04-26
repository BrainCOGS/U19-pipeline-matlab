


%Part1
% 
% t1 = datetime(2015,11,1,0,0,0);
% t2 = datetime(2024,12,1,0,0,0);
% % % %t2 = datetime('now');
% % date_vec = [t1 t2]
% date_vec = t1:caldays(30):t2;
% % %
% for i=1:length(date_vec)-1
% 
%     [i: length(date_vec)]
% 
%     date1 = char(datetime(date_vec(i),'Format','uuuu-MM-dd'));
%     date2 = char(datetime(date_vec(i+1),'Format','uuuu-MM-dd'));
% 
%     l = strjoin(["session_date between '" date1 "' and '" date2 "'"],"");
%     sessions = fetch(acquisition.Session & l);
% 
%     num_sessions_read = 0;
%     these_logs = {};
%     for j=1:length(sessions)
% 
%         [j length(sessions) num_sessions_read]
% 
%         [status, data] = lab.utils.read_behavior_file(sessions(j));
% 
%         if status
% 
%             num_sessions_read = num_sessions_read +1;
%             these_logs{num_sessions_read} = data.log.animal;
%         end
% 
% 
% 
%     end
%     save(['sessions' date1 '_' date2 '.mat'],"these_logs");
% 
% 
% end


tf = [];
filePath = matlab.desktop.editor.getActiveFilename;
filePath = fileparts(filePath);
cd(filePath)

this_dir = pwd;
animal_struct_dir = fullfile(this_dir, 'all_sessions_animal_struct_dir');
cd(animal_struct_dir);

%Get current fields
last_file = load('sessions2024-10-14_2024-11-13.mat');
tfinal = struct2table(last_file.these_logs{1},'AsArray', true);
official_fieldnames = tfinal.Properties.VariableNames;
official_fieldnames{end+1} = 'DateFile';
data_types = varfun(@class,tfinal,'OutputFormat','cell');
data_types{end+1} = 'cell';


T = table('Size',[1 length(official_fieldnames)],'VariableTypes',data_types, 'VariableNames',official_fieldnames);
T.warmupDrawMethod = {-1 -1};
T.mainDrawMethod = {-1 -1};

delete_vars = {'name', 'Date', 'refImageFiles', 'Time', 'color'};

for i=1:length(delete_vars)
    T = removevars(T,delete_vars{i});
    official_fieldnames(ismember(official_fieldnames,delete_vars{i})) = [];
end

files = dir;
all_files = {files.name};
all_files = all_files(3:end);
for i = 1:length(all_files)

    [i length(all_files)]
    this_file = load(all_files{i});
    these_logs = this_file.these_logs;

    initial_idx = height(tf);
    tf2 = [];
    for j=1:length(these_logs)
        

        if isstruct(these_logs{j})
            t1 = struct2table(these_logs{j},'AsArray', true);
            columns_t1 = t1.Properties.VariableNames;
            %if ismember('refImageFiles', columns_t1)
            %    t1 = removevars(t1,'refImageFiles');
            %end
            c = setdiff(columns_t1,official_fieldnames);
            c2 = setdiff(official_fieldnames,columns_t1);
            if ~isempty(c)
                t1(:, c) = [];
            end
            if ~isempty(c2)
                t1 = [t1 T(:,c2)];
            end

            if ~iscell(t1.motionBlurRange)
                t1.motionBlurRange = {t1.motionBlurRange};
            end
            if ~iscell(t1.pulseDelayStim)
                t1.pulseDelayStim = {t1.pulseDelayStim};
            end
             if ~iscell(t1.stimulationProtocol)
                t1.stimulationProtocol = {t1.stimulationProtocol};
             end
            if ~iscell(t1.softwareParams)
                t1.softwareParams = {t1.softwareParams};
            end
            if ~iscell(t1.behaviorVideo)
                t1.behaviorVideo = {t1.behaviorVideo};
            end
            if ~iscell(t1.pupillometryVideo)
                t1.pupillometryVideo = {t1.pupillometryVideo};
            end
            if ~iscell(t1.pupillometry_video_acq_struct)
                t1.pupillometry_video_acq_struct = {t1.pupillometry_video_acq_struct};
            end

            if j==1
                tf2 = t1;
            else
                %if i == 88 && j == 23
                %    lo = 0
                %end
                tf2 = [tf2; t1];
            end
        end
    end

    if(~isempty(tf2))

        tf = [tf; tf2];

        final_idx = height(tf);
        tf{initial_idx+1:final_idx,'DateFile'} = repmat(all_files(i),final_idx-initial_idx,1);

    end
end

cd(filePath);
save('all_sessions_animal_struct.mat', 'tf')




