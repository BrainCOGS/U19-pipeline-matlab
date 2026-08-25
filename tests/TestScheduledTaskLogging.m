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
    end

    methods(TestMethodSetup)
        function isolate_log(testCase)
            % Point the fallback log at a scratch dir so tests never append to
            % a real rig log.
            testCase.LogDir = fullfile(tempdir, 'u19_scheduled_task_logs');
            if exist(testCase.LogDir, 'dir')
                log_file = fullfile(testCase.LogDir, 'scheduled_tasks.log');
                if exist(log_file, 'file')
                    delete(log_file);
                end
            end
        end
    end

    methods(Static)
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

            log_file = fullfile(testCase.LogDir, 'scheduled_tasks.log');
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

            contents = fileread(fullfile(testCase.LogDir, 'scheduled_tasks.log'));
            testCase.verifySubstring(contents, 'first entry');
            testCase.verifySubstring(contents, 'second entry');
        end

        function testMultilineMessageStaysOneLogLine(testCase)
        % Corner case: embedded newlines would otherwise corrupt the one
        % event per line structure the log relies on.
            msg = sprintf('line one\nline two\nline three');
            evalc('log_scheduled_task_event(''t'', ''ERROR'', msg)');

            contents = fileread(fullfile(testCase.LogDir, 'scheduled_tasks.log'));
            entry_lines = strsplit(strtrim(contents), newline);
            testCase.verifyEqual(numel(entry_lines), 1, ...
                'multi-line message was not flattened to a single log line');
            testCase.verifySubstring(contents, 'line one | line two | line three');
        end

        function testEmptyMessageIsHandled(testCase)
        % Corner case around empty input: must not error.
            testCase.verifyWarningFree( ...
                @() evalc('log_scheduled_task_event(''t'', ''INFO'', '''')'));

            contents = fileread(fullfile(testCase.LogDir, 'scheduled_tasks.log'));
            testCase.verifySubstring(contents, '[INFO]');
        end

        function testEchoesToStdout(testCase)
        % Task Scheduler captures stdout, so this is the zero-config record.
            output = evalc('log_scheduled_task_event(''copy_Test_Files'', ''WARNING'', ''on stdout'')');
            testCase.verifySubstring(output, 'copy_Test_Files');
            testCase.verifySubstring(output, 'on stdout');
            testCase.verifySubstring(output, '[WARNING]');
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
