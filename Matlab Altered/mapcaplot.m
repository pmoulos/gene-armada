function output = mapcaplot(varargin)
%MAPCAPLOT creates a Principal Component plot of expression profile data.
%
%   MAPCAPLOT(DATA) creates 2D scatter plots of the principal component scores
%   of DATA.  The scores used for the x and y data are selected from popup
%   menus, below each scatter plot.
%
%   Once the scores have been plotted, a region can be selected in either axes
%   with the mouse.  This will highlight the points in the selected region, and
%   the corresponding points in the other axes.  This will also display a list
%   of the row numbers of the selected points in the listbox.  Selecting an
%   entry in the listbox will display a label with the row number in each axes,
%   at the corresponding point.  Clicking on a point in the scatter plot will
%   display a label with its row number until the mouse is released.
%
%   MAPCAPLOT(DATA,LABELS) uses the elements of the cell array of strings LABELS,
%   instead of the row numbers, to label the data points.
%
%   Example:
%
%    load filteredyeastdata
%    mapcaplot(yeastvalues,genes)
%
%   See also CLUSTERGRAM, PRINCOMP, MATTEST, MAVOLCANOPLOT.

% Copyright 2003-2006 The MathWorks, Inc.
% $Revision: 1.1.6.10 $   $Date: 2006/09/27 00:19:41 $

%  % Click and drag on scatter plots to create a "data brush"
%  % Click on a parallel coordinate line to highlite a data point.
%  % Select data column via the list boxes.

% Modified on 2007/10/20 by PM for the needs of ARMADA

error(nargchk(1,3,nargin)) %#ok

% Callback entry if one argument string
if nargin==1 && ischar(varargin{1})

    feval(varargin{1});
    % Special mode for testing from commandline
% elseif nargin >= 3 && ishandle(varargin{1}) && ischar(varargin{2})  %test mode
    % output = localDoTest(varargin{:});
    
    % First argument data, second argument is labels
elseif nargin>0

    % start with invisible figure
    startProps.Visible = 'off';
    fig = hgload('mapcaplot.fig',startProps);

    localDebug(fig,'Brush Tool Initialization');

    % Data must have at least 4 columns
    if size(varargin{1},1) < 4
        error('Bioinfo:mapcaplot:NotEnoughRows',...
            'Data input must have at least 4 rows.')
    end

    % initialize
    localInit(fig,varargin{:});

    % make figure visible
    set(fig,'Visible','on');
    if nargout > 0
        output = fig;
    end
    
else
    error('Bioinfo:mapcaplot:BadInputs',...
        'Incorrect input arguments')
end

%-----------------------------------------------%
function localInit(fig,varargin)
% Initialize tool

localDebug(fig,'localInit');

% center the figure onscreen
localCenterFig(fig);

% correct background of font labels
if ismac
   set([findall(fig,'String','vs');findall(fig,'String','Selected Data')],...
       'Background',get(fig,'Color'))
end

%store appdata
appdata = localGetAppData(fig);

if size(varargin{1},2) < 3
    error('Bioinfo:NotEnoughColumns',...
        'Data input must have at least 3 columns.')
end

% Assign data and labels
appdata.originaldata = varargin{1};
if size(appdata.originaldata,2) > size(appdata.originaldata,1)
    [appdata.pc,appdata.score,appdata.latent] = princomp(appdata.originaldata,'econ');
else
    [appdata.pc,appdata.score,appdata.latent] = princomp(appdata.originaldata);
end

% [appdata.pc,appdata.score] = princomp(appdata.originaldata);
% [junk1,junk2,appdata.latent] = princomp(appdata.originaldata); %#ok

appdata.percent = appdata.latent / sum(appdata.latent) * 100;


siz = size(appdata.originaldata);
numVals = numel(appdata.percent);
str = cell(1,numVals);
for n = 1:numVals
    str{n} = sprintf('Component # %d (%0.1f%%)',n,appdata.percent(n));
end
appdata.componentlabels = str;


