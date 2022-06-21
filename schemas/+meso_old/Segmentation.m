%{
# ROI segmentation
-> meso_old.FieldOfView
-> meso_old.SegParameterSet
---
num_chunks                  : tinyint                       # number of different segmentation chunks within the session
cross_chunks_x_shifts       : blob                          # nChunks x niter,
cross_chunks_y_shifts       : blob                          # nChunks x niter,
cross_chunks_reference_image: longblob                      # reference image for cross-chunk registration
%}


classdef Segmentation < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


