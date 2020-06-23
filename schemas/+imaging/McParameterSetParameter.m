%{
# pre-saved parameter values
-> imaging.McParameterSet
-> imaging.McParameter
---
value         : blob     # value of parameter
%}

classdef McParameterSetParameter < dj.Part
    properties(SetAccess=protected)
        master   = imaging.McParameterSet
    end
    methods
        function make(self, key)
            
            paramKey.mcorr_method = key.mcorr_method;
            query = imaging.McParameter & paramKey;
            parameters = query.fetchn('mc_parameter_name');
            
            tableParam  =cell2table({
                'LinearNormalized' , 'mc_max_shift' , 15;
                'LinearNormalized' , 'mc_max_iter' , 5;
                'LinearNormalized' , 'mc_extra_param' , false;
                'LinearNormalized' , 'mc_stop_below_shift' , 0.3;
                'LinearNormalized' , 'mc_black_tolerance' , -1;
                'LinearNormalized' , 'mc_median_rebin' , 10;
                
                'NonLinearNormalized' , 'mc_max_shift' , [15 15];
                'NonLinearNormalized' , 'mc_max_iter' , [5 2];
                'NonLinearNormalized' , 'mc_stop_below_shift' , 0.3;
                'NonLinearNormalized' , 'mc_black_tolerance' , -1;
                'NonLinearNormalized' , 'mc_median_rebin' , 10;
                
                }, 'VariableNames',{'mcorr_method' 'mc_parameter_name' 'value'});
            
            tableParam.mcorr_method = categorical(tableParam.mcorr_method);
            tableParam.mc_parameter_name = categorical(tableParam.mc_parameter_name);
            
            for i=1:length(parameters)
                key.mc_parameter_name = parameters{i};
                value_cell = tableParam{tableParam.mcorr_method == key.mcorr_method & ...
                                        tableParam.mc_parameter_name == key.mc_parameter_name, 'value'};
            
                if size(value_cell,1) > 1
                    warning('More than one value for this key found: %s %d %s',key.mcorr_method, key.mc_parameter_set_id, key.mc_parameter_name)
                    key.value = value_cell{1,1};
                elseif size(value_cell,1) == 0
                    error('No value for this key found: : %s %d %s',key.mcorr_method, key.mc_parameter_set_id, key.mc_parameter_name)
                else
                    key.value = value_cell{1,1};
                end
            
                self.insert(key);
            end
            
        end
    end
end
