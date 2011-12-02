function varargout = ExportMATLABEditor(varargin)
% EXPORTMATLABEDITOR M-file for ExportMATLABEditor.fig
%      EXPORTMATLABEDITOR, by itself, creates a new EXPORTMATLABEDITOR or raises the existing
%      singleton*.
%
%      H = EXPORTMATLABEDITOR returns the handle to a new EXPORTMATLABEDITOR or the handle to
%      the existing singleton*.
%
%      EXPORTMATLABEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTMATLABEDITOR.M with the given input arguments.
%
%      EXPORTMATLABEDITOR('Property','Value',...) creates a new EXPORTMATLABEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExportMATLABEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExportMATLABEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExportMATLABEditor

% Last Modified by GUIDE v2.5 03-Sep-2007 15:56:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExportMATLABEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @ExportMATLABEditor_OutputFcn, ...
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


% --- Executes just before ExportMATLABEditor is made visible.
function ExportMATLABEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.ExportMATLABEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.ExportMATLABEditor,'Position',winpos);

% Get input
len=varargin{1};
handles.whatdone=varargin{2};
contents=cell(len,1);
for i=1:len
    contents{i}=['Analysis ',num2str(i)];
end
set(handles.analysisList,'String',contents)
if handles.whatdone(1).raw
    set(handles.rawImageCheck,'Enable','on')
else
    set(handles.rawImageCheck,'Enable','off')
end
if handles.whatdone(1).unnormratio
    set(handles.unnormRatioCheck,'Enable','on')
else
    set(handles.unnormRatioCheck,'Enable','off')
end
if handles.whatdone(1).normratio
    set(handles.normRatioCheck,'Enable','on')
else
    set(handles.normRatioCheck,'Enable','off')
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
    handles.exportWhat(i).unnorm=false;
    handles.exportWhat(i).norm=false;
    handles.exportWhat(i).de=false;
end
handles.cancel=false;    % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ExportMATLABEditor wait for user response (see UIRESUME)
uiwait(handles.ExportMATLABEditor);


% --- Outputs from this function are returned to the command line.
function varargout = ExportMATLABEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.ExportMATLABEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.ExportMATLABEditor);
end

varargout{1}=handles.exportWhat;
varargout{2}=handles.cancel;


% --- Executes on selection change in analysisList.
function analysisList_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
% Check gene names state
if handles.exportWhat(val).genenames
    set(handles.geneNamesCheck,'Value',1)
else
    set(handles.geneNamesCheck,'Value',0)
end
% Check raw data state
if handles.whatdone(val).raw % It exists
    set(handles.rawImageCheck,'Enable','on')
    if handles.exportWhat(val).rawdata
        set(handles.rawImageCheck,'Value',1)
    else
        set(handles.rawImageCheck,'Value',0)
    end
else % Disable it
    set(handles.rawImageCheck,'Enable','off','Value',0)
end
% Check unnormalized state
if handles.whatdone(val).unnormratio % It exists
    set(handles.unnormRatioCheck,'Enable','on')
    if handles.exportWhat(val).unnorm
        set(handles.unnormRatioCheck,'Value',1)
    else
        set(handles.unnormRatioCheck,'Value',0)
    end
else % Disable it
    set(handles.unnormRatioCheck,'Enable','off','Value',0)
end 
% Check normalized state
if handles.whatdone(val).normratio % It exists
    set(handles.normRatioCheck,'Enable','on')
    if handles.exportWhat(val).norm
        set(handles.normRatioCheck,'Value',1)
    else
        set(handles.normRatioCheck,'Value',0)
    end
else % Disable it
    set(handles.normRatioCheck,'Enable','off','Value',0)
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


% --- Executes during object creation, after setting all properties.
function analysisList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in geneNamesCheck.
function geneNamesCheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).genenames=true;
else
    handles.exportWhat(ind).genenames=false;
end
guidata(hObject,handles);


% --- Executes on button press in rawImageCheck.
function rawImageCheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).rawdata=true;
else
    handles.exportWhat(ind).rawdata=false;
end
guidata(hObject,handles);


% --- Executes on button press in unnormRatioCheck.
function unnormRatioCheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).unnorm=true;
else
    handles.exportWhat(ind).unnorm=false;
end
guidata(hObject,handles);


% --- Executes on button press in normRatioCheck.
function normRatioCheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).norm=true;
else
    handles.exportWhat(ind).norm=false;
end
guidata(hObject,handles);


% --- Executes on button press in DECheck.
function DECheck_Callback(hObject, eventdata, handles)

ind=get(handles.analysisList,'Value');
if get(hObject,'Value')==1
    handles.exportWhat(ind).de=true;
else
    handles.exportWhat(ind).de=false;
end
guidata(hObject,handles);


% --- Executes on button press in exportButton.
function exportButton_Callback(hObject, eventdata, handles)

uiresume(handles.ExportMATLABEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Restore defaults
for i=1:length(get(handles.analysisList,'String'))
    handles.exportWhat(i).genenames=false;
    handles.exportWhat(i).rawdata=false;
    handles.exportWhat(i).unnorm=false;
    handles.exportWhat(i).norm=false;
    handles.exportWhat(i).de=false;
end
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.ExportMATLABEditor);
