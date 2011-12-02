function varargout = VolcanoPlotEditor(varargin)
% VOLCANOPLOTEDITOR M-file for VolcanoPlotEditor.fig
%      VOLCANOPLOTEDITOR, by itself, creates a new VOLCANOPLOTEDITOR or raises the existing
%      singleton*.
%
%      H = VOLCANOPLOTEDITOR returns the handle to a new VOLCANOPLOTEDITOR or the handle to
%      the existing singleton*.
%
%      VOLCANOPLOTEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VOLCANOPLOTEDITOR.M with the given input arguments.
%
%      VOLCANOPLOTEDITOR('Property','Value',...) creates a new VOLCANOPLOTEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VolcanoPlotEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VolcanoPlotEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VolcanoPlotEditor

% Last Modified by GUIDE v2.5 13-Jul-2007 17:18:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VolcanoPlotEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @VolcanoPlotEditor_OutputFcn, ...
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


% --- Executes just before VolcanoPlotEditor is made visible.
function VolcanoPlotEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.VolcanoPlotEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.VolcanoPlotEditor,'Position',winpos);

% Get inputs
handles.nocond=varargin{1};
handles.conds=varargin{2};
if handles.nocond==1
    set(handles.rawRatioRadio,'Enable','off')
    set(handles.subtractRatioRadio,'Enable','off')
    set(handles.divideRatioRadio,'Enable','off')
    set(handles.refStatic,'Enable','off')
    set(handles.refPopup,'Enable','off')
    set(handles.treStatic,'Enable','off')
    set(handles.trePopup,'Enable','off')
else
    set(handles.refPopup,'String',handles.conds)
    set(handles.trePopup,'String',handles.conds)
end

% Set default outputs
handles.effect=2;                     % Default, effect is the subtraction
handles.dispvalLine=true;             % Default display p-value cutoff line
handles.disFCLine=true;               % Same for fold change line
handles.pvalCut=0.05;                 % Default p-value cutoff 0.05
handles.FCCut=2;                      % Default fold change 2
handles.title='';                     % No default title
handles.control=0;                    % Places to shift in DataCellStat{4} for control: 0
handles.controlName=handles.conds{1}; % Its name
handles.treated=0;                    % Places to shift in DataCellStat{4} for treated: 0
handles.treatedName=handles.conds{1}; % Its name
handles.cancel=false;                 % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VolcanoPlotEditor wait for user response (see UIRESUME)
uiwait(handles.VolcanoPlotEditor);


% --- Outputs from this function are returned to the command line.
function varargout = VolcanoPlotEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.VolcanoPlotEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.VolcanoPlotEditor);
end

varargout{1}=handles.effect;
varargout{2}=handles.dispvalLine;
varargout{3}=handles.disFCLine;
varargout{4}=handles.pvalCut;
varargout{5}=handles.FCCut;
varargout{6}=handles.title;
varargout{7}=handles.control;
varargout{8}=handles.controlName;
varargout{9}=handles.treated;
varargout{10}=handles.treatedName;
varargout{11}=handles.cancel;


% --- Executes on button press in rawRatioRadio.
function rawRatioRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.effect=1; % Effect is the ratio
    guidata(hObject,handles);
end


% --- Executes on button press in subtractRatioRadio.
function subtractRatioRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.effect=2; % Effect is ratio treated - ratio control
    guidata(hObject,handles);
end


% --- Executes on button press in divideRatioRadio.
function divideRatioRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.effect=3; % % Effect is ratio treated / ratio control
    guidata(hObject,handles);
end


function titlesEdit_Callback(hObject, eventdata, handles)

handles.title=get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function titlesEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dispvalcutCheck.
function dispvalcutCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dispvalLine=true;
    set(handles.pvalStatic,'Enable','on')
    set(handles.pvalCutEdit,'Enable','on')
else
    handles.dispvalLine=false;
    set(handles.pvalStatic,'Enable','off')
    set(handles.pvalCutEdit,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in disFCcutCheck.
function disFCcutCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.disFCLine=true;
    set(handles.fcStatic,'Enable','on')
    set(handles.fcCutEdit,'Enable','on')
else
    handles.disFCLine=false;
    set(handles.fcStatic,'Enable','off')
    set(handles.fcCutEdit,'Enable','off')
end
guidata(hObject,handles);


function pvalCutEdit_Callback(hObject, eventdata, handles)

pval=str2double(get(hObject,'String'));
if isnan(pval) || pval<0 || pval>1
    uiwait(errordlg('The p-value must be a positive number between 0 and 1.',...
                    'Bad Input'));
    set(hObject,'String','0.05');
    handles.pvalCut=str2double(get(hObject,'String'));
else
    handles.pvalCut=pval;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function pvalCutEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fcCutEdit_Callback(hObject, eventdata, handles)

fc=str2double(get(hObject,'String'));
if isnan(fc) || fc<=0
    uiwait(errordlg('The fold change line must be a positive value.',...
                    'Bad Input'));
    set(hObject,'String','2');
    handles.FCCut=str2double(get(hObject,'String'));
else
    handles.FCCut=fc;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function fcCutEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in refPopup.
function refPopup_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
contents=get(hObject,'String');
handles.control=val-1;
handles.controlName=contents{val};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function refPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in trePopup.
function trePopup_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
contents=get(hObject,'String');
handles.treated=val-1;
handles.treatedName=contents{val};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function trePopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.VolcanoPlotEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Return default
handles.effect=2; 
handles.dispvalLine=true;
handles.disFCLine=true;
handles.pvalCut=0.05; 
handles.FCCut=2;
handles.title='';
handles.control=0;
handles.controlName=handles.conds{1};
handles.treated=0;
handles.treatedName=handles.conds{1};
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.VolcanoPlotEditor);
