%{
# metainfo about imaging session
-> meso_old.Scan
---
file_name_base              : varchar(255)                  # base name of the file
scan_width                  : int                           # width of scanning in pixels
scan_height                 : int                           # height of scanning in pixels
acq_time                    : datetime                      # acquisition time
n_depths                    : tinyint                       # number of depths
scan_depths                 : blob                          # depth values in this scan
frame_rate                  : float                         # imaging frame rate
inter_fov_lag_sec           : float                         # time lag in secs between fovs
frame_ts_sec                : longblob                      # frame timestamps in secs 1xnFrames
power_percent               : float                         # percentage of power used in this scan
channels                    : blob                          # is this the channer number or total number of channels
cfg_filename                : varchar(255)                  # cfg file path
usr_filename                : varchar(255)                  # usr file path
fast_z_lag                  : float                         # fast z lag
fast_z_flyback_time         : float                         # time it takes to fly back to fov
line_period                 : float                         # scan time per line
scan_frame_period           : float                         # 
scan_volume_rate            : float                         # 
flyback_time_per_frame      : float                         # 
flyto_time_per_scan_field   : float                         # 
fov_corner_points           : blob                          # coordinates of the corners of the full 5mm FOV, in microns
nfovs                       : int                           # number of field of view
nframes                     : int                           # number of frames in the scan
nframes_good                : int                           # number of frames in the scan before acceptable sample bleaching threshold is crossed
last_good_file              : int                           # number of the file containing the last good frame because of bleaching
%}


classdef ScanInfo < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


