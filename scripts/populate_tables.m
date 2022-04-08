
% Populate behavior tables
[keys_session, errors_session] = populate(acquisition.Session);
[keys_session_block, errors_session_block] = populate(acquisition.SessionBlock);
[keys_towers_session, errors_towers_session] = populate(behavior.TowersSession);
[keys_block, errors_block] = populate(behavior.TowersBlock);


% Populate optogenetics tables
sm = acquisition.SessionManipulation;
ref_date = datestr(datetime('now') - days(14), 'YYYY-mm-dd');
query_sessions = ['session_date > "', ref_date, '"'];
sm.ingest_previous_optogenetic_sessions(query_sessions);

[keys_session_opto, errors_session_opto] = populate(optogenetics.OptogeneticSession);


% Populate psychometric tables
[keys_session_psych, errors_session_psych] = populate(behavior.TowersSessionPsych);
[keys_subject_psych, errors_subject_psych] = populate(behavior.TowersSubjectCumulativePsych);
[keys_psych_level, errors_psych_level] = populate(behavior.TowersSubjectCumulativePsychLevel);
[keys_psych_task, errors_psych_task] = populate(behavior.TowersSessionPsychTask);
