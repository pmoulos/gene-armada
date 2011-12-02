function hp = plotGeneric(x,y,varargin)

% Count is a variable to help when this function is called multiple times from ARMADA.
% It helps naming handle objects and distinguishing them with the find function

% Set defaults
titre='Generic Plot';
xtitre='X';
ytitre='Y';
discutline=false;
logscale=false;
discorr=false;
lcut=[];
labels='';
count=1;

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'title','xtitle','ytitle','displaycutline','cutline','logscale','showcorrelation',...
            'labels','count'};
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
                case 2 % X-axis title
                    if ~ischar(parVal) && ~iscellstr(parVal)
                        error('The %s parameter value must be a string or cell array of strings',parName)
                    else
                        xtitre=parVal;
                    end
                case 3 % Y-axis title
                    if ~ischar(parVal) && ~iscellstr(parVal)
                        error('The %s parameter value must be a string or cell array of strings',parName)
                    else
                        ytitre=parVal;
                    end
                case 4 % Display cutoff line
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        discutline=parVal;
                    end
                case 5 % Cutoff line level
                    if isscalar(parVal) 
                        if parVal<=0
                            error('The %s parameter value must be a positive value if scalar',parName)
                        end
                    else
                        if length(parVal)~=2
                            error('The %s parameter values must be positive of length 2 if vector',parName)
                        end
                    end
                    lcut=parVal;
                case 6 % Display log2 of cutoff line
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        logscale=parVal;
                    end
                case 7 % Display correlation coefficient
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        discorr=parVal;
                    end    
                case 8 % Labels
                    if ~iscellstr(parVal)
                        error('The %s parameter value must be a cell array of strings',parName)
                    else
                        labels=parVal;
                    end
                case 9 % Figure count
                    if ~isscalar(parVal) || parVal<0
                        error('The %s parameter value must be a positive scalar',parName)
                    else
                        count=parVal;
                    end
            end
        end
    end
end

x=x(:);
y=y(:);

if logscale
    x=log2(x);
    y=log2(y);
    lcut=log2(lcut);
end
% goodvals=~isnan(y);
% x=x(goodvals);
% y=y(goodvals);
% if ~isempty(labels)
%     labels=labels(goodvals);
% end

if isscalar(lcut)
    lcut=[-lcut lcut];
end

% Possible problems with Affymetrix
if length(x)~=length(labels)
    labels='';
end

% Plot XY data
figure;
% Display cutoff line (if wanted) and color data
if discutline
    % Set colors
    low=[244/255 168/255 23/255];
    high=[76/255 80/255 169/255];
    med=[170/255 170/255 170/255];
    % Find genes that meet cut lines criteria and color them (by redrawing them so as
    % not having to implement again the label stuff)
    medx=x(y<x+lcut(2) & y>x+lcut(1));
    medy=y(y<x+lcut(2) & y>x+lcut(1));
    highx=x(y>=x+lcut(2));
    highy=y(y>=x+lcut(2));
    lowx=x(y<=x+lcut(1));
    lowy=y(y<=x+lcut(1));
    h=plot(medx,medy,'Color',med,'Marker','.','LineStyle','none');
    hold on
    if ~isempty(highx)
        hhigh=plot(highx,highy,'Color',high,'Marker','.','LineStyle','none');
    else
        hhigh=[];
    end
    if ~isempty(lowx)
        hlow=plot(lowx,lowy,'Color',low,'Marker','.','LineStyle','none');
    else
        hlow=[];
    end
    % Display fold line
    hline=lcutlines(lcut);
else
    h=plot(x,y,'Color',[170/255 170/255 170/255],'Marker','.','LineStyle','none');
    hhigh=[];
    hlow=[];
end

% Label and title plot
xlabel(xtitre,'FontWeight','bold','Tag',['xaxlabel',num2str(count)]);
ylabel(ytitre,'FontWeight','bold','Tag',['yaxlabel',num2str(count)]);
title(titre,'FontSize',11,'FontWeight','bold')
grid on

