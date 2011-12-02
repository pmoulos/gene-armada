function output = quantread(filename,validcolnames)

%QUANTREAD reads QuantArray Results Format files.
%
%   QUANTDATA = QUANTREAD(FILE) reads in ImaGene results format data
%   from FILE and creates a structure QUANTDATA, containing these fields:
%           Header
%           Data
%           Blocks
%           Rows
%           Columns
%           Number
%           IDs
%           ColumnNames
%           Indices
%           Shape
%
%   QUANTREAD(...,true) returns ColumnNames that are
%   valid MATLAB variable names. By default, the ColumnNames in the QUANT ARRAY
%   file may contain spaces and some characters that cannot be used in
%   MATLAB variable names. This option should be used if you plan to use
%   the column names as variables names in a function.
%
%   The Indices field of the structure contains MATLAB indices that can be
%   used for plotting heat maps of the data with the image or imagesc
%   commands.
%
%   Example:
%
%       % Read in a sample QuantArray file and plot the ch1 Intensity
%       quantData = quantread('file.txt');
%       maimage(quantData,'ch1 Intensity');
%       Cy3sigCol = find(strcmp('ch1 Intensity',quantData.ColumnNames));
% 		cy3Signal = quantData.Data(:,Cy3sigCol);
%       Cy5SigCol = find(strcmp('ch2 Intensity',quantData.ColumnNames));
% 		cy5Signal = quantData.Data(:,Cy5SigCol);
%       maloglog(cy3Signal,cy5Signal,'title','Signal Mean');
%
%   For more details on the QuantArray format and example data, see the
%   QuantArray User Manual.
%
%   See also MYIMAGENEREAD, GPRREAD.
%
%   QuantArray is a registered trademark of Packard Biosciences, Inc.

% Created on 2007/03/13 by Panagiotis Moulos.
% Inspired by the original imageneread function from the MATLAB's Bioinformatics toolbox

if nargin<2
    validcolnames=false;
end

try
    fid = fopen(filename,'rt');
catch
    fid = -1;
end

if fid == -1
    error('Problem opening file %s. %s',filename,lasterr);
end

% Read in the header data
theLines = textread(filename,'%s','delimiter','\n');

% First phrase should be User Name
if isempty(strmatch('user name',lower(theLines{1})))
    error('File %s does not appear to be a QuantArray file.',filename)
end

EndHeader = find(~cellfun('isempty',regexpi(theLines,'^End Measurements','once')),1);
PreEndHeader = find(~cellfun('isempty',regexpi(theLines,'^End Image Info','once')),1);
output.Header.Type = 'QuantArray';
% In this way we exclude program normalized data from text
output.Header.Text = strtrim(theLines(2:PreEndHeader));
output.Header.SoftwareProcess = strtrim(theLines(PreEndHeader+2:EndHeader-1));

if isempty(strmatch('begin data',lower(theLines{EndHeader+2})))
    error('File %s does not appear to be a QuantArray file.',filename)
end

colNames = strread(theLines{EndHeader+3},'%s','delimiter','\t');
theLines(EndHeader+4:end) = [];

numFields = numel(colNames);

% Now read in the raw data
format = ['%f%f%f%f%f%s' repmat('%f',1,numFields-6)];
rawdata = textscan(fid,format,'headerLines',EndHeader+3,'Delimiter','\t');
fclose(fid);

try
    output.Data = cell2mat(rawdata(7:end));
catch
    lastLine = size(rawdata{end},1);
    error('Problems reading QuantArray file. Possible bad data around line %d.',...
          lastLine);
end

%numBlockRows = max(rawdata{2});
numBlockCols = max(rawdata{3});
output.Blocks = numBlockCols*(rawdata{2}-1)+numBlockCols;
output.BlockRows = rawdata{2};
output.BlockColumns = rawdata{3};
output.Rows = rawdata{4};
output.Columns = rawdata{5};
output.Number = rawdata{1};
output.IDs = rawdata{6};
if validcolnames
    colNames = strrep(colNames,' ','_');
    colNames = strrep(colNames,'%','pct');
    colNames = strrep(colNames,'>','gt');
    colNames = strrep(colNames,'+','_plus_');
    colNames = strrep(colNames,'.','_dot_');
end

output.ColumnNames = colNames(7:end);

try
    [output.Indices, output.Shape] = block_ind(output);
catch
    output.Indices  = [];
end


function [fullIndices, blockStruct] = block_ind(imgStruct)
% BLOCK_IND maps from block, row,column to MATLAB style indexing
% Blocks are numbered along the columns first.

blockRows = imgStruct.BlockRows;
blockColumns = imgStruct.BlockColumns;
rows = imgStruct.Rows;
columns = imgStruct.Columns;

numBlockRows = max(blockRows);
numBlockCols = max(blockColumns);
numRows = max(rows);
numCols = max(columns);
numBlocks = numBlockRows*numBlockCols;

% Convert file indexing into MATLAB ordering -- row major
indices = zeros(numRows,numCols,numBlockRows,numBlockCols);

dataRows = size(blockRows,1);
for index = 1:dataRows
    indices(rows(index),columns(index),blockRows(index),blockColumns(index)) = index;
end

fullIndices = repmat(indices(:,:,1,1),numBlockRows,numBlockCols);
blockStruct.NumBlocks = numBlocks;
blockStruct.BlockRange = ones(numBlocks,2);
count =1;
for outer = 1:numBlockRows
    for inner = 1:numBlockCols
        [col,row] = ind2sub([numBlockCols,numBlockRows],count);
        rowStart = ((row-1)*numRows)+1;
        colStart = ((col-1)*numCols)+1;
        blockStruct.BlockRange(count,:) = [colStart, rowStart];
        count = count +1;
        fullIndices(rowStart:rowStart+numRows-1,colStart:colStart+numCols-1) = indices(:,:,outer,inner);
    end
end
