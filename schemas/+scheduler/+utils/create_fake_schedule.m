

schedule_struct = struct();
schedule_struct.subject_fullname = 'efonseca_ef559_act121';
schedule_struct.input_output_profile_id = 5;


schedule_struct(2).subject_fullname = 'jk8386_jk53';
schedule_struct(2).input_output_profile_id = 2;

schedule_struct(3).subject_fullname = 'efonseca_ef756_act123';
schedule_struct(3).input_output_profile_id = 6;

schedule_struct(4).subject_fullname = 'jyanar_ya012';
schedule_struct(4).input_output_profile_id = 4;


%Get only input_output_profile_ids from schedule struct
input_output_profile_id_struct = struct();
for i=1:length(schedule_struct)
    input_output_profile_id_struct(i).input_output_profile_id = schedule_struct(i).input_output_profile_id;
end

% Fetch all input outputs needed from InputOutputProfileList
input_output_profile_list = fetch(scheduler.InputOutputProfileList & input_output_profile_id_struct,'*');

% Unique tests to perform
tests_perform = unique({input_output_profile_list.input_output_name});



