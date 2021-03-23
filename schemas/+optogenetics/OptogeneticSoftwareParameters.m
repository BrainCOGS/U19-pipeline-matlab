%{
# Information of a optogenetic session
optogenetic_software_parameters_set_id          : INT AUTO_INCREMENT
---
optogenetic_software_parameters_set_description : VARCHAR(256)  # string to describe parameter set
optogenetic_software_parameters_set_hash        : UUID          # hash to identify parameter set
optogenetic_software_parameters                 : longblob      # structure with all parameters
%}

classdef OptogeneticSoftwareParameters < dj.Manual

end
