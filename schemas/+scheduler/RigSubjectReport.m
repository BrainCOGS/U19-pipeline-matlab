%{
# Subjects with problems to train for the day (from MATLAB Rig Tester)
id_rig_subject_report:         int AUTO_INCREMENT          # report id identifier
-----
-> lab.Location                                               # in which rig was performed io test
-> subject.Subject
-> scheduler.RigIOTechReport                                  # to which tech report is attached
rig_subject_report_datetime:     datetime                     # datetime report
report_type:                     enum('Mandatory','Optional') # type of report
%}

classdef RigSubjectReport < dj.Manual
end