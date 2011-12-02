function hp = plotVolcano(logtreated,logcontrol,pval,varargin)

%
% PropertyName          PropertyValue                                                  
% -----------------------------------------------------------------------------
% DisplayPLine          Display p-value cut of line or not.
%                       Values: true or false
%                       
% DisplayFCLine         Display fold change cutoff line or not.
%                       Values: true or false
%         
% PValue                The p-value cutoff (numeric between 0 and 1)
%
% FoldChange            The fold change (numeric)
%
% Title                 The plot title
% 
% Labels                Gene lables to annotate points in the plot
%
% Effect                The way the fold change is calculated:
%                       Values: 1 for treated ratio
%                               2 for treated ratio - control ratio
%                               3 for treated ratio / control ratio
%                       If we have only one condition (logcontrol=[]) then it defaults to
%                       1 (treated ratio)
%
% Count                 A unique integer serving for multiple figures (ARMADA) threads
%                       at the same time
%

% Set defaults
displine=true;
disfcline=true;
pvalcut=0.05;
fccut=2;
titre='Volcano Plot';
labels='';
caleffect=2; % Subtract
condnames='';
count=1;


% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)==0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'displaypline','displayfcline','pvalue','foldchange','title','labels','effect',...
            'names','count'};
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
                case 1 % Display p-value cutoff line
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        displine=parVal;
                    end
                case 2 % Display fold change cutoff line
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        disfcline=parVal;
                    end
                case 3 % p-value cutoff
                    if ~isscalar(parVal) || parVal<0 || parVal>1
                        error('The %s parameter value must be a positive scalar value between 0 and 1',parName)
                    else
                        pvalcut=parVal;
                    end
                case 4 % Fold change cutoff
                    if ~isscalar(parVal) || parVal<=0
                        error('The %s parameter value must be a positive scalar value',parName)
                    else
                        fccut=parVal;
                    end
                case 5 % Title
                    if ~ischar(parVal)
                        error('The %s parameter value must be a string',parName)
                    else
                        titre=parVal;
                    end
                case 6 % Labels
                    if ~iscellstr(parVal)
                        error('The %s parameter value must be a cell array of strings',parName)
                    else
                        labels=parVal;
                    end
                case 7 % Effect calculation
                    if ~isscalar(parVal) || ~ismember(parVal,[1 2 3])
                        error('The %s parameter value must be a value between 1, 2 or 3',parName)
                    else
                        caleffect=parVal;
                    end
                case 8 % Condition names
                    if ~ischar(parVal) && ~iscellstr(parVal)
                        error('The %s parameter value must be a string or cell array of strings',parName)
                    else
                        condnames=parVal;
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

% Discard any zero elements
if ~isempty(logcontrol)
    allZeros=((logtreated==0) | (logcontrol==0) | (pval==0));
    allNaN=(isnan(logtreated) | isnan(logcontrol));
else
    allZeros=((logtreated==0) | (pval==0));
    allNaN=isnan(logtreated);
end
goodVals=~(allZeros | allNaN);
                         
logfc=log2(fccut);
pval=pval(goodVals);
logpval=-log10(pval);
logtreated=logtreated(goodVals);
if isempty(logcontrol)
    effect=logtreated;
else
    logcontrol=logcontrol(goodVals);
    if caleffect==1
        effect=logtreated;
    elseif caleffect==2
        effect=logtreated-logcontrol;
    elseif caleffect==3
        effect=logtreated./logcontrol;
    end
end
if ~isempty(labels)
    labels=labels(goodVals);
end
xlims=[min(effect)-0.5,max(effect)+0.5];

% Create volcano plot
figure
hold on
% Various cases concerning fold change and p-value displays
if displine && disfcline
    critblue=pval>pvalcut | abs(effect)<logfc;
    critred=pval<=pvalcut & effect>=logfc;
    critgreen=pval<=pvalcut & effect<=-logfc;
elseif displine && ~disfcline
    critblue=pval>pvalcut;
    critred=pval<=pvalcut & effect>=0;
    critgreen=pval<=pvalcut & effect<0;
elseif ~displine && disfcline
    critblue=abs(effect)<logfc;
    critred=pval<=max(pval) & effect>=logfc;
    critgreen=pval<=max(pval) & effect<=-logfc;
