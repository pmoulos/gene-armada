function hp = plotMA(inten,lograt,logratsmth,varargin)

% Count is a variable to help when this function is called multiple times from ARMADA.
% It helps naming handle objects and distinguishing them with the find function

% Set defaults
titre='MA Plot';
discurve=false;
disfcline=false;
fc=[];
labels='';
count=1;

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)==0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'title','displaynormcurve','displayfcline','foldchange','labels','count'};
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
                case 1 % Title
                    if ~ischar(parVal) && ~iscellstr(parVal)
                        error('The %s parameter value must be a string or cell array of strings',parName)
                    else
                        titre=parVal;
                    end
                case 2 % Display normalization points
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        discurve=parVal;
                    end
                case 3 % Display fold change cutoff line
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        disfcline=parVal;
                    end
                case 4 % Fold change cutoff
                    if isscalar(parVal) 
                        if parVal<=0
                            error('The %s parameter value must be a positive value if scalar',parName)
                        end
                    else
                        if length(parVal)~=2
                            error('The %s parameter values must be positive of length 2 if vector',parName)
                        end
                    end
                    fc=parVal;
                case 5 % Labels
                    if ~iscellstr(parVal)
                        error('The %s parameter value must be a cell array of strings',parName)
                    else
                        labels=parVal;
                    end
                case 6 % Figure count
                    if ~isscalar(parVal) || parVal<0
                        error('The %s parameter value must be a positive scalar',parName)
                    else
                        count=parVal;
                    end
            end
        end
    end
end
                         
logfc=log2(fc);
goodvals=~isnan(lograt);
inten=inten(goodvals);
lograt=lograt(goodvals);
logratsmth=logratsmth(goodvals);
if ~isempty(labels)
    labels=labels(goodvals);
end

if isscalar(fc)
    logfc=[-logfc logfc];
end

% Plot MA data
figure;
h=plot(inten,lograt,'.b');

% Display FC line (if wanted)
if disfcline
    hline=fclines(h,logfc);
end

% Display normalization points (if wanted)
if discurve
    hold on
    hcurve=plot(inten,logratsmth,'.y');
end

% Label and title plot
xlabel('Intensity (A)','FontWeight','bold');
ylabel('Ratio (M)','FontWeight','bold');
% Replace '_' character
titre=strrep(titre,'_','-');
title(titre,'FontSize',11,'FontWeight','bold')
grid on

% Create legend
hall=h;
if ~discurve && ~disfcline
    strleg={'MA data'};
elseif discurve && ~disfcline
    hall=[hall;hcurve];
    strleg={'MA data','Normalization points'};
elseif discurve && disfcline
    hall=[hall;hcurve;hline(1)];
    strleg={'MA data','Normalization points','Fold change cutoff'};
elseif ~discurve && disfcline
    hall=[hall;hline(1)];
    strleg={'MA data','Fold change cutoff'};
end
legend(hall,strleg)

% If labels exist, set up a buttondown function
if ~isempty(labels)
    
    hax=get(h,'Parent');
    set(hax,'UserData',[h,count],...
            'Tag',['allaxisbefore',num2str(count)],...
            'ButtonDownFcn',@clickonplot);
    set(h,'UserData',{labels,inten,lograt,count},...
          'Tag',['alldatabefore',num2str(count)],...
          'ButtonDownFcn',@clickonplot);
    
    % Create the context menu for exporting
    exportmenu=uicontextmenu('Tag',['rightMenuBefore',num2str(count)]);
    item1=uimenu(exportmenu,'Label','Select Data',...
                            'Callback',@enterSelectState,...
                            'Tag',['selectDataBefore',num2str(count)],...
                            'UserData',count);
    item2=uimenu(exportmenu,'Label','Export Selected',...
                            'Callback',@exportSelected,...
                            'Tag',['exportSelectedBefore',num2str(count)],...
                            'Enable','off');
    item3=uimenu(exportmenu,'Label','Export All',...
                            'Callback',@exportAll,...
                            'Tag',['exportAllBefore',num2str(count)],...
                            'UserData',count);
    set(hax,'UIContextMenu',exportmenu)
    set(h,'UIContextMenu',exportmenu)

end

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
hline(1)=line([xrange(1),xrange(2)], val(2)*[1,1],'Color','k','LineStyle','--');
hline(2)=line([xrange(1),xrange(2)], [1,1]*val(1),'Color','k','LineStyle','--');


function clickonplot(varargin)

% Highlights selected element and displays label

[hObject,hFig]=gcbo;

% Clean up any old labels
% hFig = localCleanUpLabel;
udata=get(hObject,'UserData');
if ishandle(udata(1))
    hObject=udata(1);
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


function enterSelectState(varargin)

hmenu=gcbo;
count=get(hmenu,'UserData');
hf=localCleanUpLabel;

if strcmp(get(hmenu,'Checked'),'off')
    
    % Indicate data selection enabled
    set(hmenu,'Checked','on');
    % Change the cursor
    set(hf,'Pointer','crosshair')
    % De-activate clickonplot
    hallaxisbefore=findobj('Tag',['allaxisbefore',num2str(count)]);
    halldatabefore=findobj('Tag',['alldatabefore',num2str(count)]);
    if ishandle(hallaxisbefore)
        set(hallaxisbefore,'ButtonDownFcn',@selectData)
    end
    if ishandle(halldatabefore)
        set(halldatabefore,'ButtonDownFcn',@selectData)
    end

