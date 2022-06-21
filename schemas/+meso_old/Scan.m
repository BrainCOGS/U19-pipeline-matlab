%{
# existence of an imaging session
-> acquisition.SessionOld
---
scan_directory              : varchar(255)                  # 
gdd=null                    : float                         # 
wavelength=940              : float                         # in nm
pmt_gain=null               : float                         # 
%}


classdef Scan < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


