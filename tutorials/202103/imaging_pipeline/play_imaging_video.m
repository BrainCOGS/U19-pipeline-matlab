
data_dir = fullfile(fileparts(matlab.desktop.editor.getActiveFilename), 'data');
imaging_video = fullfile(data_dir, 'imaging_pipeline_test_video_1.avi');
vidObj        = VideoReader(imaging_video);
f = figure('units','normalized','outerposition',[0 0 1 1])
hold on
imshow(frame, 'InitialMagnification', 1024);
movegui(f, 'center')
tic
while(hasFrame(vidObj))
    frame = readFrame(vidObj);
    imshow(frame, 'InitialMagnification', 1024);
end
toc