else
    critblue=pval<=max(pval) & abs(effect)>=0;
    critred=[];
    critgreen=[];
end

% Plot non DE (or all genes in case user does not wish to display De lines)
if ~isempty(critblue)
    hblue=plot(effect(critblue),logpval(critblue),'.b');
else
    hblue=[];
end
% Plot up-regulated
if ~isempty(critred)
    hred=plot(effect(critred),logpval(critred),'.r');
else
    hred=[];
end
% Plot down-regulated
if ~isempty(critgreen)
    hgreen=plot(effect(critgreen),logpval(critgreen),'.g');
else
    hgreen=[];
end
set(gca,'XLim',xlims)
    
% Display fold line
if disfcline
    fcline=fclines(hblue,logfc);
end
if displine
    pline=plines(hblue,-log10(pvalcut));
end

% Label and title plot
xlabel('Fold change (effect)','FontWeight','bold');
ylabel('-log10(p-value)','FontWeight','bold');
% Replace '_' character
titre=strrep(titre,'_','-');
title(titre,'FontSize',11,'FontWeight','bold')
grid on
box on

% Create legend
hall=hblue;
if ~disfcline && ~displine
    strleg={'Data'};
else
    if ~isempty(hred) && ~isempty(hgreen)
        if disfcline && displine
            hall=[hall;hred;hgreen;fcline(1);pline(1)];
            strleg={'Data','Up regulated','Down regulated',...
                    'Fold change cutoff','p-value cutoff'};
        elseif disfcline && ~displine
            hall=[hall;hred;hgreen;fcline(1)];
            strleg={'Data','Up regulated','Down regulated',...
                    'Fold change cutoff'};
        elseif ~disfcline && displine
            hall=[hall;hred;hgreen;pline(1)];
            strleg={'Data','Up regulated','Down regulated',...
                    'p-value cutoff'};
        end
    elseif ~isempty(hred) && isempty(hgreen)
        if disfcline && displine
            hall=[hall;hred;fcline(1);pline(1)];
            strleg={'Data','Up regulated','Fold change cutoff','p-value cutoff'};
        elseif disfcline && ~displine
            hall=[hall;hred;fcline(1)];
            strleg={'Data','Up regulated','Fold change cutoff'};
        elseif ~disfcline && displine
            hall=[hall;hred;pline(1)];
            strleg={'Data','Up regulated','p-value cutoff'};
        end
    elseif isempty(hred) && ~isempty(hgreen)
        if disfcline && displine
            hall=[hall;hgreen;fcline(1);pline(1)];
            strleg={'Data','Down regulated','Fold change cutoff','p-value cutoff'};
        elseif disfcline && ~displine
            hall=[hall;hgreen;fcline(1)];
            strleg={'Data','Down regulated','Fold change cutoff'};
        elseif ~disfcline && displine
            hall=[hall;hgreen;pline(1)];
            strleg={'Data','Down regulated','p-value cutoff'};
        end
    elseif isempty(hred) && isempty(hgreen)
        if disfcline && displine
            hall=[hall;fcline(1);pline(1)];
            strleg={'Data','Fold change cutoff','p-value cutoff'};
        elseif disfcline && ~displine
            hall=[hall;fcline(1)];
            strleg={'Data','Fold change cutoff'};
        elseif ~disfcline && displine
            hall=[hall;pline(1)];
            strleg={'Data','p-value cutoff'};
        end
    end
end
legend(hall,strleg)

