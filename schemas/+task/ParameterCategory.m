%{
parameter_category: varchar(16)
%}


classdef ParameterCategory < dj.Lookup
    properties
        contents = {'maze'; 'criterion'; 'visible'}
    end
end