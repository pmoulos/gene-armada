% function  [datstruct]=Affy2Struct(celfile,celpath,cdffile,cdfpath)
function  datstruct = Affy2Struct(celfile,cdfpath)

%
% Read Affymetrix data in a MATLAB structure
% For internal use
% Please use CREATEDATSTRUCTAFFY for importing data in ARMADA
%

% Read data...
affydata=affyread(celfile,cdfpath);

% Construct header
header={['Name: ',affydata.Name];...
        ['Data Path: ',affydata.DataPath];...
        ['Library Path: ',affydata.LibPath];...
        ['Full Path Name: ',affydata.FullPathName];...
        ['Chip Type: ',affydata.ChipType];...
        ['File Version: ',num2str(affydata.ChipType)];...
        ['Algorithm: ',affydata.Algorithm];...
        ['Algorithm Parameters: ',affydata.AlgParams];...
        ['Number of Algorithm Parameters: ',num2str(affydata.NumAlgParams)];...
        ['Cell Margin: ',num2str(affydata.CellMargin)];...
        ['Rows: ',num2str(affydata.Rows)];...
        ['Columns: ',num2str(affydata.Cols)];...
        ['Number of Masked: ',num2str(affydata.NumMasked)];...
        ['Number of Outliers: ',num2str(affydata.NumOutliers)];...
        ['Number of Probes: ',num2str(affydata.NumProbes)];...
        ['Upper Left X: ',num2str(affydata.UpperLeftX)];...
        ['Upper Left Y: ',num2str(affydata.UpperLeftY)];...
        ['Upper Right X: ',num2str(affydata.UpperRightX)];...
        ['Upper Right Y: ',num2str(affydata.UpperRightY)];...
        ['Lower Left X: ',num2str(affydata.UpperLeftX)];...
        ['Lower Left Y: ',num2str(affydata.UpperLeftY)];...
        ['Lower Right X: ',num2str(affydata.UpperRightX)];...
        ['Lower Right Y: ',num2str(affydata.UpperRightY)]};%...
        %['Server Name: ',affydata.ServerName]};
    
datstruct.Header=header;

% % Get X Positions
% XPosCol=find(strcmp('PosX',affydata.ProbeColumnNames));
% datstruct.PosX=affydata.Probes(:,XPosCol);

% % Get Y Positions
% YPosCol=find(strcmp('PosY',affydata.ProbeColumnNames));
% datstruct.PosY=affydata.Probes(:,YPosCol);

% Get Intensities
IntenCol=find(strcmp('Intensity',affydata.ProbeColumnNames));
datstruct.Intensity=affydata.Probes(:,IntenCol);

% Get Standard Deviations
StCol=find(strcmp('StdDev',affydata.ProbeColumnNames));
datstruct.StdDev=affydata.Probes(:,StCol);

% % Get Pixels
% PixCol=find(strcmp('Pixels',affydata.ProbeColumnNames));
% datstruct.Pixels=affydata.Probes(:,PixCol);

% % Get Outliers
% OutCol=find(strcmp('Outlier',affydata.ProbeColumnNames));
% datstruct.Outlier=affydata.Probes(:,OutCol);

% % Get Masked
% MaskCol=find(strcmp('Masked',affydata.ProbeColumnNames));
% datstruct.Masked=affydata.Probes(:,MaskCol);

% % Get Probe Types
% TypeCol=find(strcmp('ProbeType',affydata.ProbeColumnNames));
% datstruct.ProbeType=affydata.Probes(:,TypeCol);

% Data that allow to create images
datstruct.Shape.NumBlocks = 1;
datstruct.Shape.BlockRange = [1 1];
datstruct.Blocks=ones(size(datstruct.Intensity));
datstruct.ColumnNames=affydata.ProbeColumnNames;

% X=datstruct.PosX;
% Y=datstruct.PosY;

X=affydata.Probes(:,find(strcmp('PosX',affydata.ProbeColumnNames)));
Y=affydata.Probes(:,find(strcmp('PosY',affydata.ProbeColumnNames)));

% Convert file indexing into MATLAB ordering -- row major
datstruct.Indices = reshape(sub2ind([max(Y+1), max(X+1)],Y+1,X+1),max(Y+1), max(X+1));

% Create probe names ...too much time
% names=cell(length(datstruct.Intensity),1);
% for i=1:length(datstruct.Intensity)
%     names{i}=['Probe ',num2str(i)];
% end
% datstruct.GeneNames=names;
% names=1:length(datstruct.Intensity);
% datstruct.GeneNames=names';
