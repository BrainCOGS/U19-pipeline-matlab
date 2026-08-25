classdef TestScheduledTaskScripts < matlab.unittest.TestCase
% Regression tests for the nightly scheduled-task copy scripts.
%
% These are source-level checks only: they read the scripts as text and never
% execute them, so they run anywhere. The copy scripts themselves only run on
% the Windows rig machines (hardcoded C:/Experiments, RigParameters, a live
% DataJoint connection), so executing them here is not possible.
%
% Regression context: startup_scheduled_tasks.m used to end with a bare
% `clearvars`, which wiped the *caller's* workspace because it is a script and
% shares the workspace of whatever invoked it. Every variable a copy script set
% before the call -- notably task_name -- was silently destroyed, so the error
% handler died with "Unrecognized function or variable 'task_name'" instead of
% reporting the real failure.

    properties(Constant)
        ScriptFiles = { ...
            fullfile('scripts', 'copy_behavior_files', 'copy_behavior_files_script.m'), ...
            fullfile('scripts', 'copy_video_files',    'copy_video_files_script.m'), ...
            fullfile('scripts', 'copy_noDB_files',     'copy_noDB_files_script.m')};
    end

    methods(Static)
        function root = repo_root()
            root = fileparts(fileparts(mfilename('fullpath')));
        end

        function lines = read_lines(relative_path)
            full_path = fullfile(TestScheduledTaskScripts.repo_root(), relative_path);
            txt = fileread(full_path);
            txt = strrep(txt, sprintf('\r\n'), newline);
            lines = strsplit(txt, newline);
        end

        function idx = find_line(lines, pattern)
            hits = regexp(lines, pattern, 'once');
            idx = find(~cellfun(@isempty, hits), 1);
        end
    end

    methods(Test)

        function testStartupDoesNotClearCallerWorkspace(testCase)
        % The core regression. startup_scheduled_tasks is invoked as a script,
        % so a bare `clearvars` / `clear` destroys the caller's variables. Any
        % clearing must name the variables to remove.
            lines = TestScheduledTaskScripts.read_lines('startup_scheduled_tasks.m');
            for i = 1:numel(lines)
                code = strtrim(regexprep(lines{i}, '%.*$', ''));
                testCase.verifyEmpty( ...
                    regexp(code, '^(clearvars|clear)\s*;?$', 'once'), ...
                    sprintf(['startup_scheduled_tasks.m line %d clears the whole ' ...
                             'caller workspace; this destroys task_name in the ' ...
                             'copy scripts. Name the variables to clear instead.'], i));
            end
        end

        function testStartupStillClearsItsOwnTemporaries(testCase)
        % Guard the other direction: the scoped clearvars should still tidy up
        % the loop/toolbox temporaries the script leaks into the workspace.
            lines = TestScheduledTaskScripts.read_lines('startup_scheduled_tasks.m');
            joined = strjoin(lines, ' ');
            expected = {'parent_path', 'projects_update', 'pipeline_path', ...
                        'project_path', 'i', 'tbxlist', 'path', 'mym_folder', ...
                        'toolbox_load', 'idx', 'folder'};
            clear_idx = TestScheduledTaskScripts.find_line(lines, '^\s*clearvars\s+\S');
            testCase.verifyNotEmpty(clear_idx, ...
                'startup_scheduled_tasks.m no longer clears its own temporaries.');
            for k = 1:numel(expected)
                testCase.verifyNotEmpty( ...
                    regexp(joined, ['clearvars[^;]*\<' expected{k} '\>'], 'once'), ...
                    sprintf('startup_scheduled_tasks.m leaks temporary "%s"', expected{k}));
            end
        end

        function testStateDefinedBeforeTryBlock(testCase)
        % successful_task must be assigned before the try, so an early throw
        % (e.g. the cd to a missing directory) still leaves the trailing
        % `if successful_task` check and the registry insert well defined.
            for i = 1:numel(TestScheduledTaskScripts.ScriptFiles)
                relative_path = TestScheduledTaskScripts.ScriptFiles{i};
                lines = TestScheduledTaskScripts.read_lines(relative_path);

                try_line    = TestScheduledTaskScripts.find_line(lines, '^\s*try\s*$');
                assign_line = TestScheduledTaskScripts.find_line(lines, '^\s*successful_task\s*=');
                name_line   = TestScheduledTaskScripts.find_line(lines, '^\s*task_name\s*=');

                testCase.verifyNotEmpty(try_line, ...
                    sprintf('%s has no try block', relative_path));
                testCase.verifyNotEmpty(assign_line, ...
                    sprintf('%s never assigns successful_task', relative_path));
                testCase.verifyNotEmpty(name_line, ...
                    sprintf('%s never assigns task_name', relative_path));

                testCase.verifyLessThan(assign_line, try_line, ...
                    sprintf(['%s first assigns successful_task inside the try ' ...
                             'block; an early throw leaves it undefined for the ' ...
                             'trailing success check.'], relative_path));
                testCase.verifyLessThan(name_line, try_line, ...
                    sprintf('%s assigns task_name inside the try block', relative_path));
            end
        end

        function testCatchHandlerGuardsTaskName(testCase)
        % Defence in depth: even if something clobbers the workspace again, the
        % catch block must not raise an undefined-variable error that masks the
        % failure it exists to report.
            for i = 1:numel(TestScheduledTaskScripts.ScriptFiles)
                relative_path = TestScheduledTaskScripts.ScriptFiles{i};
                lines = TestScheduledTaskScripts.read_lines(relative_path);

                catch_line = TestScheduledTaskScripts.find_line(lines, '^\s*catch\s+err\s*$');
                guard_line = TestScheduledTaskScripts.find_line(lines, ...
                    'exist\s*\(\s*''task_name''\s*,\s*''var''\s*\)');
                notify_line = TestScheduledTaskScripts.find_line(lines, ...
                    'notify_scheduled_task_failure\s*\(\s*task_name');

                testCase.verifyNotEmpty(catch_line, ...
                    sprintf('%s has no catch err block', relative_path));
                testCase.verifyNotEmpty(guard_line, ...
                    sprintf(['%s has no existence guard for task_name; an ' ...
                             'unhandled error would raise "Unrecognized function ' ...
                             'or variable ''task_name''" instead of reporting the ' ...
                             'real failure.'], relative_path));
                testCase.verifyGreaterThan(guard_line, catch_line, ...
                    sprintf('%s guards task_name before the catch block', relative_path));
                testCase.verifyNotEmpty(notify_line, ...
                    sprintf('%s never notifies with task_name', relative_path));
            end
        end

        function testTaskNameIsNonEmptyCharLiteral(testCase)
        % task_name feeds log_scheduled_task_event, the Slack alert title, and
        % the registry primary key, so it must be a real non-empty literal.
            for i = 1:numel(TestScheduledTaskScripts.ScriptFiles)
                relative_path = TestScheduledTaskScripts.ScriptFiles{i};
                lines = TestScheduledTaskScripts.read_lines(relative_path);
                joined = strjoin(lines, newline);

                tokens = regexp(joined, 'task_name\s*=\s*''([^'']*)''', 'tokens');
                testCase.verifyNotEmpty(tokens, ...
                    sprintf('%s has no literal task_name assignment', relative_path));

                for t = 1:numel(tokens)
                    testCase.verifyNotEmpty(strtrim(tokens{t}{1}), ...
                        sprintf('%s assigns an empty task_name', relative_path));
                end

                % Every literal assignment in one script must agree, or the
                % catch-block fallback would report a different task than the
                % one that actually failed.
                values = cellfun(@(t) t{1}, tokens, 'UniformOutput', false);
                testCase.verifyEqual(numel(unique(values)), 1, ...
                    sprintf(['%s assigns conflicting task_name values (%s); the ' ...
                             'fallback must match the real task name.'], ...
                             relative_path, strjoin(unique(values), ', ')));
            end
        end

        function testTaskNamesAreUniqueAcrossScripts(testCase)
        % Each nightly task needs its own identifier, since the registry and
        % the Slack alerts key off it.
            names = cell(1, numel(TestScheduledTaskScripts.ScriptFiles));
            for i = 1:numel(TestScheduledTaskScripts.ScriptFiles)
                lines = TestScheduledTaskScripts.read_lines(TestScheduledTaskScripts.ScriptFiles{i});
                tokens = regexp(strjoin(lines, newline), 'task_name\s*=\s*''([^'']*)''', 'tokens', 'once');
                names{i} = tokens{1};
            end
            testCase.verifyEqual(numel(unique(names)), numel(names), ...
                sprintf('Copy scripts share task names: %s', strjoin(names, ', ')));
        end

    end
end
