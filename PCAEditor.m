function varargout = PCAEditor(varargin)
% PCAEDITOR M-file for PCAEditor.fig
%      PCAEDITOR, by itself, creates a new PCAEDITOR or raises the existing
%      singleton*.
%
%      H = PCAEDITOR returns the handle to a new PCAEDITOR or the handle to
%      the existing singleton*.
%
%      PCAEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PCAEDITOR.M with the given input arguments.
%
%      PCAEDITOR('Property','Value',...) creates a new PCAEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PCAEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PCAEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PCAEditor

% Last Modified by GUIDE v2.5 20-Oct-2007 14:02:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PCAEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @PCAEditor_OutputFcn, ...
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


% --- Executes just before PCAEditor is made visible.
function PCAEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.PCAEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.PCAEditor,'Position',winpos);

% Get input
handles.genes=varargin{1};
handles.indices=varargin{2};
set(handles.geneList,'String',handles.genes,'Max',length(handles.genes));

% Default outputs
val=get(handles.geneList,'Value');
str=get(handles.geneList,'String');
handles.outelem=str(val);                % Default genes to plot
handles.outelemind=handles.indices(val); % Default output values 
handles.dowhat='select';                 % PCA selected genes
handles.cancel=false;                    % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PCAEditor wait for user response (see UIRESUME)
uiwait(handles.PCAEditor);


% --- Outputs from this function are returned to the command line.
function varargout = PCAEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.PCAEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.PCAEditor);
end

varargout{1}=handles.outelem;
varargout{2}=handles.outelemind;
varargout{3}=handles.dowhat;
varargout{4}=handles.cancel;


% --- Executes on selection change in geneList.
function geneList_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
str=get(hObject,'String');
handles.outelem=str(val);
handles.outelemind=handles.indices(val);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function geneList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectRadio.
function selectRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dowhat='select';
    set(handles.geneList,'Enable','on','String',handles.genes)
end
guidata(hObject,handles);


% --- Executes on button press in allRadio.
function allRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dowhat='all';
    set(handles.geneList,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in deRadio.
function deRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dowhat='de';
    set(handles.geneList,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.PCAEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Restore defaults
val=get(handles.geneList,'Value');
str=get(handles.geneList,'String');
handles.outelem=str(val);
handles.outelemind=handles.indices(val);
handles.dowhat='select';
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.PCAEditor);
