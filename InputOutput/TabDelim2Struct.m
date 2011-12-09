function output = TabDelim2Struct(filename,cols,allcolnames)

nfcols=length(allcolnames);
frmt=cell(1,nfcols);
colnames=cell(1,nfcols);
for i=1:nfcols
    frmt{i}='%*s'; % Fill with a general skip format
end

if all(cols==0)
    uiwait(errordlg('You must specify the column numbers of the files to be read',...
           'Bad Input'));
    output=[];
    return
end

% We need to change 20 fields in frmt according to cols... manually
% We suppose that the control of optional or mandatory fields has been performed

% Gene Numbers
if cols(1)~=0
    frmt{cols(1)}='%u';
    colnames{cols(1)}='Gene Numbers';
end
% Array Blocks
if cols(2)~=0
    frmt{cols(2)}='%u';
    colnames{cols(2)}='Array Blocks';
end
% Meta Rows
if cols(3)~=0
    frmt{cols(3)}='%u';
    colnames{cols(3)}='Meta Rows';
end
% Array Columns
if cols(4)~=0
    frmt{cols(4)}='%u';
    colnames{cols(4)}='Meta Columns';
end
% Rows
if cols(5)~=0
    frmt{cols(5)}='%u';
    colnames{cols(5)}='Rows';
end
% Columns
if cols(5)~=0
    frmt{cols(6)}='%u';
    colnames{cols(6)}='Columns';
end
% Gene Names
frmt{cols(7)}='%s';
colnames{cols(7)}='Gene Names';
% Array Spot Flags
if cols(8)~=0
    frmt{cols(8)}='%u';
    colnames{cols(8)}='Array Spot Flags';
end
% Cy3 Signal Mean
frmt{cols(9)}='%f';
colnames{cols(9)}='Cy3 Signal Mean';
% Cy3 Signal Median
if cols(10)~=0
    frmt{cols(10)}='%f';
    colnames{cols(10)}='Cy3 Signal Median';
end
% Cy3 Signal Standard Deviation
if cols(11)~=0
    frmt{cols(11)}='%f';
    colnames{cols(11)}='Cy3 Signal Standard Deviation';
end
% Cy3 Background Mean
frmt{cols(12)}='%f';
colnames{cols(12)}='Cy3 Background Mean';
% Cy3 Background Median
if cols(13)~=0
    frmt{cols(13)}='%f';
    colnames{cols(13)}='Cy3 Background Median';
end
% Cy3 Background Standard Deviation
if cols(14)~=0
    frmt{cols(14)}='%f';
    colnames{cols(14)}='Cy3 Background Standard Deviation';
end
% Cy5 Signal Mean
frmt{cols(15)}='%f';
colnames{cols(15)}='Cy5 Signal Mean';
% Cy5 Signal Median
if cols(16)~=0
    frmt{cols(16)}='%f';
    colnames{cols(16)}='Cy5 Signal Median';
end
% Cy5 Signal Standard Deviation
if cols(17)~=0
    frmt{cols(17)}='%f';
    colnames{cols(17)}='Cy5 Signal Standard Deviation';
end
% Cy5 Background Mean
frmt{cols(18)}='%f';
colnames{cols(18)}='Cy5 Background Mean';
% Cy5 Background Median
if cols(19)~=0
    frmt{cols(19)}='%f';
    colnames{cols(19)}='Cy5 Background Median';
end
% Cy5 Background Standard Deviation
if cols(20)~=0
    frmt{cols(20)}='%f';
    colnames{cols(20)}='Cy5 Background Standard Deviation';
end

ncolnames=cell(1,length(find(cols)));
ind=0;
for i=1:length(colnames)
    if ~isempty(colnames{i})
        ind=ind+1;
        ncolnames{ind}=colnames{i}; 
    end
end
for i=1:length(ncolnames)
    if isempty(ncolnames{i})
        ncolnames{i}='';
    end
end

frmt=cell2mat(frmt);
fid=fopen(filename);
alldata=textscan(fid,frmt,'Delimiter','\t','HeaderLines',1);
fclose(fid);

% Create output structure
if cols(1)==0
    output.Number=1:length(alldata{strmatch('Gene Names',ncolnames)});
    output.Number=output.Number';
else
    output.Number=alldata{strmatch('Gene Numbers',ncolnames)};