% Create legend
hall=h;
if ~discutline
    strleg={'Data'};
else
    if ~isempty(hhigh) && ~isempty(hlow)
        hall=[hall;hhigh;hlow;hline(1)];
        strleg={'Data','Above threshold','Below threshold','Threshold'};
    elseif ~isempty(hhigh) && isempty(hlow)
        hall=[hall;hhigh;hline(1)];
        strleg={'Data','Above threshold','Below threshold'};
    elseif isempty(hhigh) && ~isempty(hlow)
        hall=[hall;hlow;hline(1)];
        strleg={'Data','Below threshold','Threshold'};
    elseif isempty(hhigh) && isempty(hlow)
        hall=[hall;hline(1)];
        strleg={'Data','Threshold'};
    end
end
legend(hall,strleg)

if discorr
    bad=isnan(x) | isnan(y);
    co=corr(x(~bad),y(~bad));
    text('Position',[0.7 0.05],...
         'Units','normalized',...
         'String',['Correlation: ',num2str(co)],...
         'FontWeight','bold')
end

% If labels exist, set up a buttondown function
if ~isempty(labels)
    if ~discutline
        hax=get(h,'Parent');
        set(hax,'UserData',[h,count],...
                'Tag',['allaxisgeneric',num2str(count)],...
                'ButtonDownFcn',@clickonplot);
        set(h,'UserData',{labels,x,y,count},...
              'Tag',['meddatageneric',num2str(count)],...
              'ButtonDownFcn',@clickonplot);
    else
        % They are all on the same axis
        hax=get(h,'Parent');
        set(hax,'UserData',[h,hhigh,hlow,count],...
                'Tag',['allaxisgeneric',num2str(count)],...
                'ButtonDownFcn',@clickonplot);
        udatamed={labels(y<x+lcut(2) & y>x+lcut(1)),...
                   x(y<x+lcut(2) & y>x+lcut(1)),...
                   y(y<x+lcut(2) & y>x+lcut(1)),...
                   count};
        set(h,'UserData',udatamed,...
              'Tag',['meddatageneric',num2str(count)],...
              'ButtonDownFcn',@clickonplot);
        udatahigh={labels(y>=x+lcut(2)),...
                  x(y>=x+lcut(2)),...
                  y(y>=x+lcut(2)),...
                  count};
        set(hhigh,'UserData',udatahigh,...
                  'Tag',['highdatageneric',num2str(count)],...
                  'ButtonDownFcn',@clickonplot);
        udatalow={labels(y<=x+lcut(1)),...
                    x(y<=x+lcut(1)),...
                    y(y<=x+lcut(1)),...
                    count};
        set(hlow,'UserData',udatalow,...
                 'Tag',['lowdatageneric',num2str(count)],...
                 'ButtonDownFcn',@clickonplot);
    end
    
    % Create the context menu for exporting
    exportmenu=uicontextmenu('Tag',['rightMenuGeneric',num2str(count)]);
    item1=uimenu(exportmenu,'Label','Select Data',...
                            'Callback',@enterSelectState,...
                            'Tag',['selectDataGeneric',num2str(count)],...
                            'UserData',count);
    item2=uimenu(exportmenu,'Label','Export Selected',...
                            'Callback',@exportSelected,...
                            'Tag',['exportSelectedGeneric',num2str(count)],...
                            'Enable','off',...
                            'UserData',count);
    item3=uimenu(exportmenu,'Label','Export high',...
                            'Callback',@exportUp,...
                            'Tag',['exportUpGeneric',num2str(count)],...
                            'Enable','on',...
                            'UserData',count);
    item4=uimenu(exportmenu,'Label','Export low',...
                            'Callback',@exportDown,...
                            'Tag',['exportDownGeneric',num2str(count)],...
                            'Enable','on',...
                            'UserData',count);
    item5=uimenu(exportmenu,'Label','Export high and low',...
                            'Callback',@exportUpDown,...
                            'Tag',['exportUpDownGeneric',num2str(count)],...
                            'Enable','on',...
                            'UserData',count);
    item6=uimenu(exportmenu,'Label','Export middle points',...
                            'Callback',@exportNull,...
                            'Tag',['exportNull',num2str(count)],...
                            'Enable','on',...
                            'UserData',count);
    item7=uimenu(exportmenu,'Label','Export All',...
                            'Callback',@exportAll,...
                            'Tag',['exportAll',num2str(count)],...
                            'UserData',count);
    set(hax,'UIContextMenu',exportmenu)
    set(h,'UIContextMenu',exportmenu)
    if ~isempty(hhigh)
        set(hhigh,'UIContextMenu',exportmenu)
    end
    if ~isempty(hlow)
        set(hlow,'UIContextMenu',exportmenu)
    end
    if discutline
        if ~isempty(hhigh) && ishandle(hhigh)
            set(hhigh,'UIContextMenu',exportmenu)
        else
            set(item3,'Enable','off')
        end
        if ~isempty(hlow) && ishandle(hlow)
            set(hlow,'UIContextMenu',exportmenu)
        else
            set(item4,'Enable','off')
        end
        if isempty(hhigh) && isempty(hlow)
            set(item3,'Enable','off')
            set(item4,'Enable','off')
            set(item5,'Enable','off')
        end
    else
        set(item3,'Enable','off')
        set(item4,'Enable','off')
        set(item5,'Enable','off')
    end

