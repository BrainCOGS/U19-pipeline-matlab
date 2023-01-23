function recording_struct = get_recording_directories_behavior_key(key, recording_type)
% Function to get basic data (paths, recording_ids, job_ids, from subject, session, etc)
%Inputs
% key              = key to reference session, subject, etc.
% recording_type   = string ("with_behavior", "just_recording", "all") type of recording performed
% Outputs
% recording_struct = tnx1 struct with all jobs, recording_ids, paths and modalities of tables


config = dj.config;

% Assume is bheavior sessions if not provided
if nargin < 2
    recording_type = "with_behavior";
else
    recording_type = string(recording_type);
end

%Get recording_id <-> behavior sessions relationship from key
if recording_type == "with_behavior" || recording_type == "all" 
    recording_id_b = fetch(recording.RecordingBehaviorSession * proj(acquisition.Session, 'session_start_time') ...
        & key, '*');
else
    recording_id_b = [];
end

%Get recording_id <-> recirdunf sessions relationship from key
if recording_type == "just_recording" || recording_type == "all" 
    t_rec = proj(recording.RecordingRecordingSession, 'subject_fullname', 'date(recording_datetime)->session_date', ...
    '-1->session_number', 'recording_datetime->session_start_time');
    recording_id_r = fetch(t_rec & key, '*');
else
    recording_id_r = [];
end 

recording_structs = [recording_id_b; recording_id_r];

%If there were recordings associated
if ~isempty(recording_structs)    
    
    % Transform to table
    recording_structs = struct2table(recording_structs, 'AsArray', true);
    
    % look for job & recording data
    recording_ids = num2cell([recording_structs.recording_id]);
    rec_key = struct('recording_id', recording_ids);
    job_data = fetch(recording_process.Processing * proj(recording.Recording, 'recording_modality') & rec_key, ...
        'recording_process_pre_path','recording_process_post_path', 'recording_modality');
    
    %If there are associated jobs
    if ~isempty(job_data)

        
        %Fix paths for imaging & ephys respectively (with RootDirectroies from configuration)
        job_data = struct2table(job_data, 'AsArray', true);
        
        idx_imaging = strcmp(job_data.recording_modality, 'imaging');
        if ~isempty(idx_imaging)
        job_data.recording_process_pre_path(idx_imaging) = fullfile(config.custom.ImagingRootDataDir{1}, job_data.recording_process_pre_path(idx_imaging));
        job_data.recording_process_post_path(idx_imaging) = fullfile(config.custom.ImagingRootDataDir{2}, job_data.recording_process_post_path(idx_imaging));
        end
        idx_ephys = strcmp(job_data.recording_modality, 'electrophysiology');
        if ~isempty(idx_ephys)
        job_data.recording_process_pre_path(idx_ephys) = fullfile(config.custom.EphysRootDataDir{1}, job_data.recording_process_pre_path(idx_ephys));
        job_data.recording_process_post_path(idx_ephys) = fullfile(config.custom.EphysRootDataDir{2}, job_data.recording_process_post_path(idx_ephys));
        end
        %Fix for windows paths
        if ispc
            job_data.recording_process_pre_path = strrep(job_data.recording_process_pre_path,'/','\');
            job_data.recording_process_post_path = strrep(job_data.recording_process_post_path,'/','\');
        end
        
        %Merge data and transform to struct
        recording_struct = join(recording_structs,job_data);
        recording_struct = table2struct(recording_struct);
        
        
    else
        disp(recording_structs)
        error('jobs not found for current recordings')
    end
    
    
else
    error('key provided does not match any recording')
end
