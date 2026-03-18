function obj = getSchema
prefix = getenv('DB_PREFIX');
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'posture_tracking', [prefix 'posture_tracking']);
end
obj = schemaObject;
end
