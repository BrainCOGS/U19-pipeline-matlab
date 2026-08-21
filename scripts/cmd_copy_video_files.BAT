
@echo off


cd C:\Experiments\U19-pipeline-matlab
matlab -nosplash -nodesktop -batch "run '.\scripts\copy_video_files\copy_video_files_script.m';"
set "matlab_exit=%ERRORLEVEL%"

if not "%matlab_exit%"=="0" (
    eventcreate /T WARNING /ID 1 /L APPLICATION /SO U19-pipeline-matlab /D "cmd_copy_video_files.BAT: MATLAB exited with code %matlab_exit%. See copy_Video_Files task output for details." >nul 2>&1
)

exit /b %matlab_exit%
