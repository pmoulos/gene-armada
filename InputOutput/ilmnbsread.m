function output = ilmnbsread(filename,varargin)
%ILMNBSREAD reads data exported from Illumina BeadStudio.
%
%   ILMNSTRUCT = ILMNBSREAD(FILE) reads tab-delimited or comma-separated
%   expression data exported from Illumina BeadStudio from FILE and creates
%   a structure ILMNSTRUCT, containing these fields:
%           Header
%           TargetID
%           Data
%           ColumnNames
%           TextData
%           TextColumnNames
%
%   ILMNBSREAD(...,'COLUMNS',COLNAMES) only reads the data from columns
%   with names in cell array COLNAMES. The default is to read data from all
%   columns.
%
%   ILMNBSREAD(...,'HEADERONLY',true) creates the structure and loads the
%   the Header, ColumnNames and TextColumnNames fields but leaves the Data
%   and TextData fields empty. You can use this option to find out the
%   column names for large data sets without having to load all of the data
%   in the file.
%
%   ILMNBSREAD(...,'CLEANCOLNAMES',true) returns ColumnNames that are valid
%   MATLAB variable names. By default, the ColumnNames in the exported file
%   may contain spaces and some characters that cannot be used in MATLAB
%   variable names. This option should be used if you plan to use the
%   column names as variable names in a function.
%
%   Example:
%
%       % Read in a sample BeadStudio file. 
%       % Note that this file is not provided with Bioinformatics Toolbox.
%       ilmnStruct = ilmnbsread('TumorAdjacent-probe-raw.txt')
%
%   See also AFFYREAD, AGFEREAD, CELINTENSITYREAD, GALREAD, GEOSOFTREAD,
%   GPRREAD, ILMNBSLOOKUP, IMAGENEREAD, MAGETFIELD, SPTREAD.
%
%   Illumina is a registered trademark of Illumina, Inc.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2008/06/16 16:33:43 $

% Handle inputs
bioinfochecknargin(nargin, 1, mfilename)
[allColumns,colNamesToRead, headeronly,cleancolnames] = parse_inputs(varargin{:});

% try to open the file
try
    fopenMessage = '';
    [fid, fopenMessage] = fopen(filename,'rt');
catch
    fid = -1;
end

if fid == -1
    error('Bioinfo:ilmnbsread:CannotOpenFile',...
        'Problem opening file %s.\n%s',filename,fopenMessage);
end

% Some files contain header information
HeaderStrings = {'Illumina Inc. BeadStudio version','BeadStudio_Version';
    'Normalization','Normalization';
    'Array Content','Array_Content';
    'Error Model','Error_Model';
    'DateTime','DateTime';
    'Local Settings','Local_Settings'};

defaultHeader = struct(HeaderStrings{1,2},'',...
    HeaderStrings{2,2},'',...
    HeaderStrings{3,2},'',...
    HeaderStrings{4,2},'',...
    HeaderStrings{5,2},'',...
    HeaderStrings{6,2},'',...
    'Filename',filename,...
    'Text','',...
    'Type','Illumina BeadStudio');


numHeaderLines = 1;
maxHeaderLines = 100;
headerLines = cell(maxHeaderLines,1);
colNames = {};
delimiter = '\t';

% Read the first line and extract the column names
while numHeaderLines <= maxHeaderLines || feof(fid)
    theLine = fgetl(fid);
    if feof(fid)
        break
    end
    theLine = strtrim(theLine);
    if ~isempty(theLine)
        colNames = strread(theLine,'%s','delimiter','\t');
        headerLines{numHeaderLines} = theLine;
        numHeaderLines = numHeaderLines+1;
        if strcmpi(colNames{1},'TargetID') || strcmpi(colNames{1},'ID_REF')
            headerLines(numHeaderLines:end) = [];
            break
        end
        % try comma as a delimiter instead of \t
        colNames = strread(theLine,'%s','delimiter',',');
        if strcmpi(colNames{1},'TargetID') || strcmpi(colNames{1},'ID_REF')
            headerLines(numHeaderLines:end) = [];
            delimiter = ',';
            break
        end
    end
end
if numHeaderLines >= maxHeaderLines || isempty(colNames)
    fclose(fid);
    error('Bioinfo:ilmnbsread:NoTargetIDColumn',...
        '%s does not contain a TargetID or ID_REF column.',filename);
end
if isempty(headerLines)
    headerLines = defaultHeader;
end
% set up some variables
numCols = numel(colNames);
colsToRead = true(1,numCols);
isNumCol = false(1,numCols);
formatStr = repmat('%*s',1,numCols);

