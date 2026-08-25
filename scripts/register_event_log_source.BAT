@echo off
REM Register the U19-pipeline-matlab Windows Event Log source.
REM
REM Run this ONCE per rig machine, as Administrator (right-click ->
REM "Run as administrator"). Creating an event source writes to
REM HKLM\SYSTEM\CurrentControlSet\Services\EventLog, which is not writable
REM by a normal user -- that is why the nightly copy jobs, which run
REM unelevated, report:
REM
REM     Failed to write to Windows Event Log: ERROR: Access is denied.
REM
REM After this runs successfully, log_scheduled_task_event can write INFO /
REM WARNING / ERROR events to the Application log without elevation, and they
REM show up in Event Viewer under Windows Logs -> Application with the source
REM "U19-pipeline-matlab".
REM
REM This does NOT affect the Task Scheduler History tab. That tab is a
REM read-only view of the Microsoft-Windows-TaskScheduler/Operational channel,
REM which only the Task Scheduler service itself can write to. History shows
REM whether a run succeeded (via the exit code the .BAT wrappers propagate);
REM the Application log is where the details of why live.

setlocal

set "SOURCE_NAME=U19-pipeline-matlab"
set "REG_KEY=HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Application\%SOURCE_NAME%"

echo Registering Windows Event Log source "%SOURCE_NAME%"...
echo.

REM Verify we are actually elevated before touching HKLM, so the failure mode
REM is a clear message rather than an opaque access-denied from reg.exe.
net session >nul 2>&1
if errorlevel 1 (
    echo ERROR: This script must be run as Administrator.
    echo.
    echo        Right-click register_event_log_source.BAT and choose
    echo        "Run as administrator", then run it again.
    exit /b 1
)

REM Already registered? Then there is nothing to do; re-registering is
REM harmless but reporting it avoids confusion about whether it worked.
reg query "%REG_KEY%" >nul 2>&1
if not errorlevel 1 (
    echo Event source "%SOURCE_NAME%" is already registered. Nothing to do.
    exit /b 0
)

reg add "%REG_KEY%" /v EventMessageFile /t REG_EXPAND_SZ ^
    /d "%SystemRoot%\System32\EventCreate.exe" /f >nul
if errorlevel 1 goto :failed

REM Types supported: 1=ERROR, 2=WARNING, 4=INFORMATION -> 7 enables all three.
reg add "%REG_KEY%" /v TypesSupported /t REG_DWORD /d 7 /f >nul
if errorlevel 1 goto :failed

echo Successfully registered event source "%SOURCE_NAME%".
echo.
echo The nightly copy jobs will now log to Event Viewer under
echo   Windows Logs -^> Application   (Source: %SOURCE_NAME%)
exit /b 0

:failed
echo ERROR: Failed to register the event source.
echo        Confirm this prompt is elevated and that the registry is writable.
exit /b 1