% If labels exist, set up a buttondown function
if ~isempty(labels)
    if ~disfcline && ~displine
        hax=get(hblue,'Parent');
        set(hax,'UserData',[hblue,count],...
                'ButtonDownFcn',@clickonplot,...
                'Tag',['allaxis',num2str(count)]);
        set(hblue,'UserData',{labels,logtreated,logcontrol,effect,pval,condnames,count},...
                  'ButtonDownFcn',@clickonplot,...
                  'Tag',['bluedata',num2str(count)]);
    else
        hax=get(hblue,'Parent');
        set(hax,'UserData',[hblue,hred,hgreen,count],...
                'ButtonDownFcn',@clickonplot,...
                'Tag',['allaxis',num2str(count)]);
            
        udatablue={labels(critblue),logtreated(critblue)};
        if ~isempty(logcontrol)
            udatablue{3}=logcontrol(critblue);
        else
            udatablue{3}=[];
        end
        udatablue{4}=effect(critblue);
        udatablue{5}=pval(critblue);
        udatablue{6}=condnames;
        udatablue{7}=count;
        set(hblue,'UserData',udatablue,...
                  'ButtonDownFcn',@clickonplot,...
                  'Tag',['bluedata',num2str(count)]);
     
        udatared={labels(critred),logtreated(critred)};
        if ~isempty(logcontrol)
            udatared{3}=logcontrol(critred);
        else
            udatared{3}=[];
        end
        udatared{4}=effect(critred);
        udatared{5}=pval(critred);
        udatared{6}=condnames;
        udatared{7}=count;
        set(hred,'UserData',udatared,...
                 'ButtonDownFcn',@clickonplot,...
                 'Tag',['reddata',num2str(count)]);
        
        udatagreen={labels(critgreen),logtreated(critgreen)};
        if ~isempty(logcontrol)
            udatagreen{3}=logcontrol(critgreen);
        else
            udatagreen{3}=[];
        end
        udatagreen{4}=effect(critgreen);
        udatagreen{5}=pval(critgreen);
        udatagreen{6}=condnames;
        udatagreen{7}=count;
        set(hgreen,'UserData',udatagreen,...
                   'ButtonDownFcn',@clickonplot,...
                   'Tag',['greendata',num2str(count)]);
    end
    
    % Create the context menu for exporting
    exportmenu=uicontextmenu('Tag',['rightMenu',num2str(count)]);
    item1=uimenu(exportmenu,'Label','Select Data',...
                            'Callback',@enterSelectState,...
                            'Tag',['selectData',num2str(count)],...
                            'UserData',count);
    item2=uimenu(exportmenu,'Label','Export Selected',...
                            'Callback',@exportSelected,...
                            'Tag',['exportSelected',num2str(count)],...
                            'Enable','off');
    item3=uimenu(exportmenu,'Label','Export up regulated',...
                            'Callback',@exportUp,...
                            'Tag',['exportUp',num2str(count)],...
                            'Enable','on',...
                            'UserData',count);
    item4=uimenu(exportmenu,'Label','Export down regulated',...
                            'Callback',@exportDown,...
                            'Tag',['exportDown',num2str(count)],...
                            'Enable','on',...
                            'UserData',count);
    item5=uimenu(exportmenu,'Label','Export deregulated',...
                            'Callback',@exportUpDown,...
                            'Tag',['exportUpDown',num2str(count)],...
                            'Enable','on',...
                            'UserData',count);
    item6=uimenu(exportmenu,'Label','Export unregulated',...
                            'Callback',@exportNull,...
                            'Tag',['exportNull',num2str(count)],...
                            'Enable','on',...
                            'UserData',count);
    item7=uimenu(exportmenu,'Label','Export All',...
                            'Callback',@exportAll,...
                            'Tag',['exportAll',num2str(count)],...
                            'UserData',count);
    set(hax,'UIContextMenu',exportmenu)
    set(hblue,'UIContextMenu',exportmenu)
    if ~isempty(hred)
        set(hred,'UIContextMenu',exportmenu)
    end
    if ~isempty(hgreen)
        set(hgreen,'UIContextMenu',exportmenu)
    end
    if disfcline || displine
        if ~isempty(hred) && ishandle(hred)
            set(hred,'UIContextMenu',exportmenu)
        else
            set(item3,'Enable','off')
        end
        if ~isempty(hgreen) && ishandle(hgreen)
            set(hgreen,'UIContextMenu',exportmenu)
        else
            set(item4,'Enable','off')
        end
        if isempty(hred) && isempty(hgreen)
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

           
function hline = fclines(h,val)

% Resize axes
hax=get(h,'Parent');
yrange=get(hax,'YLim');

% Plot line y=0;
line([0,0],[yrange(1),yrange(2)],'Color','k','LineStyle',':');

% plot fold change line
hline(1)=line(val*[1,1],[yrange(1),yrange(2)],'Color','k','LineStyle','--');
hline(2)=line([-1,-1]*val,[yrange(1),yrange(2)],'Color','k','LineStyle','--');


