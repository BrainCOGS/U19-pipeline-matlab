function create_all_schemas_DB(sync_schema)
%Creata a all missing schemas in your definition


if nargin < 1
    sync_schema = 0;
end

conn = dj.conn;

%Get all DBs
all_db = conn.query('SHOW DATABASES');
all_db = all_db.Database;

%Get only DBs with DB_PREFIX
idx_prefix_db = startsWith(all_db,getenv('DB_PREFIX'));
all_db = all_db(idx_prefix_db);
all_db = strrep(all_db, getenv('DB_PREFIX'), '');

%Create schema for each DB
for i = 1:length(all_db)
    create_schema_from_DB(all_db{i}, sync_schema)
end
