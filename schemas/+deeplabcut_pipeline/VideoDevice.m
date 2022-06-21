%{
# Camera information for each recording
camera_id                   : int AUTO_INCREMENT            # 
---
-> `u19_lab`.`#location`
-> deeplabcut_pipeline.VideoType
active=1                    : tinyint                       # This camera is active (1) or has been replaced (0)
camera_type                 : varchar(64)                   # Type of the camera used in video acquisition
camera_model                : varchar(64)                   # Model of the camera used in video acquisition
camera_description          : varchar(128)                  # Description for each camera used on video recordings
%}


classdef VideoDevice < dj.Lookup
    properties
        contents = {
            1, 'NULL',        'NULL',         1, 'default camera type', 'default model','Default camera';
            2, '165A-Rig5-T', 'pupillometry', 1, 'mwspinnakerimaq', 'mwspinnakerimaq_1','Pupillimetry camera 1';
            3, '188-Rig2',    'pupillometry', 1, 'mwspinnakerimaq', 'mwspinnakerimaq_2','Pupillimetry camera 2';
            }
    end
end
