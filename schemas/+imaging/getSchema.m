function obj = getSchema
prefix = getenv('DB_PREFIX');
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'imaging', [prefix 'imaging']);
end
obj = schemaObject;
end
