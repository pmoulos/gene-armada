function affystruct = affyread(filename,libdir,noLibCheck)
%AFFYREAD reads Affymetrix GeneChip data files.
%
%   AFFYDATA = AFFYREAD(FILE) reads the Affymetrix data file, FILE, and
%   creates a structure, AFFYDATA. AFFYREAD can read DAT, EXP, CEL, CHP,
%   CDF and GIN files.
%
%   AFFYDATA = AFFYREAD(FILE,LIBDIR) allows you to specify the directory
%   where the library (CDF and GIN) files are stored.
%
%   Note: When reading a CHP file, the Affymetrix GDAC Runtime Libraries
%   look for the associated CEL file in the directory that it was in when
%   the CHP file was created. If the CEL file is not found then no probe
%   set values will be read.
%
%   If you encounter errors reading files then check that the Affymetrix
%   GDAC Runtime Libraries are correctly installed. You can re-install the
%   libraries by running the installer from the Windows Explorer:
%   $MATLAB$\toolbox\bioinfo\microarray\lib\GdacFilesRuntimeInstall-v4.exe
%
%   Example:
%
%       % Read in a CEL file
%       celStruct = affyread('Drosophila.CEL')
%       % Display a spatial plot of probe intensities
%       maimage(celStruct,'Intensity');
%
%       % Read in a DAT file and display the raw image data
%       datStruct = affyread('Drosophila.dat')
%       imagesc(datStruct.Image);
%       axis image;
%
%       % Read in a CHP file and plot the probe values for probe set 143417_at
%       % Note the CHP files require the library files. Your file may be in
%       % a different location.
%       chpStruct = affyread('Drosophila.chp',...
%                                  'D:\Affymetrix\LibFiles\DrosGenome1')
%       geneName = probesetlookup(chpStruct,'143417_at')
%       probesetplot(chpStruct,'143417_at');
%
%   Sample data files are available from
%   http://www.affymetrix.com/support/technical/sample_data/demo_data.affx
%
%   See also AGFEREAD, CELINTENSITYREAD, GPRREAD, PROBELIBRARYINFO,
%   PROBESETLINK, PROBESETLOOKUP, PROBESETPLOT, PROBESETVALUES, SPTREAD. 
%
%   GeneChip and Affymetrix are registered trademarks of Affymetrix, Inc.

% Copyright 2003-2006 The MathWorks, Inc.
% $Revision: 1.1.6.13 $   $Date: 2006/06/16 20:07:24 $

% Currently only supported on Windows
if ~ispc
    error('Bioinfo:affyread:AffyreadWindowsOnly',...
        'AFFYREAD is only supported on Windows.');
end

if nargin < 1
    error('Bioinfo:affyread:NotEnoughInputs',...
        'Not enough input arguments.');
end

% The GDAC runtime libraries must be installed. Check to see if they are.
% If not try to install them.

% first see if the files are on the path,

% The old libraries put a registry key but the new version doesn't
% seem to do this.
%     verNum  = winqueryreg('HKEY_LOCAL_MACHINE',...
%         'SOFTWARE\Affymetrix\GDAC', 'GDACFiles Version'); %#ok

if (nargin < 3) && (isempty(strfind(lower(getenv('PATH')),'gdacfiles')))
    % GDAC runtime not on the path...
    theButton =questdlg(...
        sprintf(['The Affymetrix GDAC Runtime Libraries must be installed. \n',...
        'Would you like to install them now?\n\n',...
        'You may need to restart MATLAB after running the GDAC files installer.']),...
        'Install GDAC Runtime Libraries?',...
        'Yes','No','Yes');
    if strcmp(theButton,'Yes')
        system([matlabroot '\toolbox\bioinfo\microarray\lib\GdacFilesRuntimeInstall-v4.exe']);
    else
        error('Bioinfo:affyread:GDACNotInstalled',...
            'Affyread requires the Affymetrix GDAC Runtime Libraries.');
    end
elseif (nargin > 2) && strcmp(noLibCheck,'verbose')
    disp('Library check disabled');
end

% figure out if the file is in the current directory or on the path
wfilename = which(filename);
if ~isempty(wfilename)
    filename = wfilename;
end
[pathdir,theName,theExt] = fileparts(filename);

% if no path part, use the local directory (this is probably redundant)
if isempty(pathdir)
    pathdir = pwd;
end

% check for valid extensions?
theFile = [theName,upper(theExt)];

