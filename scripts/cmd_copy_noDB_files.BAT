
@echo off

set "this_pwd=%cd%"

cd C:\Experiments\U19-pipeline-matlab
matlab -nosplash -nodesktop -batch "run '.\scripts\copy_noDB_files\copy_noDB_files_script.m';"
set "matlab_exit=%ERRORLEVEL%"

if not "%matlab_exit%"=="0" (
    eventcreate /T WARNING /ID 1 /L APPLICATION /SO U19-pipeline-matlab /D "cmd_copy_noDB_files.BAT: MATLAB exited with code %matlab_exit%. See copy_noDB_Files task output for details." >nul 2>&1
)

cd %this_pwd%
exit /b %matlab_exit%