% Decide which columns we want to read
if ~allColumns
    % we always read TargetID
    colNamesToRead{end+1} = 'TargetID';
    matches = cell2mat(cellfun(@(x)strncmpi(x,colNames,length(x)),...
        colNamesToRead,'UniformOutput',false));
    % check that we found all the columns we asked for
    foundCols = any(matches);
    if any(~foundCols)
        notFound = find(~foundCols);
        for count = notFound
            warning('Bioinfo:ilmnbsread:ColumnNotFound',...
                '''%s'' is not a valid column name.',colNamesToRead{count});
        end
    end
    colsToRead = any(matches,2);
end
colsToReadNdx = find(colsToRead);

% Read one line and use this to identify text columns
fpos = ftell(fid);
line1 = strread(fgetl(fid),'%s','delimiter',delimiter);
fseek(fid, fpos,-1);

% see if the columns contain numeric data
for count = 1:numel(line1)
    if colsToRead(count) && (~isnan(str2double(line1{count})) || strcmp(line1{count},'NaN'))
        isNumCol(count) = true;
        formatStr(3*count) = 'f';
    end
end

% Keep columns that we want
formatStr(3*colsToReadNdx-1) = ' ';
colNames = colNames(colsToReadNdx);
isNumCol = isNumCol(colsToReadNdx);

% read the data if necessary
if headeronly
    allData = cell(size(colNames));
else

    % try to read everything in one go
    loopNum = numCols;
    while ~feof(fid) && loopNum > 0
        % note that we strip out spaces from format string
        allData = textscan(fid,strrep(formatStr,' ',''),'delimiter',delimiter);
        if ~feof(fid)
            % if textscan can't read the file, figure out which column
            % failed to be converted and then try again with this column as
            % a string
            badCol = find(diff(cellfun(@length,allData)))+1;
            isNumCol(badCol) = false;
            formatStr(3*colsToReadNdx(badCol)) = 's';
            fseek(fid, fpos,-1);
            loopNum = loopNum -1; % should be redundant but let's be safe
        end
    end
end
fclose(fid);

% clean up colNames so that they can be used as MATLAB variables

if cleancolnames
    colNames = strrep(colNames,'"','');
    colNames = strrep(colNames,' ','_');
    colNames = strrep(colNames,'%','pct');
    colNames = strrep(colNames,'>','gt');
    colNames = strrep(colNames,'+','_plus_');
    colNames = strrep(colNames,'-','_');
    colNames = strrep(colNames,'.','_dot_');
end

% Put data into structure for output
output.Header = defaultHeader;
for headerCount = 1:size(HeaderStrings,1)
    hRow = strmatch(HeaderStrings{headerCount,1},headerLines);
    if ~isempty(hRow)
        theVal = regexp(headerLines{hRow},[HeaderStrings{headerCount,1} '\W+(\w.*$)'],'tokens');
        if ~isempty(theVal)
            output.Header.(HeaderStrings{headerCount,2}) = theVal{1}{1};
        end
    end
end

output.Header.Text = headerLines;
targetIDCol = strcmpi('TargetID',colNames);
% We found some examples where there was no TargetID but there was an
% ID_REF
if ~any(targetIDCol)
    targetIDCol = strcmpi('ID_REF',colNames);
end
if any(targetIDCol)
    output.TargetID = allData{targetIDCol};
else % should never get here as header code errors if there is no TargetID or ID_REF
    output.TargetID = {};
end
if any(isNumCol)
    output.ColumnNames = colNames(isNumCol)';
    output.Data = cell2mat(allData(isNumCol));
else
    output.ColumnNames = {};
    output.Data = [];
end
isNumCol(targetIDCol) = true;
if any(~isNumCol)
    output.TextColumnNames = colNames(~isNumCol)';
else
    output.TextColumnNames = {};
end

if  any(~isNumCol) && ~headeronly
    output.TextData = [allData{:,~isNumCol}];
else
    output.TextData = {};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allColumns,colNamesToRead, headeronly,cleancolnames] = parse_inputs(varargin)
% Parse the varargin parameter/value inputs

% Check that we have the right number of inputs
if rem(nargin,2)== 1
    error(sprintf('Bioinfo:%s:IncorrectNumberOfArguments',mfilename),...
        'Incorrect number of arguments to %s.',mfilename);
end

% The allowed inputs
okargs = {'columns','headeronly','cleancolnames'};
headeronly = false;
cleancolnames = false;
allColumns = true;
colNamesToRead = {};
% deal with the various inputs


for j=1:2:nargin
    [k, pval] = pvpair(varargin{j}, varargin{j+1}, okargs, mfilename);
    switch(k)
        case 1  % columns
            if ischar(pval)
                pval = {pval};
            end
            if iscellstr(pval)
                allColumns = false;
                colNamesToRead = pval;
            else
                error('Bioinfo:ilmnbsread:ColumnsMustBeCellstr',...
                    'COLUMNS must be a cell array of strings.');
            end
        case 2  % headeronly
            headeronly = opttf(pval,okargs{k},mfilename);
        case 3  % cleancolnames
            cleancolnames = opttf(pval,okargs{k},mfilename);
    end
end

