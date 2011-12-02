function [hpbefore,hpafter] = plotMABeforeAfter(inten,lograt,logratnorm,logratsmth,varargin)

% Count is a variable to help when this function is called multiple times from ARMADA.
% It helps naming handle objects and distinguishing them with the find function
                                            
% Set defaults
titre={'Un-normalized MA Plot','Normalized MA Plot'};
suptitre='';
discurve=false;
disfcline=false;
fc=[];
labels='';
count=1;

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'title','supertitle','displaynormcurve','displayfcline','foldchange','labels','count'};
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
                    if ~iscell(parVal)
                        error('The %s parameter value must be a string or cell array of strings',parName)
                    else
                        if length(parVal)==1
                            titre={parVal,''};
                        elseif length(parVal)==2
                            titre=parVal;
                        end
                    end
                case 2 % Supertitle
                    if ~ischar(parVal) && ~iscellstr(parVal)
                        error('The %s parameter value must be a string or cell array of strings',parName)
                    else
                        suptitre=parVal;
                    end
                case 3 % Display normalization points
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        discurve=parVal;
                    end
                case 4 % Display fold change cutoff line
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        disfcline=parVal;
                    end
                case 5 % Fold change cutoff
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
                case 6 % Labels
                    if ~iscellstr(parVal)
                        error('The %s parameter value must be a cell array of strings',parName)
                    else
                        labels=parVal;
                    end
                case 7 % Figure count
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
logratnorm=logratnorm(goodvals);
logratsmth=logratsmth(goodvals);
if ~isempty(labels)
    labels=labels(goodvals);
end

if isscalar(fc)
    logfc=[-logfc logfc];
end

% Plot all MA data
figure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot MA data before normalization
subplot(2,1,1);
hbefore=plot(inten,lograt,'.b');

% Display FC line (if wanted)
if disfcline
    hlinebefore=fclines(hbefore,logfc);
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
titre{1}=strrep(titre{1},'_','-');
title(titre{1},'FontSize',11,'FontWeight','bold')
grid on

% Create legend
hallbefore=hbefore;
if ~discurve && ~disfcline
    strlegbefore={'MA data'};
elseif discurve && ~disfcline
    hallbefore=[hallbefore;hcurve];
    strlegbefore={'MA data','Normalization points'};
elseif discurve && disfcline
    hallbefore=[hallbefore;hcurve;hlinebefore(1)];
    strlegbefore={'MA data','Normalization points','Fold change cutoff'};
elseif ~discurve && disfcline
    hallbefore=[hallbefore;hlinebefore(1)];
    strlegbefore={'MA data','Fold change cutoff'};
end
legend(hallbefore,strlegbefore)

% If labels exist, set up a buttondown function
if ~isempty(labels)
    haxupper=get(hbefore,'Parent');
    set(haxupper,'UserData',[hbefore,count],...
                 'ButtonDownFcn',@clickonplotBefore,...
                 'Tag',['allaxisBefore',num2str(count)]);
    set(hbefore,'UserData',{labels,inten,lograt,count},...
                'ButtonDownFcn',@clickonplotBefore,...
                'Tag',['alldataBefore',num2str(count)]);
    
    % Create the context menu for exporting
    exportmenuBefore=uicontextmenu('Tag',['rightMenuBeforeBoth',num2str(count)]);
    item1B=uimenu(exportmenuBefore,'Label','Select Data',...
                                   'Callback',@enterSelectStateBefore,...
                                   'Tag',['selectDataBeforeBoth',num2str(count)],...
                                   'UserData',count);
    item2B=uimenu(exportmenuBefore,'Label','Export Selected',...
                                   'Callback',@exportSelectedBefore,...
                                   'Tag',['exportSelectedBeforeBoth',num2str(count)],...
                                   'Enable','off');
    item3B=uimenu(exportmenuBefore,'Label','Export All',...
                                   'Callback',@exportAllBefore,...
                                   'Tag',['exportAllBeforeBoth',num2str(count)],...
                                   'UserData',count);
    set(haxupper,'UIContextMenu',exportmenuBefore)
    set(hbefore,'UIContextMenu',exportmenuBefore)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot MA data after normalization