if length(varargin)>1
    labels = varargin{2};
    if length(labels) < size(appdata.originaldata,1)
        error('Bioinfo:mapcaplot:LabelRowMismatch',...
            'The number of labels should match the number of rows in the input data')
    end
    appdata.rowlabels = labels;
else
    for n = 1:siz(1)
        str{n} = sprintf('Row %d',n);
    end
    appdata.rowlabels = str;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Addition by PM
if length(varargin)>2
    names = varargin{3};
    if length(names) < size(appdata.originaldata,2)
        error('Bioinfo:mapcaplot:LabelColumnMismatch',...
            'The number of names should match the number of columns in the input data')
    end
    appdata.columnlabels = names;
else
    strc = cell(size(appdata.originaldata,2),1);
    for n = 1:size(appdata.originaldata,2)
        strc{n} = sprintf('Column %d',n);
    end
    appdata.columnlabels = strc;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Set Axes properties
set(appdata.Axes1,'Units','Pixels','ButtonDown',@localCreateBrush_AxesButtonDownFcn);
set(appdata.Axes2,'Units','Pixels','ButtonDown',@localCreateBrush_AxesButtonDownFcn);

% Set popupmenu properties
set(appdata.axes1_x_popup,'String',appdata.componentlabels,'Value',1);
set(appdata.axes1_y_popup,'String',appdata.componentlabels,'Value',2);
set(appdata.axes2_x_popup,'String',appdata.componentlabels,'Value',1);
set(appdata.axes2_y_popup,'String',appdata.componentlabels,'Value',3);

set(appdata.axes1_x_popup,'Callback',@localPopupmenuCallback);
set(appdata.axes1_y_popup,'Callback',@localPopupmenuCallback);
set(appdata.axes2_x_popup,'Callback',@localPopupmenuCallback);
set(appdata.axes2_y_popup,'Callback',@localPopupmenuCallback);

% Create red data markers which appear on data points when it is brushed
lineprops.Parent = appdata.Axes1;
lineprops.Color = 'red';
lineprops.MarkerFaceColor = 'red';
lineprops.LineStyle = 'none';
lineprops.Marker = 'Square';
lineprops.XData = nan;
lineprops.YData = nan;
lineprops.Tag = 'dataline1';
appdata.datamarker(1) = line(lineprops);
lineprops.Parent = appdata.Axes2;
lineprops.Tag = 'dataline2';
appdata.datamarker(2) = line(lineprops);
set(appdata.expbutton, 'Enable', 'off');

% Save state
localSetAppData(fig,appdata);

% Update plots
localUpdateBrushPlots(fig);

set(fig,'WindowButtonMotionFcn',{@localChangeCursorMotionFcn,fig})

%-----------------------------------------------%
function localUpdateBrushPlots(fig)
% Update the two scatter plots at the bottom of the figure

localDebug(fig,'localUpdateBrushPlots');

appdata = localGetAppData(fig);

% Get specified data
INDEX_DIM1 = get(appdata.axes1_x_popup,'Value');
INDEX_DIM2 = get(appdata.axes1_y_popup,'Value');
INDEX_DIM3 = get(appdata.axes2_x_popup,'Value');
INDEX_DIM4 = get(appdata.axes2_y_popup,'Value');

% get data
data = appdata.score;

% index data to get x,y data
xdata = data(:,INDEX_DIM1);
ydata = data(:,INDEX_DIM2);

% get rid of the existing plot
if ishandle(appdata.scatterplot)
    delete(appdata.scatterplot);
end

% clear the locations for the red data markers
if ishandle(appdata.datamarker)
    set(appdata.datamarker,'xdata',nan,'ydata',nan);
end

if ishandle(appdata.SelectedText)
    delete(appdata.SelectedText);
end
if ishandle(appdata.SelectedMarkers)
    delete(appdata.SelectedMarkers);
end
appdata.SelectedText = [];
appdata.SelectedMarkers = [];

