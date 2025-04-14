function ingest_new_headplate_images()

query_hpi = "head_plate_mark is not null and headplate_image_path is null";

[~, local_u19_path, rel_path] = lab.utils.get_path_from_official_dir('u19_dj');

local_headplate_path = fullfile(local_u19_path, 'external_files', 'headplate_images');
relative_headplate_path = spec_fullfile('/', rel_path, 'external_files', 'headplate_images');
relative_headplate_path = relative_headplate_path(2:end);

images = fetch(subject.Subject & query_hpi, 'head_plate_mark');

for i = 1:length(images)
    this_image = images(i);

    local_path_image = fullfile(local_headplate_path, ['headplate_mark_', this_image.subject_fullname, '.png']);
    relative_path_image = spec_fullfile('/', relative_headplate_path, ['headplate_mark_', this_image.subject_fullname, '.png']);



    imwrite(this_image.head_plate_mark,local_path_image);
    query_subject.subject_fullname = this_image.subject_fullname;
    update(subject.Subject & query_subject, 'headplate_image_path', relative_path_image)

end

