function connect_datajoint00()
%CONNECT_DATAJOINT00 run this function to connect to datajoint00 DB with stored configuration

setenv('DB_PREFIX', 'u19_')
current_dir = pwd;

if isfile('dj_local_conf.json')
    dj.config.load()
    dj.conn()
else
    error('Configuration file not found, run dj_initial_conf')
end

if endsWith(current_dir,'U19-pipeline-matlab')
    addpath(genpath(current_dir));
end

end
