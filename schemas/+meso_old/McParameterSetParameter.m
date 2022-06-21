%{
# pre-saved paraemter values
-> meso_old.McParameterSet
-> meso_old.McParameter
---
mc_max_shift                : blob                          # max allowed shift in pixels
mc_max_iter                 : blob                          # max number of iterations
mc_stop_below_shift         : float                         # tolerance for stopping algorithm
mc_black_tolerance          : float                         # tolerance for black pixel value
mc_median_rebin             : float                         # ? (check with Sue Ann)
%}


classdef McParameterSetParameter < dj.Lookup


end


