function add_recording_system(system_name, acquisition_type)
%Add new recording_system to location table, if already exist update system_type
% Inputs
% system_name      = name label for the new system (Regularly room#-recording)
% acquisition_type = choose from (2photon, 3photon, mesoscope electrophysiology)


new_key = struct;
query_key = struct;
query_key.location = system_name;
%Check if system already exists
location_record = fetch(lab.Location & query_key);

%If is entirely new
if isempty(location_record)
    new_key.location         = system_name;
    %Set values recording and acquisition type
    new_key.system_type      = "recording";
    new_key.acquisition_type = acquisition_type;
    insert(lab.Location, new_key)
% If already is there
else
    %Set values recording and acquisition type
    update(lab.Location & query_key, 'system_type', 'recording');
    update(lab.Location & query_key, 'acquisition_type', acquisition_type);
end
    

end

