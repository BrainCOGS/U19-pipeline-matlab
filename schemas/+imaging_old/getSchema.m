function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'imaging_old', [prefix 'imaging_old']);
end
obj = schemaObject;
end
