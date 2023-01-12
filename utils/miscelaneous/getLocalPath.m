function p = getLocalPath(p,os)
% Converts path names to local operating system format using lab conventions.
%
%    localPath = getLocalPath(inputPath) converts inputPath to local OS format
%    using lab conventions. The paths that are converted are stored in the
%    lab.Paths table.
%
%    localPath = getLocalPath(inputPath,OS) will return the path in the format
%    of the operating system specified in OS ('global' | 'linux' |'win' | 'mac')
%
% AE 2011, MF 2016, SS 2019

% determine operating system;
if nargin < 2
    os = computer;
end
os = os(1:min(3,length(os)));

% local os' column
switch lower(os)
    case 'glo'
        local = 1;
        home = '~';
    case {'lin','gln'}
        local = 2;
        home = getenv('HOME');
    case {'win','pcw'}
        local = 3;
        home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
    case 'mac'
        local = 4;
        home = '~';
    otherwise
        error('unknown OS');
end

% convert file separators if necessary
p = strrep(p,'\','/');

% assign home
p = strrep(p,'~',home);

% mapping table

systems = {'linux', 'windows', 'mac'};
globs = unique(fetchn(lab.Path, 'global_path'));
mapping = cell(length(globs), length(systems));
for ikey = 1:length(globs)
    glob = globs{ikey};
    mapping{ikey, 1} = glob;
    for isys = 1:length(systems)
        system = systems{isys};
        mapping{ikey, isys+1} = fetch1(lab.Path & sprintf('global_path="%s"', glob) & sprintf('system="%s"', system), 'local_path');
    end
end

% convert path
sz = size(mapping);
for i = 1:sz(1)
    for j = 1:sz(2)
        n = length(mapping{i,j});
        if j ~= local && strncmpi(p,mapping{i,j},n)
            p = fullfile(mapping{i,local},p(n+2:end));
            break;
        end
    end
end

if filesep == '\' && ~isequal(lower(os),'glo')
    p = strrep(p, '/', '\');
else
    p = strrep(p, '\','/');
end

