function varargout = HierarchicalClusteringEditor(varargin)
% HIERARCHICALCLUSTERINGEDITOR M-file for HierarchicalClusteringEditor.fig
%      HIERARCHICALCLUSTERINGEDITOR, by itself, creates a new HIERARCHICALCLUSTERINGEDITOR or raises the existing
%      singleton*.
%
%      H = HIERARCHICALCLUSTERINGEDITOR returns the handle to a new HIERARCHICALCLUSTERINGEDITOR or the handle to
%      the existing singleton*.
%
%      HIERARCHICALCLUSTERINGEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HIERARCHICALCLUSTERINGEDITOR.M with the given input arguments.
%
%      HIERARCHICALCLUSTERINGEDITOR('Property','Value',...) creates a new HIERARCHICALCLUSTERINGEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HierarchicalClusteringEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HierarchicalClusteringEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HierarchicalClusteringEditor

% Last Modified by GUIDE v2.5 11-Dec-2007 14:15:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HierarchicalClusteringEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @HierarchicalClusteringEditor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before HierarchicalClusteringEditor is made visible.
function HierarchicalClusteringEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.HierarchicalClusteringEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.HierarchicalClusteringEditor,'Position',winpos);

% Set hierarchical clustering defaults
handles.inconChosen=true;         % Inconsistency coefficient as cluster cutoff by default
handles.repchoice='Replicates';   % Use all replicate values
handles.dim=3;                    % Cluster genes and conditions by default
handles.linkage='Single';        % Use average linkage by default
handles.distance='euclidean';     % Euclidean distance by default
handles.distanceName='Euclidean'; % Its name
handles.incutoff=1;               % Inconsistency coefficient cutoff
handles.maxclust=NaN;             % NaN, use only inconsistency by default
handles.pval=0.05;                % Default p-value cutoff on the list
handles.optleaf=false;            % Default optimal dendrogram
handles.disheat=true;             % Display heatmap by default
handles.colormap='redgreen';      % Default colormap is red-green
handles.cmapDensity=64;           % Its density
handles.title='';                 % Automated heatmap title generation
handles.cancel=false;             % Cancel is not pressed

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HierarchicalClusteringEditor wait for user response (see UIRESUME)
uiwait(handles.HierarchicalClusteringEditor);


% --- Outputs from this function are returned to the command line.
function varargout = HierarchicalClusteringEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.HierarchicalClusteringEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.HierarchicalClusteringEditor);
end

varargout{1}=handles.repchoice;
varargout{2}=handles.dim;
varargout{3}=handles.linkage;
varargout{4}=handles.distance;
varargout{5}=handles.distanceName;
varargout{6}=handles.incutoff;
varargout{7}=handles.maxclust;
varargout{8}=handles.pval;
varargout{9}=handles.optleaf;
varargout{10}=handles.disheat;
varargout{11}=handles.colormap;
varargout{12}=handles.cmapDensity;
varargout{13}=handles.title;
varargout{14}=handles.cancel;


% --- Executes on button press in meansRadio.
function meansRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.repchoice='Means';
else
    handles.repchoice='Replicates';
end
guidata(hObject,handles);


% --- Executes on button press in replicatesRadio.
function replicatesRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.repchoice='Replicates';
else
    handles.repchoice='Means';
end
guidata(hObject,handles);


% --- Executes on button press in clusterRows.
function clusterRows_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dim=1; % Cluster rows
end
guidata(hObject,handles);


% --- Executes on button press in clusterColumns.
function clusterColumns_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dim=2; % Cluster columns
end
guidata(hObject,handles);


% --- Executes on button press in clusterBoth.
function clusterBoth_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dim=3; % Cluster both
end
guidata(hObject,handles);


% --- Executes on selection change in linkagePopup.
function linkagePopup_Callback(hObject, eventdata, handles)

linkages=get(hObject,'String');
val=get(hObject,'Value');
handles.linkage=linkages{val};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function linkagePopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in distancePopup.
function distancePopup_Callback(hObject, eventdata, handles)

distances=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1 % Euclidean
        handles.distance='euclidean';
        handles.distanceName=distances{1};
    case 2 % Standardized Euclidean
        handles.distance='seuclidean';
        handles.distanceName=distances{2};
    case 3
        handles.distance='correlation';
        handles.distanceName=distances{3};
    case 4
        handles.distance='mahalanobis';
        handles.distanceName=distances{4};
    case 5
        handles.distance='cityblock';
        handles.distanceName=distances{5};
    case 6
        handles.distance='cosine';
        handles.distanceName=distances{6};
    case 7
        handles.distance='spearman';
        handles.distanceName=distances{7};
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function distancePopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in inconRadio.
function inconRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.inconChosen=true;
    handles.maxclust=NaN;
    set(handles.cutoffEdit,'String','1')
