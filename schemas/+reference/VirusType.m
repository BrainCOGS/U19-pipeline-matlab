%{
# 
virus_type                  : varchar(64)                   # 
%}


classdef VirusType < dj.Lookup
    properties
        contents = {'AAV'; 'Rabies'; 'Psedotyped rabies'; 'Lenti'}
    end
end
