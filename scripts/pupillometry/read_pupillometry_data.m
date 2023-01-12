
function data = read_pupillometry_data(key)


data = fetch(pupillometry.PupillometrySyncBehavior * pupillometry.PupillometryData & key,'*');


