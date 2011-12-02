function varargout = MAPlotEditor(varargin)
% MAPLOTEDITOR M-file for MAPlotEditor.fig
%      MAPLOTEDITOR, by itself, creates a new MAPLOTEDITOR or raises the existing
%      singleton*.
%
%      H = MAPLOTEDITOR returns the handle to a new MAPLOTEDITOR or the handle to
%      the existing singleton*.
%
%      MAPLOTEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAPLOTEDITOR.M with the given input arguments.
%
%      MAPLOTEDITOR('Property','Value',...) creates a new MAPLOTEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MAPlotEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MAPlotEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MAPlotEditor

% Last Modified by GUIDE v2.5 28-Jun-2007 16:22:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MAPlotEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @MAPlotEditor_OutputFcn, ...
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


% --- Executes just before MAPlotEditor is made visible.
function MAPlotEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.MAPlotEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.MAPlotEditor,'Position',winpos);

% Get input arguments
handles.arrays=varargin{1};   % Arrays for the listbox
handles.subPfmd=varargin{2};  % Has subgrid normalization been performed?
set(handles.beforeAfterNormCheck,'Value',1)
set(handles.arrayList,'String',handles.arrays,...
                      'Max',length(handles.arrays),...
                      'Value',1)
if ~handles.subPfmd
    set(handles.displaySubCheck,'Enable','off')
end
handles.len=length(get(handles.arrayList,'Value'));

% Choose default outputs (1st aproach, will also depend from the input)
handles.whichones=handles.arrays(1);                           % No arrays returned by default
handles.before=get(handles.beforeNormCheck,'Value');           % Do not display
handles.after=get(handles.afterNormCheck,'Value');             % Do not display
handles.beforeafter=get(handles.beforeAfterNormCheck,'Value'); % Do not display
handles.beforeTitles='';                                       % Auto titles
handles.afterTitles='';                                        % Auto titles
handles.beforeafterTitles='';                                  % Auto titles
handles.disCurve=false;                                        % Do not display
handles.disFCLine=false;                                       % Do not display
handles.FCLine=2;                                              % Default FC
handles.disSub=false;                                          % Do not display subgrid plots
handles.cancel=false;                                          % Cancel not pressed

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MAPlotEditor wait for user response (see UIRESUME)
uiwait(handles.MAPlotEditor);


% --- Outputs from this function are returned to the command line.
function varargout = MAPlotEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.MAPlotEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.MAPlotEditor);
end

varargout{1}=handles.whichones;
varargout{2}=handles.before;
varargout{3}=handles.after;
varargout{4}=handles.beforeafter;
varargout{5}=handles.beforeTitles;
varargout{6}=handles.afterTitles;
varargout{7}=handles.beforeafterTitles;
varargout{8}=handles.disCurve;
varargout{9}=handles.disFCLine;
varargout{10}=handles.FCLine;
varargout{11}=handles.disSub;
varargout{12}=handles.cancel;


% --- Executes on selection change in arrayList.
function arrayList_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
handles.whichones=contents(val);
handles.len=length(val);
set(handles.beforeNormTitlesEdit,'Max',handles.len)
set(handles.afterNormTitlesEdit,'Max',handles.len)
set(handles.befAftNormTitlesEdit,'Max',handles.len)
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function arrayList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on button press in beforeAfterNormCheck.
function beforeAfterNormCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.beforeafter=true;
    set(handles.befAftNormTitlesEdit,'Enable','on')
else
    handles.beforeafter=false;
    set(handles.befAftNormTitlesEdit,'Enable','off')
end
guidata(hObject,handles);


function beforeNormTitlesEdit_Callback(hObject, eventdata, handles)

tit=cellstr(get(hObject,'String'));
if length(tit)~=handles.len
    uiwait(errordlg({'Please provide a number of titles equal to the number of arrays',...
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

tit=cellstr(get(hObject,'String'));
if length(tit)~=handles.len
    uiwait(errordlg({'Please provide a number of titles equal to the number of arrays',...
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


function befAftNormTitlesEdit_Callback(hObject, eventdata, handles)

tit=cellstr(get(hObject,'String'));
if length(tit)~=handles.len
    uiwait(errordlg({'Please provide a number of titles equal to the number of arrays',...
                     ['you selected (',num2str(handles.len),') or else leave the field completely'],... 
                     'empty for automated title generation.'},'Bad Input'));
    set(hObject,'String','')
    handles.beforeafterTitles='';
else
    handles.beforeafterTitles=tit;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function befAftNormTitlesEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in displaySubCheck.
function displaySubCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.disSub=true;
    set(handles.beforeAfterNormCheck,'Enable','off')
    set(handles.befAftNormTitlesEdit,'Enable','off')
    handles.beforeafter=false;
else
    handles.disSub=false;
    set(handles.beforeAfterNormCheck,'Enable','on')
    set(handles.befAftNormTitlesEdit,'Enable','on')
    handles.beforeafter=true;
end
guidata(hObject,handles);


% --- Executes on button press in displayCurveCheck.
function displayCurveCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.disCurve=true;
else
    handles.disCurve=false;
end
guidata(hObject,handles);


% --- Executes on button press in displayFoldCheck.
function displayFoldCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.disFCLine=true;
    set(handles.fcStatic,'Enable','on')
    set(handles.fcEdit,'Enable','on')
else
    handles.disFCLine=false;
    set(handles.fcStatic,'Enable','off')
    set(handles.fcEdit,'Enable','off')
end
guidata(hObject,handles);


function fcEdit_Callback(hObject, eventdata, handles)

fc=str2double(get(hObject,'String'));
if isnan(fc) || fc<=0
    uiwait(errordlg('The fold change line must be a positive value.',...
                    'Bad Input'));
    set(hObject,'String','2');
    handles.FCLine=str2double(get(hObject,'String'));
else
    handles.FCLine=fc;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function fcEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.MAPlotEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.whichones='';
handles.before=get(handles.beforeNormCheck,'Value');
handles.after=get(handles.afterNormCheck,'Value');
handles.beforeafter=get(handles.beforeAfterNormCheck,'Value');
handles.beforeTitles='';
handles.afterTitles='';
handles.beforeafterTitles='';
handles.disCurve=false;
handles.disFCLine=false;
handles.FCLine=2;
handles.disSub=false;
handles.cancel=false; % Cancel pressed
guidata(hObject,handles);
uiresume(handles.MAPlotEditor);