% Create Upper Scatter Plot
scatterplot.Parent =  appdata.Axes1;
scatterplot.XData = xdata;
scatterplot.YData = ydata;
scatterplot.LineStyle = 'none';
scatterplot.Marker = 'square';
scatterplot.MarkerSize = 4;
scatterplot.MarkerFaceColor = 'blue';
scatterplot.ButtonDownFcn = @localLabelPoint;
appdata.scatterplot(1) = line(scatterplot);

% Create Lower Scatter Plot
xdata = data(:,INDEX_DIM3);
ydata = data(:,INDEX_DIM4);
scatterplot.XData = xdata;
scatterplot.YData = ydata;
scatterplot.Parent = appdata.Axes2;
appdata.scatterplot(2) = line(scatterplot);

% Add Labels to Axes
str = get(appdata.axes1_x_popup,'String');
val = get(appdata.axes1_x_popup,'Value');
delete(get(appdata.Axes1,'XLabel'));
xlabel(appdata.Axes1,str{val});

str = get(appdata.axes1_y_popup,'String');
val = get(appdata.axes1_y_popup,'Value');
delete(get(appdata.Axes1,'YLabel'));
ylabel(appdata.Axes1,str{val});
% hlabel(2) = get(appdata.Axes1,'ylabel');
% set(hlabel(2),'string',str{val});

str = get(appdata.axes2_x_popup,'String');
val = get(appdata.axes2_x_popup,'Value');
delete(get(appdata.Axes2,'XLabel'));
xlabel(appdata.Axes2,str{val});
% hlabel(3) = get(appdata.Axes2,'xlabel');
% set(hlabel(3),'string',str{val});

str = get(appdata.axes2_y_popup,'String');
val = get(appdata.axes2_y_popup,'Value');
delete(get(appdata.Axes2,'YLabel'));
ylabel(appdata.Axes2,str{val});
% hlabel(4) = get(appdata.Axes2,'ylabel');
% set(hlabel(4),'string',str{val});

% ax = appdata.Axes1;
% set(hlabel,'FontAngle',  get(ax, 'FontAngle'), ...
%           'FontName',   get(ax, 'FontName'), ...
%           'FontSize',   get(ax, 'FontSize'), ...
%           'FontWeight', get(ax, 'FontWeight'));

% Let MATLAB pick the best axis limits
axis(appdata.Axes1,'auto');
axis(appdata.Axes2,'auto');

% Prevent further change to axis limits
drawnow;
axis(appdata.Axes1,'manual');
axis(appdata.Axes2,'manual');

% store the data
localSetAppData(fig,appdata);

%-----------------------------------------------%

% -- CALLBACKS -- %

% %-----------------------------------------------%
% function localClickedOnLine
% % User clicked on a line in the parallel coordinated axes
%
% fig = gcbf;
%
% localDebug(fig,'localClickedOnLine');
%
% appdata = localGetAppData(fig);
%
% % Remove brush
%
% % set(appdata.BrushHandle,'visible','off','parent',appdata.ParallelCoordinateAxes);
% set(appdata.BrushHandle,'visible','off');
%
% % Determine which index we selected
% n = getappdata(gcbo,'INDEX');
%
% localSetAppData(fig,appdata);
%
% localSelectIndices(fig,n);

%--------------------------------------------------------%
function localSelectIndices(fig,n)
% Select data points to highlite

localDebug(fig,'localSelectIndices');

appdata = localGetAppData(fig);

datamarker = appdata.datamarker;
brushhandle = appdata.BrushHandle; %#ok

if isempty(n)
    set(datamarker,'Visible','off')
    set(appdata.selected_list,'String','')
    set(appdata.expbutton, 'Enable', 'off');
    appdata.SelectedIndices = [];
    localSetAppData(fig,appdata);
    return
end

% Highlite selected point
INDEX_DIM1 = get(appdata.axes1_x_popup,'Value');
INDEX_DIM2 = get(appdata.axes1_y_popup,'Value');
INDEX_DIM3 = get(appdata.axes2_x_popup,'Value');
INDEX_DIM4 = get(appdata.axes2_y_popup,'Value');

