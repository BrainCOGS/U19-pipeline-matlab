function obj = getSchema
prefix = getenv("DB_PREFIX");
persistent schemaObject
if isempty(schemaObject)
schemaObject = dj.Schema(dj.conn, 'pipeline_imaging_element', [prefix 'pipeline_imaging_element']);
end
obj = schemaObject;
end
