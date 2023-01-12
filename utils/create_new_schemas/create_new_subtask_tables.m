function create_new_subtask_tables(new_subtask)

%Get package and Package names
package_name = lower(new_subtask);
Package_name = dj.internal.toCamelCase(package_name);

new_tables_order = {'Session', 'Block', 'BlockTrial'};
for i = 1:length(new_tables_order)
    new_table = str2func(['behavior_subtask.' Package_name new_tables_order{i}]);
    new_table()
    pause(2);
end

end
