%{
# scan meta information from the tiff file
-> previousimaging.Scan
---
nframes                     : int                           # number of recorded frames
frame_rate                  : float                         # imaging frame rate
last_good_file              : int                           # 
%}


classdef ScanInfo < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


