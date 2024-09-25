%{
# Which Inputs and Outputs can be installed in rigs (for RigTester purposes)
input_output_name           : varchar(32)                   # Name and ID for Input/Output
---
description                 : varchar(255)                  # Input/Output description
direction                   : enum('Input','Output')        # Input/Output direction (for RigTester purposes)
test_type                   : enum('Automatic','Manual')    # Manual if technician have to check test (e.g. Speaker) Automatic otherwise
%}


classdef InputOutputRig < dj.Lookup


end


