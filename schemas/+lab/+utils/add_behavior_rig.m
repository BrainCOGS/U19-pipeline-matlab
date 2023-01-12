function add_behavior_rig(rig_name)
%Add new behavior rig to location table, if already exist update system_type and acquisition_type
% Input
% rig_name = label for the new rig (must_match RigParameters.rig)


new_key = struct;
query_key = struct;
query_key.location = rig_name;
%Check if rig already exists
location_record = fetch(lab.Location & query_key);

%If is new
if isempty(location_record)
    new_key.location         = rig_name;
    % Set default values for rig, it is a rig for behavior
    new_key.system_type      = "rig";
    new_key.acquisition_type = "behavior";
    insert(lab.Location, new_key)
%If already exists
else
    % Set default values for rig, it is a rig for behavior
    update(lab.Location & query_key, 'system_type', 'rig');
    update(lab.Location & query_key, 'acquisition_type', 'behavior');
end
    

end

