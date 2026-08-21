
@echo off

set "this_pwd=%cd%"

cd C:\Experiments\U19-pipeline-matlab
matlab -nosplash -nodesktop -batch "run '.\scripts\copy_noDB_files\copy_noDB_files_script.m';"
set "matlab_exit=%ERRORLEVEL%"

cd %this_pwd%
exit /b %matlab_exit%