function pline = plines(h,val)

% Resize axes
hax=get(h,'Parent');
xrange=get(hax,'XLim');

% Plot line x=0;
line([xrange(1),xrange(2)],[0,0],'Color','k','LineStyle',':');

% plot p-value cutoff line
pline=line([xrange(1),xrange(2)],val*[1,1],'Color','k','LineStyle','-.');


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
    tre=cell(length(udatatemp),1);
    eff=cell(length(udatatemp),1);
    pval=cell(length(udatatemp),1);
    if ~isempty(udatatemp{1}{3})
        con=cell(length(udatatemp{1}),1);
        for i=1:length(udatatemp)
            labs{i}=cell2mat(udatatemp{i}{1});
            tre{i}=udatatemp{i}{2};
            con{i}=udatatemp{i}{3};
            eff{i}=udatatemp{i}{4};
            pval{i}=udatatemp{i}{5};
        end
    else
        con=[];
        for i=1:length(udatatemp)
            labs{i}=cell2mat(udatatemp{i}{1});
            tre{i}=udatatemp{i}{2};
            eff{i}=udatatemp{i}{4};
            pval{i}=udatatemp{i}{5};
        end
    end
    labs=cellstr(cell2mat(labs));
    tre=cell2mat(tre);
    eff=cell2mat(eff);
    pval=cell2mat(pval);
    if ~isempty(con)
        con=cell2mat(con);
    end
    udata={labs,tre,con,eff,pval,udatatemp{1}{6}};
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
    
    if isempty(udata{6})
        t1='Sample 1 (Treated) = ';
        t2='Sample 2 (Reference) = ';
    else
        if ischar(udata{6})
            t1=[udata{6},' = '];
            t2='';
        else
            t1=[char(udata{6}(1)),' = '];
            t2=[char(udata{6}(2)),' = '];
        end
    end

    % Create a new text object -- start with it invisible
    displayed={udata{1}{index};...
               [t1,num2str(udata{2}(index))]};
    if ~isempty(udata{3})
        displayed=[displayed;...
                   [t2,num2str(udata{3}(index))];...
                   ['Effect = ',num2str(udata{4}(index))];...
                   ['p-value = ',num2str(udata{5}(index))]];
    else
        displayed=[displayed;...
                   ['Effect = ',num2str(udata{4}(index))];...
                   ['p-value = ',num2str(udata{5}(index))]];
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
    hallaxis=findobj('Tag',['allaxis',num2str(count)]);
    hbluedata=findobj('Tag',['bluedata',num2str(count)]);
    hreddata=findobj('Tag',['reddata',num2str(count)]);
    hgreendata=findobj('Tag',['greendata',num2str(count)]);
    if ~isempty(hallaxis) && ishandle(hallaxis)
        set(hallaxis,'ButtonDownFcn',@selectData)
    end
    if ~isempty(hbluedata) && ishandle(hbluedata)
        set(hbluedata,'ButtonDownFcn',@selectData)
    end
    if ~isempty(hreddata) && ishandle(hreddata)
        set(hreddata,'ButtonDownFcn',@selectData)
    end
    if ~isempty(hgreendata) && ishandle(hgreendata)
        set(hgreendata,'ButtonDownFcn',@selectData)
    end

else
    
    % Delete previous selection boxes and points (if any)
    prevbox=findobj('Tag',['selectedRegion',num2str(count)]);
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
    hallaxis=findobj('Tag',['allaxis',num2str(count)]);
    hbluedata=findobj('Tag',['bluedata',num2str(count)]);
    hreddata=findobj('Tag',['reddata',num2str(count)]);
    hgreendata=findobj('Tag',['greendata',num2str(count)]);
    if ~isempty(hallaxis) && ishandle(hallaxis)
        set(hallaxis,'ButtonDownFcn',@clickonplot)
    end
    if ~isempty(hbluedata) && ishandle(hbluedata)
        set(hbluedata,'ButtonDownFcn',@clickonplot)
    end
    if ~isempty(hreddata) && ishandle(hreddata)
        set(hreddata,'ButtonDownFcn',@clickonplot)
    end
    if ~isempty(hgreendata) && ishandle(hgreendata)
        set(hgreendata,'ButtonDownFcn',@clickonplot)
    end
    % Disable export selected data
    item2=findobj('Tag',['exportSelected',num2str(count)]);
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
prevbox=findobj('Tag',['selectedRegion',num2str(count)]);
if ishandle(prevbox)
    delete(prevbox);
