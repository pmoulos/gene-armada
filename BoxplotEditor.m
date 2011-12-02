function varargout = BoxplotEditor(varargin)
% BOXPLOTEDITOR M-file for BoxplotEditor.fig
%      BOXPLOTEDITOR, by itself, creates a new BOXPLOTEDITOR or raises the existing
%      singleton*.
%
%      H = BOXPLOTEDITOR returns the handle to a new BOXPLOTEDITOR or the handle to
%      the existing singleton*.
%
%      BOXPLOTEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BOXPLOTEDITOR.M with the given input arguments.
%
%      BOXPLOTEDITOR('Property','Value',...) creates a new BOXPLOTEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BoxplotEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BoxplotEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BoxplotEditor

% Last Modified by GUIDE v2.5 04-Jul-2007 13:44:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BoxplotEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @BoxplotEditor_OutputFcn, ...
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


% --- Executes just before BoxplotEditor is made visible.
function BoxplotEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.BoxplotEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.BoxplotEditor,'Position',winpos);

% Get inputs
handles.arrays=varargin{1};
handles.conditions=varargin{2};
handles.normpfmd=varargin{3};
handles.software=varargin{4};
handles.ratioexists=varargin{5};

% Fill listboxes
set(handles.arrayList,'String',handles.arrays,...
                      'Max',length(handles.arrays),...
                      'Value',1)
set(handles.conditionList,'String',handles.conditions,...
                          'Max',length(handles.conditions),...
                          'Value',1)
  
if ~handles.normpfmd
    set(handles.beforeNormCheck,'Value',1,'Enable','on')
    set(handles.afterNormCheck,'Enable','off')
    set(handles.beforeafterNormCheck,'Value',0,'Enable','off')
    set(handles.beforeNormTitlesEdit,'Enable','on')
    set(handles.afterNormTitlesEdit,'Enable','off')
    set(handles.beforeafterNormTitlesEdit,'Enable','off')
end 
                     
% Set default outputs
handles.whicharrays=handles.arrays(1);                         % Default output is one array
handles.whichconditions=handles.conditions{1};                 % Default condition is the first
handles.sliorcon=1;                                            % Plot for each slide
handles.plotwhat=1;                                            % Default, plot ratio
handles.plotwhatName='Ratio';                                  % Its name
handles.before=get(handles.beforeNormCheck,'Value');           % Do not create plots before normalization
handles.after=get(handles.afterNormCheck,'Value');             % Do not create plots after notmalzation
handles.beforeafter=get(handles.beforeafterNormCheck,'Value'); % Create plots for both before and after nrmlztn
handles.beforeTitles='';                                       % No titles before, auto creation by default
handles.afterTitles='';                                        % No titles after, auto creation by default
handles.beforeafterTitles='';                                  % No titles before/after, auto creation by default
handles.cancel=false;                                          % User did not press cancel

if ~handles.ratioexists
    set(handles.dataSelectPopup,'Value',2);
    handles.plotwhat=2;
    handles.plotwhatName='Channel 1 Foreground Mean';
end
    
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BoxplotEditor wait for user response (see UIRESUME)
uiwait(handles.BoxplotEditor);


% --- Outputs from this function are returned to the command line.
function varargout = BoxplotEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.BoxplotEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.BoxplotEditor);
end

varargout{1}=handles.whicharrays;
varargout{2}=handles.whichconditions;
varargout{3}=handles.sliorcon;
varargout{4}=handles.plotwhat;
varargout{5}=handles.plotwhatName;
varargout{6}=handles.before;
varargout{7}=handles.after;
varargout{8}=handles.beforeafter;
varargout{9}=handles.beforeTitles;
varargout{10}=handles.afterTitles;
varargout{11}=handles.beforeafterTitles;
varargout{12}=handles.cancel;


% --- Executes on selection change in arrayList.
function arrayList_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
handles.whicharrays=contents(val);
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


