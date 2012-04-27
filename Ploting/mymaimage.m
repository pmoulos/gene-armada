function [hOut,hLines] = mymaimage(maStruct,attrib,field,varargin)

%MAIMAGE displays a spatial image of microarray data.
%
%   MAIMAGE(X,FIELD) displays an image of field FIELD from
%   microarray data structure X. Clicking on the image displays a data tip
%   showing the value and ID, if known, for a particular spot.
%
%   MAIMAGE(...,'TITLE',TITLE) allows you to specify the title of the plot.
%   The default title is FIELDNAME.
%
%   MAIMAGE(...,'COLORBAR',false) creates an image without displaying a
%   colorbar.
%
%   MAIMAGE(...,Handle Graphics name/value) allows you to pass optional
%   Handle Graphics property name/property value pairs to the function.
%
%   H = MAIMAGE(...) returns the handle of the image.
%
%   [H,HLINES] = MAIMAGE(...) returns the handles of the lines used to
%   separate the different blocks in the image.
%
%   See also IMAGESC, MABOXPLOT, MAGETFIELD, MAIRPLOT, MALOGLOG, MALOWESS.

% Copyright 2003-2006 The MathWorks, Inc.
% $Revision: 1.13.6.11 $   $Date: 2006/10/20 15:46:49 $

% Modified on 2007/06/18 by Panagiotis Moulos for the needs of ARMADA
% field is a cell of length 2 where field{1} contains a selection from 1-16 and field{2}
% its corresponding name (see MAImageEditor.m)

if ~isstruct(maStruct)
    error('ARMADA:MAImageNotStruct',...
          'The first input to MAIMAGE must be a microarray structure.')
end

titleString = '';
hgargs = {};
showColorbar = true;
rowLabels = {};
columnLabels = {};

if nargin > 2

    if rem(nargin,2)==0
        error('ARMADA:IncorrectNumberOfArguments',...
              'Incorrect number of arguments to %s.',mfilename);
    end
    okargs = {'title','colorbar','rowlabels','columnlabels'};
    for j=1:2:length(varargin)-1
        pname = varargin{j};
        pval = varargin{j+1};
        k = find(strncmpi(pname,okargs,numel(pname)));
        if isempty(k)
            % here we assume that these are handle graphics options
            hgargs{end+1} = pname; %#ok
            hgargs{end+1} = pval; %#ok
        elseif length(k)>1
            error('ARMADA:AmbiguousParameterName',...
                  'Ambiguous parameter name: %s.',pname);
        else
            switch(k)
                case 1 % title
                    titleString = pval;
                case 2 % colorbar
                    showColorbar = destf(pval);
                    if isempty(showColorbar)
                        error('ARMADA:InputOptionNotLogical','%s must be a logical value, true or false.',...
                              upper(char(okargs(k))));
                    end
                case 3 % rowlabels
                    if ~iscellstr(pval)
                        error('ARMADA:InputOptionNotCellStr','%s must be a cell array of strings.',upper(char(okargs(k))));
                    end
                    if numel(pval) ~= size(attrib.Indices,1)
                        error('ARMADA:MAIMAGEIncorrectNumberOfRowLabels','The number of row labels must match the number of rows.');
                    end
                    rowLabels = pval;
                case 4 % columnlabels
                    if ~iscellstr(pval)
                        error('ARMADA:InputOptionNotCellStr','%s must be a cell array of strings.',upper(char(okargs(k))));
                    end
                    if numel(pval) ~= size(attrib.Indices,2)
                        error('ARMADA:MAIMAGEIncorrectNumberOfColumnLabels','The number of column labels must match the number of columns.');
                    end
                    columnLabels = pval;
            end
        end
    end
    
end

