function output = gprread(filename,varargin)
%GPRREAD reads GenePix Results Format (GPR) files.
%
%   GPRDATA = GPRREAD(FILE) reads in GenePix results format data from FILE
%   and creates a structure GPRDATA, containing these fields:
%           Header
%           Data
%           Blocks
%           Columns
%           Rows
%           Names
%           IDs
%           ColumnNames
%           Indices
%           Shape
%
%   GPRREAD(...,'CLEANCOLNAMES',true) returns ColumnNames that are valid
%   MATLAB variable names. By default, the ColumnNames in the GPR file may
%   contain spaces and some characters that cannot be used in MATLAB
%   variable names. This option should be used if you plan to use the
%   column names as variables names in a function.
%
%   The Indices field of the structure contains MATLAB indices that can be
%   used for plotting heat maps of the data with the image or imagesc
%   commands.
%
%   The function supports versions 3, 4, and 5, of the GenePix Results
%   Format.
%
%   For more details on the GPR format, see
%   http://www.moleculardevices.com/pages/software/gn_genepix_file_formats.html
%   http://www.moleculardevices.com/pages/software/gn_gpr_format_history.html
%
%   Example:
%
%       % Read in a sample GPR file and plot the median foreground
%       % intensity for the 635 nm channel.
%       gprStruct = gprread('mouse_a1pd.gpr')
%       maimage(gprStruct,'F635 Median');
%
%       % Alternatively you can create a similar plot using
%       % more basic graphics commands.
%       F635Median = magetfield(gprStruct,'F635 Median');
%       imagesc(F635Median(gprStruct.Indices));
%       colorbar;
%
%   See also AFFYREAD, AGFEREAD, CELINTENSITYREAD, GALREAD, GEOSOFTREAD,
%   ILMNBSREAD, IMAGENEREAD, MAGETFIELD, MOUSEDEMO, SPTREAD.
%
%   GenePix is a registered trademark of Molecular Devices Corporation

% Copyright 2002-2008 The MathWorks, Inc.
% $Revision: 1.18.6.19 $   $Date: 2008/06/16 16:33:41 $

bioinfochecknargin(nargin,1,mfilename); 
try
    fopenMessage = '';
    [fid, fopenMessage] = fopen(filename,'rt');
catch
    fid = -1;
end

if fid == -1
    error('Bioinfo:gprread:CannotOpenGPRFile',...
        'Problem opening file %s.\n%s',filename,fopenMessage);
end

cleancolnames = false;
% deal with the various inputs
if nargin > 1
    if rem(nargin,2) == 0
        error('Bioinfo:gprread:IncorrectNumberOfArguments',...
            'Incorrect number of arguments to %s.',mfilename);
    end
    okargs = {'cleancolnames',''};
    for j=1:2:nargin-2
        pname = varargin{j};
        pval = varargin{j+1};
        k = find(strncmpi(pname,okargs,numel(pname)));
        if isempty(k)
            error('Bioinfo:gprread:UnknownParameterName',...
                'Unknown parameter name: %s.',pname);
        elseif length(k)>1
            error('Bioinfo:gprread:AmbiguousParameterName',...
                'Ambiguous parameter name: %s.',pname);
        else
            switch(k)
                case 1  % cleancolnames
                    cleancolnames = opttf(pval,okargs{k},mfilename);
            end
        end
    end
end

% first line should be ATF versions
checkHeader = fgetl(fid);

if ~strncmp(checkHeader,'ATF',3)
    fclose(fid);
    error('Bioinfo:gprread:BadGPRFile','File does not appear to be a GPR file.')
end

fileSize = sscanf(fgetl(fid),'%d');

for count = 1:fileSize(1)
    line = strrep(fgetl(fid),'"','');
    [field,val] = strtok(line,'=');
    field = strrep(field,':','_');
    val = deblank(val(2:end));
    v = str2num(val); %#ok
    if ~isempty(v)
        blockNum = sscanf(field,'Block%d');
        if isempty(blockNum)
            header.(field) = v;
        else
            header.Block(blockNum,:) = v;
        end

    else
        header.(field) = val;
    end
end


% now deal with the data
colNames = strread(fgetl(fid),'%s','delimiter','\t');

% clean up colNames so that they can be used as MATLAB variables

colNames = strrep(colNames,'"','');
if cleancolnames
    colNames = strrep(colNames,' ','_');
    colNames = strrep(colNames,'%','pct');
    colNames = strrep(colNames,'>','gt');
    colNames = strrep(colNames,'+','_plus_');
    colNames = strrep(colNames,'.','_dot_');
end

nameCol = find(strncmpi(colNames,'Name',4));
if isempty(nameCol)
    nameCol = find(strncmpi(colNames,'gene description',16));
end

IDCol = find(strncmpi(colNames,'ID',2));
if isempty(IDCol)
    IDCol = find(strncmpi(colNames,'Unigene ID',10));
end
flipIDName = false;
if (IDCol == 4) && (nameCol == 5)
    nameCol = 4;
    IDCol = 5;
    flipIDName = true;
end

headerCols = 5;
ontologyCol = find(strncmpi(colNames,'Gene ontology',13),1);
if ~isempty(ontologyCol)
    headerCols = 6;
end

if isempty(nameCol) || isempty(IDCol)|| (nameCol ~=4 && IDCol ~=5)
    fclose(fid);
    error('Bioinfo:gprread:ProblemsReadingGPR',...
        'Cannot read %s.\nThe file does not appears to be in the GPR Format.',filename);
end

% some examples were found with extra text columns
% "ControlType", "GeneName"	"TopHit"	"Description"
textCols = 0;

