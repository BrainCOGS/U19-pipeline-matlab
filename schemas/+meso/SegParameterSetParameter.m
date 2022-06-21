%{
# parameter values of a segmentation parameter set
-> meso.SegParameterSet
-> meso.SegParameter
---
chunks_auto_select_behav    : tinyint                       # select chunks automaticaly based on good behavioral performance
chunks_auto_select_bleach   : tinyint                       # select chunks automaticaly based on bleaching
chunks_towers_min_n_trials  : int                           # min number of towers task trials to include a block
chunks_towers_perf_thresh   : float                         # min performance (fraction correct) of towers task to include a block
chunks_towers_bias_thresh   : float                         # max side bias (fraction trials) of towers task to include a block
chunks_towers_max_frac_bad  : float                         # max fraction of bad motor trials of towers task to include a block
chunks_visguide_min_n_trials: int                           # min number of towers task trials to include a block
chunks_visguide_perf_thresh : float                         # min performance (fraction correct) of towers task to include a block
chunks_visguide_bias_thresh : float                         # max side bias (fraction trials) of towers task to include a block
chunks_visguide_max_frac_bad: float                         # max fraction of bad motor trials of towers task to include a block
chunks_min_num_consecutive_blocks: int                      # min good consecuitve blocks to select session
chunks_break_nonconsecutive_blocks: tinyint                 # set true to break non consecuitve behavior blocks into separate segmentation chunks
cnmf_num_components         : int                           # number of components to be found, for initialization purposes
cnmf_tau                    : float                         # std of gaussian kernel (size of neuron)
cnmf_p                      : tinyint                       # order of autoregressive system (p = 0 no dynamics, p=1 just decay, p = 2, both rise and decay)
cnmf_num_iter               : tinyint                       # number of iterations
cnmf_files_per_chunk        : int                           # max allowed files per segmentation chunk
cnmf_proto_num_chunks       : int                           # how many chunks to use when initializing morphological segmentation
cnmf_zero_is_minimum        : tinyint                       # allow min fluorescence to be higher than zero
cnmf_default_timescale      : float                         # ? (ask Sue Ann)
cnmf_time_resolution        : float                         # time resolution in ms, if different than frame rate results in downsampling
cnmf_dff_rectification      : float                         # deemphasize dF/F values below this magnitude when computing component correlations
cnmf_min_roi_significance   : float                         # minimum significance for components to retain; at least some time points must be above this threshold
cnmf_frame_rate             : float                         # imaging frame rate in fps
cnmf_min_num_frames         : int                           # min required number of frames for segmentation
cnmf_max_centroid_dist      : float                         # maximum fraction of diameter within which to search for a matching template
cnmf_min_dist_pixels        : int                           # allow searching within this many pixels even if the diameter is very small
cnmf_min_shape_corr         : float                         # minimum shape correlation for global registration
cnmf_pixels_surround        : blob                          # number of pixels considered to be the roi's surround
gof_contain_energy          : float                         # goodness of fit, fractional amount of energy used to specify spatial support
gof_core_energy             : float                         # fractional amount of energy used to specify core of component
gof_noise_range             : float                         # range in which to search for modal (baseline) activation
gof_max_baseline            : float                         # number of factors below the data noise to consider as (unambiguously) baseline
gof_min_activation          : int                           # number of factors above the data noise to consider activity as significant
gof_high_activation         : int                           # number of factors above the data noise to consider activity as significant with reduced time span
gof_min_time_span           : int                           # number of timeScale chunks to require activity to be above threshold
gof_bkg_time_span           : int                           # number of timeScale chunks for smoothing the background activity level in order to determine its baseline
gof_min_dff                 : float                         # minimum dF/F to be considered as a significant transient
%}

classdef SegParameterSetParameter < dj.Part
    properties(SetAccess=protected)
        master = meso.SegParameterSet
        contents = {
          'cnmf', 1, 'cnmfParameters', true, true, 30, .6, .4, .2, 10, .8, .4, .2, 2, true, 400, 4, 2, 2, 50, 1, false, 10, 1000/12.3, 2, 3, 12.3, 2000, 1, 1, 0.85, [3 13], 0.9, 0.7, 2, 1.5, 3, 5, 1, 3, 0.3 
          }
    end
end

% fieldls = {
% 'segmentation_method',
% 'seg_parameter_set_id',
% 'seg_parameter_name',
% 'chunks_auto_select_behav',
% 'chunks_auto_select_bleach',
% 'chunks_towers_min_n_trials',
% 'chunks_towers_perf_thresh',
% 'chunks_towers_bias_thresh',
% 'chunks_towers_max_frac_bad',
% 'chunks_visguide_min_n_trials',
% 'chunks_visguide_perf_thresh',
% 'chunks_visguide_bias_thresh',
% 'chunks_visguide_max_frac_bad',
% 'chunks_min_num_consecutive_blocks',
% 'chunks_break_nonconsecutive_blocks',
% 'cnmf_num_components',
% 'cnmf_tau',
% 'cnmf_p',
% 'cnmf_num_iter',
% 'cnmf_files_per_chunk',
% 'cnmf_proto_num_chunks',
% 'cnmf_zero_is_minimum',
% 'cnmf_default_timescale',
% 'cnmf_time_resolution',
% 'cnmf_dff_rectification',
% 'cnmf_min_roi_significance',
% 'cnmf_frame_rate',
% 'cnmf_min_num_frames',
% 'cnmf_max_centroid_dist',
% 'cnmf_min_dist_pixels',
% 'cnmf_min_shape_corr',
% 'cnmf_pixels_surround',
% 'gof_contain_energy',
% 'gof_core_energy',
% 'gof_noise_range',
% 'gof_max_baseline',
% 'gof_min_activation',
% 'gof_high_activation',
% 'gof_min_time_span',
% 'gof_bkg_time_span',
% 'gof_min_dff',
% };
% 
% data = [];
% for iField=1:numel(fieldls)
%   data.(fieldls{iField}) = contents{iField};
% end
% inserti(meso.SegParameterSetParameter,data)
