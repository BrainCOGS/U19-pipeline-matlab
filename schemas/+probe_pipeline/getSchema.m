function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'probe_pipeline', [prefix 'probe_pipeline']);
end
obj = schemaObject;
end
