function obj = getSchema
prefix = getenv('DB_PREFIX');
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'pupillometry', [prefix 'pupillometry']);
end
obj = schemaObject;
end