% --- Executes on selection change in dataSelectPopup.
function dataSelectPopup_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1 % Ratio (normalized or non-normalized)
        handles.plotwhat=val;
        handles.plotwhatName=contents{val};
        % Enable after and before/after normalization checkboxes and titles in case they
        % have been disabled
        if ~handles.normpfmd
            handles.before=true;
            handles.after=false;
            handles.beforeafter=false;
            set(handles.beforeNormCheck,'Value',1,'Enable','on')
            set(handles.afterNormCheck,'Enable','off')
            set(handles.beforeafterNormCheck,'Value',0,'Enable','off')
            set(handles.beforeNormTitlesEdit,'Enable','on')
            set(handles.afterNormTitlesEdit,'Enable','off')
            set(handles.beforeafterNormTitlesEdit,'Enable','off')
            if ~handles.ratioexists
                warnmsg={'Ratio calculation has not been performed yet. Please go to',...
                         'Preprocessing -> Background Correction and Preprocessing ->',...
                         'Filtering to select your choices for channel ratio calculation.',...
                         'Ratio boxplots will not be available until ratio is calculated.'};
                uiwait(warndlg(warnmsg,'Warning'));
                set(hObject,'Value',2)
                handles.plotwhat=2;
                handles.plotwhatName=contents{2};
            end
        else
            handles.before=false;
            handles.after=false;
            handles.beforeafter=true;
            set(handles.beforeNormCheck,'Value',0,'Enable','on')
            set(handles.afterNormCheck,'Value',0,'Enable','on')
            set(handles.beforeafterNormCheck,'Value',1,'Enable','on')
            set(handles.beforeNormTitlesEdit,'Enable','off')
            set(handles.afterNormTitlesEdit,'Enable','off')
            set(handles.beforeafterNormTitlesEdit,'Enable','on')
        end
    otherwise % Everything else...
        handles.plotwhat=val;
        handles.plotwhatName=contents{val};
        % Disable after and before/after normalization checkboxes and titles
        handles.before=true;
        handles.after=false;
        handles.beforeafter=false;
        set(handles.beforeNormCheck,'Value',1)
        set(handles.afterNormCheck,'Value',0,'Enable','off')
        set(handles.beforeafterNormCheck,'Value',0,'Enable','off')
        set(handles.beforeNormTitlesEdit,'Enable','on')
        set(handles.afterNormTitlesEdit,'Enable','off')
        set(handles.beforeafterNormTitlesEdit,'Enable','off')
end
% Handle the case of QuantArray where there is no Median
if ismember(val,[4 5 8 9 16 17 20 21]) && handles.software==1;
    uiwait(errordlg({'The image analysis software you have used (QuantArray) does not',...
                     'support signal median values. Please select means instead.'},...
                     'Bad Input','modal'));
    if ~handles.ratioexists
        set(hObject,'Value',2);
        handles.plotwhat=2;
        handles.plotwhatName='Channel 1 Foreground Mean';
    else
        set(hObject,'Value',1)
        handles.plotwhat=1;
        handles.plotwhatName=contents{1};
    end
elseif ismember(val,2:21) && handles.software==100 % External data
    uiwait(errordlg({'You have imported external data. The information provided',...
                     'is not sufficient to support other that ratio boxplots.'},...
                     'Bad Input','modal'));
    set(hObject,'Value',1)
    handles.plotwhat=1;
    handles.plotwhatName=contents{1};
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function dataSelectPopup_CreateFcn(hObject, eventdata, handles)

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

tit=cellstr(get(hObject,'String'));
if length(tit)~=1
    uiwait(errordlg({'Please provide a one-line title  for the boxplot or leave',...
                     'the field completely empty for automated title generation.'},'Bad Input'));
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
if length(tit)~=1
    uiwait(errordlg({'Please provide a one-line title  for the boxplot or leave',...
                     'the field completely empty for automated title generation.'},'Bad Input'));
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

tit=cellstr(get(hObject,'String'));
if length(tit)~=1
    uiwait(errordlg({'Please provide a one-line title  for the boxplot or leave',...
                     'the field completely empty for automated title generation.'},'Bad Input'));
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

uiresume(handles.BoxplotEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Set default outputs
handles.whicharrays=handles.arrays(1);
handles.whichconditions='';
handles.sliorcon=1;
handles.plotwhat=1;
handles.plotwhatName='Ratio';
handles.before=get(handles.beforeNormCheck,'Value'); 
handles.after=get(handles.afterNormCheck,'Value');
handles.beforeafter=get(handles.beforeafterNormCheck,'Value');
handles.beforeTitles='';
handles.afterTitles='';
handles.beforeafterTitles='';
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.BoxplotEditor);
