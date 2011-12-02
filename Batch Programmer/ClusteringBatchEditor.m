function varargout = ClusteringBatchEditor(varargin)
% CLUSTERINGBATCHEDITOR M-file for ClusteringBatchEditor.fig
%      CLUSTERINGBATCHEDITOR, by itself, creates a new CLUSTERINGBATCHEDITOR or raises the existing
%      singleton*.
%
%      H = CLUSTERINGBATCHEDITOR returns the handle to a new CLUSTERINGBATCHEDITOR or the handle to
%      the existing singleton*.
%
%      CLUSTERINGBATCHEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLUSTERINGBATCHEDITOR.M with the given input arguments.
%
%      CLUSTERINGBATCHEDITOR('Property','Value',...) creates a new CLUSTERINGBATCHEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ClusteringBatchEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ClusteringBatchEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ClusteringBatchEditor

% Last Modified by GUIDE v2.5 22-Oct-2007 15:38:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ClusteringBatchEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @ClusteringBatchEditor_OutputFcn, ...
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


% --- Executes just before ClusteringBatchEditor is made visible.
function ClusteringBatchEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.ClusteringBatchEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.ClusteringBatchEditor,'Position',winpos);

% Get inputs
handles.len=varargin{1};
handles.maxrep=varargin{2}; % Total number of replicates for that analysis

% Initialize list content
cont=cell(handles.len,1);
for i=1:handles.len
    cont{i}=['Analysis ',num2str(i)];
end
set(handles.analysisList,'String',cont,'Value',1)

% Internal selection index
handles.currentSelection=1;

% Initialize default output for all clustering methods
handles.method=cell(1,handles.len);
handles.methodname=cell(1,handles.len);
handles.repchoice=cell(1,handles.len);
handles.dim=zeros(1,handles.len);
handles.linkage=cell(1,handles.len);
handles.distance=cell(1,handles.len);
handles.distancename=cell(1,handles.len);
handles.k=zeros(1,handles.len);
handles.pvalue=zeros(1,handles.len);
handles.incutoff=zeros(1,handles.len);
handles.optleaf=false(1,handles.len);
handles.disheat=false(1,handles.len);
handles.colormap=cell(1,handles.len);
handles.cmapdensity=zeros(1,handles.len);
handles.title=cell(1,handles.len);
handles.seed=cell(1,handles.len);
handles.seedname=cell(1,handles.len);
handles.repeat=zeros(1,handles.len);
handles.maxiter=zeros(1,handles.len);
handles.fuzzyparam=zeros(1,handles.len);
handles.tolerance=zeros(1,handles.len);
handles.optimize=false(1,handles.len);
handles.cvconstant=zeros(1,handles.len);
handles.fuzzytolerance=zeros(1,handles.len);
handles.fuzzyiter=zeros(1,handles.len);
handles.cancel=false;

% Set defaults (all hierarchical)
for i=1:handles.len
    handles.method{i}='hierarchical';  
    handles.methodname{i}='Hierarchical';
    handles.repchoice{i}='replicates';
    handles.dim(i)=3;
    handles.linkage{i}='single';
    handles.distance{i}='euclidean';
    handles.distancename{i}='Euclidean';
    handles.k(i)=10;
    handles.pvalue(i)=0.05;
    handles.incutoff(i)=NaN;
    handles.optleaf(i)=false;
    handles.disheat(i)=true;
    handles.colormap{i}='redgreen';
    handles.cmapdensity(i)=64;
    handles.title{i}='';
    handles.seed{i}='sample';
    handles.seedname{i}='Random k samples';
    handles.repeat(i)=1;
    handles.maxiter(i)=300;
    handles.fuzzyparam(i)=2;
    handles.tolerance(i)=0.00001;
    handles.optimize(i)=true;
    handles.cvconstant(i)=0.03;
    handles.fuzzytolerance(i)=0.001;
    handles.fuzzyiter(i)=500;
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ClusteringBatchEditor wait for user response (see UIRESUME)
uiwait(handles.ClusteringBatchEditor);


% --- Outputs from this function are returned to the command line.
function varargout = ClusteringBatchEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.ClusteringBatchEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.ClusteringBatchEditor);
end

varargout{1}=handles.method;
varargout{2}=handles.methodname;
varargout{3}=handles.repchoice;
varargout{4}=handles.dim;
varargout{5}=handles.linkage;
varargout{6}=handles.distance;
varargout{7}=handles.distancename;
varargout{8}=handles.k;
varargout{9}=handles.pvalue;
varargout{10}=handles.incutoff;
varargout{11}=handles.disheat;
varargout{12}=handles.colormap;
varargout{13}=handles.cmapdensity;
varargout{14}=handles.title;
varargout{15}=handles.seed;
varargout{16}=handles.seedname;
varargout{17}=handles.repeat;
varargout{18}=handles.maxiter;
varargout{19}=handles.fuzzyparam;
varargout{20}=handles.tolerance;
varargout{21}=handles.optimize;
varargout{22}=handles.cvconstant;
varargout{23}=handles.fuzzytolerance;
varargout{24}=handles.fuzzyiter;
varargout{25}=handles.cancel;


