%{
# Module report (from MATLAB Rig Tester)
id_rig_io_module_report:            int AUTO_INCREMENT          # report id identifier
-----
-> lab.Location                                      # in which rig was performed io test
-> scheduler.InputOutputRig                          # module reported
-> scheduler.RigIOTechReport                         # to which tech report is attached
report_module_datetime:             datetime         # at what time module was reported 
error_message=null:                 varchar(256)     # basic error string
full_error_report=null:             varchar(4096)    # full error string
%}

classdef RigIOModuleReport < dj.Manual
end