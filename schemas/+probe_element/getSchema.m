function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'probe_element', [prefix 'probe_element']);
end
obj = schemaObject;
end
