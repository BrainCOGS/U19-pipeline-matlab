function populate_Imaging_AcquiredTiff(key)

%Populate Scaninfo (from recording handler pipeline)
startup_virtual_machine

if nargin < 1
    populate(imaging_pipeline.AcquiredTiff);
    populate(imaging_pipeline.SyncImagingBehavior);
else
    populate(imaging_pipeline.AcquiredTiff, key);
    populate(imaging_pipeline.SyncImagingBehavior, key);
     
end

s = dj.conn;
s.close();

end