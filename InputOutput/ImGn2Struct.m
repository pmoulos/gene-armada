function [datstruct] = ImGn2Struct(expCy3,expCy5,emSpotCh)

%
% Read ImaGene data in a MATLAB structure
% For internal use
% Please use CREATEDATSTRUCT for importing data in MATLAB
%

Cy3data = myimageneread(expCy3);
Cy5data = myimageneread(expCy5);

% Get header info for GUI use
datstruct.Header=Cy3data.Header;

% Assign Gene Number (Slide Position)
datstruct.Number=1:length(Cy3data.IDs);
datstruct.Number=datstruct.Number';
       
% Get column names and spatial data
datstruct.ColumnNames = Cy3data.ColumnNames;
datstruct.GeneNames = Cy3data.IDs;
datstruct.BlockRows = Cy3data.BlockRows;
datstruct.BlockColumns = Cy3data.BlockColumns;
datstruct.Rows = Cy3data.Rows;
datstruct.Columns = Cy3data.Columns;
                
% Get Signal Means (Cy3, Cy5)
Cy3MeanCol = find(strcmp('Signal Mean',Cy3data.ColumnNames));
datstruct.ch1Intensity = Cy3data.Data(:,Cy3MeanCol);
Cy5MeanCol = find(strcmp('Signal Mean',Cy5data.ColumnNames));
datstruct.ch2Intensity = Cy5data.Data(:,Cy5MeanCol);

% Get Signal Medians (Cy3, Cy5)
Cy3MedianCol = find(strcmp('Signal Median',Cy3data.ColumnNames));
datstruct.ch1IntensityMedian = Cy3data.Data(:,Cy3MedianCol);
Cy5MedianCol = find(strcmp('Signal Median',Cy5data.ColumnNames));
datstruct.ch2IntensityMedian = Cy5data.Data(:,Cy5MedianCol);

% Get Signal Standard Deviations (Cy3, Cy5)
Cy3StdCol = find(strcmp('Signal Stdev',Cy3data.ColumnNames));
datstruct.ch1IntensityStd = Cy3data.Data(:,Cy3StdCol);
Cy5StdCol = find(strcmp('Signal Stdev',Cy5data.ColumnNames));
datstruct.ch2IntensityStd = Cy5data.Data(:,Cy5StdCol);

% Get Background Means (Cy3, Cy5) 
Cy3BackgrndCol = find(strcmp('Background Mean',Cy3data.ColumnNames));
datstruct.ch1Background = Cy3data.Data(:,Cy3BackgrndCol);
Cy5BackgrndCol = find(strcmp('Background Mean',Cy5data.ColumnNames));
datstruct.ch2Background = Cy5data.Data(:,Cy5BackgrndCol);

% Get Background Medians (Cy3, Cy5) 
Cy3BackgrndMedCol = find(strcmp('Background Median',Cy3data.ColumnNames));
datstruct.ch1BackgroundMedian = Cy3data.Data(:,Cy3BackgrndMedCol);
Cy5BackgrndMedCol = find(strcmp('Background Median',Cy5data.ColumnNames));
datstruct.ch2BackgroundMedian = Cy5data.Data(:,Cy5BackgrndMedCol);

% Get Background Standard Deviations (Cy3, Cy5) 
Cy3BackgrndStdCol = find(strcmp('Background Stdev',Cy3data.ColumnNames));
datstruct.ch1BackgroundStd = Cy3data.Data(:,Cy3BackgrndStdCol);
Cy5BackgrndStdCol = find(strcmp('Background Stdev',Cy5data.ColumnNames));
datstruct.ch2BackgroundStd = Cy5data.Data(:,Cy5BackgrndStdCol);

