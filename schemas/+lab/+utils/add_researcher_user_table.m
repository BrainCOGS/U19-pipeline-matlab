function add_researcher_user_table(user_id, full_name, email, phone)
%add_researcher_user_table, add new reseracher to user table 
% Inputs
% user_id   = NETID of user
% full_name = First Name & Last Name 
% email     = princeton email
% phone     = only numbers

user_id_query = ['user_id ="' user_id '"'];
user = fetch(lab.User & user_id_query);

%If is entirely new
if isempty(user)

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

%Insert new user
insert(lab.User, new_key)

%If user already there
else
    update(lab.User & user_id_query, 'user_nickname', full_name);
    update(lab.User & user_id_query, 'full_name', full_name);
    update(lab.User & user_id_query, 'email', email);
    update(lab.User & user_id_query, 'phone', phone);

end

