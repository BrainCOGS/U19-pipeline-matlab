function animal_list = get_test_live_animals_list()

%get_liveAnimals_list get a full list of live subjects only
%Outputs
% animal_list = cell with list of all live subjects

%Get only subjects that are not dead
animal_list = fetch(subject.Subject & 'subject_fullname like "testuser%"');
animal_list = {animal_list.subject_fullname};


end



