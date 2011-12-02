function hp = plotMANorm(inten,logratnorm,varargin)

% Count is a variable to help when this function is called multiple times from ARMADA.
% It helps naming handle objects and distinguishing them with the find function

% Set defaults
titre='MA Plot';
disfcline=false;
fc=[];
labels='';
affyvalstruct=[];
count=1;

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'title','displayfcline','foldchange','labels','foraffy','count'};
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
                case 2 % Display fold change cutoff line
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        disfcline=parVal;
                    end
                case 3 % Fold change cutoff
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
                case 4 % Labels
                    if ~iscellstr(parVal) && ~isempty(parVal)
                        error('The %s parameter value must be a cell array of strings or empty',parName)
                    else
                        labels=parVal;
                    end
                case 5 % Affy values
                    if ~isstruct(parVal) && ~isempty(parVal)
                        error('The %s parameter value must be a structure',parName)
                    end
                    if isstruct(parVal)
                        if ~isfield(parVal,'type') && ~isfield(parVal,'scale')
                            error('The %s parameter value must have fields ''type'' and ''scale''',parName)
                        else
                            affyvalstruct=parVal;
                        end
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

if ~isempty(affyvalstruct)
    [inten,logratnorm,logfc]=affytransform(inten,logratnorm,fc,affyvalstruct);
else
    logfc=log2(fc);
end

goodvals=~isnan(logratnorm);
inten=inten(goodvals);
logratnorm=logratnorm(goodvals);
if ~isempty(labels)
    labels=labels(goodvals);
end

if isscalar(fc)
    logfc=[-logfc logfc];
end

if length(inten)>1e+5
    msize=2;
else
    msize=6;
end

% Plot MA data
figure
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
    h=plot(blueinten,bluelogratnorm,'.b','MarkerSize',msize);
    hold on
    if ~isempty(redinten)
        hred=plot(redinten,redlogratnorm,'.r','MarkerSize',msize);
    else
        hred=[];
    end
    if ~isempty(greeninten)
        hgreen=plot(greeninten,greenlogratnorm,'.g','MarkerSize',msize);
    else
        hgreen=[];
    end
    % Display fold line
    hline=fclines(h,logfc);
else
    h=plot(inten,logratnorm,'.b','MarkerSize',msize);
    hred=[];
    hgreen=[];
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
if ~disfcline
    strleg={'MA data'};
else
    if ~isempty(hred) && ~isempty(hgreen)
        hall=[hall;hred;hgreen;hline(1)];
        strleg={'MA data','Up regulated','Down regulated','Fold change cutoff'};
    elseif ~isempty(hred) && isempty(hgreen)
        hall=[hall;hred;hline(1)];
        strleg={'MA data','Up regulated','Fold change cutoff'};
    elseif isempty(hred) && ~isempty(hgreen)
        hall=[hall;hgreen;hline(1)];
        strleg={'MA data','Down regulated','Fold change cutoff'};
    elseif isempty(hred) && isempty(hgreen)
        hall=[hall;hline(1)];
        strleg={'MA data','Fold change cutoff'};
    end
end
legend(hall,strleg)

