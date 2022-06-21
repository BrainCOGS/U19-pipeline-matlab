%{
# field-specific scan information
-> scan_element.ScanInfo
field_idx                   : int                           # 
---
px_height                   : smallint                      # height in pixels
px_width                    : smallint                      # width in pixels
um_height=null              : float                         # height in microns
um_width=null               : float                         # width in microns
field_x                     : float                         # (um) center of field in the motor coordinate system
field_y                     : float                         # (um) center of field in the motor coordinate system
field_z                     : float                         # (um) relative depth of field
delay_image=null            : longblob                      # (ms) delay between the start of the scan and pixels in this field
%}


classdef ScanInfoField < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


