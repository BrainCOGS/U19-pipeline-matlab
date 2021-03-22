function reprocess_tiff_headers(key_data)

isMesoscope = 1;
scan_dir_db    = fetch1(imaging.Scan & key_data,'scan_directory');
scan_directory = lab.utils.format_bucket_path(scan_dir_db);

%Check if directory exists in system
lab.utils.assert_mounted_location(scan_directory)

tif_dir = fullfile(scan_directory, 'originalStacks');
cd(tif_dir)

scanInfo = imaging.ScanInfo;

%% loop through files to read all image headers
[fl, basename, isCompressed] = scanInfo.check_tif_files(tif_dir);

fprintf('\tgetting headers...\n')
[imheader, parsedInfo] = scanInfo.get_parsed_info(fl, isMesoscope);

%Get recInfo field
[recInfo, framesPerFile] = scanInfo.get_recording_info(fl, imheader, parsedInfo);

%get nfovs field
recInfo.nfovs = scanInfo.get_nfovs(recInfo, isMesoscope);

%Get last "good" file because of bleaching
[lastGoodFile, cumulativeFrames] = scanInfo.get_last_good_frame(framesPerFile, tif_dir);
recInfo.nframes_good              = cumulativeFrames(lastGoodFile);
recInfo.last_good_file            = lastGoodFile;

% check acqTime is valid, and if not, correct it
recInfo.AcqTime = scanInfo.check_acqtime(recInfo.AcqTime, scan_directory);

nROI                          = recInfo.nROIs;
% scan image concatenates FOVs (ROIs) by adding rows, with padding between them.
% This part parses and write tifs individually for each FOV

%Get stridx again
stridx   = regexp(fl{1},self.tif_number_fmt);

if isempty(gcp('nocreate'))
    
    c = parcluster('local'); % build the 'local' cluster object
    num_workers = min(c.NumWorkers, 16);
    parpool('local', num_workers, 'IdleTimeout', 120);
    
end

fieldLs = {'ImageLength','ImageWidth','BitsPerSample','Compression', ...
    'SamplesPerPixel','PlanarConfiguration','Photometric'};
fprintf('\tparsing ROIs...\n')

ROInr       = arrayfun(@(x)(x.pixelResolutionXY(2)),recInfo.ROI);
ROInc       = arrayfun(@(x)(x.pixelResolutionXY(1)),recInfo.ROI);
interROIlag = recInfo.interROIlag_sec;
Depths      = recInfo.nDepths;

% make the folders in advance, before the parfor loop
for iROI = 1:nROI
    for iDepth = 1:Depths
        mkdir(sprintf('ROIn%02d_z%d',iROI,iDepth));
    end
end

tagNames = Tiff.getTagNames();
parfor iF = 1:numel(fl)
    fprintf('%s\n',fl{iF})
    
    % read image and header
    %         if iF <= lastGoodFile % do not write frames beyond last good frame based on bleaching
    readObj    = Tiff(fl{iF},'r');
    
    current_header = struct();
    for i = 1:length(tagNames)
        try
            current_header.(tagNames{i}) = readObj.getTag(tagNames{i});
        catch
            %warning([tagNames{i} 'does not exist on tif'])
        end
    end
    
    thisstack  = zeros(imheader{iF}(1).Height,imheader{iF}(1).Width,numel(imheader{iF}),'uint16');
    for iFrame = 1:numel(imheader{iF})
        readObj.setDirectory(iFrame);
        thisstack(:,:,iFrame) = readObj.read();
    end
    
    % number of ROIs and blank pixels from beam travel
    [nr,nc,~]  = size(thisstack);
    padsize    = (nr - sum(ROInr)) / (nROI - 1);
    rowct      = 1;
    
    % create a separate tif for each ROI
    for iROI = 1:nROI
        
        thislag  = interROIlag*(iROI-1);
        
        for iDepth = 1:Depths
            
            % extract correct frames
            zIdx       = iDepth:Depths:size(thisstack,3);
            substack   = thisstack(rowct:rowct+ROInr(iROI)-1,1:ROInc(iROI),zIdx); % this square ROI, depths are interleaved
            thisfn     = sprintf('../ROIn%02d_z%d/%sROI%02d_z%d_%s',iROI,iDepth,basename,iROI,iDepth,fl{iF}(stridx+1:end));
            writeObj   = Tiff(thisfn,'w');
            thisheader = struct([]);
            
            % set-up header
            for iField = 1:numel(fieldLs)
                switch fieldLs{iField}
                    case 'TIFF File'
                        thisheader(1).(fieldLs{iField}) = thisfn;
                        
                    case 'ImageLength'
                        thisheader(1).(fieldLs{iField}) = nc;
                        
                    otherwise
                        thisheader(1).(fieldLs{iField}) = readObj.getTag(fieldLs{iField});
                end
            end
            thisheader(1).ImageDescription        = imheader{iF}(zIdx(1)).ImageDescription;
            %strrep(thisheader(1).Software,'hRoiManager.mroiEnable = 1', 'hRoiManager.mroiEnable = 0');
            
            thisheader(1).Artist                  = current_header.Artist;
            thisheader(1).Software                = current_header.Software;
            thisheader(1).Software = strrep(thisheader(1).Software,'hRoiManager.mroiEnable = 1', 'hRoiManager.mroiEnable = 0');
            fovum = strfind(thisheader(1).Software,'SI.hRoiManager.imagingFovUm');
            if ~isempty(fovum)
                idx_new = regexp(thisheader(1).Software(fovum:end), newline, 'once');
                thisheader(1).Software(fovum:fovum+idx_new-1) = [];
            end
            
            % write first frame
            writeObj.setTag(thisheader);
            writeObj.setTag('SampleFormat',Tiff.SampleFormat.UInt);
            writeObj.write(substack(:,:,1));
            
            % write frames
            for iZ = 2:size(substack,3)
                %                 % do not write frames beyond last good frame based on bleaching
                %                 if iF == lastGoodFile && iZ > lastFrameInFile; continue; end
                
                % account for ROI lags in new time stamps
                imdescription = imheader{iF}(zIdx(iZ)).ImageDescription;
                old           = cell2mat(regexp(cell2mat(regexp(imdescription,'frameTimestamps_sec = [0-9]+.[0-9]+','match')),'\d+.\d+','match'));
                new           = num2str(thislag + str2double(old));
                imdescription = replace(imdescription,old,new);
                % write image and hedaer
                thisheader(1).ImageDescription = imdescription;
                thisheader(1).Artist           = current_header.Artist;
                thisheader(1).Software         = current_header.Software;
                thisheader(1).Software = strrep(thisheader(1).Software,'hRoiManager.mroiEnable = 1', 'hRoiManager.mroiEnable = 0');
                fovum = strfind(thisheader(1).Software,'SI.hRoiManager.imagingFovUm');
                if ~isempty(fovum)
                    idx_new = regexp(thisheader(1).Software(fovum:end), newline, 'once');
                    thisheader(1).Software(fovum:fovum+idx_new-1) = [];
                end
                writeObj.writeDirectory();
                writeObj.setTag(thisheader);
                writeObj.setTag('SampleFormat',Tiff.SampleFormat.UInt);
                write(writeObj,substack(:,:,iZ));
            end
            
            % close tif stack object
            writeObj.close();
            
            %clear substack
        end
        
        % update first row index
        rowct    = rowct+padsize+ROInr(iROI);
    end
    
    readObj.close();
    % now move file
    %movefile(fl{iF},sprintf('originalStacks/%s',fl{iF}));
end

end