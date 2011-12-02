function [datstruct] = GnPx2Struct(filename)

% Function to read from GenePix files (.gpr) and convert them to a structure for further
% use with ARMADA

% Read data...
gpdata=gprread(filename);

% ...and keep useful columns

% Get header info for GUI use (different from others because GenePix...)
datstruct.Header.Type=gpdata.Header.Type;
otherfields=fieldnames(gpdata.Header);
otherfields(1)=[]; % Type, we already have it
alltext=struct2cell(gpdata.Header);
alltext(1)=[]; % Type data, we already have it
newtext=cell(length(otherfields),1);
for i=1:length(otherfields)
    if isnumeric(alltext{i})
        newtext{i}=[otherfields{i} ' : ' num2str(alltext{i})];
    elseif ischar(alltext{i})
        newtext{i}=[otherfields{i} ' : ' alltext{i}];
    else
        newtext{i}=[otherfields{i} ' : ' 'Field could not be converted'];
    end
end
datstruct.Header.Text=newtext;        

% Assign Gene Number (Slide Position)
datstruct.Number=1:length(gpdata.IDs);
datstruct.Number=datstruct.Number';

% Get spatial information and names
datstruct.Blocks = gpdata.Blocks;
datstruct.Rows = gpdata.Rows;
datstruct.Columns = gpdata.Columns;
datstruct.ColumnNames = gpdata.ColumnNames;
datstruct.GeneNames = gpdata.IDs;
                
% Get Signal Means (532(Green) and 635(Red))
datstruct.ch1Intensity = magetfield(gpdata,'F532 Mean');
datstruct.ch2Intensity = magetfield(gpdata,'F635 Mean');

% Get Signal Medians (532(Green) and 635(Red))
datstruct.ch1IntensityMedian = magetfield(gpdata,'F532 Median');
datstruct.ch2IntensityMedian = magetfield(gpdata,'F635 Median');

% Get Signal Standard Deviations (532(Green) and 635(Red))
datstruct.ch1IntensityStd = magetfield(gpdata,'F532 SD');
datstruct.ch2IntensityStd = magetfield(gpdata,'F635 SD');

% Get Background Means (532(Green) and 635(Red))
datstruct.ch1Background = magetfield(gpdata,'B532 Mean');
datstruct.ch2Background = magetfield(gpdata,'B635 Mean');

% Get Background Medians (532(Green) and 635(Red))
datstruct.ch1BackgroundMedian = magetfield(gpdata,'B532 Median');
datstruct.ch2BackgroundMedian = magetfield(gpdata,'B635 Median');

% Get Background Standard Deviations (532(Green) and 635(Red))
datstruct.ch1BackgroundStd = magetfield(gpdata,'B532 SD');
datstruct.ch2BackgroundStd = magetfield(gpdata,'B635 SD');

%-----------------------------------------------------------------------------------------

% Koukouves test
 
% % Get Signal Means (532(Green) and 635(Red))
% datstruct.ch1Intensity = magetfield(gpdata,'F531 Mean');
% datstruct.ch2Intensity = magetfield(gpdata,'F632 Mean');
% 
% % Get Signal Medians (532(Green) and 635(Red))
% datstruct.ch1IntensityMedian = magetfield(gpdata,'F531 Median');
% datstruct.ch2IntensityMedian = magetfield(gpdata,'F632 Median');
% 
% % Get Signal Standard Deviations (532(Green) and 635(Red))
% datstruct.ch1IntensityStd = magetfield(gpdata,'F531 SD');
% datstruct.ch2IntensityStd = magetfield(gpdata,'F632 SD');
% 
% % Get Background Means (532(Green) and 635(Red))
% datstruct.ch1Background = magetfield(gpdata,'B531 Mean');
% datstruct.ch2Background = magetfield(gpdata,'B632 Mean');
% 
% % Get Background Medians (532(Green) and 635(Red))
% datstruct.ch1BackgroundMedian = magetfield(gpdata,'B531 Median');
% datstruct.ch2BackgroundMedian = magetfield(gpdata,'B632 Median');
% 
% % Get Background Standard Deviations (532(Green) and 635(Red))
% datstruct.ch1BackgroundStd = magetfield(gpdata,'B531 SD');
% datstruct.ch2BackgroundStd = magetfield(gpdata,'B632 SD');

%-----------------------------------------------------------------------------------------

% For the ARMADA GUI, do not get some fields since they are not used anywhere yet
% 
% % Get Ratio of Medians
% datstruct.RatioOfMedians = magetfield(gpdata,'Ratio of Medians');
% 
% % Get Ratio of Means
% datstruct.RatioOfMeans = magetfield(gpdata,'Ratio of Means');
% 
% % Get Median of Ratios
% datstruct.MedianOfRatios = magetfield(gpdata,'Median of Ratios');
% 
% % Get Mean of Ratios
% datstruct.MeanOfRatios = magetfield(gpdata,'Mean of Ratios');
% 
% % Get Ratios SD
% datstruct.RatiosSD = magetfield(gpdata,'Ratios SD');
% 
% % Get Sum of Medians
% datstruct.SumofMedians = magetfield(gpdata,'Sum of Medians');
% 
% % Get Sum of Means
% datstruct.SumofMeans = magetfield(gpdata,'Sum of Means');
% 
% % Get Log Ratio
% datstruct.LogRatio = magetfield(gpdata,'Log Ratio');

% Get Array Indices
datstruct.Indices = gpdata.Indices;

% Get Array Shape
datstruct.Shape = gpdata.Shape;

% Get bad spots flags (this part not very clear...)
flagged = magetfield(gpdata,'Flags');
tempIgnoreFilter = flagged<0;
datstruct.IgnoreFilter = ~tempIgnoreFilter;
