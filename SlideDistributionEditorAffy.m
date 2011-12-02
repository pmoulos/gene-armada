function varargout = SlideDistributionEditorAffy(varargin)
% SLIDEDISTRIBUTIONEDITORAFFY M-file for SlideDistributionEditorAffy.fig
%      SLIDEDISTRIBUTIONEDITORAFFY, by itself, creates a new SLIDEDISTRIBUTIONEDITORAFFY or raises the existing
%      singleton*.
%
%      H = SLIDEDISTRIBUTIONEDITORAFFY returns the handle to a new SLIDEDISTRIBUTIONEDITORAFFY or the handle to
%      the existing singleton*.
%
%      SLIDEDISTRIBUTIONEDITORAFFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLIDEDISTRIBUTIONEDITORAFFY.M with the given input arguments.
%
%      SLIDEDISTRIBUTIONEDITORAFFY('Property','Value',...) creates a new SLIDEDISTRIBUTIONEDITORAFFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SlideDistributionEditorAffy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SlideDistributionEditorAffy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SlideDistributionEditorAffy

% Last Modified by GUIDE v2.5 29-Mar-2009 22:31:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SlideDistributionEditorAffy_OpeningFcn, ...
                   'gui_OutputFcn',  @SlideDistributionEditorAffy_OutputFcn, ...
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


% --- Executes just before SlideDistributionEditorAffy is made visible.
function SlideDistributionEditorAffy_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.SlideDistributionEditorAffy,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.SlideDistributionEditorAffy,'Position',winpos);

% Plot options for Affymetrix and Illumina
affyChoice={'PM','MM',...
            'BackAdjusted PM','Normalized PM',...
            'Expression (raw)','Expression (back)','Expression (norm)'};
illuChoice={'Expression (raw)','Expression (norm)'};

% Get inputs
handles.arrays=varargin{1};
handles.imgsw=varargin{2};

% Fill lists
if handles.imgsw==99 % Affymetrix
    set(handles.dataPlotPopup,'String',affyChoice)
    handles.pw=3;
elseif handles.imgsw==98 % Illumina
    set(handles.dataPlotPopup,'String',illuChoice)
    handles.pw=1;
end
set(handles.arrayList,'String',handles.arrays)

plat=get(handles.dataPlotPopup,'String');
% Set default outputs
handles.whicharrays=handles.arrays(1); % Default array to plot from non-normalized 
handles.single=true;                   % One distribution or multiple in same plot
handles.plotwhat=handles.pw;           % What quantity to plot 
handles.plotwhatName=plat{1};          % Its name
handles.titles='';                     % The title(s) 
handles.logscale=false;                % Plot in log2 scale
handles.cancel=false;                  % User did not press cancel 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SlideDistributionEditorAffy wait for user response (see UIRESUME)
uiwait(handles.SlideDistributionEditorAffy);


% --- Outputs from this function are returned to the command line.
function varargout = SlideDistributionEditorAffy_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.SlideDistributionEditorAffy);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.SlideDistributionEditorAffy);
end

% Get default command line output from handles structure
varargout{1}=handles.whicharrays;
varargout{2}=handles.single;
varargout{3}=handles.plotwhat;
varargout{4}=handles.plotwhatName;
varargout{5}=handles.titles;
varargout{6}=handles.logscale;
varargout{7}=handles.cancel;


function arrayList_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
str=get(hObject,'String');
handles.whicharrays=str(val);
if length(val)>1
    set(handles.singleRadio,'Enable','on')
    set(handles.multiRadio,'Enable','on')
else
    set(handles.singleRadio,'Enable','off')
    set(handles.multiRadio,'Enable','off')
end
if strcmp(get(handles.singleRadio,'Enable'),'on') && get(handles.singleRadio,'Value')==1
    set(handles.titlesEdit,'Max',1)
end
if strcmp(get(handles.multiRadio,'Enable'),'on') && get(handles.multiRadio,'Value')==1
    set(handles.titlesEdit,'Max',length(val))
end
guidata(hObject,handles);
    
    
function arrayList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function clearArrays_Callback(hObject, eventdata, handles)

set(handles.arrayList,'Value',[])
set(handles.titlesEdit,'Max',1)
set(handles.singleRadio,'Enable','off')
set(handles.multiRadio,'Enable','off')
handles.whicharrays={};
guidata(hObject,handles);


function singleRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.single=true;
    set(handles.titlesEdit,'Max',1)
end
guidata(hObject,handles);
    

function multiRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.single=false;
    v=get(handles.arrayList,'Value');
    if length(v)>1
        set(handles.titlesEdit,'Max',length(v))
    else
        set(handles.titlesEdit,'Max',1)
    end
end
guidata(hObject,handles);


function dataPlotPopup_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
if handles.imgsw==99 % Affymetrix
    handles.plotwhat=val+2; % Exclude Intensity and StdDev
elseif handles.plotwhat==98 % Illumina
    handles.plotwhat=val;
end
handles.plotwhatName=contents{val};
guidata(hObject,handles);


function dataPlotPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function titlesEdit_Callback(hObject, eventdata, handles)

tit=cellstr(get(hObject,'String'));
len=length(get(handles.arrayList,'Value'));
if length(tit)~=len && ~handles.single
    uiwait(errordlg({'Please provide a number of titles equal to the number of arrays',...
                     ['you selected (',num2str(len),') or else leave the field completely'],... 
                     'empty for automated title generation.'},'Bad Input'));
    set(hObject,'String','')
    handles.titles='';
else
    handles.titles=tit;
end
guidata(hObject,handles);


function titlesEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function logCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.logscale=true;
else
    handles.logscale=false;
end
guidata(hObject,handles);


function okButton_Callback(hObject, eventdata, handles)

% Transformation for Affymetrix data, for use with retrieveArrayData inside ARMADA main
if handles.imgsw==99 % Affymetrix
    handles.plotwhat=handles.plotwhat+100;
elseif handles.imgsw==98 % Illumina
    handles.plotwhat=handles.plotwhat+200;
end
guidata(hObject,handles);
uiresume(handles.SlideDistributionEditorAffy);


function cancelButton_Callback(hObject, eventdata, handles)

plat=get(handles.dataPlotPopup,'String');
% Resume defaults
handles.whicharrays='';
handles.single=true; 
handles.plotwhat=handles.pw;
handles.plotwhatName=plat{1}; 
handles.titles='';
handles.logscale=false;
handles.cancel=true; % User pressed cancel 
guidata(hObject,handles);   
uiresume(handles.SlideDistributionEditorAffy);