end

if nargout>0
    hp=h;
end

           
function hline = lcutlines(val)

% function hline = lcutlines(h,val)

% Get axes data
% hax=get(h,'Parent');
xrange=get(gca,'XLim');
yrange=get(gca,'YLim');

a=min(xrange(1),yrange(1));
b=max(xrange(2),yrange(2));

x=linspace(a,b,1000);
y=x;
yup=x+val(2);
ydown=x+val(1);

downleft=[xrange(1),yrange(1)];
upright=[xrange(2),yrange(2)];

xinind=x>=downleft(1) & x<=upright(1);
yinind=y>=downleft(2) & y<=upright(2);
allin=xinind & yinind;

yinindup=yup>=downleft(2) & yup <=upright(2);
allinup=xinind & yinindup;

yininddown=ydown>=downleft(2) & ydown <=upright(2);
allindown=xinind & yininddown;

plot(gca,x(allin),y(allin),'k:');
hline(1)=plot(gca,x(allinup),yup(allinup),'k--');
hline(2)=plot(gca,x(allindown),ydown(allindown),'k--');


function clickonplot(varargin)

% Highlights selected element and displays label

[hObject,hFig]=gcbo;
udata=get(hObject,'UserData');
if ishandle(udata(1))
    hObject=udata(1);
end
hAxis=get(hObject,'Parent');

