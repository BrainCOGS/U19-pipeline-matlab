%{
# 
watertype_name              : varchar(255)                  # 
%}


classdef WaterType < dj.Lookup
    properties
        contents = {
            'Water'
            'Water 10% Sucrose'
            'Milk'
            'Unknown'
            }
    end
end
