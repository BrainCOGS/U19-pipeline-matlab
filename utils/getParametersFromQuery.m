function [params] = getParametersFromQuery(query)
%GETPARAMETERSFROMTABLES
%  Get all parameters needed from xxParameterSetParameter like tables

% Inputs
%   query   = reference to a query in datajoint

% Outputs
%   params  = structure with all corresponding parmaeter, structure:
%             params.paramName_1 = x1
%             params.paramName_2 = x2
%             ....
%             params.paramName_n = xn
%
%  table in datajoint need to have two columns:
%   xxxx_parameter_name = column with name of parameters
%   value               = column with corresponding value of parameters

TemplateParamNameCol = 'parameter_name';
valueNameCol = 'value';

%Get Parameters from xxParameterSetParameter table
params         = fetch(query, '*');
%Convert struct 2 table (easier to index)
paramTable     = struct2table(params,'AsArray',true);

%Check if table contains xx_parameter_name column
columnNames = paramTable.Properties.VariableNames;
Index = find(contains(columnNames,TemplateParamNameCol));

if isempty(Index)
    error(['No column named as xx', TemplateParamNameCol, ' in param table']);
elseif length(Index) > 1
    warning(['Many columns named as xx', TemplateParamNameCol, ' in param table, getting first']);
end
paramNameCol = columnNames{Index(1)};

%Convert table as a single entry params structure
params = struct();
for i=1:size(paramTable,1)
    %get name of parameter
    paramName = paramTable.(paramNameCol){i};
    %get value of parameter
    paramValue = paramTable.(valueNameCol)(i);
    if iscell(paramValue)
        params.(paramName) = paramValue{1};
    else
        params.(paramName) = paramValue;
    end
end

end