end
prevpts=findobj('Tag',['selectedPoints',num2str(count)]);
if ishandle(prevpts)
    delete(prevpts);
end

% Get some useful data
hallaxis=findobj('Tag',['allaxis',num2str(count)]);
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
    tre=cell(length(udatatemp),1);
    eff=cell(length(udatatemp),1);
    pval=cell(length(udatatemp),1);
    if ~isempty(udatatemp{1}{3})
        con=cell(length(udatatemp{1}),1);
        for i=1:length(udatatemp)
            labs{i}=char(udatatemp{i}{1});
            tre{i}=udatatemp{i}{2};
            con{i}=udatatemp{i}{3};
            eff{i}=udatatemp{i}{4};
            pval{i}=udatatemp{i}{5};
        end
    else
        con=[];
        for i=1:length(udatatemp)
            labs{i}=char(udatatemp{i}{1});
            tre{i}=udatatemp{i}{2};
            eff{i}=udatatemp{i}{4};
            pval{i}=udatatemp{i}{5};
        end
    end
    labs=cellstr(char(labs));
    tre=cell2mat(tre);
    eff=cell2mat(eff);
    pval=cell2mat(pval);
    if ~isempty(con)
        con=cell2mat(con);
    end
    udata={labs,tre,con,eff,pval,udatatemp{1}{6}};
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
selrect=plot(x,y,'m-','Tag',['selectedRegion',num2str(count)]);
set(selrect,'LineWidth',3)

% Set our context menu for the box drawed
conmenu=findobj('Tag',['rightMenu',num2str(count)]);
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
item2=findobj('Tag',['exportSelected',num2str(count)]);
if ~isempty(xinside)
    set(item2,'Enable','on')
else
    set(item2,'Enable','off')
end

% Color data by plotting again... the new handle will be destroyed after this action
selpts=plot(xinside,yinside,'.m','Tag',['selectedPoints',num2str(count)]);
% ...and find the corresponding labels too
if ~isempty(udata)
    labs=udata{1};
    tre=udata{2};
    con=udata{3};
    eff=udata{4};
    pval=udata{5};
    cond=udata{6};
    newlabs=labs(allin);
    newtre=tre(allin);
    if ~isempty(con)
        newcon=con(allin);
    else
        newcon=con;
    end
    neweff=eff(allin);
    newpval=pval(allin);
    newdata={newlabs,newtre,newcon,neweff,newpval,cond};
    set(selpts,'UserData',newdata)
end

% Store the selected points and their labels into figures userdata
hfig=gcbf;
set(hfig,'UserData',selpts)


function exportSelected(varargin)

selpts=get(gcbf,'UserData');
if ~ishandle(selpts)
    uiwait(errordlg('No points selected!','Error'));
else
    EData=get(selpts,'XData');
    udata=get(selpts,'UserData');
    labels=udata{1};
    treated=udata{2};
    control=udata{3};
    % effect=udata{4};
    pvals=udata{5};
    conds=udata{6};
    
    [filename,pathname]=uiputfile('*.txt','Export Volcano data');
    if filename==0
        return
    else
        fid=fopen(strcat(pathname,filename),'wt');
        if ~isempty(control)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[conds{1} ' (Treated)'],...
                                               [conds{2} ' (Control)'],'Effect','p-value');
            for i=1:length(EData)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\n',...
                            labels{i},treated(i),control(i),EData(i),pvals(i));
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID',[conds{1} ' (Treated)'],'Effect','p-value');
            for i=1:length(EData)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\n',labels{i},treated(i),EData(i),pvals(i));
            end
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportUp(varargin)

count=get(gcbo,'UserData');
hup=findobj('Tag',['reddata',num2str(count)]);
if ~ishandle(hup) % Unlikely to happen though. It is controled from the main function
    uiwait(errordlg('No up regulated genes found!','Error'));
