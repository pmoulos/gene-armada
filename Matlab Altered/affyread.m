function affystruct = affyread(filename,libdir)
%AFFYREAD reads Affymetrix GeneChip data files.
%
%   AFFYDATA = AFFYREAD(FILE) reads the Affymetrix data file, FILE, and
%   creates a structure, AFFYDATA. AFFYREAD can read BGP, DAT, EXP, CEL,
%   CDF, CHP, CLF, and GIN files.
%
%   AFFYDATA = AFFYREAD(FILE,LIBDIR) allows you to specify the directory
%   where the library (CDF and GIN) files are stored. This option is only
%   used when reading CHP, CDF or GIN files. If LIBDIR is not set then
%   AFFYREAD will look in the current working directory for the library
%   files. Note that you can read CHP files without specifying a LIBDIR
%   however unless the corresponding CDF file is in the current working
%   directory, the probe set names and types will not be set.
%
%   Sample data files are available from
%   http://www.affymetrix.com/support/technical/sample_data/demo_data.affx
%   The data files are stored in .DTT format. You will need to install the
%   Data Transfer Tool to extract the individual files. This tool can also
%   be used to extract files from legacy CAB format files.
%   http://www.affymetrix.com/products/software/specific/dtt.affx
%
%   Example:
%
%       % Read in a CEL file
%       celStruct = affyread('Ecoli-antisense-121502.CEL')
%       % Display a spatial plot of probe intensities
%       maimage(celStruct,'Intensity');
%
%       % Read in a DAT file and display the raw image data
%       datStruct = affyread('Ecoli-antisense-121502.dat')
%       imagesc(datStruct.Image);
%       axis image;
%
%       % Read in a CHP file and extract information for Probe Set 3315278.
%       % Note that reading CHP files requires the corresponding CDF
%       % library files. Your files may be in a different location.
%       chpStruct = affyread('Ecoli-antisense-121502.chp',...
%                                  'C:\Affymetrix\LibFiles\Ecoli_ASv2')
%       geneName = probesetlookup(chpStruct,'3315278')
%
%   See also AGFEREAD, AFFYDEMO, AFFYPREPROCESSDEMO, AFFYRMA, AFFYGCRMA,
%   CELINTENSITYREAD, GPRREAD, PROBELIBRARYINFO, PROBESETLINK,
%   PROBESETLOOKUP, PROBESETPLOT, PROBESETVALUES, SPTREAD.
%
%   GeneChip and Affymetrix are registered trademarks of Affymetrix, Inc.

% Copyright 2003-2008 The MathWorks, Inc.
% $Revision: 1.1.6.22 $   $Date: 2009/05/07 18:16:23 $


bioinfochecknargin(nargin,1,mfilename);

if ~ischar(filename)
    error('Bioinfo:affyread:FilenameNotChar',...
        'The filename must be a string.');
end
filename = strtrim(filename);

% figure out if the file is in the current directory or on the path
wfilename = which(filename);
if ~isempty(wfilename)
    filename = wfilename;
end

[pathdir,theName,theExt] = fileparts(filename);

% if libdir is set then work out what we got
if nargin > 1
    % if it doesn't exist then error
    if ~exist(libdir,'file') % 'file' covers both dir and file
        error('Bioinfo:affyread:LibdirNotExist',...
            'LIBDIR %s does not exist.',libdir);
    end
% % Not really necessary...    
%     %Throw warning if using libdir with any file type other than .CHP, .CDF,
%     %.GIN or .PSI
%     if ~any(strncmpi(theExt,{'.chp','.cdf','.gin','.psi'},numel(theExt)))
%         warning('Bioinfo:affyread:FileTypeNotChpCdfGin',...
%             ['The FILE input, %s, is not a CHP, CDF or GIN filetype.\n',...
%             'The LIBDIR input is only valid with CHP, CDF and GIN filetypes.'],[theName theExt]);
%     end
    % if the full path to a CDF file is given then extract the path
    if ~exist(libdir,'dir') %% i.e. it is a file
        [tempdir,z,tempExt] = fileparts(which(libdir));
        if any(strcmpi(tempExt,{'.cdf','.gin','.psi'}));
            libdir = tempdir;
        else
            error('Bioinfo:affyread:LibdirNotDirectory',...
                'LIBDIR %s is not a directory.',libdir);
        end
    end
    % The old libraries allowed the CDF file to be in the libdir
    % E.g. affyread('Test3.CDF','C:\genechip\libDir');
    % if libdir is specified then look here first
    if strcmpi(theExt,'.cdf') || strcmpi(theExt,'.gin')  || strcmpi(theExt,'.psi')
        if exist(fullfile(libdir,[theName,theExt]),'file')
            filename = fullfile(libdir,[theName,theExt]);
            [pathdir,theName,theExt] = fileparts(filename);
        end
    end
else
    libdir = pathdir;
end

% if no path part, use the local directory (this is probably redundant)
if isempty(pathdir)
    pathdir = pwd;
end

% check for valid extensions?
theFile = [theName,theExt];  % do we need to care about case insensitivity?

fullpath = [pathdir,filesep,theFile];
% affyread(libFile,libPath) is valid
if nargin > 1 && ~exist(fullpath,'file')
    % try libdir
    fullpath = [libdir,filesep,theFile];
    pathdir = libdir;
end

