function varargout = TimeCourseANOVAEditor(varargin)
% TIMECOURSEANOVAEDITOR M-file for TimeCourseANOVAEditor.fig
%      TIMECOURSEANOVAEDITOR, by itself, creates a new TIMECOURSEANOVAEDITOR or raises the existing
%      singleton*.
%
%      H = TIMECOURSEANOVAEDITOR returns the handle to a new TIMECOURSEANOVAEDITOR or the handle to
%      the existing singleton*.
%
%      TIMECOURSEANOVAEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIMECOURSEANOVAEDITOR.M with the given input arguments.
%
%      TIMECOURSEANOVAEDITOR('Property','Value',...) creates a new TIMECOURSEANOVAEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TimeCourseANOVAEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TimeCourseANOVAEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TimeCourseANOVAEditor

% Last Modified by GUIDE v2.5 12-Nov-2007 18:21:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TimeCourseANOVAEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @TimeCourseANOVAEditor_OutputFcn, ...
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


% --- Executes just before TimeCourseANOVAEditor is made visible.
function TimeCourseANOVAEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.TimeCourseANOVAEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.TimeCourseANOVAEditor,'Position',winpos);

% Get input
handles.names=varargin{1};
handles.cind=varargin{2};
handles.tind=varargin{3};
handles.pairListContents=varargin{4};

set(handles.controlPopup,'String',handles.names);
set(handles.treatedPopup,'String',handles.names);
set(handles.pairsList,'String',handles.pairListContents)

if ~isempty(handles.pairListContents)
    set(handles.removeButton,'Enable','on')
end

% Default output
handles.controlIndices=handles.cind;       % Already selected input indices
handles.treatedIndices=handles.tind;       % Already selected input indices
handles.pairList=handles.pairListContents; % Already selected pairs
handles.cancel=false;                      % User did not press cancel

% Assign some internal variables
handles.currentControl=handles.names{1};
handles.currentTreated=handles.names{1};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TimeCourseANOVAEditor wait for user response (see UIRESUME)
uiwait(handles.TimeCourseANOVAEditor);


% --- Outputs from this function are returned to the command line.
function varargout = TimeCourseANOVAEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.TimeCourseANOVAEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.TimeCourseANOVAEditor);
end

varargout{1}=handles.controlIndices;
varargout{2}=handles.treatedIndices;
varargout{3}=handles.pairList;
varargout{4}=handles.cancel;


% --- Executes on selection change in controlPopup.
function controlPopup_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
conts=get(hObject,'String');
handles.currentControl=conts{val};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function controlPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in treatedPopup.
function treatedPopup_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
conts=get(hObject,'String');
handles.currentTreated=conts{val};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function treatedPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pairsList.
function pairsList_Callback(hObject, eventdata, handles)

if ~isempty(get(hObject,'String'))
    set(handles.removeButton,'Enable','on')
else
    set(handles.removeButton,'Enable','off')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function pairsList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addButton.
function addButton_Callback(hObject, eventdata, handles)

% Get the wanted indices
indControl=strmatch(handles.currentControl,handles.names,'exact');
indTreated=strmatch(handles.currentTreated,handles.names,'exact');
% Check if already selected. If not, include else not
if ismember(indTreated,handles.treatedIndices)
    return
end

handles.controlIndices=[handles.controlIndices indControl];
handles.treatedIndices=[handles.treatedIndices indTreated];

% Update the list of calculations
oldstr=get(handles.pairsList,'String');
p2=['Pair FC is: ',handles.names{indTreated},'/',handles.names{indControl}];
newstr=[oldstr;{p2}];
set(handles.pairsList,'String',newstr,'Max',length(newstr))
handles.pairList=newstr;
set(handles.removeButton,'Enable','on')

guidata(hObject,handles);


% --- Executes on button press in removeButton.
function removeButton_Callback(hObject, eventdata, handles)

% Get indices to remove
reminds=get(handles.pairsList,'Value');
str=get(handles.pairsList,'String');

% Update condition indices
handles.controlIndices(reminds)=[];
handles.treatedIndices(reminds)=[];
str(reminds)=[];

% Update list
set(handles.pairsList,'String',str,'Value',1,'Max',length(str))
handles.pairList=str;

% Check if empty so as to disable remove button
if isempty(get(handles.pairsList,'String'))
    set(hObject,'Enable','off')
end

guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.TimeCourseANOVAEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.controlIndices=[];
handles.treatedIndices=[];
handles.pairList=handles.pairListContents;
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.TimeCourseANOVAEditor);
