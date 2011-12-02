function output = excelread(filename,colnums)

%
% Function to read column delimited files (already manipulated outputs from an image
% analysis software). The user must specify certain columns to keep through a GUI. If any
% of the data that the user is prompted to supply does not exist, the user must leave the
% corresponding field empty. The output structure will have this field but it will be an
% empty matrix. Apart from text tab delimited files, this function is also able to read
% Excel files with the same content or format. For the text case, other column separators
% are supported but the user has to specify them.
% Certain fields are mandatory. More specifically the user must provide the gene names,
% the row and column coordinates of the genes and signal means and standard deviations
% for both channels. Concenring the flags column, any flags must be manipulated so as the
% flag equals to zero if a spot has to be excluded and equals to one otherwise (flag=0 for
% bad points, flag=1 for good points).
%
% In this automated version user does not give the column numbers in a GUI but specifies
% them in the cell colnums. Alternatively, the user has already specified colnums in a
% separate GUI and the result is repeadetly used to read multiple files (like in
% CREATEDATSTRUCT)
%
% Usage : output = colsepread(filename,colnums)
%
% colnums should be a cell of length 12 or 13 containing in its entries the following 
% information (column numbers) in the following order (if info does not exist leave empty []):
%
% colnums{1}  : The Gene Numbers in the array : length 1 (optional)
% colnums{2}  : The Array Blocks in the array : length 1 (optional)
% colnums{3}  : The Array Meta Rows and Meta Columns : length 2 (optional)
% colnums{4}  : The Array Rows and Columns coords : length 2 (mandatory)
% colnums{5}  : The Gene Names (identifiers) : length 1 (mandatory)
% colnums{6}  : The Cy3 and Cy5 Signal Means : length 2 (mandatory)
% colnums{7}  : The Cy3 and Cy5 Signal Medians : length 2 (optional)
% colnums{8}  : The Cy3 and Cy5 Background Means : length 2 (mandatory)
% colnums{9}  : The Cy3 and Cy5 Background Medians : length 2 (optional)
% colnums{10} : The Cy3 and Cy5 Signal Standard Deviations : length 2 (mandatory)
% colnums{11} : The Cy3 and Cy5 Background Standard Deviations : length 2 (mandatory)
% colnums{12} : The Spot Quality Flags (optional)
% colnums{13} : The column separator. If not given it is assumed that the file is text tab
%               delimited format ('\t')
% 
% The following command is an example of a valid expression:
% output = colsepread(filename,{[],1,[],[2 3],4,[10 19],[9 18],[13 22],[12 21],...
%                     [11 20],[14 23],43,'\t'})
%
% See also GETCOLUMNS, QUANTREAD, MYIMAGENEREAD, GPRREAD, CREATEDATSTRUCT
%

% Check column cell length
if length(colnums)<12 || length(colnums)>13 
    error('The columns numbers vector should be of length 13. Bad Input.')
end
% Set default separator if missing
if length(colnums)==12
    colnums{13}='\t';
end

cols=cell2mat(colnums(1:12));
if all(cols==0)
    uiwait(errordlg('You must specify the column numbers of the files to be read',...
           'Bad Input'));
    output=[];
    return
end

% Read excel data
try
    [res,head]=xlsread2xlsread8(filename);
catch
    rethrow(lasterror)
    output=[];
    return
end

% Create output structure
if colnums{1}==0
    output.Number=1:length(res(:,colnums{5}));
    output.Number=output.Number';
else
    output.Number=cell2mat(res(:,colnums{1}));
end
if colnums{2}==0
    output.Blocks=[];
else
    output.Blocks=cell2mat(res(:,colnums{2}));
end
if colnums{3}(1)~=0 && colnums{3}(2)~=0
    output.MetaRows=cell2mat(res(:,colnums{3}(1)));
    output.MetaColumns=cell2mat(res(:,colnums{3}(2)));
else
    output.MetaRows=[];
    output.MetaColumns=[];
end
if colnums{4}(1)~=0 && colnums{4}(2)~=0
    output.Rows=cell2mat(res(:,colnums{4}(1)));
    output.Columns=cell2mat(res(:,colnums{4}(2)));
else
    output.Rows=[];
    output.Columns=[];
end
output.GeneNames=res(:,colnums{5});
output.ch1Intensity=cell2mat(res(:,colnums{6}(1)));
output.ch2Intensity=cell2mat(res(:,colnums{6}(2)));
if colnums{7}(1)~=0 && colnums{7}(2)~=0
    output.ch1IntensityMedian=cell2mat(res(:,colnums{7}(1)));
    output.ch2IntensityMedian=cell2mat(res(:,colnums{7}(2)));
else
    output.ch1IntensityMedian=[];
    output.ch2IntensityMedian=[];
end
output.ch1Background=cell2mat(res(:,colnums{8}(1)));
output.ch2Background=cell2mat(res(:,colnums{8}(2)));
if colnums{9}(1)~=0 && colnums{9}(2)~=0
    output.ch1BackgroundMedian=cell2mat(res(:,colnums{9}(1)));
    output.ch2BackgroundMedian=cell2mat(res(:,colnums{9}(2)));
else
    output.ch1BackgroundMedian=[];
    output.ch2BackgroundMedian=[];
