function varargout = QuantileProps(varargin)
% QUANTILEPROPS M-file for QuantileProps.fig
%      QUANTILEPROPS, by itself, creates a new QUANTILEPROPS or raises the existing
%      singleton*.
%
%      H = QUANTILEPROPS returns the handle to a new QUANTILEPROPS or the handle to
%      the existing singleton*.
%
%      QUANTILEPROPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUANTILEPROPS.M with the given input arguments.
%
%      QUANTILEPROPS('Property','Value',...) creates a new QUANTILEPROPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QuantileProps_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to QuantileProps_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help QuantileProps

% Last Modified by GUIDE v2.5 31-Aug-2007 23:34:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QuantileProps_OpeningFcn, ...
                   'gui_OutputFcn',  @QuantileProps_OutputFcn, ...
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


% --- Executes just before QuantileProps is made visible.
function QuantileProps_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.QuantileProps,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.QuantileProps,'Position',winpos);

% Get input
if ~isempty(varargin)
    handles.presel=varargin{1};
else
    handles.presel={[]};
end

handles.presel=handles.presel{1};
if ~isempty(handles.presel)
    if handles.presel.usemedian
        set(handles.medianCheck,'Value',1)
    else
        set(handles.medianCheck,'Value',0)
    end
    handles.usemedian=handles.presel.usemedian;
    if handles.presel.display
        set(handles.displayFigureCheck,'Value',1)
    else
        set(handles.displayFigureCheck,'Value',0)
    end
    handles.display=handles.presel.display;
else
    % Set defaults
    handles.usemedian=false; % Do not use median
    handles.display=false;   % Do not show figure
    handles.cancel=false;    % User did not press cancel
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes QuantileProps wait for user response (see UIRESUME)
uiwait(handles.QuantileProps);


% --- Outputs from this function are returned to the command line.
function varargout = QuantileProps_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.QuantileProps);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.QuantileProps);
end

out.usemedian=handles.usemedian;
out.display=handles.display;

varargout{1}=out;
varargout{2}=handles.cancel;


% --- Executes on button press in medianCheck.
function medianCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.usemedian=true;
else
    handles.usemedian=false;
end
guidata(hObject,handles);


% --- Executes on button press in displayFigureCheck.
function displayFigureCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.display=true;
else
    handles.display=false;
end
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.QuantileProps);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

if isempty(handles.presel)
    % Restore defaults
    handles.usemedian=false;
    handles.display=false;
end
handles.cancel=true; % Used pressed cancel
guidata(hObject,handles);
uiresume(handles.QuantileProps);
