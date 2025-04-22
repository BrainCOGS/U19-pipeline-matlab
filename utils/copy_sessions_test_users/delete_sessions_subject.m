function delete_sessions_subject(test_subject)


if ~contains(test_subject,'test','IgnoreCase',true)
    error('Cannot delete not test subjects ')
end

new_subject_query.subject_fullname = test_subject;

del(behavior.TowersSession & new_subject_query);
del(behavior_subtask.TwolickspoutsSession & new_subject_query);
del(pupillometry.PupillometrySession & new_subject_query);
del(optogenetics.OptogeneticSession & new_subject_query);
del(acquisition.SessionStarted & new_subject_query);

