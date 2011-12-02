function varargout = RankInvariantAffyEditor(varargin)
% RANKINVARIANTAFFYEDITOR M-file for RankInvariantAffyEditor.fig
%      RANKINVARIANTAFFYEDITOR, by itself, creates a new RANKINVARIANTAFFYEDITOR or raises the existing
%      singleton*.
%
%      H = RANKINVARIANTAFFYEDITOR returns the handle to a new RANKINVARIANTAFFYEDITOR or the handle to
%      the existing singleton*.
%
%      RANKINVARIANTAFFYEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RANKINVARIANTAFFYEDITOR.M with the given input arguments.
%
%      RANKINVARIANTAFFYEDITOR('Property','Value',...) creates a new RANKINVARIANTAFFYEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RankInvariantAffyEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RankInvariantAffyEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RankInvariantAffyEditor

% Last Modified by GUIDE v2.5 07-Oct-2008 14:30:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RankInvariantAffyEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @RankInvariantAffyEditor_OutputFcn, ...
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


% --- Executes just before RankInvariantAffyEditor is made visible.
function RankInvariantAffyEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.RankInvariantAffyEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.RankInvariantAffyEditor,'Position',winpos);

% Get input
arrays=varargin{1};
set(handles.arrayListPopup,'String',arrays)

% Set defaults
handles.lowrank=0.005;                % Lower rank threshold
handles.uprank=0.05;                  % Upper rank threshold
handles.maxdata=1;                    % Higher or Lower average rank exclusion position
handles.maxinvar=1.5;                 % Maximum percentage of dataset points included in the set
handles.baseline=-1;                  % Baseline array
handles.baseName='Median of medians'; % Its name
handles.method='lowess';              % Method for data smoothing
handles.span=0.1;                     % Its span
handles.showplot=false;               % Show plot
handles.cancel=false;                 % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RankInvariantAffyEditor wait for user response (see UIRESUME)
uiwait(handles.RankInvariantAffyEditor);


% --- Outputs from this function are returned to the command line.
function varargout = RankInvariantAffyEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.RankInvariantAffyEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.RankInvariantAffyEditor);
end

varargout{1}=handles.lowrank;
varargout{2}=handles.uprank;
varargout{3}=handles.maxdata;
varargout{4}=handles.maxinvar;
varargout{5}=handles.baseline;
varargout{6}=handles.baseName;
varargout{7}=handles.method;
varargout{8}=handles.span;
varargout{9}=handles.showplot;
varargout{10}=handles.cancel;


function lowEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<0 || val>1
    uiwait(errordlg('The lower rank limit must be a positive number between 0 and 1.',...
                    'Bad Input'));
    set(hObject,'String','0.005');
    handles.lowrank=str2double(get(hObject,'String'));
else
    handles.lowrank=val;
end
guidata(hObject,handles);


function lowEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function upEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<0 || val>1
    uiwait(errordlg('The upper rank limit must be a positive number between 0 and 1.',...
                    'Bad Input'));
    set(hObject,'String','0.05');
    handles.uprank=str2double(get(hObject,'String'));
else
    handles.uprank=val;
end
guidata(hObject,handles);


function upEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxDataEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<0
    uiwait(errordlg('The maximum points in set threshold must be greater than or equal to zero.',...
                    'Bad Input'));
    set(hObject,'String','1');
    handles.maxdata=str2double(get(hObject,'String'));
else
    handles.maxdata=val;
end
guidata(hObject,handles);


function maxDataEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxRankEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<0
    uiwait(errordlg('The maximum points in line set threshold must be greater than or equal to zero.',...
                    'Bad Input'));
    set(hObject,'String','1.5');
    handles.maxinvar=str2double(get(hObject,'String'));
else
    handles.maxinvar=val;
end
guidata(hObject,handles);


function maxRankEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function defaultBaseRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.baseline=-1;
    handles.baseName='Median of medians';
    set(handles.arrayListPopup,'Enable','off');
end
guidata(hObject,handles);


function customBaseRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.baseline=get(handles.arrayListPopup,'Value');
    strs=get(handles.arrayListPopup,'String');
    handles.baseName=strs(handles.baseline);
    set(handles.arrayListPopup,'Enable','on');
end
guidata(hObject,handles);


function arrayListPopup_Callback(hObject, eventdata, handles)

strs=get(hObject,'String');
val=get(hObject,'Value');
handles.baseline=val;
handles.baseName=strs{val};
guidata(hObject,handles);


function arrayListPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dispPlotCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.showplot=true;
else
    handles.showplot=false;
end
guidata(hObject,handles);


function smootherPopup_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
switch val
    case 1 % Lowess
        handles.method='lowess';
    case 2 % Running median
        handles.method='runmed';
    case 3 % Running mean
        handles.method='runmean';
end
guidata(hObject,handles);


function smootherPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function spanEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<0
    uiwait(errordlg('The smoother span must be a positive number.',...
                    'Bad Input'));
    set(hObject,'String','0.1');
    handles.span=str2double(get(hObject,'String'));
elseif val>1 && rem(val,1)~=0
    uiwait(errordlg('If > 1 the smoother span must be a positive integer.',...
                    'Bad Input'));
    set(hObject,'String','0.1');
    handles.span=str2double(get(hObject,'String'));
else
    handles.span=val;
end
guidata(hObject,handles);


function spanEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.RankInvariantAffyEditor);


function cancelButton_Callback(hObject, eventdata, handles)

handles.lowrank=0.005;
handles.uprank=0.05;
handles.maxdata=1;
handles.maxinvar=1.5;
handles.baseline=-1;
handles.baseName='Median of medians';
handles.method='lowess';
handles.span=0.1;
handles.showplot=false;
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.RankInvariantAffyEditor);
