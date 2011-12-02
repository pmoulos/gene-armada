function him = createDataImage(datamat,labels,colnames,ax)

flag=false;
if nargin<2
    labels={};
    colnames={};
end
if nargin<3
    colnames={};
end
if nargin<4
    flag=true;
    figure;
    ax=axes;
end

datamat(isinf(datamat))=NaN;
datamat(isnan(datamat))=0;

if flag
    him=imagesc(datamat);
else
    him=imagesc(datamat,'Parent',ax);
end

% Turn off axis
axis('off');
% Get parent
fig=get(ax,'Parent');
% Set some callbacks
if ~isempty(labels)
    set(fig,'WindowButtonDownFcn',{@localInfoOn,him},...
        'WindowButtonMotionFcn',{@localShowInfo,him},...
        'WindowButtonUpFcn',{@localInfoOff});
    setappdata(fig,'ShowMAIMAGEInfo',false);
    set(him,'UserData',{labels,colnames})
end


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
cols=userdata{2};

% ids='';
% if ~isempty(IDs)
%     ids=IDs(inds);
% end

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
if ~isempty(IDs)
    id=IDs{y};
    col=cols{x};
end

str={['Value: ' num2str(val)]; ['GeneID: ' id]; ['Sample: ',col]};

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
