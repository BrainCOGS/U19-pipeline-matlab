%{
# general data about the reso/meso scans, from ScanImage header
-> scan_element.Scan
---
nfields                     : tinyint                       # number of fields
nchannels                   : tinyint                       # number of channels
ndepths                     : int                           # Number of scanning depths (planes)
nframes                     : int                           # number of recorded frames
nrois                       : tinyint                       # number of ROIs (see scanimage's multi ROI imaging)
x                           : float                         # (um) ScanImage's 0 point in the motor coordinate system
y                           : float                         # (um) ScanImage's 0 point in the motor coordinate system
z                           : float                         # (um) ScanImage's 0 point in the motor coordinate system
fps                         : float                         # (Hz) frames per second - Volumetric Scan Rate
bidirectional               : tinyint                       # true = bidirectional scanning
usecs_per_line=null         : float                         # microseconds per scan line
fill_fraction=null          : float                         # raster scan temporal fill fraction (see scanimage)
%}


classdef ScanInfo < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


