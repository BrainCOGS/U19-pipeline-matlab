function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'ephys_pipeline', [prefix 'ephys_pipeline']);
end
obj = schemaObject;
end
