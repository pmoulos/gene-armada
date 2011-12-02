function him = createRawNormImage(stru,attrib,ndata,dim,ax)

flag=false;
if nargin<4
    dim=1;
    flag=true;
    figure;
    ax=axes;
elseif nargin<5
    flag=true;
    figure;
    ax=axes;
end

% Perform a check in case a subgrid part of the array is black
zeroind=find(attrib.Indices==0);
if ~isempty(zeroind)
    attrib.Indices(zeroind)=1;
end

% Createimage matrix
normdata=ndata(attrib.Indices);
if ~isempty(zeroind)
    normdata(zeroind)=0;
end
% Display true color image
normdatananrep=normdata;
normdatananrep(isnan(normdatananrep))=0;
if dim==1
    if flag
        him=imagesc(normdatananrep);
    else
        him=imagesc(normdatananrep,'Parent',ax);
    end
    % More proper view
    axis image
elseif dim==2
    if flag
        him=surf(normdatananrep,'FaceColor','interp','LineStyle','none');
    else
        him=surf(normdatananrep,'Parent',ax,'FaceColor','interp','LineStyle','none');
    end
    % More proper view
    axis vis3d
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
set(him,'UserData',{names,attrib.Indices})


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
imCData(imCData==0)=NaN;

% point relative to data
ax_cp=get(ax,'CurrentPoint');
x=round(ax_cp(1,1));
y=round(ax_cp(1,2));

userdata=get(hImage,'UserData');
IDs=userdata{1};
inds=userdata{2};

ids='';
if ~isempty(IDs)
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
val=imCData(ind);
id='';
if ~isempty(ids)
    id=ids{ind};
end

str={['Ratio: ' num2str(val)]};
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