% Determine data
affy=false;
switch field{1}
    case 1 % Channel 1 Foreground Mean
        theData = maStruct.ch1Intensity;
    case 2 % Channel 2 Foreground Mean
        theData = maStruct.ch2Intensity;
    case 3 % Channel 1 Foreground Median
        theData = maStruct.ch1IntensityMedian;
    case 4 % Channel 2 Foreground Median
        theData = maStruct.ch2IntensityMedian;
    case 5 % Channel 1 Background Mean
        theData = maStruct.ch1Background;
    case 6 % Channel 2 Background Mean
        theData = maStruct.ch2Background;
    case 7 % Channel 1 Background Median
        theData = maStruct.ch1BackgroundMedian;
    case 8 % Channel 2 Background Median
        theData = maStruct.ch2BackgroundMedian;
    case 9 % Channel 1 Foreground Standard Deviation
        theData = maStruct.ch1IntensityStd;
    case 10 % Channel 2 Foreground Standard Deviation
        theData = maStruct.ch2IntensityStd;
    case 11 % Channel 1 Background Standard Deviation
        theData = maStruct.ch1BackgroundStd;
    case 12 % Channel 2 Background Standard Deviation
        theData = maStruct.ch2BackgroundStd;
    case 13 % Channel 1 Foreground - Background (Mean)
        theData = maStruct.ch1Intensity - maStruct.ch1Background;
    case 14 % Channel 2 Foreground - Background (Mean)
        theData = maStruct.ch2Intensity - maStruct.ch2Background;
    case 15 % Channel 1 Foreground - Background (Median)
        theData = maStruct.ch1IntensityMedian - maStruct.ch1BackgroundMedian;
    case 16 % Channel 2 Foreground - Background (Median)
        theData = maStruct.ch2IntensityMedian - maStruct.ch2BackgroundMedian;
    case 17 % Channel 1 Foreground/Background (Mean)
        theData = maStruct.ch1Intensity ./ maStruct.ch1Background;
    case 18 % Channel 2 Foreground/Background (Mean)
        theData = maStruct.ch2Intensity ./ maStruct.ch2Background;
    case 19 % Channel 1 Foreground/Background (Median)
        theData = maStruct.ch1IntensityMedian ./ maStruct.ch1BackgroundMedian;
    case 20 % Channel 2 Foreground - Background (Median)
        theData = maStruct.ch2IntensityMedian ./ maStruct.ch2BackgroundMedian;
    case 100 % Affymetrix Intensity
        theData = maStruct.Intensity;
        affy=true;
    case 101 % Affymetrix StDev
        theData = maStruct.StdDev;
        affy=true;
end
        
% convert from blocks to global indices
ax = newplot;
fig = get(ax,'Parent');

% Check the case where part of the grid is empty
if ~affy
    zeroind = find(attrib.Indices==0);
    if ~isempty(zeroind)
        attrib.Indices(zeroind) = 1;
    end
    if ~isempty(zeroind)
        theData(zeroind) = 0;
    end
end
hImage = imagesc(theData(attrib.Indices),'Parent',ax,hgargs{:});
axis(ax,'image');

% set figure callbacks
set(fig,'WindowButtonDownFcn',{@localInfoOn,hImage},...
        'WindowButtonMotionFcn',{@localShowInfo,hImage},...
        'WindowButtonUpFcn',{@localInfoOff});

maimageData.maStruct = maStruct;
maimageData.attrib = attrib;
maimageData.rowLabels = rowLabels;
maimageData.columnLabels = columnLabels;
if ~affy
    maimageData.zeroind = zeroind;
end

setappdata(fig,'ShowMAIMAGEInfo',false);
setappdata(fig,'MAIMAGEData',maimageData);

% draw on lines to indicate blocks
maxX = size(attrib.Indices,2);
maxY = size(attrib.Indices,1);
XBreaks = unique(attrib.Shape.BlockRange(:,1));
YBreaks = unique(attrib.Shape.BlockRange(:,2));
numXBreaks = numel(XBreaks);
numYBreaks = numel(YBreaks);
hLines = zeros(numXBreaks+numYBreaks-2,1);
for count = 2:numXBreaks
    hLines(count-1) = line([XBreaks(count),XBreaks(count)]-.5,[0,maxY]+.5,'linewidth',2,'color','k');
end
for count = 2:numYBreaks
    hLines(numXBreaks+count-2) = line([0,maxX]+.5,[YBreaks(count),YBreaks(count)]-.5,'linewidth',2,'color','k');
end
% turn off axis
axis('off');
if isempty(titleString)
    titleString = field{2};
end
title(titleString);
if showColorbar
    colorbar('peer',ax);
    % reverse the order of the children in figure so datatip goes over the
    % colorbar
    set(gcf,'Children',flipud(get(gcf,'Children')))
end

if nargout > 0
    hOut = hImage;
end


% -----------------------------------------------------------
function localInfoOn(fig,eventdata,hImage)

setappdata(fig,'ShowMAIMAGEInfo',true);
%display info now
localShowInfo(fig,eventdata,hImage)


% -----------------------------------------------------------
function localInfoOff(fig,eventdata) %#ok

setappdata(fig,'ShowMAIMAGEInfo',false);
htext = getappdata(fig,'MAIMAGEText');
if ~isempty(htext) && ishandle(htext)
    delete(htext)
end
setappdata(fig,'MAIMAGEText',[])


% -----------------------------------------------------------
function localShowInfo(fig,eventdata,hImage) %#ok

% check whether to show info
showinfo = getappdata(fig,'ShowMAIMAGEInfo');
if ~showinfo  || hittest(fig) ~= hImage
    return;
end

