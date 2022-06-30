function obj = getSchema
prefix = getenv('DB_PREFIX');
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'behavior_subtask', [prefix 'behavior_subtask']);
end
obj = schemaObject;
end