% Set up the lib path
if nargin == 1
    libdir = pathdir;
end
fullpath = [pathdir,filesep,theFile];
if ~exist(fullpath,'file')
    % try libdir
    fullpath = [libdir,filesep,theFile];
    if ~exist(fullpath,'file')
        error('Bioinfo:affyread:FileDoesNotExist',...
            '%s does not appear to exist.',theFile);
    else
        pathdir = libdir;
    end
end

% if libdir points to a file then use its directory
if ~exist(libdir,'dir') && exist(libdir,'file')
    libdir = fileparts(libdir);
end

% check that libdir exists
if ~exist(libdir,'dir')
    warning('Bioinfo:affyread:LibdirNotDirectory',...
        '%s does not appear to be a directory.',libdir);
elseif isempty(dir([libdir,filesep,'*.cdf']))
    if strcmpi(theExt,'.chp')
        warning('Bioinfo:affyread:NoCDFInLibdir',...
            '%s does not contain any library (CDF) files.',libdir);
    end
end

% read the file using affymex
if ~strcmpi(theExt,'.gin')
    try
        affystruct = affymex(theFile,pathdir,libdir);
    catch
        error('Bioinfo:affyread:AffymetrixAPIMexError',...
            'Error reading %s.',theFile)
    end
else
    affystruct = affyginread(filename,pathdir,libdir);
end
if isempty(affystruct)
    error('Bioinfo:affyread:AffymexFailed','Unable to read file %s.',theFile);
end


function ginStruct = affyginread(filename,pathdir,libdir) %#ok
% AFFYGINREAD reads in GIN files that contain gene identifiers
fullFileName = '';
if exist(filename,'file')
    % we have the file
    fullFileName = filename;
else
    if nargin > 1
        fullFileName = fullfile(libdir,filename);
    end
end

fid = fopen(fullFileName,'r');
if fid < 0
    error('Bioinfo:affyread:BadFile',...
        'Cannot open file %s',fullFileName);
end
% Read in the header lines
line = fgetl(fid);

if strncmpi('version',line,7) == 1  % versioned files (version 2 and higher?)

    version = strread(line,'%*s%d','delimiter','=');
    line = fgetl(fid);
    name = strread(line,'%*s%s','delimiter','=');
    line = fgetl(fid);
    numURLs = strread(line,'%*s%d','delimiter','=');

    % allocate space for the references and URLS.
    urls = cell(numURLs,1);
    refname = cell(numURLs,1);
    refs = cell(numURLs,1);
    for count = 1: numURLs
        line = fgetl(fid);
        [refs(count) , refname(count), urls(count)] =...
            strread(line,'%s%s%s','delimiter',';');
    end

    % Read in the rest of the file skipping the line with column headings.
    out = textscan(fid,'%d%s%s%s%s%*[^\n]','headerlines',1,'delimiter','\t');
    % close the file
    fclose(fid);

    % Set output structure
    ginStruct.Name = name{:};
    ginStruct.Version = version;
    ginStruct.ProbeSetName = out{:,4};
    ginStruct.ID = out{:,2};
    ginStruct.Description = out{:,5};
    if numURLs == 1
        ginStruct.SourceNames = refs{:};
        ginStruct.SourceURL = urls{:};
        ginStruct.SourceID = 1;
    elseif numURLs == 0
        ginStruct.SourceNames = '';
        ginStruct.SourceURL = '';
        ginStruct.SourceID = 0;
    else
        ginStruct.SourceNames = refs;
        ginStruct.SourceURL = urls;
        [dummy, ginStruct.SourceID ] = ismember(out{:,3}, refs);%#ok
    end
else  % old files e.g. Hu6800.GIN
    name = strread(line,'%*s%s','delimiter','=');
    line = fgetl(fid);
    refname = strread(line,'%*s%s','delimiter','=');
    line = fgetl(fid);
    [dummy,urls] = strtok(line,'='); %#ok
    urls = urls(2:end);
    ginStruct.Name = name{:};
    ginStruct.Version = 1;
    out = textscan(fid,'%d%s%s%s%s%*[^\n]','headerlines',1,'delimiter','\t');
    fclose(fid);
    ginStruct.ProbeSetName = out{:,3};
    ginStruct.ID = out{:,2};
    ginStruct.Description = out{:,4};
    ginStruct.SourceNames =refname{:};
    ginStruct.SourceURL = urls;
    ginStruct.SourceID = 1;

end
