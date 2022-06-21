%{
# pre-saved paraemter values
-> meso.McParameterSet
-> meso.McParameter
---
mc_max_shift                : blob                          # max allowed shift in pixels
mc_max_iter                 : blob                          # max number of iterations
mc_stop_below_shift         : float                         # tolerance for stopping algorithm
mc_black_tolerance          : float                         # tolerance for black pixel value
mc_median_rebin             : float                         # ? (check with Sue Ann)
%}

classdef McParameterSetParameter < dj.Part
  properties(SetAccess=protected)
    master   = meso.McParameterSet
    contents = {
               'LinearNormalized', 1, 'LinearNormalizedParams', 15, 5, 0.3, -1, 10
               }
  end
end

% key.mcorr_method = 'LinearNormalized';
% key.mc_parameter_set_id = 1;
% key.mc_parameter_name = 'LinearNormalizedParams';
% key.mc_max_shift = 15;
% key.mc_max_iter = 5;
% key.mc_stop_below_shift = 0.3;
% key.mc_black_tolerance = -1;
% key.mc_median_rebin = 10;
% insert(meso.McParameterSetParameter,key)
