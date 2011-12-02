function varargout = DyeSwapEditor(varargin)
% DYESWAPEDITOR M-file for DyeSwapEditor.fig
%      DYESWAPEDITOR, by itself, creates a new DYESWAPEDITOR or raises the existing
%      singleton*.
%
%      H = DYESWAPEDITOR returns the handle to a new DYESWAPEDITOR or the handle to
%      the existing singleton*.
%
%      DYESWAPEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DYESWAPEDITOR.M with the given input arguments.
%
%      DYESWAPEDITOR('Property','Value',...) creates a new DYESWAPEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DyeSwapEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DyeSwapEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DyeSwapEditor

% Last Modified by GUIDE v2.5 09-Aug-2008 17:08:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DyeSwapEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @DyeSwapEditor_OutputFcn, ...
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


% --- Executes just before DyeSwapEditor is made visible.
function DyeSwapEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.DyeSwapEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.DyeSwapEditor,'Position',winpos);

% Get inputs
handles.conds=varargin{1};
handles.exprp=varargin{2};

% Initialize lists
set(handles.condList,'String',handles.conds,'Value',1)
set(handles.repList,'String',handles.exprp{1},'Value',1,'Max',length(handles.exprp{1}))

% Initialize output
si=zeros(1,length(handles.conds));
for i=1:length(handles.conds)
    si(i)=length(handles.exprp{i});
end
handles.outmat=ones(length(handles.conds),max(si));

% Set default output
handles.dyematrix=handles.outmat; % Default is all Cy3-->Ch1
handles.cancel=false;             % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DyeSwapEditor wait for user response (see UIRESUME)
uiwait(handles.DyeSwapEditor);


% --- Outputs from this function are returned to the command line.
function varargout = DyeSwapEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.DyeSwapEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.DyeSwapEditor);
end

varargout{1}=handles.dyematrix;
varargout{2}=handles.cancel;


function condList_Callback(hObject, eventdata, handles)

% Recreate the contents of ratio list
val=get(hObject,'Value');
currreps=handles.exprp{val}(:);
sel=find(handles.dyematrix(val,:)==2);
set(handles.repList,'String',currreps,'Value',sel,'Max',length(currreps))


function condList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function repList_Callback(hObject, eventdata, handles)

% Update dyematrix matrix
condval=get(handles.condList,'Value');
repvals=get(hObject,'Value');
allvals=1:length(handles.exprp{condval});
restvals=setdiff(allvals,repvals);
handles.dyematrix(condval,repvals)=2;
handles.dyematrix(condval,restvals)=1;
guidata(hObject,handles);


function repList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function clearCond_Callback(hObject, eventdata, handles)

val=get(handles.condList,'Value');
set(handles.repList,'Value',[]);
handles.dyematrix(val,:)=ones(1,size(handles.dyematrix,2));
guidata(hObject,handles);


function clearAll_Callback(hObject, eventdata, handles)

set(handles.repList,'Value',[]);
handles.dyematrix=handles.outmat;
guidata(hObject,handles);


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.DyeSwapEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
handles.dyematrix=handles.outmat;
handles.cancel=false; % User did not press cancel
guidata(hObject,handles);
uiresume(handles.DyeSwapEditor);