else
    
    % Delete previous selection boxes and points (if any)
    prevbox=findobj('Tag',['selectedRegionBefore',num2str(count)]);
    if ishandle(prevbox)
        delete(prevbox);
    end
    prevpts=findobj('Tag',['selectedPointsBefore',num2str(count)]);
    if ishandle(prevpts)
        delete(prevpts);
    end
    % Indicate data selection disabled
    set(hmenu,'Checked','off');
    % Change the cursor
    set(hf,'Pointer','arrow')
    % Activate clickonplot
    hallaxisbefore=findobj('Tag',['allaxisbefore',num2str(count)]);
    halldatabefore=findobj('Tag',['alldatabefore',num2str(count)]);
    if ishandle(hallaxisbefore)
        set(hallaxisbefore,'ButtonDownFcn',@clickonplot)
    end
    if ishandle(halldatabefore)
        set(halldatabefore,'ButtonDownFcn',@clickonplot)
    end
    % Disable export selected data
    item2=findobj('Tag',['exportSelectedBefore',num2str(count)]);
    set(item2,'Enable','off')
    
end


function selectData(varargin)

hobj=gcbo;
udata=get(hobj,'UserData');
if iscell(udata)
    count=udata{end};
else
    count=udata(end);
end

% Delete previous selection boxes and points (if any)
prevbox=findobj('Tag',['selectedRegionBefore',num2str(count)]);
if ishandle(prevbox)
    delete(prevbox);
end
prevpts=findobj('Tag',['selectedPointsBefore',num2str(count)]);
if ishandle(prevpts)
    delete(prevpts);
end

% Get some useful data
hallaxisbefore=findobj('Tag',['allaxisbefore',num2str(count)]);
halldatabefore=findobj('Tag',['alldatabefore',num2str(count)]);
xvals=get(halldatabefore,'XData');
yvals=get(halldatabefore,'YData');
udata=get(halldatabefore,'UserData');

% Draw the rubberband selection box and get the starting and ending points
point1=get(gca,'CurrentPoint');
rbbox;
point2=get(gca,'CurrentPoint');

% Extract 2-D coordinates
point1=point1(1,1:2);
point2=point2(1,1:2);

% Create the containing rectangle
p1=min(point1,point2);
offset=abs(point1-point2);
x=[p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y=[p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];

% Check if we are inside axes limits and ignore selection outside of axes
xlims=get(hallaxisbefore,'XLim');
ylims=get(hallaxisbefore,'YLim');
x(x<xlims(1))=xlims(1);
x(x>xlims(2))=xlims(2);
y(y<ylims(1))=ylims(1);
y(y>ylims(2))=ylims(2);

% Draw it
hold on
axis manual
selrect=plot(x,y,'m-','Tag',['selectedRegionBefore',num2str(count)]);
set(selrect,'LineWidth',3)

% Set our context menu for the box drawed
conmenu=findobj('Tag',['rightMenuBefore',num2str(count)]);
set(selrect,'UIContextMenu',conmenu);

% Find points inside box
downleft=min(point1,point2);
upright=max(point1,point2);
xinind=xvals>=downleft(1) & xvals<=upright(1);
yinind=yvals>=downleft(2) & yvals<=upright(2);
allin=xinind & yinind;
xinside=xvals(allin);
yinside=yvals(allin);

% If points not empty activate export selected
item2=findobj('Tag',['exportSelectedBefore',num2str(count)]);
if ~isempty(xinside)
    set(item2,'Enable','on')
else
    set(item2,'Enable','off')
end

% Color data by plotting again... the new handle will be destroyed after this action
selpts=plot(xinside,yinside,'.m','Tag',['selectedPointsBefore',num2str(count)]);
% ...and find the corresponding labels too
if ~isempty(udata)
    labels=udata{1};
    newlabels=labels(allin);
    set(selpts,'UserData',newlabels)
end

% Store the selected points and their labels into figures userdata
hfig=gcbf;
set(hfig,'UserData',selpts)


function exportSelected(varargin)

selpts=get(gcbf,'UserData');
if ~ishandle(selpts)
    uiwait(errordlg('No points selected!','Error'));
else
    MData=get(selpts,'XData');
    AData=get(selpts,'YData');
    labels=get(selpts,'UserData');
    
    [filename,pathname]=uiputfile('*.txt','Export MA data');
    if filename==0
        return
    else
        fid=fopen(strcat(pathname,filename),'wt');
        fprintf(fid,'%s\t%s\t%s\n','GeneID','Log Ratio (M)','Intensity (A)');
        for i=1:length(MData)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labels{i},MData(i),AData(i));
        end
        fprintf('\n')
        fclose(fid);
    end
end
    

function exportAll(varargin)

count=get(gcbo,'UserData');
alldatabefore=findobj('Tag',['alldatabefore',num2str(count)]);
MData=get(alldatabefore,'XData');
AData=get(alldatabefore,'YData');
udata=get(alldatabefore,'UserData');
labels=udata{1};

[filename,pathname]=uiputfile('*.txt','Export MA data');
if filename==0
    return
else
    fid=fopen(strcat(pathname,filename),'wt');
    fprintf(fid,'%s\t%s\t%s\n','GeneID','Log Ratio (M)','Intensity (A)');
    for i=1:length(MData)
        fprintf(fid,'%s\t%5.5f\t%5.5f\n',labels{i},MData(i),AData(i));
    end
    fprintf('\n')
    fclose(fid);
end
