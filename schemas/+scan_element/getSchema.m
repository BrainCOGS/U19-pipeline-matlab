function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'scan_element', [prefix 'scan_element']);
end
obj = schemaObject;
end
