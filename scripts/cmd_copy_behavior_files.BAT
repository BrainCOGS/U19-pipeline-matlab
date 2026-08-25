@echo off
REM Nightly copy_behavior_files job.
REM
REM MATLAB's console output is redirected to a per-run transcript. Under Task
REM Scheduler there is no console attached, so without this redirect anything
REM MATLAB prints -- including an error thrown before the logging utilities
REM are reachable -- is discarded.
REM
REM The transcript filename carries a timestamp so consecutive runs never
REM write into the same file; raw MATLAB output has no per-line timestamps of
REM its own, so appending runs together would make them impossible to tell
REM apart. Structured events go to scheduled_tasks_YYYYMMDD.log instead, which
REM is timestamped per line and therefore safe to append.
REM
REM Transcripts older than the retention window below are pruned on each run.

setlocal enabledelayedexpansion

set "this_pwd=%cd%"
set "LOG_DIR=C:\Experiments\scheduled_task_logs"
set "RETENTION_DAYS=90"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" 2>nul

REM Build a sortable yyyyMMdd_HHmmss stamp. Deliberately not derived from
REM %DATE%/%TIME%, whose formats vary with the machine's locale. PowerShell is
REM the primary source; WMIC is a fallback for older images, and is tried
REM second because it is deprecated and absent on current Windows 11.
set "STAMP="
for /f "usebackq tokens=*" %%t in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')" 2^>nul`) do set "STAMP=%%t"

if not defined STAMP (
    for /f "skip=1 tokens=1-6 delims= " %%a in ('wmic path Win32_LocalTime get Day^,Hour^,Minute^,Month^,Second^,Year /format:table 2^>nul') do (
        if not defined STAMP if not "%%f"=="" (
            set "yyyy=%%f"
            set "MM=00%%d" & set "dd=00%%a"
            set "HH=00%%b" & set "mi=00%%c" & set "ss=00%%e"
            set "STAMP=!yyyy!!MM:~-2!!dd:~-2!_!HH:~-2!!mi:~-2!!ss:~-2!"
        )
    )
)

REM Last resort: a PID-based suffix still keeps concurrent runs in separate
REM files, which matters more here than the name being human-readable.
if not defined STAMP set "STAMP=nodate_%RANDOM%"

set "TRANSCRIPT=%LOG_DIR%\copy_behavior_files_!STAMP!.log"

cd C:\Experiments\U19-pipeline-matlab
matlab -nosplash -nodesktop -batch "run '.\scripts\copy_behavior_files\copy_behavior_files_script.m';" > "!TRANSCRIPT!" 2>&1
set "matlab_exit=!ERRORLEVEL!"

REM Prune transcripts and structured logs past the retention window. Best
REM effort: a failure here must never change the job's exit code.
forfiles /p "%LOG_DIR%" /m "copy_behavior_files_*.log" /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1
forfiles /p "%LOG_DIR%" /m "scheduled_tasks_*.log" /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1

cd %this_pwd%
exit /b %matlab_exit%
