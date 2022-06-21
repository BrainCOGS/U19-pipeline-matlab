%{
# 
binomial                    : varchar(32)                   # binomial
---
species_nickname            : varchar(32)                   # nickname
%}

classdef Species < dj.Lookup
    properties
        contents = {'Mus musculus' 'Laboratory mouse'}
    end
end
