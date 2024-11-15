%{
# Tech report (from MATLAB Rig Tester)
id_rig_io_tech_report:   int AUTO_INCREMENT          # report id identifier
-----
-> lab.Location                                      # in which rig was performed io test
report_datetime:         datetime                    # datetime report
tech_notes:              varchar(2048)               # tech note when using rig tester
%}

classdef RigIOTechReport < dj.Manual
end