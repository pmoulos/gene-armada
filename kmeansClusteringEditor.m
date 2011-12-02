function varargout = kmeansClusteringEditor(varargin)
% KMEANSCLUSTERINGEDITOR M-file for kmeansClusteringEditor.fig
%      KMEANSCLUSTERINGEDITOR, by itself, creates a new KMEANSCLUSTERINGEDITOR or raises the existing
%      singleton*.
%
%      H = KMEANSCLUSTERINGEDITOR returns the handle to a new KMEANSCLUSTERINGEDITOR or the handle to
%      the existing singleton*.
%
%      KMEANSCLUSTERINGEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KMEANSCLUSTERINGEDITOR.M with the given input arguments.
%
%      KMEANSCLUSTERINGEDITOR('Property','Value',...) creates a new KMEANSCLUSTERINGEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kmeansClusteringEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kmeansClusteringEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kmeansClusteringEditor

% Last Modified by GUIDE v2.5 17-Jun-2007 13:47:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kmeansClusteringEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @kmeansClusteringEditor_OutputFcn, ...
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


% --- Executes just before kmeansClusteringEditor is made visible.
function kmeansClusteringEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.kmeansClusteringEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.kmeansClusteringEditor,'Position',winpos);

% Get inputs
handles.maxrows=varargin{1};
handles.maxcols=varargin{2};

% Set hierarchical clustering defaults
handles.repchoice='Replicates';           % Use all replicate values
handles.dim=1;                            % Cluster genes by default
handles.k=5;                              % 5 centroids linkage by default
handles.distance='sqEuclidean';           % Euclidean distance by default
handles.distanceName='Squared Euclidean'; % Its name
handles.seed='sample';                    % Random centroid seeds
handles.seedName='Random k samples';      % Its name
handles.repeat=1;                         % Perform one clustering iteration with 1 seed
handles.maxiter=100;                      % Maximum number of convergence iterations
handles.pval=0.05;                        % Default p-value cutoff on the list
handles.cancel=false;                     % Cancel is not pressed

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes kmeansClusteringEditor wait for user response (see UIRESUME)
uiwait(handles.kmeansClusteringEditor);


% --- Outputs from this function are returned to the command line.
function varargout = kmeansClusteringEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.kmeansClusteringEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.kmeansClusteringEditor);
end

varargout{1}=handles.repchoice;
varargout{2}=handles.dim;
varargout{3}=handles.k;
varargout{4}=handles.distance;
varargout{5}=handles.distanceName;
varargout{6}=handles.seed;
varargout{7}=handles.seedName;
varargout{8}=handles.repeat;
varargout{9}=handles.maxiter;
varargout{10}=handles.pval;
varargout{11}=handles.cancel;


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

k=str2double(get(handles.kEdit,'String'));
if get(hObject,'Value')==1 
    if k>handles.maxrows
        uiwait(errordlg('k cannot be larger than the number of genes to cluster','Bad Input'));
        set(handles.kEdit,'String','5')
    end
    handles.dim=1; % Cluster rows
else
    if k>handles.maxcols
        uiwait(errordlg('k cannot be larger than the number of arrays to cluster','Bad Input'));
        set(handles.kEdit,'String',num2str(handles.maxcols))
    end
    handles.dim=2;
end
guidata(hObject,handles);


% --- Executes on button press in clusterColumns.
function clusterColumns_Callback(hObject, eventdata, handles)

k=str2double(get(handles.kEdit,'String'));
if get(hObject,'Value')==1
    if k>handles.maxcols
        uiwait(errordlg('k cannot be larger than the number of arrays to cluster','Bad Input'));
        set(handles.kEdit,'String',num2str(handles.maxcols))
    end
    handles.dim=2; % Cluster columns
else
    if k>handles.maxrows
        uiwait(errordlg('k cannot be larger than the number of genes to cluster','Bad Input'));
        set(handles.kEdit,'String','5')
    end
    handles.dim=1;
end
guidata(hObject,handles);


function kEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The number of centroids must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','5')
    handles.k=str2double(get(hObject,'String'));
else
    if handles.dim==1 && val>handles.maxrows
        uiwait(errordlg('k cannot be larger than the number of genes to cluster.','Bad Input'));
        set(hObject,'String','5')
        handles.k=str2double(get(hObject,'String'));
    elseif handles.dim==2 && val>handles.maxcols
        uiwait(errordlg('k cannot be larger than the number of arrays to cluster.','Bad Input'));
        set(hObject,'String',num2str(handles.maxcols))
        handles.k=str2double(get(hObject,'String'));
    else
        handles.k=val;
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function kEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in distancePopup.
function distancePopup_Callback(hObject, eventdata, handles)

distances=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1 % Squared Euclidean
        handles.distance='sqEuclidean';
        handles.distanceName=distances{1};
    case 2 % Manhattan
        handles.distance='cityblock';
        handles.distanceName=distances{2};
    case 3 % Cosine
        handles.distance='cosine';
        handles.distanceName=distances{3};
    case 4
        handles.distance='correlation';
        handles.distanceName=distances{4};
    case 5
        z=get(handles.seedPopup,'Value');
        if z==2 % Uniform
            uiwait(errordlg({'Hamming distance cannot be used with random uniform k samples.',...
                             'Non-binary data cannot be clustered using Hamming distance.'},...
                             'Bad Input','modal'));
            set(hObject,'Value',1)
            handles.distance='sqEuclidean';
            handles.distanceName='Squared Euclidean';
        else
            handles.distance='hamming';
            handles.distanceName=distances{5};
        end
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function distancePopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in seedPopup.
function seedPopup_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
switch val
    case 1 % Random sample
        handles.seed='sample';
        handles.seedName='Random k observations';
    case 2 % Uniform
        z=get(handles.distancePopup,'Value');
        if z==5 % Hamming
            uiwait(errordlg({'Random uniform k sample cannot be used with Hamming distance.',...
                             'Non-binary data cannot be clustered using Hamming distance.'},...
                             'Bad Input','modal'));
            set(hObject,'Value',1)
            handles.seed='sample';
            handles.seedName='Random k observations';
        else
            handles.seed='uniform';
            handles.seedName='Random uniform k samples';
        end
    case 3 % Cluster
        handles.seed='cluster';
        handles.seedName='Seeds through preliminary clustering';
end
        
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function seedPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function repeatEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The number of clustering iterations must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','1')
    handles.repeat=str2double(get(hObject,'String'));
else
    handles.repeat=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function repeatEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxIterEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The maximum number of convergence iterations must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','100')
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


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.kmeansClusteringEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.repchoice='Replicates';
handles.dim=1;
handles.k=5;
handles.distance='sqEuclidean';
handles.distanceName='Squared Euclidean';
handles.seed='Sample';
handles.seedName='Random k samples';
handles.repeat=1;
handles.maxiter=100;
handles.pval=0.05;
handles.cancel=true; % Cancel pressed
guidata(hObject,handles);
uiresume(handles.kmeansClusteringEditor);