controlTypeCol = find(strncmpi(colNames,'ControlType',11),1);
if ~isempty(controlTypeCol)
    textCols = textCols+1;
else
    controlTypeCol = 0;
end

geneNameCol = find(strncmpi(colNames,'GeneName',8),1);
if ~isempty(geneNameCol)
    textCols = textCols+1;
else
    geneNameCol = 0;  %#ok<NASGU>
end

topHitCol = find(strncmpi(colNames,'TopHit',6),1);
if ~isempty(topHitCol)
    textCols = textCols+1;
else
    topHitCol = 0; %#ok<NASGU>
end

descriptionCol = find(strncmpi(colNames,'Description',11),1);
if ~isempty(descriptionCol)
    textCols = textCols+1;
else
    descriptionCol = 0; %#ok<NASGU>
end

% count how much space we need for the data
currPos = ftell(fid);
fseek(fid,0,1);
endPos = ftell(fid);
fseek(fid,currPos,-1);

% Read all the data into lines
lines = strread(fread(fid,endPos-currPos,'uchar=>char'),'%s','delimiter','\n');

fclose(fid);

% Allocate some memory
numRows = length(lines);
numCols = numel(colNames);
blocks = zeros(numRows,1);
columns = blocks;
rows = blocks;
data = zeros(numRows,numCols-headerCols-textCols);
names = cell(numRows,1);
IDs = names;
if textCols > 0
    controlTypes = names;
    geneNames = names;
    topHits = names;
    descriptions = names;
end

tabChar = sprintf('\t');
% parse the lines
for count = 1:numRows
    line = lines{count};
    try
        % replace Error with missing values
        line = strrep(line,'Error','NaN');
        % First pull out the blocks, columns, rows, names and IDs
        [blocks(count),columns(count),rows(count),names(count),IDs(count)]...
            = strread(line,'%d%d%d%s%s%*[^\n]','delimiter','\t');
        % Now read in the 'data'
        tabs = strfind(line,tabChar);
        if textCols > 0
            data(count,:) = strread(line(tabs(headerCols)+1:tabs(controlTypeCol-1)),'%f','delimiter','\t')';
            theData = strread(line(tabs(controlTypeCol):end),'%s','delimiter','\t')';
            if numel(theData) < 4
                theData{end+1:4} = '';
            end
            controlTypes{count} = theData{1};
            geneNames{count} = theData{2};
            topHits{count} = theData{3};
            descriptions{count} = theData{4};
        else
            data(count,:) = strread(line(tabs(headerCols)+1:end),'%f','delimiter','\t')';
        end
    catch
        warning('Bioinfo:gprread:GPRBadLine','Problem reading line: %s',line);
    end
end

% Put data into structure for output
output.Header = header;
output.Data = data;
output.Blocks = blocks;
output.Columns = columns;
output.Rows = rows;
if flipIDName
    output.Names = IDs;
    output.IDs = names;
else
    output.Names = names;
    output.IDs = IDs;
end
output.ColumnNames = colNames(headerCols+1:end);
try
    [output.Indices, output.Shape] = block_ind(output);
catch
    output.Indices  = [];
end
if textCols
    output.ControlTypes = controlTypes;
    output.GeneNames = geneNames;
    output.TopHits = topHits;
    output.Descriptions = descriptions;
end

function [fullIndices, blockStruct] = block_ind(gprStruct)
% BLOCK_IND maps from block, row,column to MATLAB style indexing
% Blocks are numbered along the columns first.


blocks = gprStruct.Blocks;
rows = gprStruct.Rows;
columns = gprStruct.Columns;
theData = gprStruct.Data;

numBlocks = max(blocks);
numRows = max(rows);
numCols = max(columns);

Xdata = find(strcmpi(gprStruct.ColumnNames,'X'));
Ydata = find(strcmpi(gprStruct.ColumnNames,'Y'));

% convert file indexing into MATLAB ordering -- row major
indices = zeros(numRows,numCols,numBlocks);

dataRows = size(blocks,1);
for index = 1:dataRows
    indices(rows(index),columns(index),blocks(index)) = index;
end

% figure out orientation of blocks
topLeft = [theData(indices(1,1,:),Xdata), theData(indices(1,1,:),Ydata)];
bottomRight = [theData(indices(numRows,numCols,:),Xdata), theData(indices(numRows,numCols,:),Ydata)];

% decide if each block is orientated top left to bottom right

if (topLeft(1,1) <= bottomRight(1,1)) && (topLeft(1,2) <= bottomRight(1,2))
    %    normalSpotOrientation = true;
else
    warning('Bioinfo:gprread:CannotDetermineGPROrientation',...
        'Cannot determine orientation of the blocks.');
    fullIndices = [];
    return;
end

% Assume that block 1 is in top left and that blocks are column major
% figure out if there is more than one column

% rows change when there is a negative difference in the x coords
dRow = diff(topLeft(:,1));

numBlockRows = 1 + sum(dRow<0);
numBlockCols =  ceil(numBlocks/numBlockRows);

fullIndices = repmat(indices(:,:,1),numBlockRows,numBlockCols);
blockStruct.NumBlocks = numBlocks;
blockStruct.BlockRange = ones(numBlocks,2);

for count = 2:numBlocks
    [col,row] = ind2sub([numBlockCols,numBlockRows],count);
    rowStart = ((row-1)*numRows)+1;
    colStart = ((col-1)*numCols)+1;
    blockStruct.BlockRange(count,:) = [colStart, rowStart];
    fullIndices(rowStart:rowStart+numRows-1,colStart:colStart+numCols-1) = indices(:,:,count);
end


