%{
# Camera information for each recording
camera_id:                   int(11) AUTO_INCREMENT
-----
-> [nullable] lab.Location                  # In which Rig this camera is located
active=1:                    tinyint        # This camera is active (1) or has been replaced (0)
camera_type:                 varchar(64)    # Type of the camera used in video acquisition
camera_model:                varchar(64)    # Model of the camera used in video acquisition
camera_description:          varchar(128)   # Description for each camera used on video recordings
%}


classdef VideoDevice < dj.Lookup
    properties
        contents = {
            1, 'NULL',        1, 'default camera type', 'default model','Default camera';
            2, '165A-Rig5-T', 1, 'mwspinnakerimaq', 'mwspinnakerimaq_1','Pupillometry camera 1';
            3, '188-Rig2',    1, 'mwspinnakerimaq', 'mwspinnakerimaq_2','Pupillometry camera 2';
            }
    end
end