subplot(2,1,2)

% Display FC line (if wanted) and color data
if disfcline
    % Find genes that meet fold change criterion and color them (by redrawing them so as
    % not having to implement again the label stuff)
    blueinten=inten(logratnorm<logfc(2) & logratnorm>logfc(1));
    bluelogratnorm=logratnorm(logratnorm<logfc(2) & logratnorm>logfc(1));
    redinten=inten(logratnorm>=logfc(2));
    redlogratnorm=logratnorm(logratnorm>=logfc(2));
    greeninten=inten(logratnorm<=logfc(1));
    greenlogratnorm=logratnorm(logratnorm<=logfc(1));
    hafter=plot(blueinten,bluelogratnorm,'.b');
    hold on
    hred=plot(redinten,redlogratnorm,'.r');
    hgreen=plot(greeninten,greenlogratnorm,'.g');
    % Display fold line
    hlineafter=fclines(hafter,logfc);
else
    hafter=plot(inten,logratnorm,'.b');
    hred=[];
    hgreen=[];
end

% Label and title plot
xlabel('Intensity (A)','FontWeight','bold');
ylabel('Ratio (M)','FontWeight','bold');
% Replace '_' character
titre{2}=strrep(titre{2},'_','-');
title(titre{2},'FontSize',11,'FontWeight','bold')
grid on

% Create legend
hallafter=hafter;
if ~disfcline
    strlegafter={'MA data'};
else
    if ~isempty(hred) && ~isempty(hgreen)
        hallafter=[hallafter;hred;hgreen;hlineafter(1)];
        strlegafter={'MA data','Up regulated','Down regulated','Fold change cutoff'};
    elseif ~isempty(hred) && isempty(hgreen)
        hallafter=[hallafter;hred;hlineafter(1)];
        strlegafter={'MA data','Up regulated','Fold change cutoff'};
    elseif isempty(hred) && ~isempty(hgreen)
        hallafter=[hallafter;hgreen;hlineafter(1)];
        strlegafter={'MA data','Down regulated','Fold change cutoff'};
    elseif isempty(hred) && isempty(hgreen)
        hallafter=[hallafter;hlineafter(1)];
        strlegafter={'MA data','Fold change cutoff'};
    end
end
legend(hallafter,strlegafter)

