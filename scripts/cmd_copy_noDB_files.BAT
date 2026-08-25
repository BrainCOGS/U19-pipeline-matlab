@echo off
REM Nightly copy_noDB_files job.
REM
REM MATLAB's console output is redirected to a transcript file. Under Task
REM Scheduler there is no console attached, so without this redirect anything
REM MATLAB prints -- including an error thrown before the logging utilities
REM are reachable -- is discarded. The transcript is the record of last
REM resort; scheduled_tasks.log holds the structured events.

setlocal

set "this_pwd=%cd%"
set "LOG_DIR=C:\Experiments\scheduled_task_logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" 2>nul

cd C:\Experiments\U19-pipeline-matlab
matlab -nosplash -nodesktop -batch "run '.\scripts\copy_noDB_files\copy_noDB_files_script.m';" >> "%LOG_DIR%\copy_noDB_files_transcript.log" 2>&1
set "matlab_exit=%ERRORLEVEL%"

cd %this_pwd%
exit /b %matlab_exit%
