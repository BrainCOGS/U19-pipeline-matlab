function behavior_filepath = create_new_behavior_filename(local_behavior_filename,subject_fullname, session_date, session_number)
%create the path for a behavior file on the unified path given the session data
% Inputs
% local_behavior_filename    = Local path to be transformed (e.g. path where session is stored) 
% (e.g.'C:\Data\lucas\blocksReboot\data\gps1\PoissonBlocksReboot_cohort1_TrainVR1_gps1_T_20201021.mat')
% subject_fullname           = Subject for the session
% session_date               = Session date for the session
% session_number             = Session number for the session
% Outputs
% behavior_filepath          = Path in the unified cup filepath for behavior files
% (e.g. /braininit/Data/Raw/behavior/lpinto/lpinto_gps1/20201021_g0/PoissonBlocksReboot_cohort1_TrainVR1_gps1_T_20201021.mat)


%Get fileparts from local path
if ~ispc
    local_behavior_filename = strrep(local_behavior_filename,'\','/');
end
[~, filename, ext] = fileparts(local_behavior_filename);

% Get userid for subject
user_query.subject_fullname = subject_fullname;
user_id = fetch1(subject.Subject & user_query,'user_id');

%Format session date
session_date = [session_date(1:4) session_date(6:7) session_date(9:10)];

%get behaviorRootDataDir and use it for filepath
dj_custom_variables = lab.utils.get_dj_custom_variables();
behavior_filepath = fullfile(dj_custom_variables.BehaviorRootDataDir, user_id, subject_fullname, ...
    [session_date '_g' num2str(session_number)], [filename, ext]);


end