data = appdata.score;
xdata = data(n,INDEX_DIM1);
ydata = data(n,INDEX_DIM2);
set(datamarker(1),'xdata',xdata,'ydata',ydata,'Visible','on');
xdata = data(n,INDEX_DIM3);
ydata = data(n,INDEX_DIM4);
set(datamarker(2),'xdata',xdata,'ydata',ydata,'Visible','on');

% % reorder the children, so the highlighted data appears on top
% ch1 = get(appdata.Axes1,'Children');
% ch2 = get(appdata.Axes2,'Children');
% if numel(ch1) >2
%     set(appdata.Axes1,'Children',[brushhandle; datamarker(1); scatterplot(1)]);
%     set(appdata.Axes2,'Children',[datamarker(2); scatterplot(2)]);
% else
%     set(appdata.Axes2,'Children',[brushhandle; datamarker(2); scatterplot(2)]);
%     set(appdata.Axes1,'Children',[datamarker(1); scatterplot(1)]);
% end


appdata.SelectedIndices = n;
if ishandle(appdata.SelectedText)
    delete(appdata.SelectedText);
end
if ishandle(appdata.SelectedMarkers)
    delete(appdata.SelectedMarkers);
end
appdata.SelectedText = [];
appdata.SelectedMarkers = [];

localSetAppData(fig,appdata);

selected_rows = appdata.rowlabels(n);
set(appdata.selected_list,'String',selected_rows(:),'Value',[]);
set(appdata.expbutton, 'Enable', 'on');

%--------------------------------------------------------%
function localPopupmenuCallback(h,eventdata) %#ok
% User changes data through popup menus

fig = gcbf;

localDebug(fig,'localPopupmenuCallback');

appdata = localGetAppData(fig);


% Remove brush
set(appdata.BrushHandle,'visible','off');
set(appdata.selected_list,'String','')
set(appdata.expbutton, 'Enable', 'off');
% Update plots
localUpdateBrushPlots(fig);

%-----------------------------------------------%
function [ret_ax] = localGetAxes(fig)

localDebug(fig,'localGetAxes');

appdata = localGetAppData(fig);

% Get the axes that we clicked in
ret_ax = [];
ax(1) = appdata.Axes1;
ax(2) = appdata.Axes2;
cp = get(fig,'CurrentPoint');
for i=1:length(ax),
    candidate_ax=ax(i);
    pos = get(candidate_ax,'position');
    if cp(1) >= pos(1) && cp(1) <= pos(1)+pos(3) && ...
            cp(2) >= pos(2) && cp(2) <= pos(2)+pos(4)
        ret_ax = candidate_ax;
        break
    end % if
end % for

%-----------------------------------------------%
function localCreateBrush_WindowButtonUpFcn(h,eventdata)%#ok
% Turn off brush creation when user clicks up

fig = gcbf;

localDebug(fig,'localCreateBrush_WindowButtonUpFcn');

set(fig,'WindowButtonUpFcn','');
appdata = localGetAppData(fig);

appdata.BrushPrevX = [];
appdata.BrushPrevY = [];

localSetAppData(fig,appdata);
% drawnow; % Commented out for it caused problem on Unix platform see G299343.
localUpdateHighlite(fig);

%-----------------------------------------------%
function localCreateBrush_AxesButtonDownFcn(h,eventdata)%#ok
% Buttondown functions for the brush axes

% Listen to window events
fig = gcbf;

localDebug(fig,'localCreateBrush_AxesButtonDownFcn');

set(fig,'WindowButtonUpFcn',@localCreateBrush_WindowButtonUpFcn);

appdata = localGetAppData(fig);
brush_axes = localGetAxes(fig);

% Bail out early if we didn't click on the axes
if isempty(brush_axes)
    return;
end

appdata.ClickedAxes = brush_axes;

