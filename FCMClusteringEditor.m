function varargout = FCMClusteringEditor(varargin)
% FCMCLUSTERINGEDITOR M-file for FCMClusteringEditor.fig
%      FCMCLUSTERINGEDITOR, by itself, creates a new FCMCLUSTERINGEDITOR or raises the existing
%      singleton*.
%
%      H = FCMCLUSTERINGEDITOR returns the handle to a new FCMCLUSTERINGEDITOR or the handle to
%      the existing singleton*.
%
%      FCMCLUSTERINGEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FCMCLUSTERINGEDITOR.M with the given input arguments.
%
%      FCMCLUSTERINGEDITOR('Property','Value',...) creates a new FCMCLUSTERINGEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FCMClusteringEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FCMClusteringEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FCMClusteringEditor

% Last Modified by GUIDE v2.5 05-Sep-2007 16:58:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FCMClusteringEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @FCMClusteringEditor_OutputFcn, ...
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


% --- Executes just before FCMClusteringEditor is made visible.
function FCMClusteringEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.FCMClusteringEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.FCMClusteringEditor,'Position',winpos);

% Get inputs
handles.maxrows=varargin{1};
handles.maxcols=varargin{2};

% Set defaults
handles.repchoice='Replicates'; % Use all replicate values
handles.dim=1;                  % Cluster genes by default
handles.k=10;                   % Default number of clusters
handles.m=2;                    % Default fuzzy parameter
handles.tol=0.00001;            % Default overall convergence tolerance
handles.maxiter=500;            % Default maximum number of iterations
handles.pval=0.05;              % Default p-value cutoff
handles.doopt=true;             % Default m optimization - do it
handles.cvcon=0.03;             % Default constant such like CV(Dim) = 0.03 * Data Dimensionality
handles.mtol=0.001;             % Default tolerance for optimal m convergence
handles.miter=500;              % Default maximum number of iterations for optimal m convergence
handles.cancel=false;           % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FCMClusteringEditor wait for user response (see UIRESUME)
uiwait(handles.FCMClusteringEditor);


% --- Outputs from this function are returned to the command line.
function varargout = FCMClusteringEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.FCMClusteringEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.FCMClusteringEditor);
end

varargout{1}=handles.repchoice;
varargout{2}=handles.dim;
varargout{3}=handles.k;
varargout{4}=handles.m;
varargout{5}=handles.tol;
varargout{6}=handles.maxiter;
varargout{7}=handles.pval;
varargout{8}=handles.doopt;
varargout{9}=handles.cvcon;
varargout{10}=handles.mtol;
varargout{11}=handles.miter;
varargout{12}=handles.cancel;


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

k=str2double(get(handles.noClustEdit,'String'));
if get(hObject,'Value')==1 
    if k>handles.maxrows
        uiwait(errordlg('Number of clusters cannot be larger than the number of genes to cluster','Bad Input'));
        set(handles.noClustEdit,'String','10')
    end
    handles.dim=1; % Cluster rows
else
    if k>handles.maxcols
        uiwait(errordlg('Number of clusters cannot be larger than the number of arrays to cluster','Bad Input'));
        set(handles.noClustEdit,'String',num2str(handles.maxcols))
    end
    handles.dim=2;
end
guidata(hObject,handles);


% --- Executes on button press in clusterColumns.
function clusterColumns_Callback(hObject, eventdata, handles)

k=str2double(get(handles.noClustEdit,'String'));
if get(hObject,'Value')==1
    if k>handles.maxcols
        uiwait(errordlg('Number of clusters cannot be larger than the number of arrays to cluster','Bad Input'));
        set(handles.noClustEdit,'String',num2str(handles.maxcols))
    end
    handles.dim=2; % Cluster columns
else
    if k>handles.maxrows
        uiwait(errordlg('Number of clusters cannot be larger than the number of genes to cluster','Bad Input'));
        set(handles.noClustEdit,'String','10')
    end
    handles.dim=1;
end
guidata(hObject,handles);


function noClustEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The number of clusters (centroids) must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','10')
    handles.k=str2double(get(hObject,'String'));
else
    if handles.dim==1 && val>handles.maxrows
        uiwait(errordlg('Number of clusters cannot be larger than the number of genes to cluster.','Bad Input'));
        set(hObject,'String','10')
        handles.k=str2double(get(hObject,'String'));
    elseif handles.dim==2 && val>handles.maxcols
        uiwait(errordlg('Number of clusters cannot be larger than the number of arrays to cluster.','Bad Input'));
        set(hObject,'String',num2str(handles.maxcols))
        handles.k=str2double(get(hObject,'String'));
    else
        handles.k=val;
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function noClustEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0
    uiwait(errordlg('The fuzzy parameter must be a positive value.',...
                    'Bad Input'));
    set(hObject,'String','2')
    handles.m=str2double(get(hObject,'String'));
else
    handles.m=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function mEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tolEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0
    uiwait(errordlg('The convergence tolerance must be a positive value.',...
                    'Bad Input'));
    set(hObject,'String','0.00001')
    handles.tol=str2double(get(hObject,'String'));
else
    handles.tol=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function tolEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxIterEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The maximum number of convergence iterations must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','500')
    handles.maxiter=str2double(get(hObject,'String'));
else
    handles.maxiter=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function maxIterEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pvalEdit_Callback(hObject, eventdata, handles)

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
function pvalEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in automCheck.
function automCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.doopt=true;
    set(handles.cvConStatic,'Enable','on')
    set(handles.mtolStatic,'Enable','on')
    set(handles.mMaxIterStatic,'Enable','on')
    set(handles.cvConEdit,'Enable','on')
    set(handles.mtolEdit,'Enable','on')
    set(handles.mMaxIterEdit,'Enable','on')
else
    handles.doopt=false;
    set(handles.cvConStatic,'Enable','off')
    set(handles.mtolStatic,'Enable','off')
    set(handles.mMaxIterStatic,'Enable','off')
    set(handles.cvConEdit,'Enable','off')
    set(handles.mtolEdit,'Enable','off')
    set(handles.mMaxIterEdit,'Enable','off')
end
guidata(hObject,handles);


function cvConEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0
    uiwait(errordlg('The CV constant must be a positive value.',...
                    'Bad Input'));
    set(hObject,'String','0.03')
    handles.cvcon=str2double(get(hObject,'String'));
else
    handles.cvcon=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function cvConEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mtolEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0
    uiwait(errordlg('The convergence tolerance must be a positive value.',...
                    'Bad Input'));
    set(hObject,'String','0.00001')
    handles.mtol=str2double(get(hObject,'String'));
else
    handles.mtol=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function mtolEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mMaxIterEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The maximum number of convergence iterations must be a positive integer value',...
                    'Bad Input'));
    set(hObject,'String','500')
    handles.miter=str2double(get(hObject,'String'));
else
    handles.miter=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function mMaxIterEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.FCMClusteringEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.repchoice='Replicates';
handles.dim=1;
handles.k=10;
handles.m=2;
handles.tol=0.00001;
handles.maxiter=500;
handles.pval=0.05;
handles.doopt=true;
handles.cvcon=0.03;
handles.mtol=0.001;
handles.miter=500;
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.FCMClusteringEditor);
