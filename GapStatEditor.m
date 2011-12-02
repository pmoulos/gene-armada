function varargout = GapStatEditor(varargin)
% GAPSTATEDITOR M-file for GapStatEditor.fig
%      GAPSTATEDITOR, by itself, creates a new GAPSTATEDITOR or raises the existing
%      singleton*.
%
%      H = GAPSTATEDITOR returns the handle to a new GAPSTATEDITOR or the handle to
%      the existing singleton*.
%
%      GAPSTATEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAPSTATEDITOR.M with the given input arguments.
%
%      GAPSTATEDITOR('Property','Value',...) creates a new GAPSTATEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GapStatEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GapStatEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GapStatEditor

% Last Modified by GUIDE v2.5 04-Jan-2008 17:13:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GapStatEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @GapStatEditor_OutputFcn, ...
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


% --- Executes just before GapStatEditor is made visible.
function GapStatEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.GapStatEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.GapStatEditor,'Position',winpos);

% Get some inputs
handles.maxgenes=varargin{1};
handles.maxreps=varargin{2};

% Set default outputs
handles.ks=2:10;                 % Number of clusters range
handles.refsize=100;             % Reference dataset size
handles.repeat=1;                % Method repetitions
handles.algo='hierarchical';     % Clustering algorithm to be used
handles.algoName='Hierarchical'; % Clustering algorithm to be used - Name
handles.algoargs={};             % Algorithm arguments
handles.refmethod='uniform';     % Method for creation of reference dataset
handles.refmethodName='Uniform'; % Method for creation of reference dataset - Name
handles.usesquared=false;        % Do not always use squared euclidean for Wk
handles.verbose=false;           % Verbose output in command line
handles.usewaitbar=false;        % Display waitbars for progress overview
handles.showplot=false;          % Show Gap plots
handles.cancel=false;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GapStatEditor wait for user response (see UIRESUME)
uiwait(handles.GapStatEditor);


% --- Outputs from this function are returned to the command line.
function varargout = GapStatEditor_OutputFcn(hObject, eventdata, handles)

if (get(handles.cancelButton,'Value')==0)
    delete(handles.GapStatEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.GapStatEditor);
end

varargout{1}=handles.ks;
varargout{2}=handles.refsize;
varargout{3}=handles.repeat;
varargout{4}=handles.algo;
varargout{5}=handles.algoName;
varargout{6}=handles.algoargs;
varargout{7}=handles.refmethod;
varargout{8}=handles.refmethodName;
varargout{9}=handles.usesquared;
varargout{10}=handles.verbose;
varargout{11}=handles.usewaitbar;
varargout{12}=handles.showplot;
varargout{13}=handles.cancel;


function clusterRangeEdit_Callback(hObject, eventdata, handles)

val=str2num(get(hObject,'String'));
if isempty(val) || min(val)<=0 || rem(sum(val),1)~=0
    msg=['The number of clusters range must be a group of positive integer values ',...
         'and the minimum number of clusters should be greater than 1.'];
    uiwait(errordlg(msg,'Bad Input'));
    set(hObject,'String','2:10')
    handles.ks=str2num(get(hObject,'String'));
else
    handles.ks=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function clusterRangeEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function refSizeEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The size of reference datasets must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','100')
    handles.refsize=str2double(get(hObject,'String'));
else
    handles.refsize=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function refSizeEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function repetEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The length of method repetitions must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','100')
    handles.repeat=str2double(get(hObject,'String'));
else
    handles.repeat=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function repetEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in algoPopup.
function algoPopup_Callback(hObject, eventdata, handles)

algos=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1 % Hierarchical
        handles.algo='hierarchical';
        handles.algoName=algos{1};
        % Get the algorithm arguments
        [repchoice,dim,linkage,distance,distanceName,incutoff,maxclust,pval,optleaf,...
         disheat,cmap,cmapden,titre,cancel]=HierarchicalClusteringEditor;
        % Create them
        if ~cancel
            handles.algoargs={'ClusterWhat',repchoice,'ClusterDim',dim,...
                              'Distance',distance,'Linkage',linkage,...
                              'OptimalLeafOrder',optleaf,'DisplayHeatmap',disheat,...
                              'PValue',pval,'Title',titre};
        end
    case 2 % k-means
        handles.algo='kmeans';
        handles.algoName=algos{2};
        % Get the algorithm arguments
        [repchoice,dim,k,distance,distanceName,seed,seedName,repeat,maxiter,pval,cancel]=...
            kmeansClusteringEditor(handles.maxgenes,handles.maxreps);
        % Create them
        if ~cancel
            handles.algoargs={'ClusterWhat',repchoice,'ClusterDim',dim,...
                              'Distance',distance,'Start',seed,...
                              'Replications',repeat,'MaxIter',maxiter,...
                              'PValue',pval};
        end
    case 3 % FCM
        handles.algo='fcm';
        handles.algoName=algos{3};
        % Get the algorithm arguments
        [repchoice,dim,k,m,tol,maxiter,pval,doopt,cvcon,mtol,miter,cancel]=...
            FCMClusteringEditor(handles.maxgenes,handles.maxreps);
        % Create them
        if ~cancel
            handles.algoargs={'ClusterWhat',repchoice,'ClusterDim',dim,...
                              'FuzzyParam',m,'Tolerance',tol,...
                              'MaxIter',miter,'Optimize',doopt,...
                              'CVThreshold',cvcon,'MTol',mtol,...
                              'OptMaxIter',miter,'PValue',pval};
        end
        
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function algoPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in refTypePopup.
function refTypePopup_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1
        handles.refmethod='uniform';
        handles.refmethodName=contents{1};
    case 2
        handles.refmethod='pca';
        handles.refmethodName=contents{2};
    case 3
        handles.refmethod='boot';
        handles.refmethodName=contents{3};
    case 4
        handles.refmethod='bootpca';
        handles.refmethodName=contents{4};
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function refTypePopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useSquaredCheck.
function useSquaredCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.usesquared=true;
else
    handles.usesquared=false;
end
guidata(hObject,handles);


% % --- Executes on button press in uniformRadio.
% function uniformRadio_Callback(hObject, eventdata, handles)
% 
% if get(hObject,'Value')==1
%     handles.method='uniform';
% end
% guidata(hObject,handles);
% 
% 
% % --- Executes on button press in pcaRadio.
% function pcaRadio_Callback(hObject, eventdata, handles)
% 
% if get(hObject,'Value')==1
%     handles.method='pca';
% end
% guidata(hObject,handles);


% --- Executes on button press in verboseCheck.
function verboseCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.verbose=true;
else
    handles.verbose=false;
end
guidata(hObject,handles);


% --- Executes on button press in useWaitCheck.
function useWaitCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.usewaitbar=true;
else
    handles.usewaitbar=false;
end
guidata(hObject,handles);


% --- Executes on button press in showPlotCheck.
function showPlotCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.showplot=true;
else
    handles.showplot=false;
end
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.GapStatEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.ks=2:10;
handles.refsize=100; 
handles.repeat=1;
handles.algo='hierarchical';
handles.algoName='Hierarchical';
handles.algoargs={};
handles.refmethod='uniform';
handles.refmethodName='Uniform';
handles.usesquared=false;
handles.verbose=false;
handles.usewaitbar=false;
handles.showplot=false;
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.GapStatEditor);
