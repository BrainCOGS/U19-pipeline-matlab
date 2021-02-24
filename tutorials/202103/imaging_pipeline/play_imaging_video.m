
data_dir = fullfile(fileparts(matlab.desktop.editor.getActiveFilename), 'data');
imaging_video = fullfile(data_dir, 'imaging_pipeline_test_video_1.avi');
vidObj        = VideoReader(imaging_video);
figure('units','normalized','outerposition',[0 0 1 1])
tic
while(hasFrame(vidObj))
    frame = readFrame(vidObj);
    imshow(frame, 'InitialMagnification', 1024);
end
toc