% Create brush handle if we haven't already
hbrush = appdata.BrushHandle;
if isempty(hbrush)
    hbrush = line('XData',nan,...
        'YData',nan,...
        'Parent',appdata.Axes1,...
        'Visible','off',...
        'Color','r',...
        'LineWidth',3,...
        'ButtonDownFcn','mapcaplot localBrushButtonDown',...
        'Tag','brushhandle');
    appdata.BrushHandle = hbrush;
    localSetAppData(fig,appdata);
end

% Update brush rectangle if the user is clicking in a different axes
% appdata.BrushPrevPoint = [];
localSetAppData(fig,appdata);


point1 = get(brush_axes,'CurrentPoint');    % button down detected
finalRect = rbbox;                   %#ok return figure units
point2 = get(brush_axes,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions

% Rectangle coordinates
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];

xl = get(brush_axes,'XLim');
yl = get(brush_axes,'YLim');

% ignore selection outside of axes
x(x < xl(1)) = xl(1);
x(x > xl(2)) = xl(2);
y(y < yl(1)) = yl(1);
y(y > yl(2)) = yl(2);

% Update brush handle
set(hbrush,'parent',brush_axes,'xdata',x,'ydata',y,'visible','on');
localUpdateHighlite(fig);


%-----------------------------------------------%
function localBrushButtonDown
% User clicked on brush

% Swap in new window event functions
fig = gcbf;

localDebug(fig,'localBrushButtonDown');

set(fig,'WindowButtonMotionFcn','mapcaplot localMoveBrush_WindowButtonMotionFcn');
set(fig,'WindowButtonUpFcn','mapcaplot localMoveBrush_WindowButtonUpFcn');
set(fig,'Pointer','fleur');

%-----------------------------------------------%
function localMoveBrush_WindowButtonUpFcn
% Swap in new window event functions
fig = gcbf;

localDebug(fig,'localMoveBrush_WindowButtonUpFcn');

localUpdateHighlite(fig);

set(fig,'WindowButtonMotionFcn',{@localChangeCursorMotionFcn,fig});
set(fig,'WindowButtonUpFcn','');
set(fig,'Pointer','arrow');

%-----------------------------------------------%
function localMoveBrush_WindowButtonMotionFcn

fig = gcbf;
localDebug(fig,'localMoveBrush_WindowButtonMotionFcn');

appdata = localGetAppData(fig);

if ishandle(appdata.BrushHandle)
    ax = get(appdata.BrushHandle,'parent');
    cp = get(ax,'CurrentPoint');

    if isempty(appdata.BrushPrevX);
        appdata.BrushPrevX = cp(1,1);
        appdata.BrushPrevY = cp(1,2);
    else
        delta_x = cp(1,1) - appdata.BrushPrevX;
        delta_y = cp(1,2) - appdata.BrushPrevY;
        appdata.BrushPrevX = cp(1,1);
        appdata.BrushPrevY = cp(1,2);
        x = get(appdata.BrushHandle,'xdata');
        y = get(appdata.BrushHandle,'ydata');
        new_x = x + delta_x;
        new_y = y + delta_y;

        xlm = xlim(ax);
        ylm = ylim(ax);

        % Don't let the brush go beyond the axes
        if min(new_x) < xlm(1) || max(new_x) > xlm(2)
            new_x = x;
        end
        if min(new_y) < ylm(1) || max(new_y) > ylm(2)
            new_y = y;
        end

        % Update brush position
        set(appdata.BrushHandle,'xdata',new_x,'ydata',new_y);
    end
    localUpdateHighlite(fig);
end

localSetAppData(fig,appdata);

%-----------------------------------------------%
function localChangeCursorMotionFcn(obj,evd,fig) %#ok
obj = hittest(fig);
objtype = get(obj,'Type');

if ~strcmp(objtype,'line')
    set(fig,'Pointer','arrow');
    return
end

objtag = get(obj,'Tag');

if strcmp(objtag,'brushline')
    set(fig,'Pointer','fleur');
    return
end

set(fig,'Pointer','crosshair');


%-----------------------------------------------%
function localLabelPoint(h,eventdata) %#ok

