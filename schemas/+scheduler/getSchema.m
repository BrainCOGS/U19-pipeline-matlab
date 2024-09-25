function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'scheduler', [prefix 'scheduler']);
end
obj = schemaObject;
end
