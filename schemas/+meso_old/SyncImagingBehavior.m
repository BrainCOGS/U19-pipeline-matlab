%{
# synchronization between imaging and behavior
-> meso_old.FieldOfView
---
sync_im_frame               : longblob                      # frame number within tif file
sync_im_frame_global        : longblob                      # global frame number in scan
sync_behav_block_by_im_frame: longblob                      # array with behavioral block for each imaging frame
sync_behav_trial_by_im_frame: longblob                      # array with behavioral trial for each imaging frame
sync_behav_iter_by_im_frame : longblob                      # array with behavioral trial for each imaging frame, some extra zeros in file 1, marking that the behavior recording hasn't started yet.
sync_im_frame_span_by_behav_block: longblob                 # cell array with first and last imaging frames for for each behavior block
sync_im_frame_span_by_behav_trial: longblob                 # cell array with first and last imaging frames for for each behavior trial
sync_im_frame_span_by_behav_iter: longblob                  # cell array with first and last imaging frames for for each behavior iteration within each trial
%}


classdef SyncImagingBehavior < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