else
    udata=get(hup,'UserData');
    EData=get(hup,'XData');
    labels=udata{1};
    treated=udata{2};
    control=udata{3};
    % effect=udata{4};
    pvals=udata{5};
    conds=udata{6};
    
    [filename,pathname]=uiputfile('*.txt','Export Volcano data');
    if filename==0
        return
    else
        fid=fopen(strcat(pathname,filename),'wt');
        if ~isempty(control)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[conds{1} ' (Treated)'],...
                                               [conds{2} ' (Control)'],'Effect','p-value');
            for i=1:length(EData)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\n',...
                            labels{i},treated(i),control(i),EData(i),pvals(i));
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID',[conds{1} ' (Treated)'],'Effect','p-value');
            for i=1:length(EData)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\n',labels{i},treated(i),EData(i),pvals(i));
            end
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportDown(varargin)

count=get(gcbo,'UserData');
hdown=findobj('Tag',['greendata',num2str(count)]);
if ~ishandle(hdown) % Unlikely to happen though. It is controled from the main function
    uiwait(errordlg('No down regulated genes found!','Error'));
else
    udata=get(hdown,'UserData');
    EData=get(hdown,'XData');
    labels=udata{1};
    treated=udata{2};
    control=udata{3};
    % effect=udata{4};
    pvals=udata{5};
    conds=udata{6};

    [filename,pathname]=uiputfile('*.txt','Export Volcano data');
    if filename==0
        return
    else
        fid=fopen(strcat(pathname,filename),'wt');
        if ~isempty(control)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[conds{1} ' (Treated)'],...
                                               [conds{2} ' (Control)'],'Effect','p-value');
            for i=1:length(EData)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\n',...
                            labels{i},treated(i),control(i),EData(i),pvals(i));
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID',[conds{1} ' (Treated)'],'Effect','p-value');
            for i=1:length(EData)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\n',labels{i},treated(i),EData(i),pvals(i));
            end
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportUpDown(varargin)

count=get(gcbo,'UserData');
hup=findobj('Tag',['reddata',num2str(count)]);
hdown=findobj('Tag',['greendata',num2str(count)]);
% Unlikely to happen though. It is controled from the main function
if ~ishandle(hup) & ~ishandle(hdown)
    uiwait(errordlg('No regulated genes found!','Error'));
else
    if ishandle(hup)
        udataUp=get(hup,'UserData');
        EDataUp=get(hup,'XData');
        labelsUp=udataUp{1};
        treatedUp=udataUp{2};
        controlUp=udataUp{3};
        % effectUp=udataUp{4};
        pvalsUp=udataUp{5};
        condsUp=udataUp{6};
        excolUp=repmat('UP',[length(EDataUp) 1]);
        excolUp=cellstr(excolUp);
    else
        EDataUp=[];
        labelsUp=[];
        treatedUp=[];
        controlUp=[];
        % effectUp=[];
        pvalsUp=[];
        condsUp=[];
        excolUp=[];
    end
    if ishandle(hdown)
        udataDown=get(hdown,'UserData');
        EDataDown=get(hdown,'XData');
        labelsDown=udataDown{1};
        treatedDown=udataDown{2};
        controlDown=udataDown{3};
        % effectDown=udataDown{4};
        pvalsDown=udataDown{5};
        condsDown=udataDown{6};
        excolDown=repmat('DOWN',[length(EDataDown) 1]);
        excolDown=cellstr(excolDown);
    else
        EDataUp=[];
        labelsUp=[];
        treatedUp=[];
        controlUp=[];
        % effectUp=[];
        pvalsUp=[];
        condsUp=[];
        excolUp=[];
    end

    [filename,pathname]=uiputfile('*.txt','Export Volcano data');
    if filename==0
        return
    else
        fid=fopen(strcat(pathname,filename),'wt');
        if ~isempty(controlUp)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','GeneID',[condsUp{1} ' (Treated)'],...
                                                   [condsUp{2} ' (Control)'],...
                                                   'Effect','p-value','Regulation');
            for i=1:length(EDataUp)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\t%s\n',...
                            labelsUp{i},treatedUp(i),controlUp(i),EDataUp(i),pvalsUp(i),excolUp{i});
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[condsUp{1} ' (Treated)'],...
                                               'Effect','p-value','Regulation');
            for i=1:length(EDataUp)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%s\n',labelsUp{i},treatedUp(i),...
                                                            EDataUp(i),pvalsUp(i),excolUp{i});
            end
        end
        if ~isempty(controlDown)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','GeneID',[condsDown{1} ' (Treated)'],...
                                                   [condsDown{2} ' (Control)'],...
                                                   'Effect','p-value','Regulation');
            for i=1:length(EDataDown)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\t%s\n',...
                            labelsDown{i},treatedDown(i),controlDown(i),EDataDown(i),pvalsDown(i),excolDown{i});
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[condsDown{1} ' (Treated)'],...
                                               'Effect','p-value','Regulation');
            for i=1:length(EDataDown)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%s\n',labelsDown{i},treatedDown(i),...
                                                            EDataDown(i),pvalsDown(i),excolDown{i});
            end
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportNull(varargin)

