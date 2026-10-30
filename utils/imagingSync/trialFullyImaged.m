function imaged = trialFullyImaged(iterTime, frames, frameTime, syncTime, syncIter, frameAcq, framePeriod)
% TRIALFULLYIMAGED  Whether one acquisition's frames cover a whole behavior trial.
%
%   imaged = trialFullyImaged(iterTime, frames, frameTime, syncTime, syncIter, frameAcq, framePeriod)
%
%   iterTime    : the trial's logged iteration times (log.block(i).trial(j).time)
%   frames      : indices of the imaging frames labelled with the trial
%   frameTime   : per-frame time on the imaging clock (frameTimestamps_sec)
%   syncTime    : per-frame I2C packet time, NaN for frames without a packet
%   syncIter    : per-frame behavior iteration from the packets
%   frameAcq    : per-frame ScanImage acquisition number
%   framePeriod : imaging frame period (s), the tolerance at each end
%
%   The trial's packets, matched to the logged iteration times, place it on
%   the imaging clock; the median offset ignores the late first and
%   end-of-trial packets. The trial counts as imaged if the acquisition its
%   packets fall in ran from its first to its last iteration, give or take one
%   frame. It does not if imaging started or stopped partway through it, or if
%   it falls in the gap between two acquisitions. A trial whose log has no
%   iteration times cannot be judged and counts as imaged.

  iterTime  = double(iterTime(:));
  frameTime = frameTime(:);
  frameAcq  = frameAcq(:);
  t         = syncTime(frames);
  t         = t(:);
  iter      = syncIter(frames);
  iter      = iter(:);
  has       = ~isnan(t) & iter >= 1 & iter <= numel(iterTime);
  if ~any(has)
    imaged  = isempty(iterTime);
    return
  end
  offset    = median(t(has) - iterTime(iter(has)));

  acq       = unique(frameAcq(frames));
  if numel(acq) > 1
    imaged  = false;
    return
  end
  acqTime   = frameTime(frameAcq == acq);
  imaged    = acqTime(1) - framePeriod <= offset + iterTime(1)  ...
           && offset + iterTime(end) <= acqTime(end) + framePeriod;

end
