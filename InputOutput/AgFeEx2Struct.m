function datstruct = AgFeEx2Struct(filename)

% Function to read from Agilent Feature Extractor files (.gpr) and convert them to a
% structure for further use with ARMADA

% Read data...
agfedata=agferead(filename);

% ...and keep useful columns

% Get header info for GUI use (different from others because GenePix...)
datstruct.Header.Type=agfedata.Header.Type;
otherheaderfields=fieldnames(agfedata.Header);
otherheaderfields(end)=[]; % Type, we already have it
allheadertext=struct2cell(agfedata.Header);
allheadertext(end)=[]; % Type data, we already have it
newheadertext=cell(length(otherheaderfields),1);
for i=1:length(otherheaderfields)
    if isnumeric(allheadertext{i})
        newheadertext{i}=[otherheaderfields{i} ' : ' num2str(allheadertext{i})];
    elseif ischar(allheadertext{i})
        newheadertext{i}=[otherheaderfields{i} ' : ' allheadertext{i}];
    else
        newheadertext{i}=[otherheaderfields{i} ' : ' 'Field could not be converted'];
    end
end
statsfields=fieldnames(agfedata.Stats);
allstatstext=struct2cell(agfedata.Stats);
newstatstext=cell(length(statsfields),1);
for i=1:length(statsfields)
    if isnumeric(allstatstext{i})
        newstatstext{i}=[statsfields{i} ' : ' num2str(allstatstext{i})];
    elseif ischar(allstatstext{i})
        newstatstext{i}=[statsfields{i} ' : ' allstatstext{i}];
    else
        newstatstext{i}=[statsfields{i} ' : ' 'Field could not be converted'];
    end
end
datstruct.Header.Text=[newheadertext;' ';newstatstext];        

% Assign Gene Number (Slide Position)
datstruct.Number=magetfield(agfedata,'FeatureNum');

% Get spatial information and names
datstruct.Rows = magetfield(agfedata,'Row');
datstruct.Columns = magetfield(agfedata,'Col');
datstruct.ColumnNames = agfedata.ColumnNames;
datstruct.GeneNames = agfedata.Names;

% Agilent files can be one channel... We must guess it here and set a flag
try
    try
        testgreen = magetfield(agfedata,'gMeanSignal');
        isgreen = true;
    catch
        testgreen = magetfield(agfedata,'gMedianSignal');
        isgreen = true;
    end
catch
    isgreen = false;
end
try
    try
        testred = magetfield(agfedata,'rMeanSignal');
        isred = true;
    catch
        testred = magetfield(agfedata,'rMedianSignal');
        isred = true;
    end
catch
    isred = false;
end
onechannel = ~(isgreen && isred);
n = length(datstruct.GeneNames);

% Get Signal Means (Green and Red)
try
    datstruct.ch1Intensity = magetfield(agfedata,'gMeanSignal');
catch
    if onechannel && isred
        datstruct.ch1Intensity = ones(n,1);
    else
        datstruct.ch1Intensity = [];
    end
end
try
    datstruct.ch2Intensity = magetfield(agfedata,'rMeanSignal');
catch
    if onechannel && isgreen
        datstruct.ch2Intensity = ones(n,1);
    else
        datstruct.ch2Intensity = [];
    end
end

% Get Signal Medians (Green and Red)
try
    datstruct.ch1IntensityMedian = magetfield(agfedata,'gMedianSignal');
catch
    if onechannel && isred
        datstruct.ch1IntensityMedian = ones(n,1);
    else
        datstruct.ch1IntensityMedian = [];
    end
end
try
    datstruct.ch2IntensityMedian = magetfield(agfedata,'rMedianSignal');
catch
    if onechannel && isgreen
        datstruct.ch2IntensityMedian = ones(n,1);
    else
        datstruct.ch2IntensityMedian = [];
    end
end

% Get Signal Standard Deviations (Green and Red)
try
    datstruct.ch1IntensityStd = magetfield(agfedata,'gPixSDev');
catch
    datstruct.ch1IntensityStd = [];
end
try
    datstruct.ch2IntensityStd = magetfield(agfedata,'rPixSDev');
catch
    datstruct.ch2IntensityStd = [];
end

% Get Background Means (Green and Red)
try
    datstruct.ch1Background = magetfield(agfedata,'gBGMeanSignal');
catch
    if onechannel && isred
        datstruct.ch1Background = ones(n,1);
    else
        datstruct.ch1Background = [];
    end
end
try
    datstruct.ch2Background = magetfield(agfedata,'rBGMeanSignal');
catch
    if onechannel && isgreen
        datstruct.ch2Background = ones(n,1);
    else
        datstruct.ch2Background = [];
    end
end

% Get Background Medians (Green and Red)
try
    datstruct.ch1BackgroundMedian = magetfield(agfedata,'gBGMedianSignal');
catch
    if onechannel && isred
        datstruct.ch1BackgroundMedian = ones(n,1);
    else
        datstruct.ch1BackgroundMedian = [];
    end
end
try
    datstruct.ch2BackgroundMedian = magetfield(agfedata,'rBGMedianSignal');
catch
    if onechannel && isgreen
        datstruct.ch2BackgroundMedian = ones(n,1);
    else
        datstruct.ch2BackgroundMedian = [];
    end
end

% Get Background Standard Deviations (Green and Red)
try
    datstruct.ch1BackgroundStd = magetfield(agfedata,'gBGPixSDev');
catch
    datstruct.ch1BackgroundStd = [];
end
try
    datstruct.ch2BackgroundStd = magetfield(agfedata,'rBGPixSDev');
catch
    datstruct.ch2BackgroundStd = [];
end

% Get Array Indices
datstruct.Indices = agfedata.Indices;

% Get Array Shape
datstruct.Shape = agfedata.Shape;

% Get bad spots flags (this part not very clear...)
controlType = magetfield(agfedata,'ControlType'); % 0s are good
manualFlag = magetfield(agfedata,'ControlType'); % 0s are good
flags = controlType | manualFlag;
datstruct.IgnoreFilter = ~flags;

% !!!!! IMPORTANT
% If signal means do not exist, we have to assign the medians to them as ARMADA's main 
% quantitation type is Means...
if isempty(datstruct.ch1Intensity)
    datstruct.ch1Intensity = datstruct.ch1IntensityMedian;
    datstruct.ch1IntensityMedian = [];
end
if isempty(datstruct.ch2Intensity)
    datstruct.ch2Intensity = datstruct.ch2IntensityMedian;
    datstruct.ch2IntensityMedian = [];
end
if isempty(datstruct.ch1Background)
    datstruct.ch1Background = datstruct.ch1BackgroundMedian;
    datstruct.ch1BackgroundMedian = [];
end
if isempty(datstruct.ch2Background)
    datstruct.ch2Background = datstruct.ch2BackgroundMedian;
    datstruct.ch2BackgroundMedian = [];
end