% If labels exist, set up a buttondown function
if ~isempty(labels)
    if ~disfcline
        haxlower=get(hafter,'Parent');
        set(haxlower,'UserData',[hafter,count],...
                     'ButtonDownFcn',@clickonplotAfter,...
                     'Tag',['allaxisAfter',num2str(count)]);
        set(hafter,'UserData',{labels,inten,logratnorm,count},...
                   'ButtonDownFcn',@clickonplot,...
                   'Tag',['bluedataAfter',num2str(count)]);
    else
        haxlower=get(hafter,'Parent');
        set(haxlower,'UserData',[hafter,hred,hgreen,count],...
                     'ButtonDownFcn',@clickonplotAfter,...
                     'Tag',['allaxisAfter',num2str(count)]);
        udatablue={labels(logratnorm<logfc(2) & logratnorm>logfc(1)),...
                   inten(logratnorm<logfc(2) & logratnorm>logfc(1)),...
                   logratnorm(logratnorm<logfc(2) & logratnorm>logfc(1)),...
                   count};
        set(hafter,'UserData',udatablue,...
                   'ButtonDownFcn',@clickonplotAfter,...
                   'Tag',['bluedataAfter',num2str(count)]);
        udatared={labels(logratnorm>=logfc(2)),...
                  inten(logratnorm>=logfc(2)),...
                  logratnorm(logratnorm>=logfc(2)),...
                  count};
        set(hred,'UserData',udatared,...
                 'ButtonDownFcn',@clickonplotAfter,...
                 'Tag',['reddataAfter',num2str(count)]);
        udatagreen={labels(logratnorm<=logfc(1)),...
                    inten(logratnorm<=logfc(1)),...
                    logratnorm(logratnorm<=logfc(1)),...
                    count};
        set(hgreen,'UserData',udatagreen,...
                   'ButtonDownFcn',@clickonplotAfter,...
                   'Tag',['greendataAfter',num2str(count)]);
    end
    
    % Create the context menu for exporting
    exportmenuAfter=uicontextmenu('Tag',['rightMenuAfterBoth',num2str(count)]);
    item1A=uimenu(exportmenuAfter,'Label','Select Data',...
                                  'Callback',@enterSelectStateAfter,...
                                  'Tag',['selectDataAfterBoth',num2str(count)],...
                                  'UserData',count);
    item2A=uimenu(exportmenuAfter,'Label','Export Selected',...
                                  'Callback',@exportSelectedAfter,...
                                  'Tag',['exportSelectedAfterBoth',num2str(count)],...
                                  'Enable','off');
    item3A=uimenu(exportmenuAfter,'Label','Export up regulated',...
                                  'Callback',@exportUpAfter,...
                                  'Tag',['exportUpAfterBoth',num2str(count)],...
                                  'Enable','on',...
                                  'UserData',count);
    item4A=uimenu(exportmenuAfter,'Label','Export down regulated',...
                                  'Callback',@exportDownAfter,...
                                  'Tag',['exportDownAfterBoth',num2str(count)],...
                                  'Enable','on',...
                                  'UserData',count);
    item5A=uimenu(exportmenuAfter,'Label','Export deregulated',...
                                  'Callback',@exportUpDownAfter,...
                                  'Tag',['exportUpDownAfterBoth',num2str(count)],...
                                  'Enable','on',...
                                  'UserData',count);
    item6A=uimenu(exportmenuAfter,'Label','Export unregulated',...
                                  'Callback',@exportNullAfter,...
                                  'Tag',['exportNullAfterBoth',num2str(count)],...
                                  'Enable','on',...
                                  'UserData',count);
    item7A=uimenu(exportmenuAfter,'Label','Export All',...
                                  'Callback',@exportAllAfter,...
                                  'Tag',['exportAllAfterBoth',num2str(count)],...
                                  'UserData',count);
    set(haxlower,'UIContextMenu',exportmenuAfter)
    set(hafter,'UIContextMenu',exportmenuAfter)
    if ~isempty(hred)
        set(hred,'UIContextMenu',exportmenuAfter)
    end
    if ~isempty(hgreen)
        set(hgreen,'UIContextMenu',exportmenuAfter)
    end
    if disfcline
        if ~isempty(hred) && ishandle(hred)
            set(hred,'UIContextMenu',exportmenuAfter)
        else
            set(item3A,'Enable','off')
        end
        if ~isempty(hgreen) && ishandle(hgreen)
            set(hgreen,'UIContextMenu',exportmenuAfter)
        else
            set(item4A,'Enable','off')
        end
        if isempty(hred) && isempty(hgreen)
            set(item3A,'Enable','off')
            set(item4A,'Enable','off')
            set(item5A,'Enable','off')
        end
    else
        set(item3A,'Enable','off')
        set(item4A,'Enable','off')
        set(item5A,'Enable','off')
    end
end

set(gcf,'Name',suptitre)

% Assign output
if nargout>0
    if nargout==1
        hpbefore=hbefore;
    elseif nargout==2
        hpbefore=hbefore;
        if ~disfcline
            hpafter=hafter;
        else
            hpafter=[hafter;hred;hgreen];
        end
    end
end

           
function hline = fclines(h,val)

% Resize axes
hax=get(h,'Parent');
xrange=get(hax,'XLim');

% Plot line y=0;
line([xrange(1),xrange(2)],[0,0],'Color','k','LineStyle',':');

% plot fold change line
hline(1)=line([xrange(1),xrange(2)], val(2)*[1,1],'Color','k','Linestyle','--');
hline(2)=line([xrange(1),xrange(2)], [1,1]*val(1),'Color','k','Linestyle','--');


function clickonplotBefore(varargin)

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


function enterSelectStateBefore(varargin)

hmenu=gcbo;
count=get(hmenu,'UserData');
hf=localCleanUpLabel;

