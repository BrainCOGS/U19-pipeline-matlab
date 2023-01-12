
@echo off

set "this_pwd=%cd%"

cd C:\Experiments\ViRMEn
matlab -nosplash -nodesktop -batch "run '..\U19-pipeline-matlab\scripts\copy_behavior_files\copy_behavior_files_script.m';"

cd %this_pwd%