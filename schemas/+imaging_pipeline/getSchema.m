function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'imaging_pipeline', [prefix 'imaging_pipeline']);
end
obj = schemaObject;
end
