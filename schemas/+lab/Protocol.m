%{
# 
protocol                    : varchar(16)                   # protocol number
---
reference_weight_pct=null   : float                         # percentage of initial allowed
protocol_description        : varchar(255)                  # description
%}


classdef Protocol < dj.Lookup
    properties
        contents = {'1910', 0.8, 'Tank Lab protocol'}
    end
end
