%{
# pre-saved parameter values
-> imaging.McParameterSet
-> imaging.McParameter
---
value         : blob     # value of parameter
%}

classdef McParameterSetParameter < dj.Computed
    properties(SetAccess=protected)
        master   = imaging.McParameterSet
    end
    methods (Access=protected)
        function makeTuples(self, key)
            
            tableParam  =cell2table({
                'LinearNormalized' , 1 , 'mc_max_shift' , 15;
                'LinearNormalized' , 1 , 'mc_max_iter' , 5;
                'LinearNormalized' , 1 , 'mc_extra_param' , false;
                'LinearNormalized' , 1 , 'mc_stop_below_shift' , 0.3;
                'LinearNormalized' , 1 , 'mc_black_tolerance' , -1;
                'LinearNormalized' , 1 , 'mc_median_rebin' , 10;
                'NonLinearNormalized' , 1 , 'mc_max_shift' , [15 15];
                'NonLinearNormalized' , 1 , 'mc_max_iter' , [5 2];
                'NonLinearNormalized' , 1 , 'mc_stop_below_shift' , 0.3;
                'NonLinearNormalized' , 1 , 'mc_black_tolerance' , -1;
                'NonLinearNormalized' , 1 , 'mc_median_rebin' , 10;
                }, 'VariableNames',{'mcorr_method' 'mc_parameter_set_id' 'mc_parameter_name' 'value'});
            
            tableParam.mcorr_method = categorical(tableParam.mcorr_method);
            tableParam.mc_parameter_name = categorical(tableParam.mc_parameter_name);
            
            value_cell = tableParam{key.mcorr_method == tableParam.mcorr_method & ...
                key.mc_parameter_set_id == tableParam.mc_parameter_set_id & ...
                key.mc_parameter_name == tableParam.mc_parameter_name, 'value'};
            
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
