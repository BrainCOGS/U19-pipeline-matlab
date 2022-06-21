%{
# 
virus_source                : varchar(32)                   # 
%}


classdef VirusSource < dj.Lookup
    properties
        contents = {
            'UNC'
            'UPenn'
            'Addgene'
            'MIT'
            'Stanford'
            'Princeton'
            'custom'
        }
    end
end
