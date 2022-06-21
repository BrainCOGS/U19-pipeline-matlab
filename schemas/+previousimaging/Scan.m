%{
# 
-> acquisition.SessionOld
---
scan_directory              : varchar(255)                  # 
gdd=null                    : float                         # 
wavelength=920              : float                         # in nm
pmt_gain=null               : float                         # 
 (imaging_area) -> `u19_reference`.`#brain_area`
frame_time                  : longblob                      # 
%}


classdef Scan < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


