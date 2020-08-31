%{
# available segmentation methods
seg_method:    varchar(16)
%}

classdef SegmentationMethod < dj.Lookup
    
    properties
        contents = {'cnmf'; 'suite2p'}
    end
end