if iscell(hAxis) % Multiple data series, we have to adjust multiple items to one
    hAxis=hAxis{1}; % For the case of multiple dataseries (all on same axis)
    xvals=cell2mat(get(hObject,'XData')');
    yvals=cell2mat(get(hObject,'YData')');
    udatatemp=get(hObject,'UserData');
    labs=cell(length(udatatemp),1);
    ints=cell(length(udatatemp),1);
    logs=cell(length(udatatemp),1);
    for i=1:length(udatatemp)
        labs{i}=cell2mat(udatatemp{i}{1});
        ints{i}=udatatemp{i}{2};
        logs{i}=udatatemp{i}{3};
    end
    labs=cellstr(cell2mat(labs));
    ints=cell2mat(ints);
    logs=cell2mat(logs);
    udata={labs,ints,logs};
else % Just one data series... all ok
    xvals=get(hObject,'XData');
    yvals=get(hObject,'YData');
    udata=get(hObject,'UserData');
end

point=get(hAxis,'CurrentPoint');
set(hFig,'Doublebuffer','on');

% Find the closest point
[v,index]=min((((xvals-point(1,1)).^2)./(point(1,1)^2))+...
              ((yvals-point(1,2)).^2)./(point(1,2)^2));

% Highlight the point and set the title
if ~isempty(index)
    hHighlight=line(xvals(index),yvals(index),'Color','magenta','Marker','d',...
                                              'Tag','XYHighlight');
    
    % Get the value and label of the current point
    cpAct=get(hAxis,'CurrentPoint');

    % Create a new text object -- start with it invisible
    displayed={udata{1}{index};...
               ['X = ',num2str(udata{2}(index))];...
               ['Y = ',num2str(udata{3}(index))]};
    htext=text(cpAct(1,1),cpAct(1,2),displayed,'Visible','off','Interpreter','none');

    % Give it an off white background, black text and grey border
    set(htext,'BackgroundColor',[1 1 0.933333],'Color',[0 0 0],...
        'EdgeColor',[0.8 0.8 0.8],'Tag','XYDataTip');
    % Show the text
    set(htext,'Visible','on')
    set(hFig,'WindowButtonUpFcn',@localCleanUpLabel);
end


function hFig = localCleanUpLabel(varargin)

% Function to remove label from image

% Get the handles to the figure, image and axis
hFig=gcbf;

% Delete the old label if it exists
oldLabel=findobj(hFig,'Tag','XYDataTip');
if ~isempty(oldLabel)
    delete(oldLabel);
end

% Delete the old label if it exists
oldHighlight=findobj(hFig,'Tag','XYHighlight');
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
    hallaxisgeneric=findobj('Tag',['allaxisgeneric',num2str(count)]);
    hmeddata=findobj('Tag',['meddatageneric',num2str(count)]);
    hhighdata=findobj('Tag',['highdatageneric',num2str(count)]);
    hlowdata=findobj('Tag',['lowdatageneric',num2str(count)]);
    if ~isempty(hallaxisgeneric) && ishandle(hallaxisgeneric)
        set(hallaxisgeneric,'ButtonDownFcn',@selectData)
    end
    if ~isempty(hmeddata) && ishandle(hmeddata)
        set(hmeddata,'ButtonDownFcn',@selectData)
    end
    if ~isempty(hhighdata) && ishandle(hhighdata)
        set(hhighdata,'ButtonDownFcn',@selectData)
    end
    if ~isempty(hlowdata) && ishandle(hlowdata)
        set(hlowdata,'ButtonDownFcn',@selectData)
    end

else
    
    % Delete previous selection boxes and points (if any)
    prevbox=findobj('Tag',['selectedRegionGeneric',num2str(count)]);
    if ishandle(prevbox)
        delete(prevbox);
    end
    prevpts=findobj('Tag',['selectedPoints',num2str(count)]);
    if ishandle(prevpts)
        delete(prevpts);
    end
    % Indicate data selection disabled
    set(hmenu,'Checked','off');
    % Change the cursor
    set(hf,'Pointer','arrow')
    % Activate clickonplot
    hallaxisgeneric=findobj('Tag',['allaxisgeneric',num2str(count)]);
    hmeddata=findobj('Tag',['meddatageneric',num2str(count)]);
    hhighdata=findobj('Tag',['highdatageneric',num2str(count)]);
    hlowdata=findobj('Tag',['lowdatageneric',num2str(count)]);
    if ~isempty(hallaxisgeneric) && ishandle(hallaxisgeneric)
        set(hallaxisgeneric,'ButtonDownFcn',@clickonplot)
    end
    if ~isempty(hmeddata) && ishandle(hmeddata)
        set(hmeddata,'ButtonDownFcn',@clickonplot)
    end
    if ~isempty(hhighdata) && ishandle(hhighdata)
        set(hhighdata,'ButtonDownFcn',@clickonplot)
    end
    if ~isempty(hlowdata) && ishandle(hlowdata)
        set(hlowdata,'ButtonDownFcn',@clickonplot)
    end
    % Disable export selected data
    item2=findobj('Tag',['exportSelectedGeneric',num2str(count)]);
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
prevbox=findobj('Tag',['selectedRegionGeneric',num2str(count)]);
if ishandle(prevbox)
    delete(prevbox);
end
prevpts=findobj('Tag',['selectedPoints',num2str(count)]);
if ishandle(prevpts)
    delete(prevpts);
end

% Get some useful data
hallaxisgeneric=findobj('Tag',['allaxisgeneric',num2str(count)]);
hObject=get(hallaxisgeneric,'UserData');
if length(hObject)==2 % Then we do not plot fold lines, only one data series
    hObject=hObject(1);
    xvals=get(hObject,'XData');
    yvals=get(hObject,'YData');
    udata=get(hObject,'UserData');
else % More than one data series, we have to adjust multiple items
    hObject=hObject(1:end-1);
    xvals=cell2mat(get(hObject,'XData')');
    yvals=cell2mat(get(hObject,'YData')');
    udatatemp=get(hObject,'UserData');
    labs=cell(length(udatatemp),1);
    xs=cell(length(udatatemp),1);
    ys=cell(length(udatatemp),1);
    for i=1:length(udatatemp)
        labs{i}=char(udatatemp{i}{1});
        xs{i}=udatatemp{i}{2};
        ys{i}=udatatemp{i}{3};
    end
    labs=cellstr(char(labs));
    xs=cell2mat(xs);
    ys=cell2mat(ys);
    udata={labs,xs,ys};
end

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
xlims=get(hallaxisgeneric,'XLim');
ylims=get(hallaxisgeneric,'YLim');
x(x<xlims(1))=xlims(1);
x(x>xlims(2))=xlims(2);
y(y<ylims(1))=ylims(1);
y(y>ylims(2))=ylims(2);

% Draw it
hold on
axis manual
selrect=plot(x,y,'m-','Tag',['selectedRegionGeneric',num2str(count)]);
set(selrect,'LineWidth',3)

% Set our context menu for the box drawed
conmenu=findobj('Tag',['rightMenuGeneric',num2str(count)]);
set(selrect,'UIContextMenu',conmenu);

% Find points inside box
downleft=min(point1,point2);
upright=max(point1,point2);
xinind=xvals>=downleft(1) & xvals <=upright(1);
yinind=yvals>=downleft(2) & yvals <=upright(2);
allin=xinind & yinind;
xinside=xvals(allin);
yinside=yvals(allin);

% If points not empty activate export selected
item2=findobj('Tag',['exportSelectedGeneric',num2str(count)]);
if ~isempty(xinside)
    set(item2,'Enable','on')
else
    set(item2,'Enable','off')
end

% Color data by plotting again... the new handle will be destroyed after this action
selpts=plot(xinside,yinside,'.m','Tag',['selectedPoints',num2str(count)]);
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

count=get(gcbo,'UserData');
selpts=get(gcbf,'UserData');
if ~ishandle(selpts)
    uiwait(errordlg('No points selected!','Error'));
else
    XData=get(selpts,'XData');
    YData=get(selpts,'YData');
    labels=get(selpts,'UserData');
    
    [filename,pathname]=uiputfile('*.txt','Export data');
    if filename==0
        return
    else
        hxax=findall(gcf,'Tag',['xaxlabel',num2str(count)]);
        hyax=findall(gcf,'Tag',['yaxlabel',num2str(count)]);
        xname=get(hxax,'String');
        yname=get(hyax,'String');
        fid=fopen(strcat(pathname,filename),'wt');
        fprintf(fid,'%s\t%s\t%s\n','GeneID',xname,yname);
        for i=1:length(XData)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labels{i},XData(i),YData(i));
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportUp(varargin)

count=get(gcbo,'UserData');
hup=findobj('Tag',['highdatageneric',num2str(count)]);
if ~ishandle(hup) % Unlikely to happen though. It is controled from the main function
    uiwait(errordlg('No up regulated genes found!','Error'));
else
    udata=get(hup,'UserData');
    XData=get(hup,'XData');
    YData=get(hup,'YData');
    labels=udata{1};

    [filename,pathname]=uiputfile('*.txt','Export data');
    if filename==0
        return
    else
        hxax=findall(gcf,'Tag',['xaxlabel',num2str(count)]);
        hyax=findall(gcf,'Tag',['yaxlabel',num2str(count)]);
        xname=get(hxax,'String');
        yname=get(hyax,'String');
        fid=fopen(strcat(pathname,filename),'wt');
        fprintf(fid,'%s\t%s\t%s\n','GeneID',xname,yname);
        for i=1:length(MData)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labels{i},XData(i),YData(i));
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportDown(varargin)

count=get(gcbo,'UserData');
hdown=findobj('Tag',['lowdatageneric',num2str(count)]);
if ~ishandle(hdown) % Unlikely to happen though. It is controled from the main function
    uiwait(errordlg('No down regulated genes found!','Error'));
else
    udata=get(hdown,'UserData');
    XData=get(hdown,'XData');
    YData=get(hdown,'YData');
    labels=udata{1};

    [filename,pathname]=uiputfile('*.txt','Export data');
    if filename==0
        return
    else
        hxax=findall(gcf,'Tag',['xaxlabel',num2str(count)]);
        hyax=findall(gcf,'Tag',['yaxlabel',num2str(count)]);
        xname=get(hxax,'String');
        yname=get(hyax,'String');
        fid=fopen(strcat(pathname,filename),'wt');
        fprintf(fid,'%s\t%s\t%s\n','GeneID',xname,yname);
        for i=1:length(MData)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labels{i},XData(i),YData(i));
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportUpDown(varargin)

count=get(gcbo,'UserData');
hup=findobj('Tag',['highdatageneric',num2str(count)]);
hdown=findobj('Tag',['lowdatageneric',num2str(count)]);
% Unlikely to happen though. It is controled from the main function
if ~ishandle(hup) & ~ishandle(hdown)
    uiwait(errordlg('No regulated genes found!','Error'));
else
    if ishandle(hup)
        udataUp=get(hup,'UserData');
        XDataUp=get(hup,'XData');
        YDataUp=get(hup,'YData');
        labelsUp=udataUp{1};
        excolUp=repmat('HIGH',[length(XDataUp) 1]);
        excolUp=cellstr(excolUp);
    else
        XDataUp=[];
        YDataUp=[];
        labelsUp=[];
        excolUp=[];
    end
    if ishandle(hdown)
        udataDown=get(hdown,'UserData');
        XDataDown=get(hdown,'XData');
        YDataDown=get(hdown,'YData');
        labelsDown=udataDown{1};
        excolDown=repmat('LOW',[length(YDataDown) 1]);
        excolDown=cellstr(excolDown);
    else
        XDataDown=[];
        YDataDown=[];
        labelsDown=[];
        excolDown=[];
    end

    [filename,pathname]=uiputfile('*.txt','Export data');
    if filename==0
        return
    else
        hxax=findall(gcf,'Tag',['xaxlabel',num2str(count)]);
        hyax=findall(gcf,'Tag',['yaxlabel',num2str(count)]);
        xname=get(hxax,'String');
        yname=get(hyax,'String');
        fid=fopen(strcat(pathname,filename),'wt');
        fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID',xname,yname,'State');
        for i=1:length(MDataUp)
            fprintf(fid,'%s\t%5.5f\t%5.5f\t%s\n',labelsUp{i},XDataUp(i),YDataUp(i),excolUp{i});
        end
        for i=1:length(MDataDown)
            fprintf(fid,'%s\t%5.5f\t%5.5f\t%s\n',labelsDown{i},XDataDown(i),YDataDown(i),excolDown{i});
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportNull(varargin)

count=get(gcbo,'UserData');
hnull=findobj('Tag',['meddatageneric',num2str(count)]);
if ~ishandle(hnull) % Unlikely to happen though. It is controled from the main function
    uiwait(errordlg('No unregulated genes found!','Error'));
else
    udata=get(hnull,'UserData');
    XData=get(hnull,'XData');
    YData=get(hnull,'YData');
    labels=udata{1};

    [filename,pathname]=uiputfile('*.txt','Export data');
    if filename==0
        return
    else
        hxax=findall(gcf,'Tag',['xaxlabel',num2str(count)]);
        hyax=findall(gcf,'Tag',['yaxlabel',num2str(count)]);
        xname=get(hxax,'String');
        yname=get(hyax,'String');
        fid=fopen(strcat(pathname,filename),'wt');
        fprintf(fid,'%s\t%s\t%s\n','GeneID',xname,yname);
        for i=1:length(XData)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labels{i},XData(i),YData(i));
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportAll(varargin)

