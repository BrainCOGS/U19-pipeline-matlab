classdef TestScheduledTaskLogging < matlab.unittest.TestCase
% Tests for log_scheduled_task_event's durable logging and warning behaviour.
%
% The Windows Event Log path is guarded by ispc, so on non-Windows these
% exercise the stdout echo and the fallback log file. The warning-dedup logic
% is checked at source level, since triggering it needs a Windows box where
% the event source is unregistered.
%
% Regression context: the nightly jobs emitted
%   Failed to write to Windows Event Log: ERROR: Access is denied.
% on EVERY logged event, because the U19-pipeline-matlab event source was
% never registered (that needs Administrator). The noise buried real output
% and no durable record survived the run.

    properties
        LogDir
        LogFile
    end

    methods(TestMethodSetup)
        function isolate_log(testCase)
            % Point the fallback log at a scratch dir so tests never append to
            % a real rig log.
            [log_file, log_dir] = scheduled_task_log_path();
            testCase.LogDir = log_dir;
            testCase.LogFile = log_file;
            if exist(log_file, 'file')
                delete(log_file);
            end
        end
    end

    methods(Static)
        function files = wrapper_files()
            files = {'scripts/cmd_copy_behavior_files.BAT', ...
                     'scripts/cmd_copy_video_files.BAT', ...
                     'scripts/cmd_copy_noDB_files.BAT'};
        end

        function txt = read_repo_file(relative_path)
            here = fileparts(fileparts(mfilename('fullpath')));
            parts = strsplit(relative_path, '/');
            txt = fileread(fullfile(here, parts{:}));
        end

        function txt = logger_source()
            here = fileparts(fileparts(mfilename('fullpath')));
            txt = fileread(fullfile(here, 'utils', 'miscelaneous', ...
                'log_scheduled_task_event.m'));
        end
    end

    methods(Test)

        function testRejectsInvalidLevel(testCase)
            testCase.verifyError( ...
                @() log_scheduled_task_event('t', 'CRITICAL', 'msg'), ...
                'log_scheduled_task_event:InvalidLevel');
            testCase.verifyError( ...
                @() log_scheduled_task_event('t', '', 'msg'), ...
                'log_scheduled_task_event:InvalidLevel');
            testCase.verifyError( ...
                @() log_scheduled_task_event('t', 'info', 'msg'), ...
                'log_scheduled_task_event:InvalidLevel');
        end

        function testAcceptsEveryValidLevel(testCase)
            for level = {'INFO', 'WARNING', 'ERROR'}
                testCase.verifyWarningFree( ...
                    @() evalc(sprintf( ...
                        'log_scheduled_task_event(''t'', ''%s'', ''msg'')', level{1})));
            end
        end

        function testWritesFallbackLogFile(testCase)
        % The durable record is the point: an event must survive the run even
        % when Event Viewer is unavailable.
            evalc('log_scheduled_task_event(''copy_Test_Files'', ''INFO'', ''hello world'')');

            log_file = testCase.LogFile;
            testCase.assertTrue(exist(log_file, 'file') == 2, ...
                'fallback log file was not created');

            contents = fileread(log_file);
            testCase.verifySubstring(contents, 'copy_Test_Files');
            testCase.verifySubstring(contents, 'hello world');
            testCase.verifySubstring(contents, '[INFO]');
        end

        function testFallbackLogAppendsRatherThanTruncates(testCase)
        % A run logs many events; each must be kept.
            evalc('log_scheduled_task_event(''t'', ''INFO'', ''first entry'')');
            evalc('log_scheduled_task_event(''t'', ''ERROR'', ''second entry'')');

            contents = fileread(testCase.LogFile);
            testCase.verifySubstring(contents, 'first entry');
            testCase.verifySubstring(contents, 'second entry');
        end

        function testMultilineMessageStaysOneLogLine(testCase)
        % Corner case: embedded newlines would otherwise corrupt the one
        % event per line structure the log relies on.
            msg = sprintf('line one\nline two\nline three');
            evalc('log_scheduled_task_event(''t'', ''ERROR'', msg)');

            contents = fileread(testCase.LogFile);
            entry_lines = strsplit(strtrim(contents), newline);
            testCase.verifyEqual(numel(entry_lines), 1, ...
                'multi-line message was not flattened to a single log line');
            testCase.verifySubstring(contents, 'line one | line two | line three');
        end

        function testEmptyMessageIsHandled(testCase)
        % Corner case around empty input: must not error.
            testCase.verifyWarningFree( ...
                @() evalc('log_scheduled_task_event(''t'', ''INFO'', '''')'));

            contents = fileread(testCase.LogFile);
            testCase.verifySubstring(contents, '[INFO]');
        end

        function testEchoesToStdout(testCase)
        % Task Scheduler captures stdout, so this is the zero-config record.
            output = evalc('log_scheduled_task_event(''copy_Test_Files'', ''WARNING'', ''on stdout'')');
            testCase.verifySubstring(output, 'copy_Test_Files');
            testCase.verifySubstring(output, 'on stdout');
            testCase.verifySubstring(output, '[WARNING]');
        end

        function testLogFileNameCarriesDate(testCase)
        % Daily rotation: the name must encode the day so runs from different
        % days never share a file.
            log_file = scheduled_task_log_path(datetime(2026, 8, 24, 21, 7, 41));
            [~, name] = fileparts(log_file);
            testCase.verifyEqual(name, 'scheduled_tasks_20260824');
        end

        function testDifferentDaysGetDifferentFiles(testCase)
            a = scheduled_task_log_path(datetime(2026, 8, 24));
            b = scheduled_task_log_path(datetime(2026, 8, 25));
            testCase.verifyNotEqual(a, b, ...
                'two different days resolved to the same log file');
        end

        function testSameDayGetsSameFile(testCase)
        % Within a day the log appends, so a whole day stays greppable in one
        % file. Different times on one date must resolve identically.
            a = scheduled_task_log_path(datetime(2026, 8, 24, 0, 0, 1));
            b = scheduled_task_log_path(datetime(2026, 8, 24, 23, 59, 59));
            testCase.verifyEqual(a, b);
        end

        function testDatePartIsZeroPadded(testCase)
        % Corner case: single-digit months/days must pad, or lexical sorting
        % of filenames breaks.
            log_file = scheduled_task_log_path(datetime(2026, 1, 5));
            [~, name] = fileparts(log_file);
            testCase.verifyEqual(name, 'scheduled_tasks_20260105');
        end

        function testDefaultsToToday(testCase)
            expected = scheduled_task_log_path(datetime('now'));
            testCase.verifyEqual(scheduled_task_log_path(), expected);
            testCase.verifyEqual(scheduled_task_log_path([]), expected);
        end

        function testReturnsDirectoryAlongsidePath(testCase)
            [log_file, log_dir] = scheduled_task_log_path();
            testCase.verifyEqual(fileparts(log_file), log_dir);
        end

        function testWrappersUseTimestampedTranscripts(testCase)
        % Raw MATLAB output has no per-line timestamps, so appending runs into
        % one transcript makes them impossible to separate. Each run needs its
        % own file, and the stamp must sort chronologically.
            for bat = TestScheduledTaskLogging.wrapper_files()
                txt = TestScheduledTaskLogging.read_repo_file(bat{1});
                testCase.verifyNotEmpty(regexp(txt, 'Get-Date', 'once'), ...
                    sprintf(['%s does not build a locale-independent timestamp; ' ...
                             '%%DATE%%/%%TIME%% formats vary per machine.'], bat{1}));
                testCase.verifyNotEmpty(regexp(txt, 'Win32_LocalTime', 'once'), ...
                    sprintf(['%s has no WMIC fallback for images without ' ...
                             'PowerShell.'], bat{1}));
                testCase.verifyNotEmpty(regexp(txt, 'STAMP', 'once'), ...
                    sprintf('%s does not stamp the transcript name', bat{1}));
                testCase.verifyEmpty(regexp(txt, '>>\s*"', 'once'), ...
                    sprintf(['%s still appends to a shared transcript instead of ' ...
                             'writing a per-run file.'], bat{1}));
            end
        end

        function testWrappersPruneOldLogs(testCase)
        % Retention: logs are kept 90 days, then deleted, so the rigs do not
        % fill up. Both transcripts and structured logs must be covered.
            for bat = TestScheduledTaskLogging.wrapper_files()
                txt = TestScheduledTaskLogging.read_repo_file(bat{1});
                testCase.verifyNotEmpty(regexp(txt, 'RETENTION_DAYS=90', 'once'), ...
                    sprintf('%s does not set a 90 day retention window', bat{1}));
                testCase.verifyNotEmpty( ...
                    regexp(txt, 'forfiles[^\n]*scheduled_tasks_\*\.log', 'once'), ...
                    sprintf('%s does not prune old structured logs', bat{1}));
                testCase.verifyNotEmpty( ...
                    regexp(txt, 'forfiles[^\n]*_\*\.log', 'once'), ...
                    sprintf('%s does not prune old transcripts', bat{1}));
            end
        end

        function testWrappersCaptureExitCodeBeforePruning(testCase)
        % The prune runs after MATLAB, so the exit code must be captured first
        % or forfiles' status would silently replace the job's real result.
            for bat = TestScheduledTaskLogging.wrapper_files()
                txt = TestScheduledTaskLogging.read_repo_file(bat{1});
                capture_idx = regexp(txt, 'matlab_exit=', 'once');
                prune_idx = regexp(txt, 'forfiles', 'once');
                testCase.verifyNotEmpty(capture_idx, ...
                    sprintf('%s never captures the MATLAB exit code', bat{1}));
                testCase.verifyLessThan(capture_idx, prune_idx, ...
                    sprintf(['%s prunes before capturing the exit code, so the ' ...
                             'job would report the prune result instead.'], bat{1}));
            end
        end

        function testEventLogWarningIsDeduplicated(testCase)
        % The regression. A persistent flag must gate the warning so it fires
        % once per session instead of once per logged event.
            src = TestScheduledTaskLogging.logger_source();
            testCase.verifyNotEmpty(regexp(src, 'persistent\s+already_warned', 'once'), ...
                ['log_scheduled_task_event has no persistent guard on the Event ' ...
                 'Log warning; it will fire on every logged event again.']);
            testCase.verifyNotEmpty(regexp(src, 'already_warned\s*=\s*true', 'once'), ...
                'the dedup guard is never set, so it cannot suppress anything');
        end

        function testAccessDeniedMentionsRegistrationScript(testCase)
        % An operator hitting this needs to know the fix, not just the symptom.
            src = TestScheduledTaskLogging.logger_source();
            testCase.verifyNotEmpty( ...
                regexp(src, 'register_event_log_source\.BAT', 'once'), ...
                ['the Access-is-denied warning should name ' ...
                 'register_event_log_source.BAT as the remedy']);
        end

        function testRegistrationScriptChecksForElevation(testCase)
        % Registering the source touches HKLM; without an elevation check the
        % failure is an opaque access-denied from reg.exe.
            here = fileparts(fileparts(mfilename('fullpath')));
            bat = fileread(fullfile(here, 'scripts', 'register_event_log_source.BAT'));
            testCase.verifyNotEmpty(regexp(bat, 'net session', 'once'), ...
                'registration script does not verify it is running elevated');
            testCase.verifyNotEmpty(regexp(bat, 'TypesSupported', 'once'), ...
                'registration script does not set TypesSupported');
            testCase.verifyNotEmpty(regexp(bat, 'EventMessageFile', 'once'), ...
                'registration script does not set EventMessageFile');
        end

    end
end
