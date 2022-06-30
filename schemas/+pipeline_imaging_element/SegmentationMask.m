%{
# A mask produced by segmentation.
-> pipeline_imaging_element.Segmentation
mask                        : smallint                      # 
---
 (segmentation_channel) -> pipeline_scan_element.Channel
mask_npix                   : int                           # number of pixels in ROIs
mask_center_x               : int                           # center x coordinate in pixel
mask_center_y               : int                           # center y coordinate in pixel
mask_center_z               : int                           # center z coordinate in pixel
mask_xpix                   : longblob                      # x coordinates in pixels
mask_ypix                   : longblob                      # y coordinates in pixels
mask_zpix                   : longblob                      # z coordinates in pixels
mask_weights                : longblob                      # weights of the mask at the indices above
%}


classdef SegmentationMask < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


