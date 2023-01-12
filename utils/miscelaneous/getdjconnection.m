function out = getdjconnection(db_prefix, db_name)
    setenv('DB_PREFIX', db_prefix)
    try 
        out  = dj.conn(db_name, '', '', '', '', true); 
    catch 
        out  = dj.conn();
    end
end