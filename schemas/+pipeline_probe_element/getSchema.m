function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'pipeline_probe_element', [prefix 'pipeline_probe_element']);
end
obj = schemaObject;
end