htext = getappdata(fig,'MAIMAGEText');
if ~isempty(htext) && ishandle(htext)
    delete(htext)
end

% set figure Units to pixels
figUnits = get(fig,'Units');
set(fig,'Units','pixels');

% setup axes
ax = get(hImage,'Parent');
axUnits = get(ax,'Units');
set(ax,'Units','pixels');

% axPos = get(ax,'Position');
axXLim = get(ax,'XLim');
axYLim = get(ax,'YLim');

%pixels from edge of axes
imCData = get(hImage,'CData');
sizeC = size(imCData);

% point relative to data
ax_cp = get(ax,'CurrentPoint');
x = round(ax_cp(1,1));
y = round(ax_cp(1,2));

maimageData = getappdata(fig,'MAIMAGEData');

ids = '';
if isfield(maimageData.attrib,'pbID')
    if ~isempty(maimageData.zeroind)
        names = cell(numel(maimageData.attrib.Indices),1);
        pos = true(numel(maimageData.attrib.Indices),1);
        pos(maimageData.zeroind) = false;
        names(~pos) = {'Empty Spot'};
        %names(pos) = maimageData.attrib.gnID;
        names(pos) = maimageData.attrib.pbID;
    else
        %names = maimageData.attrib.gnID;
        names = maimageData.attrib.pbID;
    end
    ids = names;
end

% out of range
if x< 1 || x > sizeC(2) || y < 1 || y > sizeC(1)
    htext = getappdata(fig,'MAIMAGEText');
    if ~isempty(htext) && ishandle(htext)
        set(htext,'Visible','off')
    end
    return
end

ind = sub2ind(sizeC,y,x);
val = imCData(ind);
name = '';
id = '';
if ~isempty(ids)
    id = ids{ind};
end

str = {['Value: ' num2str(val)]};
if ~isempty(name)
    str = [str; {['Name: ' name]}];
end
if ~isempty(id)
    str = [str; {['ID: ' id]}];
end
if ~isempty(maimageData.rowLabels)
    str = [str;{['Row: ' maimageData.rowLabels{y}]}];
end
if ~isempty(maimageData.columnLabels)
    str = [str;{['Column: ' maimageData.columnLabels{x}]}];
end

htext = text(x,y,str,'Visible','off','Clipping','off','FontName','FixedWidth');
setappdata(fig,'MAIMAGEText',htext)

% give it an off white background, black text and grey border
set(htext, 'BackgroundColor', [1 1 0.933333],...
           'Color', [0 0 0],...
           'EdgeColor', [0.8 0.8 0.8],...
           'Tag','ImageDataTip',...
           'interpreter','none');

% determine the offset in pixels
set(htext,'position',[x y]);
set(htext,'Units','pixels')
pixpos = get(htext,'Position');

offsets = [0 0 0];

% determine what quadrant the pointer is in
quadrant=[x y]<[mean(axXLim) mean(axYLim)];

if ~quadrant(1)
    set(htext,'HorizontalAlignment','Right')
    offsets(1) = -2;
else
    set(htext,'HorizontalAlignment','Left')
    offsets(1) = 16;
end
if ~quadrant(2)
    set(htext,'VerticalAlignment','Bottom')
    offsets(2) = 2;
else
    set(htext,'VerticalAlignment','Top')
    offsets(2) = -2;
end

set(htext,'Position',pixpos + offsets);

% show the text
set(htext, 'Visible','on')

% restore Units
set(fig,'Units',figUnits);
set(ax,'Units',axUnits);


function tf = destf(pval)

if islogical(pval)
    tf=all(pval);
    return
end
if isnumeric(pval)
    tf=all(pval~=0);
    return
end
if ischar(pval)
    truevals={'true','yes','on','t'};
    k=any(strcmpi(pval,truevals));
    if k
        tf=true;
        return
    end
    falsevals={'false','no','off','f'};
    k=any(strcmpi(pval,falsevals));
    if k
        tf=false;
        return
    end
end
tf=logical([]);


%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% Some useful comments
% 1  Channel 1 Foreground Mean
% 2  Channel 2 Foreground Mean
% 3  Channel 1 Foreground Median
% 4  Channel 2 Foreground Median
% 5  Channel 1 Background Mean
% 6  Channel 2 Background Mean
% 7  Channel 1 Background Median
% 8  Channel 2 Background Median
% 9  Channel 1 Foreground Standard Deviation
% 10 Channel 2 Foreground Standard Deviation
% 11 Channel 1 Background Standard Deviation
% 12 Channel 2 Background Standard Deviation
% 13 Channel 1 Foreground - Background (Mean)
% 14 Channel 2 Foreground - Background (Mean)
% 15 Channel 1 Foreground - Background (Median)
% 16 Channel 2 Foreground - Background (Median)
