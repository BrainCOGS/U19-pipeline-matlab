
@echo off

set "this_pwd=%cd%"

matlab -nosplash -nodesktop -batch "run 'C:\Experiments\U19-pipeline-matlab\scripts\copy_video_files\copy_video_files_script.m';"

cd %this_pwd%