function varargout = BoxplotEditorAffy(varargin)
% BOXPLOTEDITORAFFY M-file for BoxplotEditorAffy.fig
%      BOXPLOTEDITORAFFY, by itself, creates a new BOXPLOTEDITORAFFY or raises the existing
%      singleton*.
%
%      H = BOXPLOTEDITORAFFY returns the handle to a new BOXPLOTEDITORAFFY or the handle to
%      the existing singleton*.
%
%      BOXPLOTEDITORAFFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BOXPLOTEDITORAFFY.M with the given input arguments.
%
%      BOXPLOTEDITORAFFY('Property','Value',...) creates a new BOXPLOTEDITORAFFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BoxplotEditorAffy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BoxplotEditorAffy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BoxplotEditorAffy

% Last Modified by GUIDE v2.5 29-Mar-2009 23:27:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BoxplotEditorAffy_OpeningFcn, ...
                   'gui_OutputFcn',  @BoxplotEditorAffy_OutputFcn, ...
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


% --- Executes just before BoxplotEditorAffy is made visible.
function BoxplotEditorAffy_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.BoxplotEditorAffy,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.BoxplotEditorAffy,'Position',winpos);

affyChoice={'PM','MM',...
            'BackAdjusted PM','Normalized PM',...
            'Expression (raw)','Expression (back)','Expression (norm)'};
illuChoice={'Expression (raw)','Expression (norm)'};

% Get inputs
handles.arrays=varargin{1};
handles.imgsw=varargin{2};

% Fill lists
if handles.imgsw==99 % Affymetrix
    set(handles.dataPlotPopup,'String',affyChoice)
    handles.pw=3;
elseif handles.imgsw==98 % Illumina
    set(handles.dataPlotPopup,'String',illuChoice)
    handles.pw=1;
end
set(handles.arrayList,'String',handles.arrays)

plat=get(handles.dataPlotPopup,'String');
% Set default outputs
handles.whicharrays=handles.arrays(1); % Default array to plot from non-normalized
handles.plotwhat=handles.pw;           % What quantity to plot 
handles.plotwhatName=plat{1};          % Its name
handles.title='';                      % The title(s) 
handles.logscale=false;                % Plot in log2 scale
handles.cancel=false;                  % User did not press cancel 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BoxplotEditorAffy wait for user response (see UIRESUME)
uiwait(handles.BoxplotEditorAffy);


% --- Outputs from this function are returned to the command line.
function varargout = BoxplotEditorAffy_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.BoxplotEditorAffy);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.BoxplotEditorAffy);
end

% Get default command line output from handles structure
varargout{1}=handles.whicharrays;
varargout{2}=handles.plotwhat;
varargout{3}=handles.plotwhatName;
varargout{4}=handles.title;
varargout{5}=handles.logscale;
varargout{6}=handles.cancel;


function arrayList_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
str=get(hObject,'String');
handles.whicharrays=str(val);
guidata(hObject,handles);
    

function arrayList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dataPlotPopup_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
if handles.imgsw==99 % Affymetrix
    handles.plotwhat=val+2; % Exclude Intensity and StdDev
elseif handles.imgsw==98 % Illumina
    handles.plotwhat=val+1; % No background uncorrected data anyway
end
handles.plotwhatName=contents{val};
guidata(hObject,handles);


function dataPlotPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function titleEdit_Callback(hObject, eventdata, handles)

handles.title=cellstr(get(hObject,'String'));
guidata(hObject,handles);


function titleEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function logCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.logscale=true;
else
    handles.logscale=false;
end
guidata(hObject,handles);


function okButton_Callback(hObject, eventdata, handles)

% Transformation for Affymetrix data, for use with retrieveArrayData inside ARMADA main
if handles.imgsw==99 % Affymetrix
    handles.plotwhat=handles.plotwhat+100;
elseif handles.imgsw==98 % Illumina
    handles.plotwhat=handles.plotwhat+200;
end
guidata(hObject,handles);
uiresume(handles.BoxplotEditorAffy);


function cancelButton_Callback(hObject, eventdata, handles)

plat=get(handles.dataPlotPopup,'String');
% Resume defaults
handles.whicharrays=''; 
handles.plotwhat=handles.pw;
handles.plotwhatName=plat{1}; 
handles.titles='';
handles.logscale=false;
handles.cancel=true; % User pressed cancel 
guidata(hObject,handles);   
uiresume(handles.BoxplotEditorAffy);
