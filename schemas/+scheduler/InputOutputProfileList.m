%{
# InputOutputProfile full list of InputsOutputs and type of test for each
-> scheduler.InputOutputProfile
input_output_num            : int                           # # Of Input/Output for this profile
---
-> scheduler.InputOutputRig
check_type                  : enum('Mandatory','Optional')  # Prevent training if missing this input/output
%}


classdef InputOutputProfileList < dj.Manual


end


