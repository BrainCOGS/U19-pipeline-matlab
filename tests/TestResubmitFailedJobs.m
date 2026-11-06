classdef TestResubmitFailedJobs < matlab.unittest.TestCase
    % resubmit_failed_jobs has to act on the subject it is given. Needs no database:
    % dj.conn and the tables it uses are replaced by fakes written to a temp folder,
    % which record the restrictions, updates and inserts in appdata.

    properties (Constant)
        LOG_KEY = 'TestResubmitFailedJobs_log';
    end

    methods (TestClassSetup)
        function addFakesAndScriptToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            import matlab.unittest.fixtures.TemporaryFolderFixture

            repoRoot = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(PathFixture(fullfile(repoRoot, 'scripts')));

            folder = testCase.applyFixture(TemporaryFolderFixture).Folder;
            TestResubmitFailedJobs.writeFakes(folder, testCase.LOG_KEY);
            testCase.applyFixture(PathFixture(folder));
        end
    end

    methods (TestMethodSetup)
        function resetLog(testCase)
            setappdata(0, testCase.LOG_KEY, struct('jobs', struct('job_id', {}), ...
                'fetched', {{}}, 'updates', {{}}, 'inserts', {{}}, 'commits', 0));
            testCase.addTeardown(@() rmappdata(0, testCase.LOG_KEY));
        end
    end

    methods (Test)
        function usesTheRequestedSubject(testCase)
            testCase.setFailedJobs(1465);

            resubmit_failed_jobs('efonseca_ef932');

            log = getappdata(0, testCase.LOG_KEY);
            testCase.verifyEqual(numel(log.fetched), 1);
            testCase.verifyEqual(log.fetched{1}.subject_fullname, 'efonseca_ef932');
            testCase.verifyEqual(log.fetched{1}.status_processing_id, -1);
        end

        function requeuesEachFailedJobOfTheSubject(testCase)
            testCase.setFailedJobs([1465 1466]);

            resubmit_failed_jobs('efonseca_ef932');

            log = getappdata(0, testCase.LOG_KEY);
            testCase.verifyEqual(cellfun(@(u) u.restriction.job_id, log.updates), [1465 1466]);
            testCase.verifyEqual(cellfun(@(u) u.value, log.updates), [0 0]);
            testCase.verifyEqual(cellfun(@(r) r.job_id, log.inserts), [1465 1466]);
            testCase.verifyEqual(log.commits, 1);
        end

        function subjectWithoutFailedJobsChangesNothing(testCase)
            resubmit_failed_jobs('efonseca_ef932');

            log = getappdata(0, testCase.LOG_KEY);
            testCase.verifyEmpty(log.updates);
            testCase.verifyEmpty(log.inserts);
        end

        function subjectMustBeProvided(testCase)
            testCase.verifyError(@() resubmit_failed_jobs(), ?MException);
            testCase.verifyError(@() resubmit_failed_jobs(''), ?MException);
            testCase.verifyError(@() resubmit_failed_jobs([]), ?MException);

            log = getappdata(0, testCase.LOG_KEY);
            testCase.verifyEmpty(log.fetched);
        end
    end

    methods
        function setFailedJobs(testCase, jobIds)
            log = getappdata(0, testCase.LOG_KEY);
            log.jobs = struct('job_id', num2cell(jobIds));
            setappdata(0, testCase.LOG_KEY, log);
        end
    end

    methods (Static)
        function writeFakes(folder, logKey)
            relation = @(name) sprintf('function r = %s()\nr = FakeRelation();\nend\n', name);
            files = {
                fullfile('+dj', 'conn.m'), sprintf('function c = conn()\nc = FakeConn();\nend\n')
                fullfile('+recording_process', 'Processing.m'), relation('Processing')
                fullfile('+recording_process', 'LogStatus.m'), relation('LogStatus')
                fullfile('+recording', 'Recording.m'), relation('Recording')
                fullfile('+recording', 'RecordingBehaviorSession.m'), relation('RecordingBehaviorSession')
                fullfile('+subject', 'Subject.m'), relation('Subject')
                'FakeConn.m', strjoin({
                    'classdef FakeConn < handle'
                    '    methods'
                    '        function startTransaction(~), end'
                    '        function cancelTransaction(~), end'
                    '        function commitTransaction(~)'
                    sprintf('            log = getappdata(0, ''%s'');', logKey)
                    '            log.commits = log.commits + 1;'
                    sprintf('            setappdata(0, ''%s'', log);', logKey)
                    '        end'
                    '    end'
                    'end'}, newline)
                'FakeRelation.m', strjoin({
                    'classdef FakeRelation'
                    '    properties'
                    '        restriction = struct()'
                    '    end'
                    '    methods'
                    '        function r = mtimes(r, ~), end'
                    '        function r = proj(r), end'
                    '        function r = and(r, restriction)'
                    '            r.restriction = restriction;'
                    '        end'
                    '        function rows = fetch(r)'
                    sprintf('            log = getappdata(0, ''%s'');', logKey)
                    '            log.fetched{end+1} = r.restriction;'
                    sprintf('            setappdata(0, ''%s'', log);', logKey)
                    '            rows = log.jobs;'
                    '        end'
                    '        function update(r, field, value)'
                    sprintf('            log = getappdata(0, ''%s'');', logKey)
                    '            log.updates{end+1} = struct(''restriction'', r.restriction, ''field'', field, ''value'', value);'
                    sprintf('            setappdata(0, ''%s'', log);', logKey)
                    '        end'
                    '        function insert(~, record)'
                    sprintf('            log = getappdata(0, ''%s'');', logKey)
                    '            log.inserts{end+1} = record;'
                    sprintf('            setappdata(0, ''%s'', log);', logKey)
                    '        end'
                    '    end'
                    'end'}, newline)
                };
            for i = 1:size(files, 1)
                path = fullfile(folder, files{i, 1});
                if ~isfolder(fileparts(path))
                    mkdir(fileparts(path));
                end
                fid = fopen(path, 'w');
                fprintf(fid, '%s', files{i, 2});
                fclose(fid);
            end
        end
    end
end
