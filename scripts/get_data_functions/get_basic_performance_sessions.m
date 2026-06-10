function get_basic_performance_sessions()


session_query = struct();
session_query.session_protocol = 'poisson_blocks.m poisson_blocks_reboot_3m.mat PoissonBlocksCondensed3m';

subj_query = 'dob > "2022-01-01" and dob < "2026-01-01"';


sessions = struct2table(fetch(acquisition.Session * subject.Subject & ...
    session_query & subj_query,'dob', 'level','session_performance','num_trials'));

end