if ~exist(fullpath,'file')
    error('Bioinfo:affyread:FileDoesNotExist',...
        '%s does not exist.',theFile);
end

% read the file using affymex
switch(lower(theExt))
    case '.gin'
        affystruct = affxginread(filename,pathdir,libdir);
    case '.exp'
        affystruct = affxexpread(filename);
    case '.dat'
        affystruct = affxdatread(filename);
    case '.psi'
        affystruct = affxpsiread(filename);
    case '.clf'
        affystruct = affxclfread(filename);
    case '.bgp'
        affystruct = affxbgpread(filename);
    case {'.cdf','.cel','.chp'}
        try
            [lw,lid] = lastwarn('');
            affystruct = affyfusionmex(filename,pathdir);
            [theWarn,theWID] = lastwarn;
            if ~isempty(theWarn)
                if ~isempty(strfind(theWID,'ReadError'))
                    fprintf(['The most probable cause of this problem is that you do not have enough memory to read the file.\n',...
                        'See ''doc memory'' for more information on how to make the best use of memory when running MATLAB.\n\n']);
                end
            else
                lastwarn(lw,lid);
            end
            
            affystruct.Name = theFile;
            affystruct.FullPathName = fullpath;
            affystruct.LibPath = libdir;
            if isfield(affystruct,'DataPath') && isempty(affystruct.DataPath)
                
                affystruct.DataPath = pathdir;
            end
            if isempty(affystruct.Date)
                dirInfo = dir(filename);
                affystruct.Date = dirInfo.date;
            end
            % Some CDF files, including the "unsupported"
            % HuGene-1_0-st-v1.r3.cdf are read in with a mismatch between
            % the ProbeSets(i).NumPairs and the number of pairs reported in
            % ProbeSets(i).ProbePairs. This is typically caused by unusual
            % values in the start and stop position of the probes in the
            % CDF file. Typically NumPairs is correct and the ProbePairs
            % with indices greater than NumPairs are uninitialized values,
            % i.e. zero, created when the mex file allocates the space for
            % the pairs. We remove these "pseudopairs" here.
            if(strcmpi(theExt,'.cdf'))
                for count =1:numel(affystruct.ProbeSets)
                    if affystruct.ProbeSets(count).NumPairs ~= size(affystruct.ProbeSets(count).ProbePairs,1)
                        pseudoPairs = affystruct.ProbeSets(count).ProbePairs(affystruct.ProbeSets(count).NumPairs+1:end,:);
                        if ~any(pseudoPairs(:))
                            affystruct.ProbeSets(count).ProbePairs(affystruct.ProbeSets(count).NumPairs+1:end,:) = [];
                        end
                    end
                end
            end
            % For CHP files we want to set the Names and ProbeSetTypes
            % from the associated CDF file.
            if(strcmpi(theExt,'.chp'))
                % now look for the associated CDF file. The search order is
                % libdir, pwd, pathdir.
                cdfFile = fullfile(libdir,[affystruct.ChipType,'.CDF']);
                % Assume the extension is uppercase. For non-Windows
                % platforms we need to be careful about case sensitivity.
                if ~exist(cdfFile,'file');
                    % libdir lowercase cdf
                    if exist(fullfile(libdir,[affystruct.ChipType,'.cdf']),'file')
                        cdfFile = fullfile(libdir,[affystruct.ChipType,'.cdf']);
                        % pathdir
                    elseif exist(fullfile(pathdir,[affystruct.ChipType,'.CDF']),'file')
                        cdfFile = fullfile(pathdir,[affystruct.ChipType,'.CDF']);
                    elseif exist(fullfile(pathdir,[affystruct.ChipType,'.cdf']),'file')
                        cdfFile = fullfile(pathdir,[affystruct.ChipType,'.cdf']);
                        % pwd
                    elseif exist(fullfile(pwd,[affystruct.ChipType,'.CDF']),'file')
                        cdfFile = fullfile(pwd,[affystruct.ChipType,'.CDF']);
                    elseif exist(fullfile(pwd,[affystruct.ChipType,'.cdf']),'file')
                        cdfFile = fullfile(pwd,[affystruct.ChipType,'.cdf']);
                    end
                end
                if exist(cdfFile,'file')
                    cdfstruct = affyfusionmex(cdfFile,pathdir,false);
                    for probeCount = 1:affystruct.NumProbeSets
                        affystruct.ProbeSets(probeCount).Name = cdfstruct.ProbeSets(probeCount).Name;
                        affystruct.ProbeSets(probeCount).ProbeSetType = cdfstruct.ProbeSets(probeCount).ProbeSetType;
                    end
                else
                    warning('Bioinfo:affyread:CHPNoCDF',...
                        ['The CDF file associated with Chip Type %s was not found in the library directory.\n',...
                        'Probe Set names have not been set.'],affystruct.ChipType);
                end
            end
            
        catch
            error('Bioinfo:affyread:AffymetrixAPIMexError',...
                'Error reading %s.\n%s',theFile)
        end
    otherwise
        error('Bioinfo:affyread:UnknownFileType',...
            ['%s does not have a supported file extension.\n',...
            'Supported extensions are BGP, CEL, CDF, CHP, CLF, DAT, EXP, GIN, and PSI.'],theFile);
end
if isempty(affystruct)
    error('Bioinfo:affyread:AffymexFailed','Unable to read file %s.',theFile);
end