count=get(gcbo,'UserData');
hnull=findobj('Tag',['bluedata',num2str(count)]);
if ~ishandle(hnull) % Unlikely to happen though. It is controled from the main function
    uiwait(errordlg('No unregulated genes found!','Error'));
else
    EData=get(hnull,'XData');
    udata=get(hnull,'UserData');
    labels=udata{1};
    treated=udata{2};
    control=udata{3};
    % effect=udata{4};
    pvals=udata{5};
    conds=udata{6};

    [filename,pathname]=uiputfile('*.txt','Export Volcano data');
    if filename==0
        return
    else
        fid=fopen(strcat(pathname,filename),'wt');
        if ~isempty(control)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[conds{1} ' (Treated)'],...
                                               [conds{2} ' (Control)'],'Effect','p-value');
            for i=1:length(EData)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\n',...
                            labels{i},treated(i),control(i),EData(i),pvals(i));
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID',[conds{1} ' (Treated)'],'Effect','p-value');
            for i=1:length(EData)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\n',labels{i},treated(i),EData(i),pvals(i));
            end
        end
        fprintf('\n')
        fclose(fid);
    end
end


function exportAll(varargin)

count=get(gcbo,'UserData');
hnull=findobj('Tag',['bluedata',num2str(count)]);
hup=findobj('Tag',['reddata',num2str(count)]);
hdown=findobj('Tag',['greendata',num2str(count)]);

if ishandle(hup) | ishandle(hdown)
    regexist=true;
else
    regexist=false;
end

if ishandle(hup)
    udataUp=get(hup,'UserData');
    EDataUp=get(hup,'XData');
    labelsUp=udataUp{1};
    treatedUp=udataUp{2};
    controlUp=udataUp{3};
    % effectUp=udataUp{4};
    pvalsUp=udataUp{5};
    condsUp=udataUp{6};
    if regexist
        excolUp=repmat('UP',[length(EDataUp) 1]);
        excolUp=cellstr(excolUp);
    end
else
    EDataUp=[];
    labelsUp=[];
    treatedUp=[];
    controlUp=[];
    % effectUp=[];
    pvalsUp=[];
    condsUp=[];
    if regexist
        excolUp=[];
    end
end
if ishandle(hdown)
    udataDown=get(hdown,'UserData');
    EDataDown=get(hdown,'XData');
    labelsDown=udataDown{1};
    treatedDown=udataDown{2};
    controlDown=udataDown{3};
    % effectDown=udataDown{4};
    pvalsDown=udataDown{5};
    condsDown=udataDown{6};
    if regexist
        excolDown=repmat('DOWN',[length(EDataDown) 1]);
        excolDown=cellstr(excolDown);
    end
else
    EDataDown=[];
    labelsDown=[];
    treatedDown=[];
    controlDown=[];
    % effectDown=[];
    pvalsDown=[];
    condsDown=[];
    if regexist
        excolDown=[];
    end
end
udataNull=get(hnull,'UserData');
EDataNull=get(hnull,'XData');
labelsNull=udataNull{1};
treatedNull=udataNull{2};
controlNull=udataNull{3};
% effectNull=udataNull{4};
pvalsNull=udataNull{5};
condsNull=udataNull{6};
if regexist
    excolNull=repmat('NULL',[length(EDataNull) 1]);
    excolNull=cellstr(excolNull);
end

