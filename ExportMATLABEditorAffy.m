function varargout = ExportMATLABEditorAffy(varargin)
% EXPORTMATLABEDITORAFFY M-file for ExportMATLABEditorAffy.fig
%      EXPORTMATLABEDITORAFFY, by itself, creates a new EXPORTMATLABEDITORAFFY or raises the existing
%      singleton*.
%
%      H = EXPORTMATLABEDITORAFFY returns the handle to a new EXPORTMATLABEDITORAFFY or the handle to
%      the existing singleton*.
%
%      EXPORTMATLABEDITORAFFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTMATLABEDITORAFFY.M with the given input arguments.
%
%      EXPORTMATLABEDITORAFFY('Property','Value',...) creates a new EXPORTMATLABEDITORAFFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExportMATLABEditorAffy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExportMATLABEditorAffy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExportMATLABEditorAffy

% Last Modified by GUIDE v2.5 14-Nov-2008 19:59:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExportMATLABEditorAffy_OpeningFcn, ...
                   'gui_OutputFcn',  @ExportMATLABEditorAffy_OutputFcn, ...
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


% --- Executes just before ExportMATLABEditorAffy is made visible.
function ExportMATLABEditorAffy_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.ExportMATLABEditorAffy,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.ExportMATLABEditorAffy,'Position',winpos);

% Get input
len=varargin{1};
handles.whatdone=varargin{2};
contents=cell(len,1);
for i=1:len
    contents{i}=['Analysis ',num2str(i)];
end
set(handles.analysisList,'String',contents)
if handles.whatdone(1).adjnormsum
    set(handles.geneNamesCheck,'Enable','on')
    set(handles.rawDataCheck,'Enable','on')
    set(handles.rawSumCheck,'Enable','on')
    set(handles.backSumCheck,'Enable','on')
    set(handles.normSumCheck,'Enable','on')
else
    set(handles.geneNamesCheck,'Enable','on')
    set(handles.rawDataCheck,'Enable','on')
    set(handles.rawSumCheck,'Enable','on')
    set(handles.backSumCheck,'Enable','on')
    set(handles.normSumCheck,'Enable','on')
end
if handles.whatdone(1).degenes
    set(handles.DECheck,'Enable','on')
else
    set(handles.DECheck,'Enable','off')
end

% Default output
for i=1:length(contents) % Fill all with false
    handles.exportWhat(i).genenames=false;
    handles.exportWhat(i).rawdata=false;
    handles.exportWhat(i).rawsum=false;
    handles.exportWhat(i).backsum=false;
    handles.exportWhat(i).normsum=false;
    handles.exportWhat(i).de=false;
end
handles.cancel=false;    % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ExportMATLABEditorAffy wait for user response (see UIRESUME)
uiwait(handles.ExportMATLABEditorAffy);


% --- Outputs from this function are returned to the command line.
function varargout = ExportMATLABEditorAffy_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.ExportMATLABEditorAffy);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.ExportMATLABEditorAffy);
end

varargout{1}=handles.exportWhat;
varargout{2}=handles.cancel;


function analysisList_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
% Check several states
if handles.whatdone(val).adjnormsum % They exists
    
    set(handles.geneNamesCheck,'Enable','on')
    set(handles.rawDataCheck,'Enable','on')
    set(handles.rawSumCheck,'Enable','on')
    set(handles.backSumCheck,'Enable','on')
    set(handles.normSumCheck,'Enable','on')
    
    if handles.exportWhat(val).genenames
        set(handles.geneNamesCheck,'Value',1)
    else
        set(handles.geneNamesCheck,'Value',0)
    end
    if handles.exportWhat(val).rawdata
        set(handles.rawDataCheck,'Value',1)
    else
        set(handles.rawDataCheck,'Value',0)
    end
    if handles.exportWhat(val).rawsum
        set(handles.rawSumCheck,'Value',1)
    else
        set(handles.rawSumCheck,'Value',0)
    end
    if handles.exportWhat(val).backsum
        set(handles.backSumCheck,'Value',1)
    else
        set(handles.backSumCheck,'Value',0)
    end
    if handles.exportWhat(val).normsum
        set(handles.normSumCheck,'Value',1)
    else
        set(handles.normSumCheck,'Value',0)
    end
    
else % Disable them
    set(handles.geneNamesCheck,'Enable','off','Value',0)
    set(handles.rawDataCheck,'Enable','off','Value',0)
    set(handles.rawSumCheck,'Enable','off','Value',0)
    set(handles.backSumCheck,'Enable','off','Value',0)
    set(handles.normSumCheck,'Enable','off','Value',0)
end

% Check DE state
if handles.whatdone(val).degenes % It exists
    set(handles.DECheck,'Enable','on')
    if handles.exportWhat(val).de
        set(handles.DECheck,'Value',1)
    else
        set(handles.DECheck,'Value',0)
    end
else % Disable it
    set(handles.DECheck,'Enable','off','Value',0)
end

guidata(hObject,handles);


function analysisList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function geneNamesCheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).genenames=true;
else
    handles.exportWhat(ind).genenames=false;
end
guidata(hObject,handles);


function normSumCheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).normsum=true;
else
    handles.exportWhat(ind).normsum=false;
end
guidata(hObject,handles);


function backSumCheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).backsum=true;
else
    handles.exportWhat(ind).backsum=false;
end
guidata(hObject,handles);


function rawDataCheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).rawdata=true;
else
    handles.exportWhat(ind).rawdata=false;
end
guidata(hObject,handles);


function rawSumCheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).rawsum=true;
else
    handles.exportWhat(ind).rawsum=false;
end
guidata(hObject,handles);


function DECheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).de=true;
else
    handles.exportWhat(ind).de=false;
end
guidata(hObject,handles);


function exportButton_Callback(hObject, eventdata, handles)

uiresume(handles.ExportMATLABEditorAffy);


function cancelButton_Callback(hObject, eventdata, handles)

for i=1:length(get(handles.analysisList,'String'))
    handles.exportWhat(i).genenames=false;
    handles.exportWhat(i).rawdata=false;
    handles.exportWhat(i).rawsum=false;
    handles.exportWhat(i).backsum=false;
    handles.exportWhat(i).normsum=false;
    handles.exportWhat(i).de=false;
end
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.ExportMATLABEditorAffy);
