function idx_fields = find_idx_fields_table(table, fields)

idx_fields = [];


for i=1:length(fields)
    tidx = find(string(table.Properties.VariableNames) == string(fields{i}));
    if isempty(tidx)
        error([fields{i} ' not present on table']);
    else
        idx_fields = [idx_fields tidx];
    end
end
