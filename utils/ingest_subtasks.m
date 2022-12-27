function ingest_subtasks()

%Get all subtasks from table Subtask
subtasks = fetchn(task.Subtask, 'subtask');
subtasks(strcmp(subtasks,'standard')) = [];


new_tables_order = {'Session', 'Block'};
for j=1:length(subtasks)
    for i = 1:length(new_tables_order)
    new_table = str2func(['behavior_subtask.' subtasks{j} new_tables_order{i}]);
    new_table = new_table();
    populate(new_table);
    pause(2);
    end
end

end