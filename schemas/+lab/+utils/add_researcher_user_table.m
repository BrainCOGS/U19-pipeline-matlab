function add_researcher_user_table(user_id, full_name, email, phone, secondary_contact, labname, protocol)
%add_researcher_user_table, add new reseracher to user table 
% Inputs
% user_id           = NETID of user
% full_name         = First Name & Last Name 
% email             = princeton email
% phone             = only numbers
% secondary_contact = (optional) NETID of main contact for user
% labname           = (optional) one of: (tanklab, wanglab, wittenlab)
% protocol          = (optional) one of: (1876, 1910, 1943-19)


%Default values for optional parameters
if nargin < 5
    secondary_contact = user_id;
end
if nargin < 6
    labname = 'tanklab';
end
if nargin < 7
    protocol = '1910';
end

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

%Insert new UserSecondaryContact
new_sec_contact = struct;
new_sec_contact.user_id = user_id;
new_sec_contact.secondary_contact = secondary_contact;
insert(lab.UserSecondaryContact, new_sec_contact)

%Insert new UserProtocol
new_user_protocol = struct;
new_user_protocol.user_id = user_id;
new_user_protocol.protocol = protocol;
insert(lab.UserProtocol, new_user_protocol)

%Insert new UserLab
new_user_lab = struct;
new_user_lab.user_id = user_id;
new_user_lab.lab = labname;
insert(lab.UserLab, new_user_lab)


%If user already there
else
    %Update corresponding values
    update(lab.User & user_id_query, 'user_nickname', full_name);
    update(lab.User & user_id_query, 'full_name', full_name);
    update(lab.User & user_id_query, 'email', email);
    update(lab.User & user_id_query, 'phone', phone);
    
    update(lab.UserLab & user_id_query, 'lab', labname);
    
    update(lab.UserProtocol & user_id_query, 'protocol', protocol);
    
    update(lab.UserSecondaryContact & user_id_query, 'secondary_contact', secondary_contact);

     
end

