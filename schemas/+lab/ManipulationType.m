%{
# Types of manipulation that can be performed in a experiment
manipulation_type           : varchar(64)                   # 
---
manipulation_description    : varchar(2555)                 # 
table_population            : varchar(512)                  # 
%}

classdef ManipulationType < dj.Lookup
    properties
        contents = {
            'optogenetics', 'optogentic manipulation', 'OptogeneticSession'
            }
    end
end
