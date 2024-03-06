function [syncVideoFrame, syncBehavior] = sync_pupillometry_video(log, v)
%Get synchronization matrices for pupillometry video
%Inputs
% log = behavior file from Virmen
% v   = video object from pupillometry video
%Outputs
% syncVideoFrame = matrix with corresponding iteration for each video frame
% syncBehavior:  = matrix with corresponding video frame for each iteration


videoTimeVector = linspace(0, v.Duration, v.NumFrames)' + log.timeElapsedVideoStart;

%Get time matrix for each iteration on behavior file
timeMatrix = get_trial_iteration_time_matrix(log);

%% Sync matrix for video frames
temp_vect = videoTimeVector - timeMatrix(1,1);
temp_vect(temp_vect > 0) = [];
index_first = length(temp_vect);

%Sync signal for first video frame
syncVideoFrame = NaN(4, v.NumFrames,'single')';
syncVideoFrame(1:index_first-1,1) = videoTimeVector(1:index_first-1);
syncVideoFrame(index_first,:) = [videoTimeVector(index_first) timeMatrix(1,2:end)];


for i=index_first+1:length(syncVideoFrame)
    time_frame = videoTimeVector(i);
    
    % Find closest iteration for each videoFrame
    index_time_matrix = find(timeMatrix(:,1) > time_frame,1,'first');
    
    %If there is no iteration after video frame
    if ~isempty(index_time_matrix)
        syncVideoFrame(i,:) = [time_frame timeMatrix(index_time_matrix,2:end)];
    else
        syncVideoFrame(i,:) = [time_frame NaN NaN NaN];
    end
    
end

%% Sync matrix for behavior iterations
syncBehavior = NaN(5, size(timeMatrix,1),'single')';

for i=1:size(timeMatrix,1)
    time_iteration = timeMatrix(i,1);
    
    % Find closest video frame for each iteration
    index_time_matrix = find(videoTimeVector < time_iteration,1,'last');
    
    %If there is no video frame after iteration
    if ~isempty(index_time_matrix)
        syncBehavior(i,:) = [timeMatrix(i,:) index_time_matrix];
    else
        syncBehavior(i,:) = [timeMatrix(i,:) NaN];
    end
    
end

    