% --- Executes on selection change in analysisList.
function analysisList_Callback(hObject, eventdata, handles)

handles.currentSelection=get(hObject,'Value');
switch handles.method{handles.currentSelection}
    case 'hierarchical'
        set(handles.clusterPopup,'Value',1)
    case 'kmeans'
        set(handles.clusterPopup,'Value',2)
    case 'fcm'
        set(handles.clusterPopup,'Value',3)
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function analysisList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in clusterPopup.
function clusterPopup_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
val=get(hObject,'Value');

switch val   
    case 1 % Hierarchical clustering
        
        [repchoice,dim,linkage,distance,distancename,incutoff,k,...
         pvalue,optleaf,disheat,colormap,cmapdensity,title,cancel]=...
            HierarchicalClusteringEditor;
        if isempty(k)
            k=NaN;
        end
        if isempty(incutoff)
            incutoff=NaN;
        end
        if ~cancel
            handles.method{ind}='hierarchical';
            handles.methodname{ind}='Hierarchical';
            handles.repchoice{ind}=repchoice;
            handles.dim(ind)=dim;
            handles.linkage{ind}=linkage;
            handles.distance{ind}=distance;
            handles.distancename{ind}=distancename;
            handles.incutoff(ind)=incutoff;
            handles.k(ind)=k;
            handles.pvalue(ind)=pvalue;
            handles.optleaf(ind)=optleaf;
            handles.disheat(ind)=disheat;
            handles.colormap{ind}=colormap;
            handles.cmapdensity(ind)=cmapdensity;
            handles.title{ind}=title;
        end
        
    case 2 % k-means clustering
        
        [repchoice,dim,k,distance,distancename,seed,seedname,...
         repeat,maxiter,pvalue,cancel]=...
            kmeansClusteringEditor(10000,handles.maxrep(ind));
        % Put a big number in maxgenes as we don't know it yet (derived from the
        % statistical analysis which has not yet been performed. It might result in error.
        
        if ~cancel
            handles.method{ind}='kmeans';
            handles.methodname{ind}='k-Means';
            handles.repchoice{ind}=repchoice;
            handles.dim(ind)=dim;
            handles.k(ind)=k;
            handles.distance{ind}=distance;
            handles.distancename{ind}=distancename;
            handles.seed{ind}=seed;
            handles.seedname{ind}=seedname;
            handles.repeat(ind)=repeat;
            handles.maxiter(ind)=maxiter;
            handles.pvalue(ind)=pvalue;
        end
        
    case 3 % Fuzzy C-means clustering
        
        [repchoice,dim,k,fuzzyparam,tolerance,maxiter,pvalue,optimize,...
         cvconstant,fuzzytolerance,fuzzyiter,cancel]=...
            FCMClusteringEditor(10000,handles.maxrep(ind));
        % Put a big number in maxgenes as we don't know it yet (derived from the
        % statistical analysis which has not yet been performed. It might result in error.
        
        if ~cancel
            handles.method{ind}='fcm';
            handles.methodname{ind}='Fuzzy C-Means';
            handles.repchoice{ind}=repchoice;
            handles.dim(ind)=dim;
            handles.k(ind)=k;
            handles.fuzzyparam(ind)=fuzzyparam;
            handles.tolerance(ind)=tolerance;
            handles.maxiter(ind)=maxiter;
            handles.pvalue(ind)=pvalue;
            handles.optimize(ind)=optimize;
            handles.cvconstant(ind)=cvconstant;
            handles.fuzzytolerance(ind)=fuzzytolerance;
            handles.fuzzyiter(ind)=fuzzyiter;
        end
end
guidata(hObject,handles);
        

% --- Executes during object creation, after setting all properties.
function clusterPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.ClusteringBatchEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
for i=1:handles.len
    handles.method{i}='hierarchical';  
    handles.methodname{i}='Hierarchical';
    handles.repchoice{i}='replicates';
    handles.dim(i)=3;
    handles.linkage{i}='avarage';
    handles.distance{i}='euclidean';
    handles.distancename{i}='Euclidean';
    handles.k(i)=10;
    handles.pvalue(i)=0.05;
    handles.incutoff(i)=1;
    handles.disheat(i)=true;
    handles.colormap{i}='redgreen';
    handles.cmapdensity(i)=64;
    handles.title{i}='';
    handles.seed{i}='sample';
    handles.seedname{i}='Random k samples';
    handles.repeat(i)=1;
    handles.maxiter(i)=300;
    handles.fuzzyparam(i)=2;
    handles.tolerance(i)=0.00001;
    handles.optimize(i)=true;
    handles.cvconstant(i)=0.03;
    handles.fuzzytolerance(i)=0.001;
    handles.fuzzyiter(i)=500;
end
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.ClusteringBatchEditor);
