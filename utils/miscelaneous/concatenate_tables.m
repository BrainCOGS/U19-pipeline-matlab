function output_table = concatenate_tables(table1,table2)
%CONCACTENATE_TABLES concatenate possible different fields tables
 
 
%% First add missing columns from each table
columns1 = table1.Properties.VariableNames;
columns2 = table2.Properties.VariableNames;
 
[t1colmissing, index_miss_t2] = setdiff(columns2, columns1);
[t2colmissing, index_miss_t1] = setdiff(columns1, columns2);
 
types1 = varfun(@class,table1,'OutputFormat','cell');
types2 = varfun(@class,table2,'OutputFormat','cell');
 
for i=1:length(index_miss_t2)
    if string(types2(index_miss_t2(i))) == "cell"
        table1 = [table1 cell2table(cell(height(table1),1), 'VariableNames',t1colmissing(i))];
    else
        table1 = [table1 array2table(nan(height(table1),1), 'VariableNames',t1colmissing(i))];
    end
end
 
for i=1:length(index_miss_t1)
    if string(types1(index_miss_t1(i))) == "cell"
        table2 = [table2 cell2table(cell(height(table2),1), 'VariableNames',t2colmissing(i))];
    else
        table2 = [table2 array2table(nan(height(table2),1), 'VariableNames',t2colmissing(i))];
    end
end
 
%% Compare data types of each column to check if they match
 
columns = sort(table1.Properties.VariableNames);
 
cp_table1 = table1(1,columns);
cp_table2 = table2(1,columns);
 
cp_types1 = varfun(@class,cp_table1,'OutputFormat','cell');
cp_types2 = varfun(@class,cp_table2,'OutputFormat','cell');
 
for i=1:length(cp_types1)
    
    if ~strcmp(cp_types1{i}, cp_types2{i})
        if string(cp_types1{i}) == "cell"
            
            table2.(columns{i}) = num2cell(table2.(columns{i}));
        elseif string(cp_types2{i}) == "cell"
            table1.(columns{i}) = num2cell(table1.(columns{i}));
        end             
    end
end
    
output_table = [table1; table2];
 
 
end
 

