%{
# 
-> pipeline_imaging_element.Fluorescence
-> pipeline_imaging_element.SegmentationMask
 (fluo_channel) -> pipeline_scan_element.Channel
---
fluorescence                : longblob                      # fluorescence trace associated with this mask
neuropil_fluorescence=null  : longblob                      # Neuropil fluorescence trace
%}


classdef FluorescenceTrace < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


