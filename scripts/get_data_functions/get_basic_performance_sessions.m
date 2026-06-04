function get_basic_performance_sessions()


session_query = struct();
session_query.session_protocol = 'poisson_blocks.m poisson_blocks_reboot_3m.mat PoissonBlocksCondensed3m';

sessions = struct2table(fetch(acquisition.Session & session_query,'level','session_performance','num_trials'));

end



