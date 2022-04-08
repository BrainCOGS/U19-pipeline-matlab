function [outputArg1,outputArg2] = test_pupillometry_sync(key)
%TEST_PUPILLOMETRY_SYNC check if pupillometry video is correctly synced (with laser visible on video)
% Input
% key = reference to behavior session

stim_query.stim_on = 1;
opto_data = fetch(optogenetics.OptogeneticSessionTrial & key & stim_query,'*');
video_data = fetch(pupillometry.PupillometrySyncBehavior & key,'*');

for i=1:length(opto_data)
    
    


end

