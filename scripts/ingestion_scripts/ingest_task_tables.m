% load the task information from the .mat file
datafile = 'data/PoissonBlocksReboot_cohort1_VRTrain6_E75_T_20181105.mat';
load(datafile)

% insert task related parameters
key_level.task = 'Towers';
for iLevel = 1:length(log.version.mazes)
    
    % insert task.TaskLevelParameterSet
    maze = log.version.mazes(iLevel);
    key_level.level = iLevel;
    inserti(task.TaskLevelParameterSet, key_level);
    insertTaskParameter(key_level, maze, 'visible')
    
end

function insertTaskParameter(key_level, maze, category)

    key_par.parameter_category = category;
    
    switch category
        case 'maze'
            par_set = maze.variable;
        case 'criterion'
            par_set = maze.criteria;
        case 'visible'
            par_set = maze.visible;
    end
    
    key_task_par = key_level;
    for field = fieldnames(par_set)'
        key_par.parameter = field{:};
        inserti(task.Parameter, key_par)
        
        par_value = par_set.(key_par.parameter);
        if isstring(par_value)
                par_value = str2num(par_value);
        end
        if (~isscalar(par_value) && ~isempty(par_value)) || (isscalar(par_value) && ~isnan(par_value))
            key_task_par.parameter = key_par.parameter;
            key_task_par.parameter_value = par_value;
            inserti(task.TaskParameter, key_task_par)
        end
    end
end
