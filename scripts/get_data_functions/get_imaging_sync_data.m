function get_imaging_sync_data(session_key)


[status, data] = lab.utils.read_behavior_file(session_key);

session_data = fetch(behavior.SpatialTimeBlobs & session_key,'*')

imaging_key = fetch(recording.RecordingBehaviorSession & session_key)

sync_info = fetch(imaging_pipeline.SyncImagingBehavior & imaging_key,'*')


l = 0

end