end
if colnums{10}(1)~=0
    output.ch1IntensityStd=cell2mat(res(:,colnums{10}(1)));
else
    output.ch1IntensityStd=zeros(length(output.GeneNames),1);
end
if colnums{10}(2)~=0
    output.ch2IntensityStd=cell2mat(res(:,colnums{10}(2)));
else
    output.ch2IntensityStd=zeros(length(output.GeneNames),1);
end
if colnums{11}(1)~=0
    output.ch1BackgroundStd=cell2mat(res(:,colnums{11}(1)));
else
    output.ch1BackgroundStd=zeros(length(output.GeneNames),1);
end
if colnums{11}(2)~=0
    output.ch2BackgroundStd=cell2mat(res(:,colnums{11}(2)));
else
    output.ch2BackgroundStd=zeros(length(output.GeneNames),1);
end
if colnums{12}~=0
    output.IgnoreFilter=cell2mat(res(:,colnums{12}));
else
    output.IgnoreFilter=ones(length(output.GeneNames),1); % All good, filter later
end
c=cell2mat(colnums(1:12));
c(c==0)=[];
output.ColumnNames=head(c);

try
    if ~isempty(output.Blocks) && ~isempty(output.Rows) && ~isempty(output.Columns) && ...
        isempty(output.MetaRows) && isempty(output.MetaColumns)
        [output.Indices,output.Shape]=block_ind_lessblockdata(output);
    else
        [output.Indices,output.Shape]=block_ind(output);
    end
catch
    output.Indices=[];
    output.Shape=[];
end

% Create a header for GUI use
output.Header.Type='Excel file';
str={['Number of genes on the array : ',num2str(length(output.Number))];...
     ' ';...
     'Subgrid information : ';...
     ['Number of Blocks : ',num2str(length(unique(output.Blocks)))];...
     ['Number of Meta-Rows : ',num2str(length(unique(output.MetaRows)))];...
     ['Number of Meta-Columns : ',num2str(length(unique(output.MetaColumns)))];...
     ' ';...
     'Main grid information : ';...
     ['Number of Rows : ',num2str(length(unique(output.Rows)))];...
     ['Number of Columns : ',num2str(length(unique(output.Columns)))]};
output.Header.Text=str;


function [fullIndices, blockStruct] = block_ind(tdStruct)
% BLOCK_IND maps from block, row,column to MATLAB style indexing
% Blocks are numbered along the columns first.

if isempty(tdStruct.MetaRows)
    blockRows = 1;
else
    blockRows = tdStruct.MetaRows;
end
if isempty(tdStruct.MetaColumns)
    blockColumns = 1;
else
    blockColumns = tdStruct.MetaColumns;
end
rows = tdStruct.Rows;
columns = tdStruct.Columns;

numBlockRows = max(blockRows);
numBlockCols = max(blockColumns);
numRows = max(rows);
numCols = max(columns);
numBlocks = numBlockRows*numBlockCols;

% convert file indexing into MATLAB ordering -- row major
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


function [fullIndices,blockStruct] = block_ind_lessblockdata(tdStruct)

% Function to create block indices lacking the presence of X, Y coordinates (assuming that
% blocks are ordered row major)

% Find spatial data
numbers=tdStruct.Number;
blocks=tdStruct.Blocks;
rows=tdStruct.Rows;
columns=tdStruct.Columns;
numBlocks=max(blocks);
numRows=max(rows);
numCols=max(columns);

% Determine block size (square like blocks)
blockSize=[numRows,numCols];

% Since we don't have any X, Y coordinates data we will simply create a block index matrix
% of size [numBlocks/2 2] whatever the real arrangement is. Initialize a cell with size
% [numBlock/2 2] which will contain the indices
m=ceil(numBlocks/2);
n=2;
indices=cell(m,n);
tempindices=cell(m,n);

% Fill the cell elements with gene numbers
extcount=0;
for i=1:m
    for j=1:n
        extcount=extcount+1;
        tempindices{i,j}=zeros(blockSize);
        numbersInBlock=numbers(blocks==extcount);
        rowsInBlock=rows(blocks==extcount);
        columnsInBlock=columns(blocks==extcount);
        intcount=0;    
        for p=1:length(rowsInBlock)
            intcount=intcount+1;
            tempindices{i,j}(rowsInBlock(p),columnsInBlock(p))=intcount;
        end
        zeroind=find(tempindices{i,j}==0);
        if ~isempty(zeroind)
            tempindices{i,j}(zeroind)=1;
        end
        if ~isempty(rowsInBlock)
            indices{i,j}=numbersInBlock(tempindices{i,j});
        else
            indices{i,j}=tempindices{i,j};
        end
        if ~isempty(zeroind)
            indices{i,j}(zeroind)=0;
        end
    end
end

fullIndices=cell2mat(indices);

blockStruct.NumBlocks=numBlocks;
blockrange=ones(2*ceil(numBlocks/2),2);
for i=1:ceil(numBlocks/2)
    blockrange(2*i,1)=numCols+1;
    blockrange([2*i-1 2*i],2)=blockrange([2*i-1 2*i],2)+(i-1)*numRows;
end
blockStruct.BlockRange=blockrange;