count=get(gcbo,'UserData');
hnull=findobj('Tag',['meddatageneric',num2str(count)]);
hup=findobj('Tag',['highdatageneric',num2str(count)]);
hdown=findobj('Tag',['lowdatageneric',num2str(count)]);

if ishandle(hup) | ishandle(hdown)
    regexist=true;
else
    regexist=false;
end

if ishandle(hup)
    udataUp=get(hup,'UserData');
    XDataUp=get(hup,'XData');
    YDataUp=get(hup,'YData');
    labelsUp=udataUp{1};
    if regexist
        excolUp=repmat('UP',[length(XDataUp) 1]);
        excolUp=cellstr(excolUp);
    end
else
    XDataUp=[];
    YDataUp=[];
    labelsUp=[];
    if regexist
        excolUp=[];
    end
end
if ishandle(hdown)
    udataDown=get(hdown,'UserData');
    XDataDown=get(hdown,'XData');
    YDataDown=get(hdown,'YData');
    labelsDown=udataDown{1};
    if regexist
        excolDown=repmat('DOWN',[length(XDataDown) 1]);
        excolDown=cellstr(excolDown);
    end
else
    XDataDown=[];
    YDataDown=[];
    labelsDown=[];
    if regexist
        excolDown=[];
    end
end
udataNull=get(hnull,'UserData');
XDataNull=get(hnull,'XData');
YDataNull=get(hnull,'YData');
labelsNull=udataNull{1};
if regexist
    excolNull=repmat('NULL',[length(XDataNull) 1]);
    excolNull=cellstr(excolNull);