end
if cols(2)~=0
    output.Blocks=alldata{strmatch('Array Blocks',ncolnames)};
else
    output.Blocks=[];
end
if cols(3)~=0
    output.MetaRows=alldata{strmatch('Meta Rows',ncolnames)};
else
    output.MetaRows=[];
end
if cols(4)~=0
    output.MetaColumns=alldata{strmatch('Meta Columns',ncolnames)};
else
    output.MetaColumns=[];
end 
if cols(5)~=0
    output.Rows=alldata{strmatch('Rows',ncolnames)};
else
    output.Rows=[];
end
if cols(6)~=0
    output.Columns=alldata{strmatch('Columns',ncolnames)};
else
    output.Columns=[];
end
output.GeneNames=alldata{strmatch('Gene Names',ncolnames)};

output.ch1Intensity=alldata{strmatch('Cy3 Signal Mean',ncolnames)};
if cols(10)~=0
    output.ch1IntensityMedian=alldata{strmatch('Cy3 Signal Median',ncolnames)};
else
    output.ch1IntensityMedian=[];
end
if cols(11)~=0
    output.ch1IntensityStd=alldata{strmatch('Cy3 Signal Standard Deviation',ncolnames)};
else
    output.ch1IntensityStd=zeros(length(output.GeneNames),1);
end
output.ch1Background=alldata{strmatch('Cy3 Background Mean',ncolnames)};
if cols(13)~=0
    output.ch1BackgroundMedian=alldata{strmatch('Cy3 Background Median',ncolnames)};
else
    output.ch1BackgroundMedian=[];
end
if cols(14)~=0
    output.ch1BackgroundStd=alldata{strmatch('Cy3 Background Standard Deviation',ncolnames)};
else
    output.ch1BackgroundStd=zeros(length(output.GeneNames),1);
end

output.ch2Intensity=alldata{strmatch('Cy5 Signal Mean',ncolnames)};
if cols(16)~=0
    output.ch2IntensityMedian=alldata{strmatch('Cy5 Signal Median',ncolnames)};
else
    output.ch2IntensityMedian=[];
end
if cols(17)~=0
    output.ch2IntensityStd=alldata{strmatch('Cy5 Signal Standard Deviation',ncolnames)};
else
    output.ch2IntensityStd=zeros(length(output.GeneNames),1);
end
output.ch2Background=alldata{strmatch('Cy5 Background Mean',ncolnames)};
if cols(19)~=0
    output.ch2BackgroundMedian=alldata{strmatch('Cy5 Background Median',ncolnames)};
else
    output.ch2BackgroundMedian=[];
end
if cols(20)~=0
    output.ch2BackgroundStd=alldata{strmatch('Cy5 Background Standard Deviation',ncolnames)};
else
    output.ch2BackgroundStd=zeros(length(output.GeneNames),1);
end

if cols(8)~=0
    output.IgnoreFilter=alldata{strmatch('Array Spot Flags',ncolnames)};
else
    output.IgnoreFilter=ones(length(output.GeneNames),1); % Consider all good, filter later
end
colsnz=cols;
colsnz(~cols)=[];
output.ColumnNames=allcolnames(colsnz);
output.ColumnNames=output.ColumnNames';

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
output.Header.Type='Text tab delimited file';
str={['Number of genes on the array : ',num2str(length(output.Number))];...
     ' ';...
     'Subgrid information : ';...
     ['Number of Blocks : ',num2str(length(unique(output.Blocks)))];...
     ['Number of Meta-Rows : ',num2str(length(unique(output.MetaRows)))];...
     ['Number of Meta-Columns : ',num2str(length(unique(output.MetaColumns)))];...
     ' ';...
     'Grid information : ';...
     ['Number of Rows : ',num2str(length(unique(output.Rows)))];...
     ['Number of Columns : ',num2str(length(unique(output.Columns)))]};
output.Header.Text=str;

% Add number of channels... future use...
output.Channels = 2;


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
blockrange=cast(blockrange,'uint32');
for i=1:ceil(numBlocks/2)
    blockrange(2*i,1)=numCols+1;
    blockrange([2*i-1 2*i],2)=blockrange([2*i-1 2*i],2)+(i-1)*numRows;
end
blockStruct.BlockRange=blockrange;