% If labels exist, set up a buttondown function
if ~isempty(labels)
    if ~disfcline
        hax=get(h,'Parent');
        set(hax,'UserData',[h,count],...
                'Tag',['allaxisafter',num2str(count)],...
                'ButtonDownFcn',@clickonplot);
        set(h,'UserData',{labels,inten,logratnorm,count},...
              'Tag',['bluedataafter',num2str(count)],...
              'ButtonDownFcn',@clickonplot);
    else
        % They are all on the same axis
        hax=get(h,'Parent');
        set(hax,'UserData',[h,hred,hgreen,count],...
                'Tag',['allaxisafter',num2str(count)],...
                'ButtonDownFcn',@clickonplot);
        udatablue={labels(logratnorm<logfc(2) & logratnorm>logfc(1)),...
                   inten(logratnorm<logfc(2) & logratnorm>logfc(1)),...
                   logratnorm(logratnorm<logfc(2) & logratnorm>logfc(1)),...
                   count};
        set(h,'UserData',udatablue,...
              'Tag',['bluedataafter',num2str(count)],...
              'ButtonDownFcn',@clickonplot);
        udatared={labels(logratnorm>=logfc(2)),...
                  inten(logratnorm>=logfc(2)),...
                  logratnorm(logratnorm>=logfc(2)),...
                  count};
        set(hred,'UserData',udatared,...
                 'Tag',['reddataafter',num2str(count)],...
                 'ButtonDownFcn',@clickonplot);
        udatagreen={labels(logratnorm<=logfc(1)),...
                    inten(logratnorm<=logfc(1)),...
                    logratnorm(logratnorm<=logfc(1)),...
                    count};
        set(hgreen,'UserData',udatagreen,...
                   'Tag',['greendataafter',num2str(count)],...
                   'ButtonDownFcn',@clickonplot);
    end
    
    % Create the context menu for exporting
    exportmenu=uicontextmenu('Tag',['rightMenuAfter',num2str(count)]);
    item1=uimenu(exportmenu,'Label','Select Data',...
                            'Callback',@enterSelectState,...
                            'Tag',['selectDataAfter',num2str(count)],...
                            'UserData',count);
    item2=uimenu(exportmenu,'Label','Export Selected',...
                            'Callback',@exportSelected,...
                            'Tag',['exportSelectedAfter',num2str(count)],...
                            'Enable','off');
    item3=uimenu(exportmenu,'Label','Export up regulated',...
                            'Callback',@exportUp,...
                            'Tag',['exportUpAfter',num2str(count)],...
                            'Enable','on',...
                            'UserData',count);
    item4=uimenu(exportmenu,'Label','Export down regulated',...
                            'Callback',@exportDown,...
                            'Tag',['exportDownAfter',num2str(count)],...
                            'Enable','on',...
                            'UserData',count);
    item5=uimenu(exportmenu,'Label','Export deregulated',...
                            'Callback',@exportUpDown,...
                            'Tag',['exportUpDownAfter',num2str(count)],...
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
    set(h,'UIContextMenu',exportmenu)
    if ~isempty(hred)
        set(hred,'UIContextMenu',exportmenu)
    end
    if ~isempty(hgreen)
        set(hgreen,'UIContextMenu',exportmenu)
    end
    if disfcline
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


function [tx,ty,tc] = affytransform(x,y,c,opts)

% Change of scale, everything must be in log2
if ismember(opts.type,107:109) 
    switch opts.scale
        case 'log'
            tx=log2(exp(x));
            ty=log2(exp(y));
            tc=log2(exp(c));
        case 'log2'
            tx=x;
            ty=y;
            tc=c;
        case 'log10'
            tx=log2(10.^x);
            ty=log2(10.^y);
            tc=log2(10.^c);
        case 'natural'
            tx=log2(x);
            ty=log2(y);
            tc=log2(c);
    end
    tx=(tx+ty)/2;
    ty=tx-ty;
else
    tx=(log2(x)+log2(y))/2;
    ty=log2(x)-log2(y);
    tc=log2(c);
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
    hallaxisafter=findobj('Tag',['allaxisafter',num2str(count)]);
    hbluedata=findobj('Tag',['bluedataafter',num2str(count)]);
    hreddata=findobj('Tag',['reddataafter',num2str(count)]);
    hgreendata=findobj('Tag',['greendataafter',num2str(count)]);
    if ~isempty(hallaxisafter) && ishandle(hallaxisafter)
        set(hallaxisafter,'ButtonDownFcn',@selectData)
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
    prevbox=findobj('Tag',['selectedRegionAfter',num2str(count)]);
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
    hallaxisafter=findobj('Tag',['allaxisafter',num2str(count)]);
    hbluedata=findobj('Tag',['bluedataafter',num2str(count)]);
    hreddata=findobj('Tag',['reddataafter',num2str(count)]);
    hgreendata=findobj('Tag',['greendataafter',num2str(count)]);
    if ~isempty(hallaxisafter) && ishandle(hallaxisafter)
        set(hallaxisafter,'ButtonDownFcn',@clickonplot)
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
    item2=findobj('Tag',['exportSelectedAfter',num2str(count)]);
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
prevbox=findobj('Tag',['selectedRegionAfter',num2str(count)]);
if ishandle(prevbox)
    delete(prevbox);
end
prevpts=findobj('Tag',['selectedPoints',num2str(count)]);
if ishandle(prevpts)
    delete(prevpts);
end

% Get some useful data
hallaxisafter=findobj('Tag',['allaxisafter',num2str(count)]);
hObject=get(hallaxisafter,'UserData');
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
xlims=get(hallaxisafter,'XLim');
ylims=get(hallaxisafter,'YLim');
x(x<xlims(1))=xlims(1);
x(x>xlims(2))=xlims(2);
y(y<ylims(1))=ylims(1);
y(y>ylims(2))=ylims(2);

% Draw it
hold on
axis manual
selrect=plot(x,y,'m-','Tag',['selectedRegionAfter',num2str(count)]);
set(selrect,'LineWidth',3)

% Set our context menu for the box drawed
conmenu=findobj('Tag',['rightMenuAfter',num2str(count)]);
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
item2=findobj('Tag',['exportSelectedAfter',num2str(count)]);
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


function exportUp(varargin)

count=get(gcbo,'UserData');
hup=findobj('Tag',['reddataafter',num2str(count)]);
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


function exportDown(varargin)

count=get(gcbo,'UserData');
hdown=findobj('Tag',['greendataafter',num2str(count)]);
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


function exportUpDown(varargin)

count=get(gcbo,'UserData');
hup=findobj('Tag',['reddataafter',num2str(count)]);
hdown=findobj('Tag',['greendataafter',num2str(count)]);
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


function exportNull(varargin)

count=get(gcbo,'UserData');
hnull=findobj('Tag',['bluedataafter',num2str(count)]);
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


function exportAll(varargin)

count=get(gcbo,'UserData');
hnull=findobj('Tag',['bluedataafter',num2str(count)]);
hup=findobj('Tag',['reddataafter',num2str(count)]);
hdown=findobj('Tag',['greendataafter',num2str(count)]);

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