[filename,pathname]=uiputfile('*.txt','Export MA data');
if filename==0
    return
else
    fid=fopen(strcat(pathname,filename),'wt');
    if regexist
        
        if ~isempty(controlUp)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','GeneID',[condsUp{1} ' (Treated)'],...
                                                   [condsUp{2} ' (Control)'],...
                                                   'Effect','p-value','Regulation');
            for i=1:length(EDataUp)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\t%s\n',...
                            labelsUp{i},treatedUp(i),controlUp(i),EDataUp(i),pvalsUp(i),excolUp{i});
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[condsUp{1} ' (Treated)'],...
                                               'Effect','p-value','Regulation');
            for i=1:length(EDataUp)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%s\n',labelsUp{i},treatedUp(i),...
                                                            EDataUp(i),pvalsUp(i),excolUp{i});
            end
        end
        if ~isempty(controlDown)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','GeneID',[condsDown{1} ' (Treated)'],...
                                                   [condsDown{2} ' (Control)'],...
                                                   'Effect','p-value','Regulation');
            for i=1:length(EDataDown)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\t%s\n',...
                            labelsDown{i},treatedDown(i),controlDown(i),EDataDown(i),pvalsDown(i),excolDown{i});
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[condsDown{1} ' (Treated)'],...
                                               'Effect','p-value','Regulation');
            for i=1:length(EDataDown)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%s\n',labelsDown{i},treatedDown(i),...
                                                            EDataDown(i),pvalsDown(i),excolDown{i});
            end
        end
        if ~isempty(controlNull)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','GeneID',[condsNull{1} ' (Treated)'],...
                                                   [condsNull{2} ' (Control)'],...
                                                   'Effect','p-value','Regulation');
            for i=1:length(EDataNull)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\t%s\n',...
                            labelsNull{i},treatedNull(i),controlNull(i),EDataNull(i),pvalsNull(i),excolNull{i});
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[condsNull{1} ' (Treated)'],...
                                               'Effect','p-value','Regulation');
            for i=1:length(EDataNull)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%s\n',labelsNull{i},treatedNull(i),...
                                                            EDataNull(i),pvalsNull(i),excolNull{i});
            end
        end
        
    else
        
        fprintf(fid,'%s\t%s\t%s\n','GeneID','Log Ratio (M)','Intensity (A)');
        if ~isempty(controlUp)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[condsUp{1} ' (Treated)'],...
                                                   [condsUp{2} ' (Control)'],'Effect','p-value');
            for i=1:length(EDataUp)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\n',...
                            labelsUp{i},treatedUp(i),controlUp(i),EDataUp(i),pvalsUp(i));
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID',[condsUp{1} ' (Treated)'],'Effect','p-value');
            for i=1:length(EDataUp)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\n',labelsUp{i},treatedUp(i),...
                                                            EDataUp(i),pvalsUp(i));
            end
        end
        if ~isempty(controlDown)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','GeneID',[condsDown{1} ' (Treated)'],...
                                                   [condsDown{2} ' (Control)'],'Effect','p-value');
            for i=1:length(EDataDown)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\n',...
                            labelsDown{i},treatedDown(i),controlDown(i),EDataDown(i),pvalsDown(i));
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID',[condsDown{1} ' (Treated)'],'Effect','p-value');
            for i=1:length(EDataDown)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\n',labelsDown{i},treatedDown(i),...
                                                        EDataDown(i),pvalsDown(i));
            end
        end
        if ~isempty(controlNull)
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','GeneID',[condsNull{1} ' (Treated)'],...
                                               [condsNull{2} ' (Control)'],'Effect','p-value');
            for i=1:length(EDataNull)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\t%5.5f\n',...
                            labelsNull{i},treatedNull(i),controlNull(i),EDataNull(i),pvalsNull(i));
            end
        else
            fprintf(fid,'%s\t%s\t%s\t%s\n','GeneID',[condsNull{1} ' (Treated)'],'Effect','p-value');
            for i=1:length(EDataNull)
                fprintf(fid,'%s\t%5.5f\t%5.5f\t%5.5f\n',labelsNull{i},treatedNull(i),...
                                                        EDataNull(i),pvalsNull(i));
            end
        end
        
    end
    fprintf('\n')
    fclose(fid);
end
