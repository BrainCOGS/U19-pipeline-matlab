function obj = getSchema
prefix = getenv('DB_PREFIX');
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'recording_process', [prefix 'recording_process']);
end
obj = schemaObject;
end
