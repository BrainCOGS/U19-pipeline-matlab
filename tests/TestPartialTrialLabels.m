classdef TestPartialTrialLabels < matlab.unittest.TestCase
% Exercise the production span/label code without DataJoint or TIFF parsing.
    methods (Static)
        function key = runSync(s)
            repo = fileparts(fileparts(mfilename('fullpath')));
            source = fileread(fullfile(repo, 'schemas', '+imaging_pipeline', 'SyncImagingBehavior.m'));
            first = strfind(source, '      %% Record transition indices');
            last = strfind(source, '      self.insert(key);');
            body = source(first:last-1);
            frameTime = s.frameTime;
            syncTime = s.syncTime;
            syncIter = s.iter;
            labels = double(s.trial > 0);
            n = numel(s.trial);
            sync = cell2struct(num2cell([1:n; 1:n; labels; s.trial; s.iter; s.acq; ones(1,n)]), ...
                {'frame','global','block','trial','iteration','acquisition','imagingF'}, 1);
            [imgBlock, ~] = SplitVec(labels, 'equal', 'firstval', 'bracket');
            hasImg = find(imgBlock > 0);
            blockIndex = 1;
            block = struct('trialType', ones(1,5), 'trial', struct('time', repmat({s.iterTime},1,5)));
            fov_directory = 'synthetic';
            key = struct();
            eval(body);
        end

        function verifyExcluded(testCase, s, dropped)
            key = TestPartialTrialLabels.runSync(s);
            rejected = ismember(s.trial, dropped);
            block = double(s.trial > 0); block(rejected) = 0;
            trial = s.trial; trial(rejected) = 0;
            iter = s.iter; iter(rejected) = 0;
            testCase.verifyEqual(key.sync_behav_block_by_im_frame, block);
            testCase.verifyEqual(key.sync_behav_trial_by_im_frame, trial);
            testCase.verifyEqual(key.sync_behav_iter_by_im_frame, iter);
            for t = dropped
                testCase.verifyEmpty(key.sync_im_frame_span_by_behav_trial{t});
                testCase.verifyEmpty(key.sync_im_frame_span_by_behav_iter{t});
            end
            retained = find(block > 0);
            if isempty(retained)
                testCase.verifyEmpty(key.sync_im_frame_span_by_behav_block{1});
            else
                testCase.verifyEqual(key.sync_im_frame_span_by_behav_block{1}, retained([1 end]));
            end
        end
    end

    methods (Test)
        function stop_mid_trial(testCase)
            s = TestTrialFullyImaged.session(30,30);
            s = TestTrialFullyImaged.keep(s, 1:140);
            TestPartialTrialLabels.verifyExcluded(testCase, s, 3);
        end

        function start_mid_trial(testCase)
            s = TestTrialFullyImaged.session(30,30);
            s = TestTrialFullyImaged.keep(s, 51:numel(s.trial));
            TestPartialTrialLabels.verifyExcluded(testCase, s, 1);
        end

        function restart_mid_trial(testCase)
            s = TestTrialFullyImaged.session(30,30);
            s.acq(171:end) = 2;
            s = TestTrialFullyImaged.keep(s, [1:140 171:numel(s.trial)]);
            TestPartialTrialLabels.verifyExcluded(testCase, s, 3);
        end

        function only_partial_trial(testCase)
            s = TestTrialFullyImaged.session(30,30);
            s = TestTrialFullyImaged.keep(s, 51:60);
            TestPartialTrialLabels.verifyExcluded(testCase, s, 1);
        end

        function complete_trials_unchanged(testCase)
            s = TestTrialFullyImaged.session(30,30);
            TestPartialTrialLabels.verifyExcluded(testCase, s, []);
        end
    end
end
