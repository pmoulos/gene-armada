function varargout = checkboxBad(varargin)
%CHECKBOXBAD M-file for checkboxBad.fig
%      CHECKBOXBAD, by itself, creates a new CHECKBOXBAD or raises the existing
%      singleton*.
%
%      H = CHECKBOXBAD returns the handle to a new CHECKBOXBADNEW or the handle to
%      the existing singleton*.
%
%      CHECKBOXBAD('Property','Value',...) creates a new CHECKBOXBAD using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to checkboxBad_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CHECKBOXBAD('CALLBACK') and CHECKBOXBAD('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CHECKBOXBAD.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help checkboxBad

% Last Modified by GUIDE v2.5 15-Dec-2007 13:19:07

% Begin initialization code - DO NOT EDIT 
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @checkboxBad_OpeningFcn, ...
                   'gui_OutputFcn',  @checkboxBad_OutputFcn, ... %@myOutputFun, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before checkboxBad is made visible.
function checkboxBad_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.checkboxBad,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.checkboxBad,'Position',winpos);

%handles.badEachCondOut=0;
%handles.goodEachCondOut=0;
%handles.badEachCondRepOut=0;
%handles.goodEachCondRepOut=0;
%handles.commonBadEachCondOut=0;
%handles.commonGoodEachCondOut=0;
%handles.commonBadAllCondOut=0;
%handles.commonGoodAllCondOut=0;

handles.outBox=zeros(1,8);
handles.cancel=false;

% Update handles structure
guidata(hObject,handles);

% UIWAIT makes checkboxBad wait for user response (see UIRESUME)
uiwait(handles.checkboxBad);


% --- Outputs from this function are returned to the command line.
function varargout = checkboxBad_OutputFcn(hObject, eventdata, handles)

if (get(handles.Cancelbutton,'Value')==1)
    delete(handles.checkboxBad);
else
    varargout{1}=handles.outBox;
    varargout{2}=handles.cancel;
    %varargout{1}=handles.badEachCondOut;
    %varargout{2}=handles.goodEachCondOut;
    %varargout{3}=handles.badEachCondRepOut;
    %varargout{4}=handles.goodEachCondRepOut;
    %varargout{5}=handles.commonBadEachCondOut;
    %varargout{6}=handles.commonGoodEachCondOut;
    %varargout{7}=handles.commonBadAllCondOut;
    %varargout{8}=handles.commonGoodAllCondOut;
    delete(handles.checkboxBad);
end


% --- Executes on button press in checkboxBadEachCond.
function checkboxBadEachCond_Callback(hObject, eventdata, handles)

if (get(hObject,'Value')==get(hObject,'Max'))
    %handles.badEachCondOut=1;
    handles.outBox(1)=1;
else
    %handles.badEachCondOut=0;
    handles.outBox(1)=0;
end
guidata(hObject,handles);


% --- Executes on button press in checkboxGoodEachCond.
function checkboxGoodEachCond_Callback(hObject, eventdata, handles)

if (get(hObject,'Value')==get(hObject,'Max'))
    %handles.goodEachCondOut=1;
    handles.outBox(2)=1;
else
    %handles.goodEachCondOut=0;
    handles.outBox(2)=0;
end
guidata(hObject,handles);


% --- Executes on button press in checkboxBadEachCondRep.
function checkboxBadEachCondRep_Callback(hObject, eventdata, handles)

if (get(hObject,'Value')==get(hObject,'Max'))
    %handles.badEachCondRep=1;
    handles.outBox(3)=1;
else
    %handles.badEachCondRep=0;
    handles.outBox(3)=0;
end
guidata(hObject,handles);


% --- Executes on button press in checkboxGoodEachCondRep.
function checkboxGoodEachCondRep_Callback(hObject, eventdata, handles)

if (get(hObject,'Value')==get(hObject,'Max'))
    %handles.goodEachCondRep=1;
    handles.outBox(4)=1;
else
    %handles.goodEachCondRep=0;
    handles.outBox(4)=0;
end
guidata(hObject,handles);


% --- Executes on button press in checkboxCommonBadEachCond.
function checkboxCommonBadEachCond_Callback(hObject, eventdata, handles)

if (get(hObject,'Value')==get(hObject,'Max'))
    %handles.commonBadEachCond=1;
    handles.outBox(5)=1;
else
    %handles.commonBadEachCond=0;
    handles.outBox(5)=0;
end
guidata(hObject,handles);


% --- Executes on button press in checkboxCommonGoodEachCond.
function checkboxCommonGoodEachCond_Callback(hObject, eventdata, handles)

if (get(hObject,'Value')==get(hObject,'Max'))
    %handles.commonGoodEachCond=1;
    handles.outBox(6)=1;
else
    %handles.commonGoodEachCond=0;
    handles.outBox(6)=0;
end
guidata(hObject,handles);


% --- Executes on button press in checkboxCommonBadAllCond.
function checkboxCommonBadAllCond_Callback(hObject, eventdata, handles)

if (get(hObject,'Value')==get(hObject,'Max'))
    %handles.commonBadAllCond=1;
    handles.outBox(7)=1;
else
    %handles.commonBadAllCond=0;
    handles.outBox(7)=0;
end
guidata(hObject,handles);


% --- Executes on button press in checkboxCommonGoodAllCond.
function checkboxCommonGoodAllCond_Callback(hObject, eventdata, handles)

if (get(hObject,'Value')==get(hObject,'Max'))
    %handles.commonGoodAllCond=1;
    handles.outBox(8)=1;
else
    %handles.commonGoodAllCond=0;
    handles.outBox(8)=0;
end
guidata(hObject,handles);


% --- Executes on button press in OKbutton.
function OKbutton_Callback(hObject, eventdata, handles)

uiresume(handles.checkboxBad);


% --- Executes on button press in Cancelbutton.
function Cancelbutton_Callback(hObject, eventdata, handles)

handles.cancel=true;
guidata(hObject,handles);
uiresume(handles.checkboxBad);

