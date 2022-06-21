function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'u19_recording', [prefix 'u19_recording']);
end
obj = schemaObject;
end