if strcmp(get(hmenu,'Checked'),'off')
    
    % Indicate data selection enabled
    set(hmenu,'Checked','on');
    % Change the cursor
    set(hf,'Pointer','crosshair')
    % De-activate clickonplot
    hallaxis=findobj('Tag',['allaxisBefore',num2str(count)]);
    halldata=findobj('Tag',['alldataBefore',num2str(count)]);
    if ishandle(hallaxis)
        set(hallaxis,'ButtonDownFcn',@selectDataBefore)
    end
    if ishandle(halldata)
        set(halldata,'ButtonDownFcn',@selectDataBefore)
    end

else
    
    % Delete previous selection boxes and points (if any)
    prevbox=findobj('Tag',['selectedRegionBeforeBoth',num2str(count)]);
    if ishandle(prevbox)
        delete(prevbox);
    end
    prevpts=findobj('Tag',['selectedPointsBeforeBoth',num2str(count)]);
    if ishandle(prevpts)
        delete(prevpts);
    end
    % Indicate data selection disabled
    set(hmenu,'Checked','off');
    % Change the cursor
    set(hf,'Pointer','arrow')
    % Activate clickonplot
    hallaxis=findobj('Tag',['allaxisBefore',num2str(count)]);
    halldata=findobj('Tag',['alldataBefore',num2str(count)]);
    if ishandle(hallaxis)
        set(hallaxis,'ButtonDownFcn',@clickonplotBefore)
    end
    if ishandle(halldata)
        set(halldata,'ButtonDownFcn',@clickonplotBefore)
    end
    % Disable export selected data
    item2=findobj('Tag',['exportSelectedBeforeBoth',num2str(count)]);
    set(item2,'Enable','off')
    
end


function selectDataBefore(varargin)

hobj=gcbo;
udata=get(hobj,'UserData');
if iscell(udata)
    count=udata{end};
else
    count=udata(end);
end

% Delete previous selection boxes and points (if any)
prevbox=findobj('Tag',['selectedRegionBeforeBoth',num2str(count)]);
if ishandle(prevbox)
    delete(prevbox);
end
prevpts=findobj('Tag',['selectedPointsBeforeBoth',num2str(count)]);
if ishandle(prevpts)
    delete(prevpts);
end

% Get some useful data
hallaxis=findobj('Tag',['allaxisBefore',num2str(count)]);
halldata=findobj('Tag',['alldataBefore',num2str(count)]);
xvals=get(halldata,'XData');
yvals=get(halldata,'YData');
udata=get(halldata,'UserData');

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
xlims=get(hallaxis,'XLim');
ylims=get(hallaxis,'YLim');
x(x<xlims(1))=xlims(1);
x(x>xlims(2))=xlims(2);
y(y<ylims(1))=ylims(1);
y(y>ylims(2))=ylims(2);

% Draw it
hold on
axis manual
selrect=plot(x,y,'m-','Tag',['selectedRegionBeforeBoth',num2str(count)]);
set(selrect,'LineWidth',3)

% Set our context menu for the box drawed
conmenu=findobj('Tag',['rightMenuBeforeBoth',num2str(count)]);
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
item2=findobj('Tag',['exportSelectedBeforeBoth',num2str(count)]);
if ~isempty(xinside)
    set(item2,'Enable','on')
else
    set(item2,'Enable','off')
end

% Color data by plotting again... the new handle will be destroyed after this action
selpts=plot(xinside,yinside,'.m','Tag',['selectedPointsBeforeBoth',num2str(count)]);
% ...and find the corresponding labels too
if ~isempty(udata)
    labels=udata{1};
    newlabels=labels(allin);
    set(selpts,'UserData',newlabels)
end

% Store the selected points and their labels into figures userdata
hfig=gcbf;
udataFig=get(hfig,'UserData');
if isempty(udataFig)
    udataFig=zeros(1,2);
end
if ~isempty(selpts) && ishandle(selpts)
    udataFig(1)=selpts;
end
set(hfig,'UserData',udataFig)


function exportSelectedBefore(varargin)

