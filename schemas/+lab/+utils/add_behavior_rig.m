function add_behavior_rig(rig_name)
%Add new behavior rig to location table, if already exist update system_type and acquisition_type

new_key = struct;
query_key = struct;
query_key.location = rig_name;

location_record = fetch(lab.Location & query_key);

if isempty(location_record)
    new_key.location         = rig_name;
    new_key.system_type      = "rig";
    new_key.acquisition_type = "behavior";
    insert(lab.Location, new_key)
else
    update(lab.Location & query_key, 'system_type', 'rig');
    update(lab.Location & query_key, 'acquisition_type', 'behavior');
end
    

end

