
try
    last_id = fetch1(InputOutputProfile,'input_output_profile_id', ['ORDER BY input_output_profile_id desc LIMIT 1']);
catch err
    last_id = 0;
end

%Basic Tower Task 
iop1 = struct();
iop1.user_id = 'testuser';
iop1.input_output_profile_name = 'BasicTowersTask';
iop1.input_output_profile_description = 'Input Output for basic TowersTask';
iop1.input_output_profile_date = '2024-09-06';


iopl1 = scheduler.utils.create_input_output_profile_list(last_id, {'Arduino', 'MotionSensor', 'Speakers', 'Reward'}, {'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory'});
scheduler.utils.insert_input_output_profile(iop1, iopl1)


%Basic Tower Task + Opto
last_id = last_id+1;
iop1 = struct();
iop1.user_id = 'testuser';
iop1.input_output_profile_name = 'TowersTask+Opto';
iop1.input_output_profile_description = 'Input Output for TowersTask+Opto';
iop1.input_output_profile_date = '2024-09-06';


iopl1 = scheduler.utils.create_input_output_profile_list(last_id, {'Arduino', 'MotionSensor', 'Speakers', 'Reward', 'Laser'}, ...
                                                  {'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory'});
scheduler.utils.insert_input_output_profile(iop1, iopl1);

%Basic Tower Task + Puff
last_id = last_id+1;
iop1 = struct();
iop1.user_id = 'testuser';
iop1.input_output_profile_name = 'TowersTask+PuffTask';
iop1.input_output_profile_description = 'Input Output for TowersTask+PuffTask';
iop1.input_output_profile_date = '2024-09-06';


iopl1 = scheduler.utils.create_input_output_profile_list(last_id, {'Arduino', 'MotionSensor', 'Speakers', 'Reward', 'LeftPuff', 'RightPuff'}, ...
                                                  {'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory'});
scheduler.utils.insert_input_output_profile(iop1, iopl1);

%Basic Tower Task + OptoPuff
last_id = last_id+1;
iop1 = struct();
iop1.user_id = 'testuser';
iop1.input_output_profile_name = 'TowersTask+Puff+OptoTask';
iop1.input_output_profile_description = 'Input Output for TowersTask+PuffTask';
iop1.input_output_profile_date = '2024-09-06';


iopl1 = scheduler.utils.create_input_output_profile_list(last_id, {'Arduino', 'MotionSensor', 'Speakers', 'Reward', 'Laser', 'LeftPuff', 'RightPuff'}, ...
                                                  {'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory'});
scheduler.utils.insert_input_output_profile(iop1, iopl1);

%Basic Tower Task + LickResponse
last_id = last_id+1;
iop1 = struct();
iop1.user_id = 'testuser';
iop1.input_output_profile_name = 'TowersTask+LickResponse';
iop1.input_output_profile_description = 'Input Output for TowersTask+Lickometer';
iop1.input_output_profile_date = '2024-09-06';


iopl1 = scheduler.utils.create_input_output_profile_list(last_id, {'Arduino', 'MotionSensor', 'LateralCamera', 'TopCamera', 'Motors',    'Speakers', 'LeftReward', 'RightReward', 'Lickometer'}, ...
                                                  {'Mandatory', 'Mandatory',  'Optional',      'Optional', 'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory',   'Mandatory'});
scheduler.utils.insert_input_output_profile(iop1, iopl1);

%Basic Tower Task + LickResponse + Pupillometry
last_id = last_id+1;
iop1 = struct();
iop1.user_id = 'testuser';
iop1.input_output_profile_name = 'TowersTask+Lick+Pupillometry';
iop1.input_output_profile_description = 'Input Output for TowersTask+Lickometer+Pupillometry';
iop1.input_output_profile_date = '2024-09-06';


iopl1 = scheduler.utils.create_input_output_profile_list(last_id, {'Arduino', 'MotionSensor', 'LateralCamera', 'TopCamera', 'Motors',    'Speakers', 'LeftReward', 'RightReward', 'Lickometer'}, ...
                                                  {'Mandatory', 'Mandatory',  'Optional',      'Optional', 'Mandatory', 'Mandatory', 'Mandatory', 'Mandatory',   'Mandatory'});
scheduler.utils.insert_input_output_profile(iop1, iopl1);






% 
% 
%         AllTests = {'Arduino', 'MotionSensor', 'LateralCamera', 'TopCamera', 'Speakers', 'Motors', 'Reward', 'Laser', ...
%             'LeftPuff', 'RightPuff', 'LeftReward', 'RightReward', 'Lickometer'};
% 
% 
%         TestTableProp = {'TestName', 'Component', 'Switch', 'Check', 'ReportCheckBox', 'Rowno',   'VisibleRows',  'RowHeight',    ...
%             'Active',  'Passed',  'Reported', 'Callback', 'SwitchCallbacks', 'Parameters', 'Direction',   ...
%             'Lamps', 'CorrOutputs', 'InputLogic'};
% 
%         TestTableType = {'cell',     'cell',      'cell',   'cell'  , 'cell',         'numeric', 'cell',         'cell'     ,    ...
%             'numeric', 'numeric',  'numeric' 'cell',      'cell',           'cell',     'categorical', ...
%             'cell',     'cell',     'categorical'};

%         TaskOptions = {'TowersTask', ...
%             'TowersTaskOpto', ...
%             'TowersTask_PuffTask', ...
%             'TowersTaskOpto_PuffTask', ...
%             'TowersTask_LickResponse', ...
%             'Only_Lasers'};
% 
%         TaskIdxTests = {[1, 2, 3, 4],    ...
%             [1, 2, 3, 4, 5], ...
%             [1, 2, 3, 4, 6, 7], ...
%             [1, 2, 3, 4, 5, 6, 7], ...
%         %    [1, 2, 3, 8, 9, 10], ...
%         %    5};

        %TaskOptionsDict = containers.Map(TestVRRig_2.TaskOptions, TestVRRig_2.TaskIdxTests)