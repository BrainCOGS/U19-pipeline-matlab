%{
# Input & Output needed RigParameters param for correct operation
-> scheduler.InputOutputRig                                # Input/Output for rig
rig_parameters_param         : varchar(32)                 # RigParameter needed param 
---
parameter_info               : varchar(128)                 # Additional info about parameter
%}


classdef InputOutputRigParameters < dj.Lookup


    properties
        contents = {
    'Arduino',          'arduinoPort',              'string (e.g COM1)';
    'MotionSensor',     'arduinoPort',              'string (e.g COM1)';
    'Laser',            'nidaqPort',                'integer';
    'Laser',            'laserChannel',             'integer';            
    'LeftPuff',         'nidaqPort',                'integer';
    'LeftPuff',         'leftPuffChannel',          'integer';
    'RightPuff',        'nidaqPort',                'integer';
    'RightPuff',        'rightPuffChannel',         'integer';
    'Reward',           'nidaqPort',                'integer';
    'Reward',           'rewardChannel',            'integer';
    'Reward',           'rewardDuration',           'float value';
    'LeftReward',       'leftRewardChannel',        'cell type with dev/port/channel (e.g {1,0,1})';
    'LeftReward',       'rewardDuration',           'float value';
    'RightReward',      'rightRewardChannel',       'cell type with dev/port/channel (e.g {1,0,1})';
    'RightReward',      'reward2Duration',          'float value';
    'AirFlowValve',     'airFlowValveChannel',      'cell type with dev/port/channel (e.g {1,0,1})';
    'Motors',           'MotorSerialCom',           'string (e.g COM1)'
    'ZaberActuator',    'ZaberActuatorCom',         'string (e.g COM1)'
    'Lickometer',       'nidaqLickPort',            'integer';            
    'Lickometer',       'leftLickChannel',          'integer';
    'Lickometer',       'rightLickChannel',         'integer';
    'LateralCamera',    'lateral_cam_adaptor_name', 'string (e.g. gentl)';
    'LateralCamera',    'lateral_cam_format',       'string (e.g. Mono8)';
    'LateralCamera',    'video_acquisition_rate',   'float value';
    'LateralCamera',    'video_gain',               'float value';
    'TopCamera',        'top_cam_adaptor_name',     'string (e.g. windvideo)';
    'TopCamera',        'top_cam_format',           'string (e.g. MJPG_800x600)';
            }
    end


end


