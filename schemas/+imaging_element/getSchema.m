function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'imaging_element', [prefix 'imaging_element']);
end
obj = schemaObject;
end
