function obj = getSchema
prefix = getenv('DB_PREFIX');
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'deeplabcut_pipeline', [prefix 'deeplabcut_pipeline']);
end
obj = schemaObject;
end
