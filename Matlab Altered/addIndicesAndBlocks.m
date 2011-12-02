function fixedStruct = addIndicesAndBlocks(maStruct)
% FeatureExtractor data does not have indices field. This needs adding and
% missing values need appending.

% Copyright 2005 The MathWorks, Inc.

numRows = max(maStruct.Rows);
numCols = max(maStruct.Columns);
Indices = zeros(numRows,numCols);
numVals = numel(maStruct.Rows);
for count = 1:numVals
    Indices(maStruct.Rows(count),maStruct.Columns(count)) = count;
end
Indices(Indices==0) = numVals+1;
maStruct.Data(end+1,:) = nan(1,size(maStruct.Data,2));
maStruct.Indices = Indices;
maStruct.Shape.BlockRange = [1,1];
maStruct.Shape.NumBlocks = 1;
maStruct.Blocks = 1;
maStruct.IDs{end+1} = '';
maStruct.Names{end+1} = '';
fixedStruct = maStruct;