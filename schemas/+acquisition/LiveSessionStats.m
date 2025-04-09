%{
# General information of a session
-> subject.Subject
session_date                : date                          # date of experiment
session_number              : int                           # session number
block                       : int                           # current block
trial_idx                   : int                           # current trial
---
current_datetime            : datetime                      # at what time trial was written
total_trials                : int
level                       : int
sublevel=null               : int
num_trials_left             : int
num_trials_right            : int
performance=null            : float
performance_right=null      : float
performance_left=null       : float
bias=null                   : float
mean_duration_trial=null    : float
median_duration_trial=null  : float
%}
 
classdef LiveSessionStats < dj.Manual
 
 
 
end

