%{
# Video parameters adjusted for acquisition
video_parameters_id:                 int(11) AUTO_INCREMENT
-----
video_parameters_description='':     varchar(256)            # String that describes all video parameters to help selection on GUI
video_acquisition_rate:              float                   # Acquisition rate for video
video_exposure_time_in_microseconds: int(11)                 # Exposure time of camera
video_gain:                          int(11)                 # Video gain
video_extension:                     varchar(6)              # File Extension for video 
%}


classdef VideoParameters < dj.Lookup
    properties
        contents = {
            1, 'Acq=30Hz, Exp=30us, Gain=10, Ext=.mrj', 30,  30, 10, '.mrj';
            }
    end
    
    methods
        
        
        function insert_video_parameters(self, acq_rate, exposure_time, video_gain, video_ext)
            % Insert a new record for video parameters with description included
            % Example call
            % insert_video_parameters(deeplabcut_pipeline.VideoParameters, 15, 17, 3)
            
            key = struct();
            key.video_acquisition_rate = acq_rate;
            key.video_exposure_time_in_microseconds = exposure_time;
            key.video_gain = video_gain;
            key.video_extension = video_ext;
            
            key.video_parameters_description = [...
                'Acq=', num2str(acq_rate),    'Hz, ', ...
                'Exp=', num2str(acq_rate),    'us, ', ...
                'Gain=', num2str(video_gain), ', ',   ...
                'Ext=', video_ext];
            
            self.insert(key)
            
        end
        
    end
end