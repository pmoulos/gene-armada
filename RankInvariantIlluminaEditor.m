function varargout = RankInvariantIlluminaEditor(varargin)
% RANKINVARIANTILLUMINAEDITOR M-file for RankInvariantIlluminaEditor.fig
%      RANKINVARIANTILLUMINAEDITOR, by itself, creates a new RANKINVARIANTILLUMINAEDITOR or raises the existing
%      singleton*.
%
%      H = RANKINVARIANTILLUMINAEDITOR returns the handle to a new RANKINVARIANTILLUMINAEDITOR or the handle to
%      the existing singleton*.
%
%      RANKINVARIANTILLUMINAEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RANKINVARIANTILLUMINAEDITOR.M with the given input arguments.
%
%      RANKINVARIANTILLUMINAEDITOR('Property','Value',...) creates a new RANKINVARIANTILLUMINAEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RankInvariantIlluminaEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RankInvariantIlluminaEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RankInvariantIlluminaEditor

% Last Modified by GUIDE v2.5 21-Jan-2010 17:47:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RankInvariantIlluminaEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @RankInvariantIlluminaEditor_OutputFcn, ...
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


% --- Executes just before RankInvariantIlluminaEditor is made visible.
function RankInvariantIlluminaEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.RankInvariantIlluminaEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.RankInvariantIlluminaEditor,'Position',winpos);

% Get input
arrays=varargin{1};
set(handles.arrayListPopup,'String',arrays)

% Set defaults
handles.lowrank=0.003;                % Lower rank threshold
handles.uprank=0.007;                 % Upper rank threshold
handles.exclude=0;                    % Higher or Lower average rank exclusion position
handles.percentage=1;                 % Maximum percentage of dataset points included in the set
handles.iterate=true;                 % Iterate until specified rank invariant set size reached
handles.baseline=-1;                  % Baseline array
handles.baseName='Median of medians'; % Its name
handles.method='lowess';              % Method for data smoothing
handles.span=0.1;                     % Its span
handles.showplot=false;               % Show plot
handles.cancel=false;                 % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RankInvariantIlluminaEditor wait for user response (see UIRESUME)
uiwait(handles.RankInvariantIlluminaEditor);


% --- Outputs from this function are returned to the command line.
function varargout = RankInvariantIlluminaEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.RankInvariantIlluminaEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.RankInvariantIlluminaEditor);
end

out.lowrank=handles.lowrank;
out.uprank=handles.uprank;
out.exclude=handles.exclude;
out.percentage=handles.percentage;
out.iterate=handles.iterate;
out.baseline=handles.baseline;
out.baseName=handles.baseName;
out.method=handles.method;
out.span=handles.span;
out.showplot=handles.showplot;

varargout{1}=out;
varargout{2}=handles.cancel;


function lowRankEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<0 || val>1
    uiwait(errordlg('The lower rank limit must be a positive number between 0 and 1.',...
                    'Bad Input'));
    set(hObject,'String','0.03');
    handles.lowrank=str2double(get(hObject,'String'));
else
    handles.lowrank=val;
end
guidata(hObject,handles);


function lowRankEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function upRankEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<0 || val>1
    uiwait(errordlg('The upper rank limit must be a positive number between 0 and 1.',...
                    'Bad Input'));
    set(hObject,'String','0.07');
    handles.uprank=str2double(get(hObject,'String'));
else
    handles.uprank=val;
end
guidata(hObject,handles);


function upRankEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function excludeEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<0
    uiwait(errordlg('The exclusion threshold must be greater than or equal to zero.',...
                    'Bad Input'));
    set(hObject,'String','0');
    handles.exclude=str2double(get(hObject,'String'));
else
    handles.exclude=val;
end
guidata(hObject,handles);


function excludeEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function prcntEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<0 || val>100
    uiwait(errordlg('The dataset percentage must be a positive number between 0 and 100.',...
                    'Bad Input'));
    set(hObject,'String','1');
    handles.percentage=str2double(get(hObject,'String'));
else
    handles.percentage=val;
end
guidata(hObject,handles);


function prcntEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function iterateCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.iterate=true;
else
    handles.iterate=false;
end
guidata(hObject,handles);


function dispPlotCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.showplot=true;
else
    handles.showplot=false;
end
guidata(hObject,handles);


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
hadnles.baseName=strs{val};
guidata(hObject,handles);


function arrayListPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


function smootherSpanEdit_Callback(hObject, eventdata, handles)

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


function smootherSpanEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.RankInvariantIlluminaEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.lowrank=0.003;
handles.uprank=0.007;
handles.exclude=0;
handles.percentage=1;
handles.iterate=true;
handles.baseline=-1;
handles.baseName='Median of medians';
handles.method='lowess';
handles.span=0.1;
handles.showplot=false;
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.RankInvariantIlluminaEditor);
