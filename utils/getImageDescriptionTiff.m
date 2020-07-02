function [imageDesc] = getImageDescriptionTiff(tiffHeader)
%GETIMAGEDESCRIPTIONTIFF 
%   Get image description written in ImageDescription column from
%   tiffHeader
%ImageDescription is a very long string with embedded parameters
%
% Inputs
% tiffHeader   =  Header of tiff image from imfinfo function
%
% Outputs
% imageDesc    =  Structure of various parameters of imageDescription
% e.g.
% imageDesc = 
%               imageDesc.frameNumbers: 1
%               imageDesc.acquisitionNumbers: 1
%               imageDesc.frameNumberAcquisition: 1
%               imageDesc.frameTimestamps_sec: 0
%               imageDesc.acqTriggerTimestamps_sec: -1.0938e-04
%               imageDesc.scanimage: [1×1 struct]

% Get ImageDescription column
imageDescCell = tiffHeader(1).ImageDescription;
%Separate by lines 
imageDescCell = splitlines(imageDescCell);
imageDescCell = imageDescCell(1:end-1);

% As all parameters are written as an evaluation, try to evaluate them
imageDesc = struct;
for i=1:length(imageDescCell)
    try
        % If a <struct> or something like is found, treat it like char 
        if any(strfind(imageDescCell{i}, '<'))
            imageDescCell{i} = strrep(imageDescCell{i},'<','''<');
            imageDescCell{i} = strrep(imageDescCell{i},'>','>''');
        end
        eval(['imageDesc.' imageDescCell{i} ';'])
    catch
        % Raise a warning if parameter couldn't be evaluated
        warning(['Image Description parameter couldn''t be read: ' imageDescCell{i}]);
    end
end
end

