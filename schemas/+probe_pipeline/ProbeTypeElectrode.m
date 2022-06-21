%{
# 
-> probe_pipeline.ProbeType
electrode                   : int                           # electrode index, starts at 0
---
shank                       : int                           # shank index, starts at 0, advance left to right
shank_col                   : int                           # column index, starts at 0, advance left to right
shank_row                   : int                           # row index, starts at 0, advance tip to tail
x_coord=null                : float                         # (um) x coordinate of the electrode within the probe, (0, 0) is the bottom left corner of the probe
y_coord=null                : float                         # (um) y coordinate of the electrode within the probe, (0, 0) is the bottom left corner of the probe
%}


classdef ProbeTypeElectrode < dj.Lookup


end