alludata=get(gcbf,'UserData');
selpts=alludata(1);
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
    

function exportAllBefore(varargin)

count=get(gcbo,'UserData');
alldata=findobj('Tag',['alldataBefore',num2str(count)]);
MData=get(alldata,'XData');
AData=get(alldata,'YData');
udata=get(alldata,'UserData');
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


function clickonplotAfter(varargin)

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


function enterSelectStateAfter(varargin)

hmenu=gcbo;
count=get(hmenu,'UserData');
hf=localCleanUpLabel;

if strcmp(get(hmenu,'Checked'),'off')
    
    % Indicate data selection enabled
    set(hmenu,'Checked','on');
    % Change the cursor
    set(hf,'Pointer','crosshair')
    % De-activate clickonplot
    hallaxis=findobj('Tag',['allaxisAfter',num2str(count)]);
    hbluedata=findobj('Tag',['bluedataAfter',num2str(count)]);
    hreddata=findobj('Tag',['reddataAfter',num2str(count)]);
    hgreendata=findobj('Tag',['greendataAfter',num2str(count)]);
    if ~isempty(hallaxis) && ishandle(hallaxis)
        set(hallaxis,'ButtonDownFcn',@selectDataAfter)
    end
    if ~isempty(hbluedata) && ishandle(hbluedata)
        set(hbluedata,'ButtonDownFcn',@selectDataAfter)
    end
    if ~isempty(hreddata) && ishandle(hreddata)
        set(hreddata,'ButtonDownFcn',@selectDataAfter)
    end
    if ~isempty(hgreendata) && ishandle(hgreendata)
        set(hgreendata,'ButtonDownFcn',@selectDataAfter)
    end

else
    
    % Delete previous selection boxes and points (if any)
    prevbox=findobj('Tag',['selectedRegionAfterBoth',num2str(count)]);
    if ishandle(prevbox)
        delete(prevbox);
    end
    prevpts=findobj('Tag',['selectedPointsAfterBoth',num2str(count)]);
    if ishandle(prevpts)
        delete(prevpts);
    end
    % Indicate data selection disabled
    set(hmenu,'Checked','off');
    % Change the cursor
    set(hf,'Pointer','arrow')
    % Activate clickonplot
    hallaxis=findobj('Tag',['allaxisAfter',num2str(count)]);
    hbluedata=findobj('Tag',['bluedataAfter',num2str(count)]);
    hreddata=findobj('Tag',['reddataAfter',num2str(count)]);
    hgreendata=findobj('Tag',['greendataAfter',num2str(count)]);
    if ~isempty(hallaxis) && ishandle(hallaxis)
        set(hallaxis,'ButtonDownFcn',@clickonplotAfter)
    end
    if ~isempty(hbluedata) && ishandle(hbluedata)
        set(hbluedata,'ButtonDownFcn',@clickonplotAfter)
    end
    if ~isempty(hreddata) && ishandle(hreddata)
        set(hreddata,'ButtonDownFcn',@clickonplotAfter)
    end
    if ~isempty(hgreendata) && ishandle(hgreendata)
        set(hgreendata,'ButtonDownFcn',@clickonplotAfter)
    end
    % Disable export selected data
    item2=findobj('Tag',['exportSelectedAfterBoth',num2str(count)]);
    set(item2,'Enable','off')
    
end


function selectDataAfter(varargin)

hobj=gcbo;
udata=get(hobj,'UserData');
if iscell(udata)
    count=udata{end};
else
    count=udata(end);
end

% Delete previous selection boxes and points (if any)
prevbox=findobj('Tag',['selectedRegionAfterBoth',num2str(count)]);
if ishandle(prevbox)
    delete(prevbox);
end
prevpts=findobj('Tag',['selectedPointsAfterBoth',num2str(count)]);
if ishandle(prevpts)
    delete(prevpts);
end