% For the ARMADA GUI, do not get some fields since they are not used anywhere yet
% % Get Signal Modes (Cy3, Cy5)
% Cy3SigModCol = find(strcmp('Signal Mode',Cy3data.ColumnNames));
% if ~isempty(Cy3SigModCol)
%     datstruct.ch1SignalMode = Cy3data.Data(:,Cy3SigModCol);
% end
% Cy5SigModCol = find(strcmp('Signal Mode',Cy5data.ColumnNames));
% if ~isempty(Cy5SigModCol)
%     datstruct.ch2SignalMode = Cy5data.Data(:,Cy5SigModCol);
% end
% 
% % Get Background Modes (Cy3, Cy5)
% Cy3BackModCol = find(strcmp('Background Mode',Cy3data.ColumnNames));
% if ~isempty(Cy3BackModCol)
%     datstruct.ch1BackgroundMode = Cy3data.Data(:,Cy3BackModCol);
% end
% Cy5BackModCol = find(strcmp('Background Mode',Cy5data.ColumnNames));
% if ~isempty(Cy5BackModCol)
%     datstruct.ch2BackgroundMode = Cy5data.Data(:,Cy5BackModCol);
% end
% 
% % Get Signal Areas (Cy3, Cy5)
% Cy3SigAreaCol = find(strcmp('Signal Area',Cy3data.ColumnNames));
% if ~isempty(Cy3SigAreaCol)
%     datstruct.ch1SignalArea = Cy3data.Data(:,Cy3SigAreaCol);
% end
% Cy5SigAreaCol = find(strcmp('Signal Area',Cy5data.ColumnNames));
% if ~isempty(Cy5SigAreaCol)
%     datstruct.ch2SignalArea = Cy5data.Data(:,Cy5SigAreaCol);
% end
% 
% % Get Background Areas (Cy3, Cy5)
% Cy3BackAreaCol = find(strcmp('Background Area',Cy3data.ColumnNames));
% if ~isempty(Cy3BackAreaCol)
%     datstruct.ch1BackgroundArea = Cy3data.Data(:,Cy3BackAreaCol);
% end
% Cy5BackAreaCol = find(strcmp('Background Area',Cy5data.ColumnNames));
% if ~isempty(Cy5BackAreaCol)
%     datstruct.ch2BackgroundArea = Cy5data.Data(:,Cy5BackAreaCol);
% end
% 
% % Get Signal Totals (Cy3, Cy5)
% Cy3SigTotalCol = find(strcmp('Signal Total',Cy3data.ColumnNames));
% if ~isempty(Cy3SigTotalCol)
%     datstruct.ch1SignalTotal = Cy3data.Data(:,Cy3SigTotalCol);
% end
% Cy5SigTotalCol = find(strcmp('Signal Total',Cy5data.ColumnNames));
% if ~isempty(Cy5SigTotalCol)
%     datstruct.ch2SignalTotal = Cy5data.Data(:,Cy5SigTotalCol);
% end
% 
% % Get Background Totals (Cy3, Cy5)
% Cy3BackTotalCol = find(strcmp('Background Total',Cy3data.ColumnNames));
% if ~isempty(Cy3BackTotalCol)
%     datstruct.ch1BackgroundTotal = Cy3data.Data(:,Cy3BackTotalCol);
% end
% Cy5BackTotalCol = find(strcmp('Background Total',Cy5data.ColumnNames));
% if ~isempty(Cy5BackTotalCol)
%     datstruct.ch2BackgroundTotal = Cy5data.Data(:,Cy5BackTotalCol);
% end
% 
% % Get Shape Regularities (Cy3, Cy5)
% Cy3ShRegCol = find(strcmp('Shape Regularity',Cy3data.ColumnNames));
% if ~isempty(Cy3ShRegCol)
%     datstruct.ch1ShapeRegularity = Cy3data.Data(:,Cy3ShRegCol);
% end
% Cy5ShRegCol = find(strcmp('Shape Regularity',Cy5data.ColumnNames));
% if ~isempty(Cy5ShRegCol)
%     datstruct.ch2ShapeRegularity = Cy5data.Data(:,Cy5ShRegCol);
% end
% 
% % Get Ignored Areas (Cy3, Cy5)
% Cy3IgnArCol = find(strcmp('Ignore Area',Cy3data.ColumnNames));
% if ~isempty(Cy3IgnArCol)
%     datstruct.ch1IgnoreArea = Cy3data.Data(:,Cy3IgnArCol);
% end
% Cy5IgnArCol = find(strcmp('Ignore Area',Cy5data.ColumnNames));
% if ~isempty(Cy5IgnArCol)
%     datstruct.ch2IgnoreArea = Cy5data.Data(:,Cy5IgnArCol);
% end
% 
% % Get Spot Areas (Cy3, Cy5)
% Cy3SpArCol = find(strcmp('Spot Area',Cy3data.ColumnNames));
% if ~isempty(Cy3SpArCol)
%     datstruct.ch1SpotArea = Cy3data.Data(:,Cy3SpArCol);
% end
% Cy5SpArCol = find(strcmp('Spot Area',Cy5data.ColumnNames));
% if ~isempty(Cy5SpArCol)
%     datstruct.ch2SpotArea = Cy5data.Data(:,Cy5SpArCol);
% end
% 
% % Get Ignored Medians (Cy3, Cy5)
% Cy3IgnMedCol = find(strcmp('Ignored Median',Cy3data.ColumnNames));
% if ~isempty(Cy3IgnMedCol)
%     datstruct.ch1IgnoredMedian = Cy3data.Data(:,Cy3IgnMedCol);
% end
% Cy5IgnMedCol = find(strcmp('Ignored Median',Cy5data.ColumnNames));
% if ~isempty(Cy5IgnMedCol)
%     datstruct.ch2IgnoredMedian = Cy5data.Data(:,Cy5IgnMedCol);
% end
% 
% % Get Areas to Perimeter (Cy3, Cy5)
% Cy3ATPCol = find(strcmp('Area to Perimeter',Cy3data.ColumnNames));
% if ~isempty(Cy3ATPCol)
%     datstruct.ch1AreaToPerimeter = Cy3data.Data(:,Cy3ATPCol);
% end
% Cy5ATPCol = find(strcmp('Area to Perimeter',Cy5data.ColumnNames));
% if ~isempty(Cy5ATPCol)
%     datstruct.ch2AreaToPerimeter = Cy5data.Data(:,Cy5ATPCol);
% end
% 
% % Get Open Perimeters (Cy3, Cy5)
% Cy3OPCol = find(strcmp('Open Perimeter',Cy3data.ColumnNames));
% if ~isempty(Cy3OPCol)
%     datstruct.ch1OpenPerimeter = Cy3data.Data(:,Cy3OPCol);
% end
% Cy5OPCol = find(strcmp('Open Perimeter',Cy5data.ColumnNames));
% if ~isempty(Cy5OPCol)
%     datstruct.ch2OpenPerimeter = Cy5data.Data(:,Cy5OPCol);
% end
% 
% % Get XCoords (Cy3, Cy5)
% Cy3XCCol = find(strcmp('XCoord',Cy3data.ColumnNames));
% if ~isempty(Cy3XCCol)
%     datstruct.ch1XCoord = Cy3data.Data(:,Cy3XCCol);
% end
% Cy5XCCol = find(strcmp('XCoord',Cy5data.ColumnNames));
% if ~isempty(Cy5XCCol)
%     datstruct.ch2XCoord = Cy5data.Data(:,Cy5XCCol);
% end
% 
% % Get YCoords (Cy3, Cy5)
% Cy3YCCol = find(strcmp('YCoord',Cy3data.ColumnNames));
% if ~isempty(Cy3YCCol)
%     datstruct.ch1YCoord = Cy3data.Data(:,Cy3YCCol);
% end
% Cy5YCCol = find(strcmp('YCoord',Cy5data.ColumnNames));
% if ~isempty(Cy5YCCol)
%     datstruct.ch2YCoord = Cy5data.Data(:,Cy5YCCol);
% end
% 
% % Get Diameters (Cy3, Cy5)
% Cy3DiamCol = find(strcmp('Diameter',Cy3data.ColumnNames));
% if ~isempty(Cy3DiamCol)
%     datstruct.ch1Diameter = Cy3data.Data(:,Cy3DiamCol);
% end
% Cy5DiamCol = find(strcmp('Diameter',Cy5data.ColumnNames));
% if ~isempty(Cy5DiamCol)
%     datstruct.ch2Diameter = Cy5data.Data(:,Cy5DiamCol);
% end
% 
% % Get Array Controls
% if isfield(Cy3data,'Control')
%     datstruct.Control = Cy3data.Control;
% end

% Get Array Indices
datstruct.Indices=Cy3data.Indices;

% Get Array Shape
datstruct.Shape = Cy3data.Shape;


% Get bad spots flags
flagged = find(strcmp('Flag',Cy3data.ColumnNames));
tempIgnoreFilter = Cy3data.Data(:,flagged);
if emSpotCh==1
    tempIgnoreFilter(tempIgnoreFilter==2)=1; %Mark good
elseif emSpotCh==2
    tempIgnoreFilter(tempIgnoreFilter==2)=0; %Mark bad
else
    error('Bad Input: you must choose between 1 or 2')
end
tempIgnoreFilter(tempIgnoreFilter==1)=0;
tempIgnoreFilter(tempIgnoreFilter==3)=1;
tempIgnoreFilter(tempIgnoreFilter==6)=1;
tempIgnoreFilter(tempIgnoreFilter==4)=0;
tempIgnoreFilter(tempIgnoreFilter==5)=0;
tempIgnoreFilter(tempIgnoreFilter==7)=0;
datstruct.IgnoreFilter = ~tempIgnoreFilter; % Reverse to comply with ARMADA flagging system

% Add number of channels... future use
datstruct.Channels = 2;

