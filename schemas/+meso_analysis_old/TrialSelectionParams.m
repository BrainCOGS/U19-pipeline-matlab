%{
# trial selection for meso_analysis.BinnedTrace
trial_parameter_set_id      : int                           # id of the set of parameters
---
no_excess_travel            : int                           # if == 1, will exclude trials with excess travel
towers_perf_thresh          : float                         # block performance in towers block must be above this threshold
towers_bias_thresh          : float                         # block bias in towers block must be below this threshold
visguide_perf_thresh        : float                         # block performance in visually guided block must be above this threshold
visguide_bias_thresh        : float                         # block bias in visually guided block must be above this threshold
min_trials_per_block        : int                           # there must be this many trials in the block (filters out manual changes between multiple mazes)
%}


classdef TrialSelectionParams < dj.Lookup


end