else
    handles.inconChosen=false;
    handles.incutoff=NaN;
    set(handles.cutoffEdit,'String','')
end
guidata(hObject,handles);


% --- Executes on button press in maxclustRadio.
function maxclustRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.inconChosen=false;
    handles.incutoff=NaN;
    set(handles.cutoffEdit,'String','')
else
    handles.inconChosen=true;
    handles.maxclust=NaN;
    set(handles.cutoffEdit,'String','1')
end
guidata(hObject,handles);


function cutoffEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if handles.inconChosen
    if isnan(val) || val<=0
        uiwait(errordlg('Inconsistency coefficient cutoff must be a positive scalar value',...
                        'Bad Input'));
        set(hObject,'String','1')
        handles.incutoff=str2double(get(hObject,'String'));
        handles.maxclust=NaN;
    else
        handles.incutoff=val;
        handles.maxclust=NaN;
    end
else
    if isnan(val) || val<=0 || rem(val,1)~=0
        uiwait(errordlg('Maximum number of clusters must be a positive integer value',...
                        'Bad Input'));
        set(hObject,'String','')
        handles.maxclust=NaN;
        handles.incutoff=NaN;
    else
        handles.maxclust=val;
        handles.incutoff=NaN;
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function cutoffEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pvalCutoffEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || val>1
    uiwait(errordlg('p-value must be a number between 0 and 1!','Bad Input','modal'));
    set(hObject,'String','0.05')
    handles.pval=str2double(get(hObject,'String'));
else
    handles.pval=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function pvalCutoffEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function heatTitleEdit_Callback(hObject, eventdata, handles)

titre=get(hObject,'String');
if isempty(titre)
    handles.title='';
else
    handles.title=titre;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function heatTitleEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in disHeatCheck.
function disHeatCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.cmapStatic,'Enable','on')
    set(handles.colormapPopup,'Enable','on')
    set(handles.cmapDenStatic,'Enable','on')
    set(handles.cmapDenEdit,'Enable','on')
    set(handles.heatTitleStatic,'Enable','on')
    set(handles.heatTitleEdit,'Enable','on')
    handles.disheat=true;
else
    set(handles.cmapStatic,'Enable','off')
    set(handles.colormapPopup,'Enable','off')
    set(handles.cmapDenStatic,'Enable','off')
    set(handles.cmapDenEdit,'Enable','off')
    set(handles.heatTitleStatic,'Enable','off')
    set(handles.heatTitleEdit,'Enable','off')
    handles.disheat=false;
end
guidata(hObject,handles);


% --- Executes on button press in optLeafCheck.
function optLeafCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.optleaf=true;
else
    handles.optleaf=false;
end
guidata(hObject,handles);


% --- Executes on selection change in colormapPopup.
function colormapPopup_Callback(hObject, eventdata, handles)

choices=get(hObject,'String');
val=get(hObject,'Value');
switch(val)
    case 1 % Red and green
        handles.colormap='redgreen';
        set(handles.cmapDenStatic,'Enable','on')
        set(handles.cmapDenEdit,'Enable','on')
    case 2 % Red and green but mine
        handles.colormap='redgreenfixed';
        set(handles.cmapDenStatic,'Enable','off')
        set(handles.cmapDenEdit,'Enable','off')
    otherwise
        handles.colormap=choices{val};
        set(handles.cmapDenStatic,'Enable','on')
        set(handles.cmapDenEdit,'Enable','on')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function colormapPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function cmapDenEdit_Callback(hObject, eventdata, handles)

den=str2double(get(hObject,'String'));
if isnan(den) || den<=0 || rem(den,1)~=0
    uiwait(errordlg('The colormap density must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','64');
    handles.cmapDensity=str2double(get(hObject,'String'));
else
    handles.cmapDensity=den;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function cmapDenEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

if isempty(handles.maxclust) && isempty(handles.incutoff)
    uiwait(errordlg({'You must provide at least the inconsistency coefficient',...
                     'cutoff or the maximum number of clusters to be formed'},...
                     'Bad Input'));
else
    uiresume(handles.HierarchicalClusteringEditor);
end


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.repchoice='Replicates';
handles.dim=3;
handles.linkage='Average';
handles.distance='euclidean';
handles.distanceName='Euclidean';
handles.incutoff=1;
handles.maxclust=NaN;
handles.pval=0.05;
handles.optleaf=false;
handles.disheat=true;
handles.colormap='redgreen';
handles.cmapDensity=64;
handles.title='';
handles.cancel=true; % Cancel pressed
guidata(hObject,handles);
uiresume(handles.HierarchicalClusteringEditor);