end

[filename,pathname]=uiputfile('*.txt','Export data');
if filename==0
    return
else
    hxax=findall(gcf,'Tag',['xaxlabel',num2str(count)]);
    hyax=findall(gcf,'Tag',['yaxlabel',num2str(count)]);
    xname=get(hxax,'String');
    yname=get(hyax,'String');
    fid=fopen(strcat(pathname,filename),'wt');
    if regexist
        fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID',xname,yname,'Regulation');
        for i=1:length(XDataUp)
            fprintf(fid,'%s\t%5.5f\t%5.5f\t%s\n',labelsUp{i},XDataUp(i),YDataUp(i),excolUp{i});
        end
        for i=1:length(XDataDown)
            fprintf(fid,'%s\t%5.5f\t%5.5f\t%s\n',labelsDown{i},XDataDown(i),YDataDown(i),excolDown{i});
        end
        for i=1:length(XDataNull)
            fprintf(fid,'%s\t%5.5f\t%5.5f\t%s\n',labelsNull{i},XDataNull(i),YDataNull(i),excolNull{i});
        end
    else
        fprintf(fid,'%s\t%s\t%s\n','GeneID',xname,yname);
        for i=1:length(XDataUp)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labelsUp{i},XDataUp(i),YDataUp(i));
        end
        for i=1:length(XDataDown)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labelsDown{i},XDataDown(i),YDataDown(i));
        end
        for i=1:length(XDataNull)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labelsNull{i},XDataNull(i),YDataNull(i));
        end
    end
    fprintf('\n')
    fclose(fid);
end
