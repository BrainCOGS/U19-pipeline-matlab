%{
# 
-> recording_process.Processing
---
-> pipeline_imaging_element.ProcessingParamSet
%}


classdef ProcessingImagingParams < dj.Part
    properties(SetAccess=protected)
        master = recording_process.Processing
    end

end


