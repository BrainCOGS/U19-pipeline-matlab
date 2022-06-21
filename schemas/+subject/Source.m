%{
# 
source                      : varchar(32)                   # name of source
---
source_description          : varchar(255)                  # 
%}

classdef Source < dj.Lookup
    properties
        contents = {
            'Jax Lab', ''
            'Princeton', ''
            'Allen Institute', ''
        }
    end
end
