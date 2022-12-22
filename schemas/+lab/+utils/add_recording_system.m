function add_recording_system(system_name, acquisition_type)
%Add new recording_system to location table, if already exist update system_type
% Inputs
% system_name = 



new_key = struct;
query_key = struct;
query_key.location = system_name;

location_record = fetch(lab.Location & query_key);

if isempty(location_record)
    new_key.location         = system_name;
    new_key.system_type      = "recording";
    new_key.acquisition_type = acquisition_type;
    insert(lab.Location, new_key)
else
    update(lab.Location & query_key, 'system_type', 'recording');
    update(lab.Location & query_key, 'acquisition_type', acquisition_type);
end
    

end