h = gcbo;

ax = get(h,'Parent');

fig = gcbf;

appdata = localGetAppData(fig);

xdata = get(h,'XData');
ydata = get(h,'YData');

cp = get(ax,'CurrentPoint');

x_click = cp(1,1);
y_click = cp(1,2);

x_lim = get(ax,'XLim');
y_lim = get(ax,'YLim');

x_lim_diff = diff(x_lim);
y_lim_diff = diff(y_lim);

x_range = sort(x_click + x_lim_diff * [-.01 .01]);
y_range = sort(y_click + y_lim_diff * [-.01 .01]);

ind = find(x_range(1) < xdata & xdata < x_range(2) & y_range(1) < ydata & ydata < y_range(2));

% loop until a values is found
while isempty(ind)
    x_range = sort(x_range + x_lim_diff * [-.01 .01]);
    y_range = sort(y_range + y_lim_diff * [-.01 .01]);

    ind = find(x_range(1) < xdata & xdata < x_range(2) & y_range(1) < ydata & ydata < y_range(2));
end

% just use the first point:

ind = ind(1);


xval = xdata(ind);
yval = ydata(ind);

rowlabel = appdata.rowlabels{ind};

% create a text object to display the label
t = text('Parent',ax,...
    'Position',[(xval + x_lim_diff*.02) (yval + y_lim_diff*.05)],...
    'String',rowlabel,...
    'HorizontalAlignment','left',...
    'BackgroundColor','white',...
    'EdgeColor','black',...
    'HandleVisibility','off');
p = line('Parent',ax,...
    'XData',xval,...
    'YData',yval,...
    'Color','white',...
    'Marker','o',...
    'MarkerSize',1);

set(fig,'WindowButtonUpFcn',{@localRemoveLabelButtonUpFcn,fig,t,p})


%-----------------------------------------------%
function localRemoveLabelButtonUpFcn(obj,evd,fig,t,p) %#ok

set(fig,'WindowButtonUpFcn','');
delete(t);
delete(p);



%-----------------------------------------------%
function localUpdateHighlite(fig)
% Update what data is highlited

localDebug(fig,'localUpdateHighlite');

appdata = localGetAppData(fig);
data = appdata.score;

INDEX_DIM1 = get(appdata.axes1_x_popup,'Value');
INDEX_DIM2 = get(appdata.axes1_y_popup,'Value');
INDEX_DIM3 = get(appdata.axes2_x_popup,'Value');
INDEX_DIM4 = get(appdata.axes2_y_popup,'Value');

xdata = get(appdata.BrushHandle,'xdata');
ydata = get(appdata.BrushHandle,'ydata');

maxd1 = max(xdata);
mind1 = min(xdata);

maxd2 = max(ydata);
mind2 = min(ydata);

% ax = localGetAxes(fig);

ax = appdata.ClickedAxes;


if isempty(ax)
    return;
end


if ax == appdata.Axes1
    d1 = data(:, INDEX_DIM1);
    d2 = data(:, INDEX_DIM2);
    n = find( d1<maxd1 & d1>mind1 & d2<maxd2 & d2>mind2 );
    localSelectIndices(fig,n);
elseif ax == appdata.Axes2
    d1 = data(:, INDEX_DIM3);
    d2 = data(:, INDEX_DIM4);
    n = find( d1<maxd1 & d1>mind1 & d2<maxd2 & d2>mind2 );
    localSelectIndices(fig,n);
end

%-----------------------------------------------%
function localSelectedListCallback %#ok
fig = gcbf;

localDebug(fig,'localSelectedListCallback');

appdata = localGetAppData(fig);

for n = 1:numel(appdata.SelectedText)
    if ishandle(appdata.SelectedText(n))
        delete(appdata.SelectedText(n));
    end
end

appdata.SelectedText = [];

for n = 1:numel(appdata.SelectedMarkers)
    if ishandle(appdata.SelectedMarkers(n))
        delete(appdata.SelectedMarkers(n));
    end
