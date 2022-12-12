function add_recording_system(system_name)
%Add new recording_system to location table, if already exist update system_type

new_key = struct;
query_key = struct;
query_key.location = system_name;

location_record = fetch(lab.Location & query_key);

if isempty(location_record)
    new_key.location         = system_name;
    new_key.system_type      = "recording";
    insert(lab.Location, new_key)
else
    update(lab.Location & query_key, 'system_type', 'recording');
end
    

end

