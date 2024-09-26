function iopl = create_input_output_profile_list(last_id, input_outputs, check_type)

num_input_outputs = length(input_outputs);
iopl = struct();
for i = 1:num_input_outputs
    iopl(i).input_output_profile_id = last_id+1;
    iopl(i).input_output_num = i;
    iopl(i).input_output_name = input_outputs{i};
    iopl(i).check_type = check_type{i};
end
