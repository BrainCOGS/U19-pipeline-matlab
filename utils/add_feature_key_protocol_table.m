function add_feature_key_protocol_table(protocol_table,feature_table)
%add_feature_key_protocol_table add a new fiel


%Assert the 'feature' table has only one key, it is int and 
%it is not already referenced in 'protocol'table

assert(length(feature_table.primaryKey) == 1, ...
    'Feature table must have a single field key');

assert(string(feature_table.header.attributes(1).type) == "int", ...
    'Feature table key must be int');
    
idx_parent = find(ismember(protocol_table.ancestors,feature_table.className),1);
assert(isempty(idx_parent), ...
    ['Feature table (' feature_table.className ') is already referenced ', ...
    'in Protocol table (' protocol_table.className, ')']);


%Add new column to protocol table
new_field = feature_table.primaryKey{1};
feature_table_name = feature_table.fullTableName;
protocol_table_name = protocol_table.fullTableName;

conn = dj.conn;
conn.query(['ALTER TABLE ' protocol_table_name ' ADD ' new_field ' int DEFAULT NULL NULL']);


conn.query(['ALTER TABLE ' protocol_table_name ' ADD FOREIGN KEY (`' new_field '`) ', ...
    'REFERENCES ' feature_table_name '(`' new_field '`) ' , ... 
    'ON DELETE RESTRICT ON UPDATE CASCADE']);


end

