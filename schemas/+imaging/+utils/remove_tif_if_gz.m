function remove_tif_if_gz(fl, directory)
% if there are gz files, remove tif files remove_tif_if_gz
%
% Inputs
% fl        = list of tif files to check
% directory = 
%

curr_dir = pwd;
cd(directory)

for iF = 1:numel(fl)
    if exist([fl{iF} '.gz'],'file')
        disp(['removing ' fl{iF}])
        delete(fl{iF})
    else
        disp(['compressed file not found, keeping ' fl{iF}])
    end
end

cd(curr_dir);

end


