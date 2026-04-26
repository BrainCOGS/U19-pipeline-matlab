
@echo off

set "this_pwd=%cd%"

cd C:\Experiments\U19-pipeline-matlab
matlab -nosplash -nodesktop -batch "run '.\scripts\copy_behavior_files\copy_behavior_files_script.m';"

cd %this_pwd%