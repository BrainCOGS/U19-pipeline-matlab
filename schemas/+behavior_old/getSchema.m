function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'behavior_old', [prefix 'behavior_old']);
end
obj = schemaObject;
end
