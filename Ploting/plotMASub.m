function hp = plotMASub(areas,inten,lograt,logratsmth,titre,discurve,disfcline,fc,labels)

% Check various inputs
if nargin<5
    titre='';
    discurve=false;
    disfcline=false;
    fc=[];
    labels='';
elseif nargin<6
    discurve=false;
    disfcline=false;
    fc=[];
    labels='';
elseif nargin<7
    disfcline=false;
    fc=[];
    labels='';
elseif nargin<8
    if disfcline
        fc=2;
    else
        fc=[];
    end
    labels='';
elseif nargin<9
    labels='';
end
                         
logfc=log2(fc);

% Plot MA data
figure

[p,q]=size(areas);
count=0;
haxes=zeros(1,p*q);
h=zeros(1,p*q);
hline=zeros(1,p*q);
hcurve=zeros(1,p*q);
udata=cell(1,p*q);
for i=1:p
    for j=1:q
    
        % Plot subgrid data on separate axis
        count=count+1;
        haxes(count)=subplot(p,q,count);
        h(count)=plot(inten(areas{i,j}),lograt(areas{i,j}),'.b','MarkerSize',2);

        % Display FC line (if wanted)
        if disfcline
            htemp=fclines(h(count),logfc);
            hline(count)=htemp(1);
        end

        % Display normalization curve (if wanted)
        if discurve
            hold on
            hcurve(count)=plot(inten(areas{i,j}),logratsmth(areas{i,j}),'.y','MarkerSize',2);
        end

        tit=['Subgrid (',num2str(i),',',num2str(j),')'];
        set(gca,'FontSize',6)
        title(tit,'FontSize',7)

        % If labels exist, set up a buttondown function
        if ~isempty(labels)
            udata{count}={labels(areas{i,j}),...
                inten(areas{i,j}),...
                lograt(areas{i,j})};
            set(haxes(count),'UserData',h(count),'ButtonDownFcn',@clickonplot);
            set(h(count),'UserData',udata{count},'ButtonDownFcn',@clickonplot);
        end
    end
end

% Replace '_' character
titre=strrep(titre,'_','-');
set(gcf,'Name',titre)

if nargout>0
    hp=h;
end

           
function hline = fclines(h,val)

% Resize axes
hax=get(h,'Parent');
xrange=get(hax,'XLim');

% Plot line y=0;
line([xrange(1),xrange(2)],[0,0],'Color','k','LineStyle',':');

% plot fold change line
hline(1)=line([xrange(1),xrange(2)], val*[1,1],'Color','k','LineStyle','--');
hline(2)=line([xrange(1),xrange(2)], [-1,-1]*val,'Color','k','LineStyle','--');


function clickonplot(varargin)

% Highlights selected element and displays label

[hObject,hFig]=gcbo;

% Clean up any old labels
% hFig = localCleanUpLabel;
udata=get(hObject,'UserData');
if ishandle(udata)
    hObject=udata;
end

xvals=get(hObject,'XData');
yvals=get(hObject,'YData');
hAxis=get(hObject,'parent');
point=get(hAxis,'CurrentPoint');
udata=get(hObject,'UserData');
set(hFig,'Doublebuffer','on');

% Find the closest point
[v,index]=min((((xvals-point(1,1)).^2)./(point(1,1)^2))+...
              ((yvals-point(1,2)).^2)./(point(1,2)^2));

% Highlight the point and set the title
if ~isempty(index)
    hHighlight=line(xvals(index),yvals(index),'Color','green','Marker','d',...
                                              'Tag','MAHighlight');
    
    % Get the value and label of the current point
    cpAct=get(hAxis,'CurrentPoint');
    % Create a new text object -- start with it invisible
    displayed={udata{1}{index};...
               ['A = ',num2str(udata{2}(index))];...
               ['M = ',num2str(udata{3}(index))]};
    htext=text(cpAct(1,1),cpAct(1,2),displayed,'Visible','off','Interpreter','none');

    % Give it an off white background, black text and grey border
    set(htext,'BackgroundColor',[1 1 0.933333],'Color',[0 0 0],...
        'EdgeColor',[0.8 0.8 0.8],'Tag','MADataTip');
    % Show the text
    set(htext,'Visible','on')
    set(hFig,'WindowButtonUpFcn',@localCleanUpLabel);
end


function hFig = localCleanUpLabel(varargin)

% Function to remove label from image

% Get the handles to the figure, image and axis
hFig=gcbf;

% Delete the old label if it exists
oldLabel=findobj(hFig,'Tag','MADataTip');
if ~isempty(oldLabel)
    delete(oldLabel);
end

% Delete the old label if it exists
oldHighlight=findobj(hFig,'Tag','MAHighlight');
if ~isempty(oldHighlight)
    delete(oldHighlight);
end



