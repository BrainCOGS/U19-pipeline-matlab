function add_researcher_user_table(user_id, full_name, email, phone)
%add_researcher_user_table, add new reseracher to user table 

% Values sent by function caller
new_key = struct;
new_key.user_id = user_id;
new_key.user_nickname = full_name;
new_key.full_name = full_name;
new_key.email = email;
new_key.phone = phone;

% Write default values for User
new_key.mobile_carrier = 'none';
new_key.slack = full_name;
new_key.contact_via = 'Slack';
new_key.primary_tech = 'N/A';
new_key.tech_responsibility='yes';
new_key.day_cutoff_time= [18 0];

%Insert
insert(lab.User, new_key)

end

