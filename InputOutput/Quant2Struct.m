function  [datstruct]=Quant2Struct(filename)

%
% Read QuantArray data in a MATLAB structure
% For internal use
% Please use CREATEDATSTRUCT for importing data in MATLAB
%

% Read data...
quantData = quantread(filename);

% ...and keep useful columns

% Get header info for GUI use
datstruct.Header=quantData.Header;

% Get spatial information and names
datstruct.Blocks = quantData.Blocks;
datstruct.ArrayRow = quantData.BlockRows;
datstruct.ArrayColumn = quantData.BlockColumns;
datstruct.Row = quantData.Rows;
datstruct.Column = quantData.Columns;
datstruct.ColumnNames = quantData.ColumnNames;
datstruct.Number=quantData.Number;
datstruct.GeneNames = quantData.IDs;

% Get Signal Intensities (ch1(Green) and ch2(Red))
datstruct.ch1Intensity = magetfield(quantData,'ch1 Intensity');
datstruct.ch2Intensity = magetfield(quantData,'ch2 Intensity');

% Get Signal Standard Deviations (ch1(Green) and ch2(Red))
datstruct.ch1IntensityStd = magetfield(quantData,'ch1 Intensity Std Dev');
datstruct.ch2IntensityStd = magetfield(quantData,'ch2 Intensity Std Dev');

% Get Background Means (ch1(Green) and ch2(Red))
datstruct.ch1Background = magetfield(quantData,'ch1 Background');
datstruct.ch2Background = magetfield(quantData,'ch2 Background');

% Get Background Standard Deviations (ch1(Green) and ch2(Red))
datstruct.ch1BackgroundStd = magetfield(quantData,'ch1 Background Std Dev');
datstruct.ch2BackgroundStd = magetfield(quantData,'ch2 Background Std Dev');

% For the ARMADA GUI, do not get some fields since they are not used anywhere yet
% % Get spot Diameters
% datstruct.ch1Diameter = magetfield(quantData,'ch1 Diameter');
% datstruct.ch2Diamater = magetfield(quantData,'ch2 Diameter');
% 
% % Get spot Areas
% datstruct.ch1Area = magetfield(quantData,'ch1 Area');
% datstruct.ch2Area = magetfield(quantData,'ch2 Area');
% 
% % Get spot Signal Noise Ratios
% datstruct.ch1SignalNoiseRatio = magetfield(quantData,'ch1 Signal Noise Ratio');
% datstruct.ch2SignalNoiseRatio = magetfield(quantData,'ch2 Signal Noise Ratio');
% 
% % Get spot Confidence
% datstruct.ch1Confidence = magetfield(quantData,'ch1 Confidence');
% datstruct.ch2Confidence = magetfield(quantData,'ch2 Confidence');
% 
% % Get spot locations
% datstruct.XLocation = magetfield(quantData,'X Location');
% datstruct.YLocation = magetfield(quantData,'Y Location');

% Get Ignore Filter
datstruct.IgnoreFilter = magetfield(quantData,'Ignore Filter');

% Get Indices
datstruct.Indices = quantData.Indices;

% Get Shape
datstruct.Shape = quantData.Shape;
