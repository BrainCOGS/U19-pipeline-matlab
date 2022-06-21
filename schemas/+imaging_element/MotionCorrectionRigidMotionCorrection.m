%{
# Details of rigid motion correction performed on the imaging data
-> imaging_element.MotionCorrection
---
outlier_frames=null         : longblob                      # mask with true for frames with outlier shifts (already corrected)
y_shifts                    : longblob                      # (pixels) y motion correction shifts
x_shifts                    : longblob                      # (pixels) x motion correction shifts
z_shifts=null               : longblob                      # (pixels) z motion correction shifts (z-drift)
y_std                       : float                         # (pixels) standard deviation of y shifts across all frames
x_std                       : float                         # (pixels) standard deviation of x shifts across all frames
z_std=null                  : float                         # (pixels) standard deviation of z shifts across all frames
%}


classdef MotionCorrectionRigidMotionCorrection < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


