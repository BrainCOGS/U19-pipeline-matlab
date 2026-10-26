classdef TestTrialFullyImaged < matlab.unittest.TestCase
% Tests for trialFullyImaged, which SyncImagingBehavior uses to give no frame
% span to trials that imaging only partly covered.
%
% Regression context: a researcher stopped imaging before the behavior ended.
% The trial running when imaging stopped got a normal-looking frame span (on
% the ef932 sample cut to 20 TIFFs, trial 97 with 51 of its 676 iterations
% imaged), so it would be analysed as an imaged trial.
%
% The synthetic session has 5 back-to-back trials of 50 iterations, one frame
% per iteration, and equal imaging and behavior clocks, so frame k carries the
% packet of iteration k. No database needed.

    properties (Constant)
        DT       = 0.02
        NITER    = 50
        NTRIALS  = 5
        LEAD     = 30
    end

    methods (Static)
        function s = session(lead, trail)
            % Per-frame vectors for the whole session plus padding frames
            % without packets before and after the behavior.
            dt = TestTrialFullyImaged.DT;
            n  = TestTrialFullyImaged.NITER;
            nt = TestTrialFullyImaged.NTRIALS;
            s.iterTime  = (0:n-1)' * dt;
            behav       = (0:n*nt-1) * dt;
            s.frameTime = [(-lead:-1) * dt, behav, behav(end) + (1:trail) * dt];
            s.syncTime  = [nan(1, lead), behav, nan(1, trail)];
            s.trial     = [zeros(1, lead), kron(1:nt, ones(1, n)), zeros(1, trail)];
            s.iter      = [zeros(1, lead), repmat(1:n, 1, nt), zeros(1, trail)];
            s.acq       = ones(size(s.frameTime));
        end

        function s = keep(s, idx)
            for f = {'frameTime', 'syncTime', 'trial', 'iter', 'acq'}
                s.(f{:}) = s.(f{:})(idx);
            end
        end

        function imaged = judge(s)
            % trialFullyImaged for every trial that has frames, false otherwise.
            nt     = TestTrialFullyImaged.NTRIALS;
            imaged = false(1, nt);
            period = median(diff(s.frameTime));
            for t = 1:nt
                frames = find(s.trial == t);
                if ~isempty(frames)
                    imaged(t) = trialFullyImaged(s.iterTime, frames, s.frameTime, ...
                                                 s.syncTime, s.iter, s.acq, period);
                end
            end
        end
    end

    methods (Test)
        function whole_session_keeps_every_trial(testCase)
            s = TestTrialFullyImaged.session(30, 30);
            testCase.verifyEqual(TestTrialFullyImaged.judge(s), true(1, 5));
        end

        function imaging_stopped_mid_trial_drops_that_trial(testCase)
            % The reported case: imaging ended 10 iterations into trial 3.
            s = TestTrialFullyImaged.session(30, 0);
            s = TestTrialFullyImaged.keep(s, 1:30 + 2*50 + 10);
            testCase.verifyEqual(TestTrialFullyImaged.judge(s), [true true false false false]);
        end

        function imaging_started_mid_trial_drops_that_trial(testCase)
            s = TestTrialFullyImaged.session(0, 30);
            s = TestTrialFullyImaged.keep(s, 21:numel(s.frameTime));
            testCase.verifyEqual(TestTrialFullyImaged.judge(s), [false true true true true]);
        end

        function imaging_stopped_on_a_trial_boundary_keeps_the_trial(testCase)
            s = TestTrialFullyImaged.session(30, 0);
            s = TestTrialFullyImaged.keep(s, 1:30 + 2*50);
            testCase.verifyEqual(TestTrialFullyImaged.judge(s), [true true false false false]);
        end

        function one_missing_frame_is_tolerated(testCase)
            s = TestTrialFullyImaged.session(30, 0);
            s = TestTrialFullyImaged.keep(s, 1:30 + 2*50 - 1);
            imaged = TestTrialFullyImaged.judge(s);
            testCase.verifyEqual(imaged(1:2), [true true]);
        end

        function late_packets_do_not_drop_a_trial(testCase)
            % End-of-trial packets reach ScanImage 200-450 ms late.
            s = TestTrialFullyImaged.session(30, 30);
            ends = s.iter == 50;
            s.syncTime(ends) = s.syncTime(ends) + 0.4;
            testCase.verifyEqual(TestTrialFullyImaged.judge(s), true(1, 5));
        end

        function single_imaged_frame_is_dropped(testCase)
            s = TestTrialFullyImaged.session(30, 0);
            s = TestTrialFullyImaged.keep(s, 1:30 + 50 + 1);
            testCase.verifyEqual(TestTrialFullyImaged.judge(s), [true false false false false]);
        end

        function trial_straddling_two_acquisitions_is_dropped(testCase)
            % Imaging was stopped and restarted during trial 3.
            s = TestTrialFullyImaged.session(30, 30);
            s.acq(30 + 2*50 + 41:end) = 2;
            s = TestTrialFullyImaged.keep(s, [1:30 + 2*50 + 10, 30 + 2*50 + 41:numel(s.frameTime)]);
            testCase.verifyEqual(TestTrialFullyImaged.judge(s), [true true false true true]);
        end

        function trial_without_iteration_times_is_kept(testCase)
            s = TestTrialFullyImaged.session(30, 0);
            s = TestTrialFullyImaged.keep(s, 1:30 + 2*50 + 10);
            frames = find(s.trial == 3);
            testCase.verifyTrue(trialFullyImaged([], frames, s.frameTime, s.syncTime, ...
                                                 s.iter, s.acq, TestTrialFullyImaged.DT));
        end
    end
end
