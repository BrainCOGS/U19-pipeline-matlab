function connect_datajoint00()
%CONNECT_DATAJOINT00 run this function to connect to datajoint00 DB with stored configuration

setenv('DB_PREFIX', 'u19_')
current_dir = pwd;

u19_pipeline_dir = fileparts(mfilename('fullpath'));

cd(u19_pipeline_dir)


if isfile('dj_local_conf.json')
    disp(fileparts(which('dj_local_conf.json')))
    dj.config.load()
    dj.conn()
elseif isfile('.datajoint_config.json')
    disp(fileparts(which('.datajoint_config.json')))
    dj.config.load()
    dj.conn()
elseif isfile(fullfile(getenv("HOME"), '.datajoint_config.json'))
    disp(((fullfile(getenv("HOME"), '.datajoint_config.json'))))
    dj.config.load()
    dj.conn()
else
    error('Configuration file not found, run dj_initial_conf')
end

addpath(genpath(u19_pipeline_dir));
cd(current_dir);

end

