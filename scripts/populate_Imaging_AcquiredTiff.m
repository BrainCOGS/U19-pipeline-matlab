function populate_Imaging_AcquiredTiff(key)

%Populate Scaninfo (from recording handler pipeline)
startup_u19_pipeline_matlab_spock

if nargin < 1
    populate(imaging_pipeline.AcquiredTiff);
else
    populate(imaging_pipeline.AcquiredTiff, key);
     
end

s = dj.conn;
s.close();

end