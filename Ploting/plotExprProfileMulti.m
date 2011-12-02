function hp = plotExprProfileMulti(x,y,varargin)

% Supposing that figure handle is supplied here by the main program

% Defaults
labels='';
titre='Expression Profile';
leg=false;
multicol=false;
xc=x(:);
condnames=cellstr(num2str(xc));
cntrd=false;

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'labels','title','names','legend','multicolor','centroid'};
    for i=1:2:length(varargin)-1
        parName=varargin{i};
        parVal=varargin{i+1};
        j=strmatch(lower(parName),okargs);
        if isempty(j)
            error('Unknown parameter name: %s.',parName);
        elseif length(j)>1
            error('Ambiguous parameter name: %s.',parName);
        else
            switch(j)
                case 1 % Labels
                    if ~iscellstr(parVal)
                        error('The %s parameter value must be a cell array of strings',parName)
                    else
                        labels=parVal;
                    end
                case 2 % Title
                    if ~ischar(parVal)
                        error('The %s parameter value must be a string',parName)
                    else
                        titre=parVal;
                    end
                case 3 % Condition names
                    if ~ischar(parVal) && ~iscellstr(parVal)
                        error('The %s parameter value must be a string or cell array of strings',parName)
                    else
                        condnames=parVal;
                    end
                case 4 % Legend
                    parVal=destf(parVal);
                    if ~isempty(parVal)
                        leg=parVal;
                    else
                        error('The %s parameter value must be a correct on or off specifier',parName)
                    end
                case 5 % Different color for each gene
                    parVal=destf(parVal);
                    if ~isempty(parVal)
                        multicol=parVal;
                    else
                        error('The %s parameter value must be a correct on or off specifier',parName)
                    end
                case 6
                    parVal=destf(parVal);
                    if ~isempty(parVal)
                        cntrd=parVal;
                    else
                        error('The %s parameter value must be a correct on or off specifier',parName)
                    end
            end
        end
    end
end

xlims=[min(x),max(x)];

% Plot data...
if multicol
    h=plot(x,y,'.-');
else
    col=rand(1,3);
    h=plot(x,y,'.-','Color',col);
end
if cntrd % Calculate simple centroid
    centroid=mean(y);
    resid=std(y);
    if length(centroid)==1
        centroid=centroid*ones(size(y));
        resid=resid*ones(size(y));
    end
    hold on
    errorbar(x,centroid,resid,'Color','k','LineWidth',2)
end
set(gca,'FontSize',6,'FontWeight','bold','XLim',xlims,'XTick',x)
if ~isempty(titre)
    titre=strrep(titre,'_','-');
    title(titre,'FontSize',7,'FontWeight','bold')
end
ylims=get(gca,'YLim');
text(xlims(1)+0.2,ylims(2)-0.2,[num2str(size(y,1)),' genes'],...
     'EdgeColor','black',...
     'VerticalAlignment','top',...
     'FontSize',7,...
     'FontWeight','bold',...
     'Parent',gca)
% a=annotation(gcf,'textbox',[0.01,0.99,0.01,0.01],...
%              'String',[num2str(size(y,1)),' genes'],...
%              'EdgeColor','black',...
%              'FitHeightToText','on',...
%              'VerticalAlignment','top',...
%              'FontSize',6,...
%              'FontWeight','bold',...
%              'Units','normalized');
grid on

if ~isempty(condnames)
    set(gca,'XTickLabel',condnames)
end
if leg && ~isempty(labels)
    legend(h,labels,'FontSize',6)
end

% Set up a buttondown function
hax=zeros(length(h),1);
for i=1:length(h)
    hax(i)=get(h(i),'Parent');
    set(hax(i),'UserData',h(i),'ButtonDownFcn',@clickonplot);
    if ~isempty(labels)
        lab=repmat(labels(i),[1 length(condnames)]);
    else
        lab=[];
    end
    set(h(i),'UserData',{lab,condnames,y(i,:)},'ButtonDownFcn',@clickonplot);
end
    
if nargout>0
    hp=h;
end


function clickonplot(varargin)

% Highlights selected element and displays label

[hObject,hFig]=gcbo;
udata=get(hObject,'UserData');
if ishandle(udata)
    hObject=udata;
end

xvals=get(hObject,'XData');
yvals=get(hObject,'YData');
hAxis=get(hObject,'Parent');
point=get(hAxis,'CurrentPoint');
udata=get(hObject,'UserData');
set(hFig,'Doublebuffer','on');

% Find the closest point
[v,index]=min((((xvals-point(1,1)).^2)./(point(1,1)^2))+...
              ((yvals-point(1,2)).^2)./(point(1,2)^2));

% Highlight the point and set the title
if ~isempty(index)
    hHighlight=line(xvals(index),yvals(index),'Color','red','Marker','d',...
                                              'Tag','MAHighlight');
    
    % Get the value and label of the current point
    cpAct=get(hAxis,'CurrentPoint');
    
    % Create a new text object -- start with it invisible
    if ~isempty(udata{1})
        displayed={udata{1}{index};...
                   ['Array(s) : ',char(udata{2}(index))];...
                   ['Ratio : ',num2str(udata{3}(index))]};
    else
        displayed={['Array(s) : ',udata{2}(index)];...
                   ['Ratio : ',num2str(udata{3}(index))]};
    end
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
