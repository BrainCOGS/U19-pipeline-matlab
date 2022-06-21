function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'meso_old', [prefix 'meso_old']);
end
obj = schemaObject;
end
