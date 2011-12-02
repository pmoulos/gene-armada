function varargout = MAImageEditor(varargin)
% MAIMAGEEDITOR M-file for MAImageEditor.fig
%      MAIMAGEEDITOR, by itself, creates a new MAIMAGEEDITOR or raises the existing
%      singleton*.
%
%      H = MAIMAGEEDITOR returns the handle to a new MAIMAGEEDITOR or the handle to
%      the existing singleton*.
%
%      MAIMAGEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIMAGEEDITOR.M with the given input arguments.
%
%      MAIMAGEEDITOR('Property','Value',...) creates a new MAIMAGEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MAImageEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MAImageEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MAImageEditor

% Last Modified by GUIDE v2.5 18-Jun-2007 13:04:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MAImageEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @MAImageEditor_OutputFcn, ...
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


% --- Executes just before MAImageEditor is made visible.
function MAImageEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Get input arguments
handles.len=varargin{1};      % How many arrays to plot
handles.software=varargin{2}; % Software used
set(handles.imageTitles,'Max',handles.len)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.MAImageEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.MAImageEditor,'Position',winpos);

% Change list contents if Affymetrix
if handles.software==99
    set(handles.imageDataPopup,'String',{'Intensity';'Standard Deviation'})
end

% Set default outputs
switch handles.software
    case 99 % Affymetrix
        handles.imageData=100;             % Return Intensity
        handles.imageDataName='Intensity'; % Its name
    otherwise
        handles.imageData=1;                               % Return Channel 1 Mean
        handles.imageDataName='Channel 1 Foreground Mean'; % Its name
end
handles.colormap='default';                        % Default colormap
handles.cmapDensity=64;                            % Its density
handles.discolbar=true;                            % Display colorbar by default
handles.dim=1;                                     % 2-D image
handles.titles='';                                 % Automated title generation
handles.cancel=false;                              % Cancel not pressed

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MAImageEditor wait for user response (see UIRESUME)
uiwait(handles.MAImageEditor);


% --- Outputs from this function are returned to the command line.
function varargout = MAImageEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.MAImageEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.MAImageEditor);
end

varargout{1}=handles.imageData;
varargout{2}=handles.imageDataName;
varargout{3}=handles.colormap;
varargout{4}=handles.cmapDensity;
varargout{5}=handles.discolbar;
varargout{6}=handles.dim;
varargout{7}=handles.titles;
varargout{8}=handles.cancel;


% --- Executes on selection change in imageDataPopup.
function imageDataPopup_Callback(hObject, eventdata, handles)

choices=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1 % Channel 1 Foreground Mean or Intensity
        switch handles.software
            case 99
                handles.imageData=100;
            otherwise
                handles.imageData=1;
        end
        handles.imageDataName=choices{1};
    case 2 % Channel 2 Foreground Mean or StdDev
        switch handles.software
            case 99
                handles.imageData=101;
            otherwise
                handles.imageData=2;
        end
        handles.imageDataName=choices{2};
    case 3 % Channel 1 Foreground Median
        handles.imageData=3;
        handles.imageDataName=choices{3};
    case 4 % Channel 2 Foreground Median'
        handles.imageData=4;
        handles.imageDataName=choices{4};
    case 5 % Channel 1 Background Mean
        handles.imageData=5;
        handles.imageDataName=choices{5};
    case 6 % Channel 2 Background Mean
        handles.imageData=6;
        handles.imageDataName=choices{6};
    case 7 % Channel 1 Background Median
        handles.imageData=7;
        handles.imageDataName=choices{7};    
    case 8 % Channel 2 Background Median
        handles.imageData=8;
        handles.imageDataName=choices{8};
    case 9 % Channel 1 Foreground Standard Deviation
        handles.imageData=9;
        handles.imageDataName=choices{9};
    case 10 % Channel 2 Foreground Standard Deviation
        handles.imageData=10;
        handles.imageDataName=choices{10};
    case 11 % Channel 1 Background Standard Deviation
        handles.imageData=11;
        handles.imageDataName=choices{11};
    case 12 % Channel 2 Background Standard Deviation
        handles.imageData=12;
        handles.imageDataName=choices{12};    
    case 13 % Channel 1 Foreground - Background (Mean)
        handles.imageData=13;
        handles.imageDataName=choices{13};  
    case 14 % Channel 2 Foreground - Background (Mean)
        handles.imageData=14;
        handles.imageDataName=choices{14};
    case 15 % Channel 1 Foreground - Background (Median)
        handles.imageData=15;
        handles.imageDataName=choices{15}; 
    case 16 % Channel 2 Foreground - Background (Median)
        handles.imageData=16;
        handles.imageDataName=choices{16};
    case 17 % Channel 1 Foreground/Background (Mean)
        handles.imageData=17;
        handles.imageDataName=choices{17};
    case 18 % Channel 2 Foreground/Background (Mean)
        handles.imageData=18;
        handles.imageDataName=choices{18};
    case 19 % Channel 1 Foreground/Background (Median)
        handles.imageData=19;
        handles.imageDataName=choices{19};
    case 20 % Channel 2 Foreground/Background (Median)
        handles.imageData=20;
        handles.imageDataName=choices{20};
end
% Handle the case of QuantArray where there is no Median
if ismember(val,[3 4 7 8 15 16 19 20]) && handles.software==1;
    uiwait(errordlg({'The image analysis software you have used (QuantArray) does not',...
                     'support signal median values. Please select means instead.'},...
                     'Bad Input','modal'));
    set(hObject,'Value',1)
    handles.imageData=1;
    handles.imageDataName=choices{1};
end
guidata(hObject,handles);      


% --- Executes during object creation, after setting all properties.
function imageDataPopup_CreateFcn(hObject, eventdata, handles)

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


function imageTitles_Callback(hObject, eventdata, handles)

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
function imageTitles_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in imageColormapPopup.
function imageColormapPopup_Callback(hObject, eventdata, handles)

choices=get(hObject,'String');
val=get(hObject,'Value');
handles.colormap=choices{val};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function imageColormapPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function colormapDensity_Callback(hObject, eventdata, handles)

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
function colormapDensity_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in colorbarCheck.
function colorbarCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.discolbar=true;
else
    handles.discolbar=false;
end
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.MAImageEditor);

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
switch handles.software
    case 99 % Affymetrix
        handles.imageData=100; 
        handles.imageDataName='Intensity';
    otherwise
        handles.imageData=1;
        handles.imageDataName='Channel 1 Foreground Mean';
end
handles.colormap='default';
handles.cmapDensity=64;
handles.discolbar=true;
handles.dim=1;
handles.titles='';
handles.cancel=true; % Cancel pressed
guidata(hObject,handles);
uiresume(handles.MAImageEditor);
