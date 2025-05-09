%{
# subject information
subject_fullname            : varchar(64)                   # <username>_<subject_nickname>
---
subject_nickname            : varchar(16)                   # nickname
-> lab.User
genomics_id=null            : int                           # number from the facility
sex="Unknown"               : enum('Male','Female','Unknown') # sex
dob=null                    : date                          # birth date
head_plate_mark=null        : blob                          # little drawing on the head plate for mouse identification
-> lab.Location
-> lab.Protocol
-> subject.Line
subject_description=''      : varchar(255)                  # description
initial_weight=null         : float                         # initial weight of the animal before the training start.
notification_enabled=1      : tinyint                       # Boolean to control wheter or not notifications for this subject are sent
need_reweight=0             : tinyint                       # Boolean flag for weighting GUI to notify technician to reweight subject if too thin and extra water
headplate_image_path=null  : varchar(4096)
%}

classdef Subject < dj.Manual
end