end

appdata.SelectedMarkers = [];

h = appdata.selected_list;
n = appdata.SelectedIndices;

if isempty(n)
    localSetAppData(fig,appdata);
    return;
end

x_lim_ax1 = get(appdata.Axes1,'XLim');
y_lim_ax1 = get(appdata.Axes1,'YLim');

x_lim_diff_ax1 = diff(x_lim_ax1);
y_lim_diff_ax1 = diff(y_lim_ax1);

x_lim_ax2 = get(appdata.Axes2,'XLim');
y_lim_ax2 = get(appdata.Axes2,'YLim');

x_lim_diff_ax2 = diff(x_lim_ax2);
y_lim_diff_ax2 = diff(y_lim_ax2);

INDEX_DIM1 = get(appdata.axes1_x_popup,'Value');
INDEX_DIM2 = get(appdata.axes1_y_popup,'Value');
INDEX_DIM3 = get(appdata.axes2_x_popup,'Value');
INDEX_DIM4 = get(appdata.axes2_y_popup,'Value');

xdata1 = appdata.score(n,INDEX_DIM1);
ydata1 = appdata.score(n,INDEX_DIM2);

xdata2 = appdata.score(n,INDEX_DIM3);
ydata2 = appdata.score(n,INDEX_DIM4);


v = get(h,'Value');
selected = n(v);

t = zeros(length(v),2);
p = zeros(length(v),2);
for i = 1:length(selected)
    ind = v(i);
    t(i,1) = text('Parent',appdata.Axes1,...
        'Position',[(xdata1(ind) + x_lim_diff_ax1*.02) (ydata1(ind) + y_lim_diff_ax1*.05)],...
        'String',appdata.rowlabels{selected(i)},...
        'HorizontalAlignment','left',...
        'BackgroundColor','white',...
        'EdgeColor','black',...
        'ButtonDownFcn','mapcaplot localDeleteMatching');
    p(i,1) = line('Parent',appdata.Axes1,...
        'XData',xdata1(ind),...
        'YData',ydata1(ind),...
        'Color','white',...
        'Marker','o');
    t(i,2) = text('Parent',appdata.Axes2,...
        'Position',[(xdata2(ind) + x_lim_diff_ax2*.02) (ydata2(ind) + y_lim_diff_ax2*.05)],...
        'String',appdata.rowlabels{selected(i)},...
        'HorizontalAlignment','left',...
        'BackgroundColor','white',...
        'EdgeColor','black',...
        'ButtonDownFcn','mapcaplot localDeleteMatching');
    p(i,2) = line('Parent',appdata.Axes2,...
        'XData',xdata2(ind),...
        'YData',ydata2(ind),...
        'Color','white',...
        'Marker','o');
end

appdata.SelectedText = t;
appdata.SelectedMarkers = p;
localSetAppData(fig,appdata);

%---------Export selected list----------------------%
function localExportSelectedList(varargin) %#ok
[obj,hfig] = gcbo; %#ok
appdata = localGetAppData(hfig);
bmf = get(hfig,'WindowButtonMotionFcn');
bdf = get(hfig,'WindowButtonDownFcn');
set(hfig,'WindowButtonMotionFcn','','WindowButtonDownFcn','');

selindices = appdata.SelectedIndices;
sellist = appdata.rowlabels(selindices);
seldata = appdata.originaldata(selindices,:);
colnames = appdata.columnlabels;

