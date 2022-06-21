%{
# for each chunck, global background info (from cnmf)
-> previousimaging.SegmentationChunks
---
background_spatial          : longblob                      # 2D matrix flagging pixels that belong to global background in cnmf
background_temporal         : longblob                      # time course of global background in cnmf
%}


classdef SegmentationBackground < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


