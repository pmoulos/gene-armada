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

% Last Modified by GUIDE v2.5 11-Nov-2012 13:03:55

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
handles.out='MBC';        % Signal to Noise
handles.cancel=false; % Cancel is not pressed

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
varargout{1}=handles.out;
varargout{2}=handles.cancel;


% --- Executes on button press in subtract.
function subtract_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.out='NBC';
end
guidata(hObject,handles);


% --- Executes on button press in signal2noise.
function signal2noise_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.out='MBC';
end
guidata(hObject,handles);


% --- Executes on button press in threequartile.
function threequartile_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.out='3Qs';
end
guidata(hObject,handles);


% --- Executes on button press in ninedecile.
function ninedecile_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.out='9Ds';
end
guidata(hObject,handles);


% --- Executes on button press in quadloess.
function quadloess_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.out='LsBC';
end
guidata(hObject,handles);


% --- Executes on button press in rquadloess.
function rquadloess_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.out='RLsBC';
end
guidata(hObject,handles);


% --- Executes on button press in nocorr.
function nocorr_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1;
    handles.out=3;
end
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.BackgroundCorrectionEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% If Cancel pressed return default method
handles.out='MBC';
handles.cancel=true; % Cancel pressed
guidata(hObject,handles)
uiresume(handles.BackgroundCorrectionEditor);
