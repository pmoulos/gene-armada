function him = createRawImage(stru,attrib,ax)

flag=false;
if nargin<3
    flag=true;
    figure;
    ax=axes;
end

% Perform a check in case a subgrid part of the array is black
zeroind=find(attrib.Indices==0);
if ~isempty(zeroind)
    attrib.Indices(zeroind)=1;
end

% Determine whether affymetrix or not and do...
if ~isfield(stru,'Intensity')
    
    % Get Cy3 data (or whatever channel 1)
    datagreen=stru.ch1Intensity(attrib.Indices);
    if ~isempty(zeroind)
        datagreen(zeroind)=0;
    end
    % Get Cy5 data (or whatever channel 2)
    datared=stru.ch2Intensity(attrib.Indices);
    if ~isempty(zeroind)
        datared(zeroind)=0;
    end
    % Scale them
    scaledatagreen=datagreen/max(max(datagreen));
    scaledatared=datared/max(max(datared));
    % Create true color image data
    ex=cat(3,scaledatared,scaledatagreen,zeros(size(scaledatagreen)));
    % Display true color image
    if flag
        him=image(ex);
    else
        him=image(ex,'Parent',ax);
    end
    
else % Affymetrix
    
    % Get Intensity data (or whatever channel 1)
    datagreen=stru.Intensity(attrib.Indices);
    if ~isempty(zeroind)
        datagreen(zeroind)=0;
    end
    datared=[];
    % Display image
    him=imagesc(datagreen,'Parent',ax);
    colormap('default')
    
end


% Draw on lines to indicate blocks (if they exist)
maxX=size(attrib.Indices,2);
maxY=size(attrib.Indices,1);
XBreaks=unique(attrib.Shape.BlockRange(:,1));
YBreaks=unique(attrib.Shape.BlockRange(:,2));
numXBreaks=numel(XBreaks);
numYBreaks=numel(YBreaks);
hLines=zeros(numXBreaks+numYBreaks-2,1);
for count=2:numXBreaks
    hLines(count-1)=line([XBreaks(count),XBreaks(count)]-.5,[0,maxY]+.5,...
           'linewidth',2,'color','k');
end
for count=2:numYBreaks
    hLines(numXBreaks+count-2)=line([0,maxX]+.5,[YBreaks(count),YBreaks(count)]-.5,...
           'linewidth',2,'color','k');
end
% Turn off axis
axis('off');
% More proper view
axis image
% Get parent
fig=get(ax,'Parent');
% Set some callbacks
set(fig,'WindowButtonDownFcn',{@localInfoOn,him},...
        'WindowButtonMotionFcn',{@localShowInfo,him},...
        'WindowButtonUpFcn',{@localInfoOff});

maimageData.maStruct=stru;
setappdata(fig,'ShowMAIMAGEInfo',false);
if ~isfield(attrib,'gnID')
    attrib.gnID='';
end
if ~isempty(zeroind)
    names=cell(numel(attrib.Indices),1);
    pos=true(numel(attrib.Indices),1);
    pos(zeroind)=false;
    names(~pos)={'Empty Spot'};
    names(pos)=attrib.gnID;
else
    names=attrib.gnID;
end
set(him,'UserData',{datagreen,datared,names,attrib.Indices})


% -----------------------------------------------------------
function localInfoOn(fig,eventdata,hImage)

setappdata(fig,'ShowMAIMAGEInfo',true);
localShowInfo(fig,eventdata,hImage)


% -----------------------------------------------------------
function localInfoOff(fig,eventdata)

setappdata(fig,'ShowMAIMAGEInfo',false);
htext=getappdata(fig,'MAIMAGEText');
if ~isempty(htext) && ishandle(htext)
    delete(htext)
end
setappdata(fig,'MAIMAGEText',[])


% -----------------------------------------------------------
function localShowInfo(fig,eventdata,hImage)

showinfo=getappdata(fig,'ShowMAIMAGEInfo');
if ~showinfo  || hittest(fig) ~= hImage
    return;
end

htext=getappdata(fig,'MAIMAGEText');
if ~isempty(htext) && ishandle(htext)
    delete(htext)
end

% set figure Units to pixels
figUnits=get(fig,'Units');
set(fig,'Units','pixels');

% setup axes
ax=get(hImage,'Parent');
axUnits=get(ax,'Units');
set(ax,'Units','pixels');

% axPos = get(ax,'Position');
axXLim=get(ax,'XLim');
axYLim=get(ax,'YLim');

%pixels from edge of axes
imCData=get(hImage,'CData');
sizeC=size(imCData);

% point relative to data
ax_cp=get(ax,'CurrentPoint');
x=round(ax_cp(1,1));
y=round(ax_cp(1,2));

userdata=get(hImage,'UserData');
ch1Data=userdata{1};
ch2Data=userdata{2};
IDs=userdata{3};
inds=userdata{4};

ids='';
if ~isempty(IDs) && length(IDs)==length(inds(:))
    ids=IDs(inds);
end

% out of range
if x<1 || x>sizeC(2) || y<1 || y>sizeC(1)
    htext=getappdata(fig,'MAIMAGEText');
    if ~isempty(htext) && ishandle(htext)
        set(htext,'Visible','off')
    end
    return
end

ind=sub2ind(sizeC,y,x);
val1=ch1Data(ind);
% Twn fronimwn ta paidia prin peinasoun mageireyoun ...thn Affymetrix
if ~isempty(ch2Data) 
    val2=ch2Data(ind);
else
    val2='';
end
id='';
if ~isempty(ids)
    id=ids{ind};
end

str={['Channel 1 Value: ' num2str(val1)]};
if ~isempty(val2)
    str=[str; {['Channel 2 Value: ' num2str(val2)]}];
end
if ~isempty(id)
    str=[str; {['ID: ' id]}];
end

htext=text(x,y,str,'Visible','off','Clipping','off','FontName','FixedWidth');
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
pixpos=get(htext,'Position');

offsets=[0 0 0];

% determine what quadrant the pointer is in
quadrant=[x y]<[mean(axXLim) mean(axYLim)];

if ~quadrant(1)
    set(htext,'HorizontalAlignment','Right')
    offsets(1)=-2;
else
    set(htext,'HorizontalAlignment','Left')
    offsets(1)=16;
end
if ~quadrant(2)
    set(htext,'VerticalAlignment','Bottom')
    offsets(2)=2;
else
    set(htext,'VerticalAlignment','Top')
    offsets(2)=-2;
end

set(htext,'Position',pixpos+offsets);

% show the text
set(htext,'Visible','on')

% restore Units
set(fig,'Units',figUnits);
set(ax,'Units',axUnits);
