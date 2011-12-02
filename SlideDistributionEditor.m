function varargout = SlideDistributionEditor(varargin)
% SLIDEDISTRIBUTIONEDITOR M-file for SlideDistributionEditor.fig
%      SLIDEDISTRIBUTIONEDITOR, by itself, creates a new SLIDEDISTRIBUTIONEDITOR or raises the existing
%      singleton*.
%
%      H = SLIDEDISTRIBUTIONEDITOR returns the handle to a new SLIDEDISTRIBUTIONEDITOR or the handle to
%      the existing singleton*.
%
%      SLIDEDISTRIBUTIONEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLIDEDISTRIBUTIONEDITOR.M with the given input arguments.
%
%      SLIDEDISTRIBUTIONEDITOR('Property','Value',...) creates a new SLIDEDISTRIBUTIONEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SlideDistributionEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SlideDistributionEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SlideDistributionEditor

% Last Modified by GUIDE v2.5 02-Jul-2007 16:19:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SlideDistributionEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @SlideDistributionEditor_OutputFcn, ...
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


% --- Executes just before SlideDistributionEditor is made visible.
function SlideDistributionEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.SlideDistributionEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.SlideDistributionEditor,'Position',winpos);

% Get inputs
handles.arrays=varargin{1};
handles.conditions=varargin{2};

% Fill listboxes
set(handles.arrayList,'String',handles.arrays,...
                      'Max',length(handles.arrays),...
                      'Value',1)
set(handles.conditionList,'String',handles.conditions,...
                          'Max',length(handles.conditions),...
                          'Value',1)

handles.len=length(get(handles.arrayList,'Value')); 
                     
% Set default outputs
handles.whicharrays=handles.arrays(1);                         % Default output is one array
handles.whichconditions=handles.conditions{1};                 % Default condition is the first
handles.sliorcon=1;                                            % Plot for each slide
handles.before=get(handles.beforeNormCheck,'Value');           % Do not create plots before normalization
handles.after=get(handles.afterNormCheck,'Value');             % Do not create plots after notmalzation
handles.beforeafter=get(handles.beforeafterNormCheck,'Value'); % Create plots for both before and after nrmlztn
handles.beforeTitles='';                                       % No titles before, auto creation by default
handles.afterTitles='';                                        % No titles after, auto creation by default
handles.beforeafterTitles='';                                  % No titles before/after, auto creation by default
handles.cancel=false;                                          % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SlideDistributionEditor wait for user response (see UIRESUME)
uiwait(handles.SlideDistributionEditor);


% --- Outputs from this function are returned to the command line.
function varargout = SlideDistributionEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.SlideDistributionEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.SlideDistributionEditor);
end

varargout{1}=handles.whicharrays;
varargout{2}=handles.whichconditions;
varargout{3}=handles.sliorcon;
varargout{4}=handles.before;
varargout{5}=handles.after;
varargout{6}=handles.beforeafter;
varargout{7}=handles.beforeTitles;
varargout{8}=handles.afterTitles;
varargout{9}=handles.beforeafterTitles;
varargout{10}=handles.cancel;

% --- Executes on selection change in arrayList.
function arrayList_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
handles.whicharrays=contents(val);
handles.len=length(val);
set(handles.beforeNormTitlesEdit,'Max',handles.len)
set(handles.afterNormTitlesEdit,'Max',handles.len)
set(handles.beforeafterNormTitlesEdit,'Max',handles.len)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function arrayList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in conditionList.
function conditionList_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
handles.whichconditions=contents(val);
handles.len=length(val);
set(handles.beforeNormTitlesEdit,'Max',handles.len)
set(handles.afterNormTitlesEdit,'Max',handles.len)
set(handles.beforeafterNormTitlesEdit,'Max',handles.len)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function conditionList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in eachSlideRadio.
function eachSlideRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.sliorcon=1; % One plot per slide
    set(handles.arrayStatic,'Enable','on')
    set(handles.arrayList,'Enable','on')
    set(handles.conditionStatic,'Enable','off')
    set(handles.conditionList,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in eachConditionRadio.
function eachConditionRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.sliorcon=2; % One plot per condition
    set(handles.arrayStatic,'Enable','off')
    set(handles.arrayList,'Enable','off')
    set(handles.conditionStatic,'Enable','on')
    set(handles.conditionList,'Enable','on')    
end
guidata(hObject,handles);


% --- Executes on button press in beforeNormCheck.
function beforeNormCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.before=true;
    set(handles.beforeNormTitlesEdit,'Enable','on')
else
    handles.before=false;
    set(handles.beforeNormTitlesEdit,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in afterNormCheck.
function afterNormCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.after=true;
    set(handles.afterNormTitlesEdit,'Enable','on')
else
    handles.after=false;
    set(handles.afterNormTitlesEdit,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in beforeafterNormCheck.
function beforeafterNormCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.beforeafter=true;
    set(handles.beforeafterNormTitlesEdit,'Enable','on')
else
    handles.beforeafter=false;
    set(handles.beforeafterNormTitlesEdit,'Enable','off')
end
guidata(hObject,handles);


function beforeNormTitlesEdit_Callback(hObject, eventdata, handles)

if handles.sliorcon==1;
    part='arrays';
else
    part='conditions';
end
tit=cellstr(get(hObject,'String'));
if length(tit)~=handles.len
    uiwait(errordlg({['Please provide a number of titles equal to the number of ',part],...
                     ['you selected (',num2str(handles.len),') or else leave the field completely'],... 
                     'empty for automated title generation.'},'Bad Input'));
    set(hObject,'String','')
    handles.beforeTitles='';
else
    handles.beforeTitles=tit;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function beforeNormTitlesEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function afterNormTitlesEdit_Callback(hObject, eventdata, handles)

if handles.sliorcon==1;
    part='arrays';
else
    part='conditions';
end
tit=cellstr(get(hObject,'String'));
if length(tit)~=handles.len
    uiwait(errordlg({['Please provide a number of titles equal to the number of ',part],...
                     ['you selected (',num2str(handles.len),') or else leave the field completely'],... 
                     'empty for automated title generation.'},'Bad Input'));
    set(hObject,'String','')
    handles.afterTitles='';
else
    handles.afterTitles=tit;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function afterNormTitlesEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function beforeafterNormTitlesEdit_Callback(hObject, eventdata, handles)

if handles.sliorcon==1;
    part='arrays';
else
    part='conditions';
end
tit=cellstr(get(hObject,'String'));
if length(tit)~=handles.len
    uiwait(errordlg({['Please provide a number of titles equal to the number of ',part],...
                     ['you selected (',num2str(handles.len),') or else leave the field completely'],... 
                     'empty for automated title generation.'},'Bad Input'));
    set(hObject,'String','')
    handles.beforeafterTitles='';
else
    handles.beforeafterTitles=tit;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function beforeafterNormTitlesEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.SlideDistributionEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Set default outputs
handles.whicharrays=handles.arrays(1);
handles.whichconditions='';
handles.sliorcon=1;
handles.before=get(handles.beforeNormCheck,'Value');
handles.after=get(handles.afterNormCheck,'Value');
handles.beforeafter=get(handles.beforeafterNormCheck,'Value');
handles.beforeTitles='';
handles.afterTitles='';
handles.beforeafterTitles='';
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.SlideDistributionEditor);

