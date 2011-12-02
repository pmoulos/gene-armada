function varargout = NUImageEditor(varargin)
% NUIMAGEEDITOR M-file for NUImageEditor.fig
%      NUIMAGEEDITOR, by itself, creates a new NUIMAGEEDITOR or raises the existing
%      singleton*.
%
%      H = NUIMAGEEDITOR returns the handle to a new NUIMAGEEDITOR or the handle to
%      the existing singleton*.
%
%      NUIMAGEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NUIMAGEEDITOR.M with the given input arguments.
%
%      NUIMAGEEDITOR('Property','Value',...) creates a new NUIMAGEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NUImageEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NUImageEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NUImageEditor

% Last Modified by GUIDE v2.5 30-Dec-2007 21:53:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NUImageEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @NUImageEditor_OutputFcn, ...
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


% --- Executes just before NUImageEditor is made visible.
function NUImageEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.NUImageEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.NUImageEditor,'Position',winpos);

% Get input arguments
handles.arrays=varargin{1};   % Arrays for the listbox
set(handles.arrayList,'String',handles.arrays,'Max',length(handles.arrays))
handles.len=length(get(handles.arrayList,'Value'));

% Set default outputs
handles.whichones=handles.arrays(1);      % No arrays returned by default
handles.plotwhat=1;                       % Return Channel 1 Mean
handles.plotwhatName='Normalized Ratio';  % Its name
handles.colormap='default';               % Default colormap
handles.cmapDensity=64;                   % Its density
handles.discolbar=true;                   % Display colorbar by default
handles.dim=1;                            % 2-D image
handles.titles='';                        % Automated title generation
handles.cancel=false;                     % Cancel not pressed

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NUImageEditor wait for user response (see UIRESUME)
uiwait(handles.NUImageEditor);


% --- Outputs from this function are returned to the command line.
function varargout = NUImageEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.NUImageEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.NUImageEditor);
end

varargout{1}=handles.whichones;
varargout{2}=handles.plotwhat;
varargout{3}=handles.plotwhatName;
varargout{4}=handles.colormap;
varargout{5}=handles.cmapDensity;
varargout{6}=handles.discolbar;
varargout{7}=handles.dim;
varargout{8}=handles.titles;
varargout{9}=handles.cancel;

% --- Executes on selection change in arrayList.
function arrayList_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
handles.whichones=contents(val);
handles.len=length(val);
set(handles.titlesEdit,'Max',handles.len)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function arrayList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plotwhatPopup.
function plotwhatPopup_Callback(hObject, eventdata, handles)

choices=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1 % Normalized ratio
        handles.plotwhat=1;
        handles.plotwhatName=choices{1};
    case 2 % Unnormalized ratio
        handles.plotwhat=2;
        handles.plotwhatName=choices{2};
end
guidata(hObject,handles);      


% --- Executes during object creation, after setting all properties.
function plotwhatPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in twoDRadio.
function twoDRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dim=1;
else
    handles.dim=2;
end
guidata(hObject,handles);


% --- Executes on button press in threeDRadio.
function threeDRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dim=2;
else
    handles.dim=1;
end
guidata(hObject,handles);


function titlesEdit_Callback(hObject, eventdata, handles)

tit=cellstr(get(hObject,'String'));
if length(tit)~=handles.len
    uiwait(errordlg({'Please provide a number of titles equal to the number of arrays',...
                     ['you selected (',num2str(handles.len),') or else leave the field completely'],... 
                     'empty for automated title generation.'},'Bad Input'));
    set(hObject,'String','')
    handles.titles='';
else
    handles.titles=tit;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function titlesEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmapPopup.
function cmapPopup_Callback(hObject, eventdata, handles)

choices=get(hObject,'String');
val=get(hObject,'Value');
handles.colormap=choices{val};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function cmapPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function cmapDenEdit_Callback(hObject, eventdata, handles)

den=str2double(get(hObject,'String'));
if isnan(den) || den<=0 || rem(den,1)~=0
    uiwait(errordlg('The colormap density must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','64');
    handles.cmapDensity=str2double(get(hObject,'String'));
else
    handles.cmapDensity=den;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function cmapDenEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in disColbarCheck.
function disColbarCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.discolbar=true;
else
    handles.discolbar=false;
end
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.NUImageEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Return default outputs
handles.whichones=handles.arrays(1);
handles.plotwhat=1; 
handles.plotwhatName='Normalized Ratio'; 
handles.colormap='default';
handles.cmapDensity=64; 
handles.discolbar=true;  
handles.dim=1;
handles.titles='';
handles.cancel=true; % Cancel pressed
guidata(hObject,handles);
uiresume(handles.NUImageEditor);
