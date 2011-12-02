function varargout = RMAEditor(varargin)
% RMAEDITOR M-file for RMAEditor.fig
%      RMAEDITOR, by itself, creates a new RMAEDITOR or raises the existing
%      singleton*.
%
%      H = RMAEDITOR returns the handle to a new RMAEDITOR or the handle to
%      the existing singleton*.
%
%      RMAEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RMAEDITOR.M with the given input arguments.
%
%      RMAEDITOR('Property','Value',...) creates a new RMAEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RMAEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RMAEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RMAEditor

% Last Modified by GUIDE v2.5 04-Oct-2008 18:12:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RMAEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @RMAEditor_OutputFcn, ...
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


% --- Executes just before RMAEditor is made visible.
function RMAEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.RMAEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.RMAEditor,'Position',winpos);

% Set defaults
handles.method='RMA';                           % RMA
handles.methodName='Robust Multiarray Average'; % Name
handles.trunc=true;                             % Truncate Gaussian, true
handles.cancel=false;                           % User did not press Cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RMAEditor wait for user response (see UIRESUME)
uiwait(handles.RMAEditor);


% --- Outputs from this function are returned to the command line.
function varargout = RMAEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.RMAEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.RMAEditor);
end

varargout{1}=handles.method;
varargout{2}=handles.methodName;
varargout{3}=handles.trunc;
varargout{4}=handles.cancel;


function methodPopup_Callback(hObject, eventdata, handles)

mets=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1
        handles.method='RMA';
    case 2
        handles.method='MLE';
end
handles.methodName=mets{val};
guidata(hObject,handles);


function methodPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function truncCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.trunc=true;
else
    handles.trunc=false;
end
guidata(hObject,handles);


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.RMAEditor);


function cancelButton_Callback(hObject, eventdata, handles)

handles.method='RMA';
handles.methodName='Robust Multiarray Average';
handles.trunc=true;
handles.cancel=false; % User pressed Cancel
guidata(hObject,handles);
uiresume(handles.RMAEditor);
