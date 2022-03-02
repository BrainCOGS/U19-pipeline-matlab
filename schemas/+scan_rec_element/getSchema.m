function obj = getSchema
prefix = getenv('DB_PREFIX');
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'scan_rec_element', [prefix 'scan_rec_element']);
end
obj = schemaObject;
end