% Get some useful data
hallaxis=findobj('Tag',['allaxisAfter',num2str(count)]);
hObject=get(hallaxis,'UserData');
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
    ints=cell(length(udatatemp),1);
    logs=cell(length(udatatemp),1);
    for i=1:length(udatatemp)
        labs{i}=char(udatatemp{i}{1});
        ints{i}=udatatemp{i}{2};
        logs{i}=udatatemp{i}{3};
    end
    labs=cellstr(char(labs));
    ints=cell2mat(ints);
    logs=cell2mat(logs);
    udata={labs,ints,logs};
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
xlims=get(hallaxis,'XLim');
ylims=get(hallaxis,'YLim');
x(x<xlims(1))=xlims(1);
x(x>xlims(2))=xlims(2);
y(y<ylims(1))=ylims(1);
y(y>ylims(2))=ylims(2);

% Draw it
hold on
axis manual
selrect=plot(x,y,'m-','Tag',['selectedRegionAfterBoth',num2str(count)]);
set(selrect,'LineWidth',3)

% Set our context menu for the box drawed
conmenu=findobj('Tag',['rightMenuAfterBoth',num2str(count)]);
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
item2=findobj('Tag',['exportSelectedAfterBoth',num2str(count)]);
if ~isempty(xinside)
    set(item2,'Enable','on')
else
    set(item2,'Enable','off')
end

% Color data by plotting again... the new handle will be destroyed after this action
selpts=plot(xinside,yinside,'.m','Tag',['selectedPointsAfterBoth',num2str(count)]);
% ...and find the corresponding labels too
if ~isempty(udata)
    labels=udata{1};
    newlabels=labels(allin);
    set(selpts,'UserData',newlabels)
end

% Store the selected points and their labels into figures userdata
hfig=gcbf;
udataFig=get(hfig,'UserData');
if isempty(udataFig)
    udataFig=zeros(1,2);
end
if ~isempty(selpts) && ishandle(selpts)
    udataFig(2)=selpts;
end
set(hfig,'UserData',udataFig)


function exportSelectedAfter(varargin)

alludata=get(gcbf,'UserData');
selpts=alludata(2);
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


function exportUpAfter(varargin)

count=get(gcbo,'UserData');
hup=findobj('Tag',['reddataAfter',num2str(count)]);
if ~ishandle(hup) % Unlikely to happen though. It is controled from the main function
    uiwait(errordlg('No up regulated genes found!','Error'));
else
    udata=get(hup,'UserData');
    MData=get(hup,'XData');
    AData=get(hup,'YData');
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
end


function exportDownAfter(varargin)

count=get(gcbo,'UserData');
hdown=findobj('Tag',['greendataAfter',num2str(count)]);
if ~ishandle(hdown) % Unlikely to happen though. It is controled from the main function
    uiwait(errordlg('No down regulated genes found!','Error'));
else
    udata=get(hdown,'UserData');
    MData=get(hdown,'XData');
    AData=get(hdown,'YData');
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
end


function exportUpDownAfter(varargin)

count=get(gcbo,'UserData');
hup=findobj('Tag',['reddataAfter',num2str(count)]);
hdown=findobj('Tag',['greendataAfter',num2str(count)]);
% Unlikely to happen though. It is controled from the main function
if ~ishandle(hup) & ~ishandle(hdown)
    uiwait(errordlg('No regulated genes found!','Error'));
else
    if ishandle(hup)
        udataUp=get(hup,'UserData');
        MDataUp=get(hup,'XData');
        ADataUp=get(hup,'YData');
        labelsUp=udataUp{1};
        excolUp=repmat('UP',[length(MDataUp) 1]);
        excolUp=cellstr(excolUp);
    else
        MDataUp=[];
        ADataUp=[];
        labelsUp=[];
        excolUp=[];
    end
    if ishandle(hdown)
        udataDown=get(hdown,'UserData');
        MDataDown=get(hdown,'XData');
        ADataDown=get(hdown,'YData');
        labelsDown=udataDown{1};
        excolDown=repmat('DOWN',[length(MDataDown) 1]);
        excolDown=cellstr(excolDown);
    else
        MDataDown=[];
        ADataDown=[];
        labelsDown=[];
        excolDown=[];
    end

    [filename,pathname]=uiputfile('*.txt','Export MA data');
    if filename==0
        return
    else
        fid=fopen(strcat(pathname,filename),'wt');
        fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID','Log Ratio (M)','Intensity (A)','Regulation');
        for i=1:length(MDataUp)
            fprintf(fid,'%s\t%5.5f\t%5.5f\t%s\n',labelsUp{i},MDataUp(i),ADataUp(i),excolUp{i});
        end
        for i=1:length(MDataDown)
            fprintf(fid,'%s\t%5.5f\t%5.5f\t%s\n',labelsDown{i},MDataDown(i),ADataDown(i),excolDown{i});
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportNullAfter(varargin)

