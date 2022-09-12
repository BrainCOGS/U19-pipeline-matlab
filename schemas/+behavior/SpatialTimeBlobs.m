%{
-> acquisition.Session
-> behavior.TowersSession
---
iteration_matrix:           blob@behaviortimespatialblobs   # block-trial-iteration reference matrix
trial_time:                 blob@behaviortimespatialblobs   # time series of this trial, start from zero for each trial
cumulative_session_time:    blob@behaviortimespatialblobs   # time series of this trial, start from last trial time
collision:                  blob@behaviortimespatialblobs   # boolean vector indicating whether the subject hit the maze on each time point
position:                   blob@behaviortimespatialblobs   # 3d recording of the position of the mouse, length equals to interations
velocity:                   blob@behaviortimespatialblobs   # 3d recording of the velocity of the mouse, length equals to interations
sensor_dots:                blob@behaviortimespatialblobs   # raw recordings of the ball
%}

classdef SpatialTimeBlobs < dj.Imported
    properties
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            data_dir = fetch1(acquisition.SessionStarted & key, 'remote_path_behavior_file');
            
            %Load behavioral file
            try
                [~, data_dir] = lab.utils.get_path_from_official_dir(data_dir);
                data = load(data_dir,'log');
                log = data.log;
                status = 1;
            catch
                disp(['Could not open behavioral file: ', data_dir])
                status = 0;
            end
            if status
                try
                    %Check if it is a real behavioral file
                    if isfield(log, 'session')
                        %Insert Blocks and trails from BehFile
                        self.insertSpatialTimeBlob(key,log)
                    else
                        disp(['File does not match expected Towers behavioral file: ', data_dir])
                    end
                catch err
                    disp(err.message)
                    sprintf('Error in here: %s, %s, %d',err.stack(1).file, err.stack(1).name, err.stack(1).line )
                end
            end
            
        end
        
    end
    
    % Public methods
    methods
        function insertSpatialTimeBlob(self, key,log)
            % Insert spatialtime blobs from behavior file
            
            spatial_time_struct = behavior.SpatialTimeBlobs.get_spatial_time_vars_session(log);
            
            key.iteration_matrix        = spatial_time_struct.iteration_matrix;
            key.trial_time              = spatial_time_struct.trial_time;
            key.cumulative_session_time = spatial_time_struct.cumulative_session_time;
            key.position                = spatial_time_struct.position;
            key.velocity                = spatial_time_struct.velocity;
            key.collision               = spatial_time_struct.collision;
            key.sensor_dots             = spatial_time_struct.sensor_dots;
            
            self.insert(key);
            
        end
                
    end
    
    methods (Static)
        
         function spatial_time_struct = get_spatial_time_vars_session(log)
            % Get a structure with all spatial & time variables and block-trial-iteration correspondence
            %Returns struct with next fields:
            % block
            % trial
            % iteration
            % trial_time
            % session_time
            % sensor_dots
            % position
            % velocity
            % collision
            
            % Matrices that will be appended for each trial
            iteration_matrix      = [];
            trial_time_final      = [];
            session_time_final    = [];
            position_session      = [];
            velocity_session      = [];
            collision_session     = [];
            sensor_dots_session   = [];
            
            %Check if timeElapsedFirstTrial is stored on behavior file
            timeElapsedFirstTrial = 0;
            offset_time = 0;
            if isfield(log,'timeElapsedFirstTrial') && ~isempty(log.timeElapsedFirstTrial)
                timeElapsedFirstTrial = log.timeElapsedFirstTrial;
            end
            
            % For each block
            for i = 1:length(log.block)
                
                %Get all trial data and number of trials
                trials = log.block(i).trial;
                nTrials = length([trials.choice]);
                
                for j = 1:nTrials
                    
                    current_trial = trials(j);
                    
                    % For 2nd block onwards
                    if i > 1
                        %Check if it's a restart case scenario
                        if j==1
                            if current_trial.start < end_block_relative_time
                                offset_time = seconds(datetime(log.block(i).start) - datetime(log.block(1).start));
                            else
                                offset_time = 0;
                            end
                        end
                    end
                    
                    
                    %Get time for each iteration of current trial
                    time_session =  current_trial.start+current_trial.time+ timeElapsedFirstTrial + offset_time;
                    time_trial   =  current_trial.time;
                    
                    %Block-trial-iteration number for the current trial
                    iteration_num = [1:length(time_trial)]';
                    block_num = ones(size(iteration_num))*i;
                    trial_num = ones(size(iteration_num))*j;
                    
                    % Spatial vars
                    sensor_dots      =  current_trial.sensorDots;
                    
                    % Get missing iterations from position, velocity, etc.
                    missing_pos_iter = length(time_trial) - length(current_trial.position);
                    position         = [current_trial.position; nan(missing_pos_iter,3)];
                    velocity         = [current_trial.velocity; nan(missing_pos_iter,3)];
                    collision        = [current_trial.collision; nan(missing_pos_iter,1)];
                    
                    % Store last time of the trial to check for future restart scenarios
                    if j==nTrials
                        end_block_relative_time = time_session(end);
                    end
                    
                    %Append data matrices
                    this_iteration_matrix = [block_num trial_num iteration_num];
                    iteration_matrix = [iteration_matrix; this_iteration_matrix];
                    
                    trial_time_final      = [trial_time_final; time_trial];
                    session_time_final    = [session_time_final; time_session];
                    position_session      = [position_session; position];
                    velocity_session      = [velocity_session; velocity];
                    collision_session     = [collision_session; collision];
                    sensor_dots_session   = [sensor_dots_session; sensor_dots];
                    
                    
                end
                
            end
            
            % Get all matrices in a struct
            spatial_time_struct.iteration_matrix        = iteration_matrix;
            spatial_time_struct.trial_time              = trial_time_final;
            spatial_time_struct.cumulative_session_time = session_time_final;
            spatial_time_struct.position                = position_session;
            spatial_time_struct.velocity                = velocity_session;
            spatial_time_struct.collision               = collision_session;
            spatial_time_struct.sensor_dots             = sensor_dots_session;
            
            
        end
        
    end
    
    
end




%% fix logs where trial type and choice are not recorded due to bug (Sue Ann's old sessions)
function block = fixLogs(block)

for iBlock = 1:numel(block)
    
    %Correct number of trials when there are empty trials in block
    nTrials = length([block(iBlock).trial.choice]);
    block(iBlock).trial = block(iBlock).trial(1:nTrials);
    
    nTrials = numel(block(iBlock).trial);
    for iTrial = 1:nTrials
        if isempty(block(iBlock).trial(iTrial).trialType)
            if numel(block(iBlock).trial(iTrial).cuePos{1}) > numel(block(iBlock).trial(iTrial).cuePos{1})
                block(iBlock).trial(iTrial).trialType = Choice.L;
            else
                block(iBlock).trial(iTrial).trialType = Choice.R;
            end
        end
        if isempty(block(iBlock).trial(iTrial).choice)
            pos = block(iBlock).trial(iTrial).position;
            if pos(end,2) < 300
                block(iBlock).trial(iTrial).choice   = Choice.nil;
            else
                if pos(end,3) > 0
                    block(iBlock).trial(iTrial).choice = Choice.L;
                else
                    block(iBlock).trial(iTrial).choice = Choice.R;
                end
            end
        end
    end
    block(iBlock).trialType      = [block(iBlock).trial(:).trialType];
    block(iBlock).medianTrialDur = median([block(iBlock).trial(:).duration]);
end


end


