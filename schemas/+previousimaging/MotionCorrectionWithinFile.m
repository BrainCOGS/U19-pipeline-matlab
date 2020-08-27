%{
# within each tif file, x-y shifts for motion registration
-> previousimaging.FieldOfViewFile
-> previousimaging.McParameterSet
---
within_file_x_shifts         : longblob      # nFrames x 2, meta file, frameMCorr-xShifts
within_file_y_shifts         : longblob      # nFrames x 2, meta file, frameMCorr-yShifts
within_reference_image       : longblob      # 512 x 512, meta file, frameMCorr-reference
%}


classdef MotionCorrectionWithinFile < dj.Part
    properties(SetAccess=protected)
        master   = previousimaging.MotionCorrection
    end
    % ingested by previousimaging.MotionCorrection
end