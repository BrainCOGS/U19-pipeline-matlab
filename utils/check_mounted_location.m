function status = check_mounted_location(directory)

if ~exist(directory, 'dir')
    status = false;
else
    status = true;
end

end