[filename,pathname]=uiputfile('*.txt','Export PCA data');
    if filename==0
        return
    else
        fid=fopen(strcat(pathname,filename),'wt');
        % Write first line
        frmth=[repmat('%s\t',[1 length(colnames)+1]),'\n'];
        headstr=cell(1,length(colnames)+1);
        headstr{1}='''GeneID'',';
        for i=2:length(headstr)-1
            headstr{i}=['''',colnames{i-1},''','];
        end
        headstr{end}=['''',colnames{end},''''];
        headstr=cell2mat(headstr);
        evalstrh=['fprintf(fid,frmth,',headstr,');'];
        eval(evalstrh);
        
        % Print rest of data
        frmtd=['%s\t',repmat('%5.5f\t',[1 length(colnames)]),'\n'];
        datastr=cell(1,length(colnames)+1);
        datastr{1}='sellist{currind},';
        for j=2:length(datastr)-1
            datastr{j}=['seldata(currind,',num2str(j-1),'),'];
        end
        datastr{end}=['seldata(currind,',num2str(size(seldata,2)),')'];
        datastr=cell2mat(datastr);
        for i=1:size(seldata,1)
            evalstrd=['fprintf(fid,frmtd,',datastr,');'];
            evalstrd=strrep(evalstrd,'currind',num2str(i));
            eval(evalstrd)
        end
        fclose(fid);
    end

set(hfig,'WindowButtonMotionFcn', bmf);
set(hfig,'WindowButtonDownFcn', bdf);


%-----------------------------------------------%
function localDeleteMatching %#ok
fig = gcbf;
appdata = localGetAppData(fig);

t = gco;

[r,c] = find(appdata.SelectedText == t,1);%#ok

delete(appdata.SelectedText(r,:));
delete(appdata.SelectedMarkers(r,:));
appdata.SelectedText(r,:) = [];
appdata.SelectedMarkers(r,:) = [];

%n = appdata.SelectedIndices;
v = get(appdata.selected_list,'Value');
v(r) = [];
set(appdata.selected_list,'Value',v);

localSetAppData(fig,appdata);

%-----------------------------------------------%
function [appdata] = localGetAppData(fig)

% localDebug('localGetAppData');
if isappdata(fig,'MAPCAPLOTTool')
    appdata = getappdata(fig,'MAPCAPLOTTool');
else
    appdata = guihandles(fig);

    % add fields for data, labels, line
    appdata.originaldata = [];
    appdata.pc = [];
    appdata.score = [];
    appdata.latent = [];
    appdata.percent = [];
    appdata.componentlabels = [];
    appdata.rowlabels = [];
    appdata.scatterplot = [];
    appdata.datamarker = [];


    % ...for brushing
    %     appdata.BrushPrevPoint = [];
    appdata.BrushHandle = [];
    appdata.BrushPrevX = [];
    appdata.BrushPrevY = [];
    appdata.ClickedAxes = [];
    appdata.SelectedIndices = [];
    appdata.SelectedText = [];
    appdata.SelectedMarkers = [];

    % for debugging
    appdata.Debug = false;
end

%-----------------------------------------------%
function localSetAppData(fig,appdata)

localDebug(fig,'localSetAppData');

setappdata(fig,'MAPCAPLOTTool',appdata);


%-----------------------------------------------%
function localCenterFig(fig)

localDebug(fig,'localCenterFig');

rootUnits = get(0,'Units');
set(0,'Units','pixels');
rootScrSize = get(0,'ScreenSize');
set(0,'Units',rootUnits);

rootWidth = rootScrSize(3);
rootHeight = rootScrSize(4);

figUnits = get(fig,'Units');
set(fig,'Units','Pixels');

figPos = get(fig,'Position');

figWidth = figPos(3);
figHeight = figPos(4);

figPos = [(rootWidth - figWidth)/2, (rootHeight - figHeight)/2, figWidth, figHeight];
set(fig,'Position',figPos);

set(fig,'Units',figUnits);

%-----------------------------------------------%
function localDebug(fig,fcn,varargin)

appdata = localGetAppData(fig);

if ~appdata.Debug
    return
end

if ~isempty(varargin)
    str = sprintf(' : %s',varargin{:});
    disp([fcn str])
    return
end

disp(fcn)
%-----------------------------------------------%
function output = localDoTest(fig,fcn,varargin)
appdata = localGetAppData(fig);
if strcmpi(fcn,'-setSelectedIndices')
    localSelectIndices(fig,varargin{1})
    output = [];
else
    output = appdata.(varargin{1});
end
