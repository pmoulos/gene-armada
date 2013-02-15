function varargout = BackgroundCorrectionEditor(varargin)
% BACKGROUNDCORRECTIONEDITOR M-file for BackgroundCorrectionEditor.fig
%      BACKGROUNDCORRECTIONEDITOR, by itself, creates a new BACKGROUNDCORRECTIONEDITOR or raises the existing
%      singleton*.
%
%      H = BACKGROUNDCORRECTIONEDITOR returns the handle to a new BACKGROUNDCORRECTIONEDITOR or the handle to
%      the existing singleton*.
%
%      BACKGROUNDCORRECTIONEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACKGROUNDCORRECTIONEDITOR.M with the given input arguments.
%
%      BACKGROUNDCORRECTIONEDITOR('Property','Value',...) creates a new BACKGROUNDCORRECTIONEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BackgroundCorrectionEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BackgroundCorrectionEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BackgroundCorrectionEditor

% Last Modified by GUIDE v2.5 13-Feb-2013 22:58:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BackgroundCorrectionEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @BackgroundCorrectionEditor_OutputFcn, ...
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


% --- Executes just before BackgroundCorrectionEditor is made visible.
function BackgroundCorrectionEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.BackgroundCorrectionEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.BackgroundCorrectionEditor,'Position',winpos);

% Set default output
handles.method='MBC';  % Signal to Noise
handles.step=0.1;      % Percentile
handles.loess='loess'; % For loess correction
handles.span=0.2;      % Loess span
handles.cancel=false;  % Cancel is not pressed

% Default loess selection
set(handles.typePopup,'Value',2);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BackgroundCorrectionEditor wait for user response (see UIRESUME)
uiwait(handles.BackgroundCorrectionEditor);


% --- Outputs from this function are returned to the command line.
function varargout = BackgroundCorrectionEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.BackgroundCorrectionEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.BackgroundCorrectionEditor);
end

% Get default command line output from handles structure
varargout{1}=handles.method;
varargout{2}=handles.step;
varargout{3}=handles.loess;
varargout{4}=handles.span;
varargout{5}=handles.cancel;


% --- Executes on button press in subtract.
function subtract_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.method='NBC';
    set(handles.stepStatic,'Enable','off')
    set(handles.stepEdit,'Enable','off')
    set(handles.spanStatic,'Enable','off')
    set(handles.spanEdit,'Enable','off')
    set(handles.typeStatic,'Enable','off')
    set(handles.typePopup,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in signal2noise.
function signal2noise_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.method='MBC';
    set(handles.stepStatic,'Enable','off')
    set(handles.stepEdit,'Enable','off')
    set(handles.spanStatic,'Enable','off')
    set(handles.spanEdit,'Enable','off')
    set(handles.typeStatic,'Enable','off')
    set(handles.typePopup,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in pbc.
function pbc_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.method='PBC';
    set(handles.stepStatic,'Enable','on')
    set(handles.stepEdit,'Enable','on')
    set(handles.spanStatic,'Enable','off')
    set(handles.spanEdit,'Enable','off')
    set(handles.typeStatic,'Enable','off')
    set(handles.typePopup,'Enable','off')
end
guidata(hObject,handles);


function stepEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || val>1
    uiwait(errordlg('Step must be a number between 0 and 1!','Bad Input','modal'));
    set(hObject,'String','0.1')
    handles.step=str2double(get(hObject,'String'));
else
    handles.step=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function stepEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loess.
function loess_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.method='LSBC';
    set(handles.stepStatic,'Enable','off')
    set(handles.stepEdit,'Enable','off')
    set(handles.spanStatic,'Enable','on')
    set(handles.spanEdit,'Enable','on')
    set(handles.typeStatic,'Enable','on')
    set(handles.typePopup,'Enable','on')
end
guidata(hObject,handles);


function spanEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || val>1
    uiwait(errordlg('Span must be a number between 0 and 1!','Bad Input','modal'));
    set(hObject,'String','0.1')
    handles.span=str2double(get(hObject,'String'));
else
    handles.span=val;
end
guidata(hObject,handles);


% --- Executes on selection change in typePopup.
function typePopup_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
switch val
    case 1
        handles.loess='lowess';
    case 2
        handles.loess='loess';
    case 3
        handles.loess='rlowess';
    case 4
        handles.loess='rloess';
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function typePopup_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function spanEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nocorr.
function nocorr_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.method='NBC';
    set(handles.stepStatic,'Enable','off')
    set(handles.stepEdit,'Enable','off')
    set(handles.spanStatic,'Enable','off')
    set(handles.spanEdit,'Enable','off')
    set(handles.typeStatic,'Enable','off')
    set(handles.typePopup,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.BackgroundCorrectionEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% If Cancel pressed return default method
handles.method='MBC';
handles.step=0.1;
handles.loess='loess';
handles.span=0.1;
handles.cancel=true; % Cancel pressed
guidata(hObject,handles)
uiresume(handles.BackgroundCorrectionEditor);