count=get(gcbo,'UserData');
hnull=findobj('Tag',['bluedataAfter',num2str(count)]);
if ~ishandle(hnull) % Unlikely to happen though. It is controled from the main function
    uiwait(errordlg('No unregulated genes found!','Error'));
else
    udata=get(hnull,'UserData');
    MData=get(hnull,'XData');
    AData=get(hnull,'YData');
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
end


function exportAllAfter(varargin)

count=get(gcbo,'UserData');
hnull=findobj('Tag',['bluedataAfter',num2str(count)]);
hup=findobj('Tag',['reddataAfter',num2str(count)]);
hdown=findobj('Tag',['greendataAfter',num2str(count)]);

if ishandle(hup) | ishandle(hdown)
    regexist=true;
else
    regexist=false;
end

if ishandle(hup)
    udataUp=get(hup,'UserData');
    MDataUp=get(hup,'XData');
    ADataUp=get(hup,'YData');
    labelsUp=udataUp{1};
    if regexist
        excolUp=repmat('UP',[length(MDataUp) 1]);
        excolUp=cellstr(excolUp);
    end
else
    MDataUp=[];
    ADataUp=[];
    labelsUp=[];
    if regexist
        excolUp=[];
    end
end
if ishandle(hdown)
    udataDown=get(hdown,'UserData');
    MDataDown=get(hdown,'XData');
    ADataDown=get(hdown,'YData');
    labelsDown=udataDown{1};
    if regexist
        excolDown=repmat('DOWN',[length(MDataDown) 1]);
        excolDown=cellstr(excolDown);
    end
else
    MDataDown=[];
    ADataDown=[];
    labelsDown=[];
    if regexist
        excolDown=[];
    end
end
udataNull=get(hnull,'UserData');
MDataNull=get(hnull,'XData');
ADataNull=get(hnull,'YData');
labelsNull=udataNull{1};
if regexist
    excolNull=repmat('NULL',[length(MDataNull) 1]);
    excolNull=cellstr(excolNull);
end

[filename,pathname]=uiputfile('*.txt','Export MA data');
if filename==0
    return
else
    fid=fopen(strcat(pathname,filename),'wt');
    if regexist
        fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID','Log Ratio (M)','Intensity (A)','Regulation');
        for i=1:length(MDataUp)
            fprintf(fid,'%s\t%5.5f\t%5.5f\t%s\n',labelsUp{i},MDataUp(i),ADataUp(i),excolUp{i});
        end
        for i=1:length(MDataDown)
            fprintf(fid,'%s\t%5.5f\t%5.5f\t%s\n',labelsDown{i},MDataDown(i),ADataDown(i),excolDown{i});
        end
        for i=1:length(MDataNull)
            fprintf(fid,'%s\t%5.5f\t%5.5f\t%s\n',labelsNull{i},MDataNull(i),ADataNull(i),excolNull{i});
        end
    else
        fprintf(fid,'%s\t%s\t%s\n','GeneID','Log Ratio (M)','Intensity (A)');
        for i=1:length(MDataUp)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labelsUp{i},MDataUp(i),ADataUp(i));
        end
        for i=1:length(MDataDown)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labelsDown{i},MDataDown(i),ADataDown(i));
        end
        for i=1:length(MDataNull)
            fprintf(fid,'%s\t%5.5f\t%5.5f\n',labelsNull{i},MDataNull(i),ADataNull(i));
        end
    end
    fprintf('\n')
    fclose(fid);
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



