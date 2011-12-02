function varargout = SVMTrainEditor(varargin)
% SVMTRAINEDITOR M-file for SVMTrainEditor.fig
%      SVMTRAINEDITOR, by itself, creates a new SVMTRAINEDITOR or raises the existing
%      singleton*.
%
%      H = SVMTRAINEDITOR returns the handle to a new SVMTRAINEDITOR or the handle to
%      the existing singleton*.
%
%      SVMTRAINEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SVMTRAINEDITOR.M with the given input arguments.
%
%      SVMTRAINEDITOR('Property','Value',...) creates a new SVMTRAINEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SVMTrainEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SVMTrainEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SVMTrainEditor

% Last Modified by GUIDE v2.5 23-Mar-2008 19:45:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SVMTrainEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @SVMTrainEditor_OutputFcn, ...
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


% --- Executes just before SVMTrainEditor is made visible.
function SVMTrainEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.SVMTrainEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.SVMTrainEditor,'Position',winpos);

% Set default outputs
handles.kernel='linear';     % Default kernel linear
handles.kernelName='Linear'; % Default kernel name
handles.normalize=false;     % Do not normalize input matrix
handles.scale=false;         % Do not scale input matrix
handles.scalevals=[-1 1];    % Defaults if we choose scale
handles.tol=0.001;           % Default termination tolerance
handles.params=[];           % Default linear kernel parameters (none)
handles.cancel=false;        % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SVMTrainEditor wait for user response (see UIRESUME)
uiwait(handles.SVMTrainEditor);


% --- Outputs from this function are returned to the command line.
function varargout = SVMTrainEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.SVMTrainEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.SVMTrainEditor);
end

varargout{1}=handles.kernel;
varargout{2}=handles.kernelName;
varargout{3}=handles.normalize;
varargout{4}=handles.scale;
varargout{5}=handles.scalevals;
varargout{6}=handles.tol;
varargout{7}=handles.params;
varargout{8}=handles.cancel;


function kernelPopup_Callback(hObject, eventdata, handles)

kernels={'linear','polynomial','mlp','rbf'};
kernelNames=get(hObject,'String');
val=get(hObject,'Value');
handles.kernel=kernels{val};
handles.kernelName=kernelNames{val};
% Enable and disable panels according to kernel choices
switch val
    case 1 % Linear kernel
        % Do nothing
    case 2 % Polynomial kernel
        set(handles.polyGammaStatic,'Enable','on')
        set(handles.polyCoefStatic,'Enable','on')
        set(handles.polyDegStatic,'Enable','on')
        set(handles.polyGammaEdit,'Enable','on')
        set(handles.polyCoefEdit,'Enable','on')
        set(handles.polyDegEdit,'Enable','on')
        set(handles.mlpGammaStatic,'Enable','off')
        set(handles.mlpCoefStatic,'Enable','off')
        set(handles.mlpGammaEdit,'Enable','off')
        set(handles.mlpCoefEdit,'Enable','off')
        set(handles.rbfGammaStatic,'Enable','off')
        set(handles.rbfGammaEdit,'Enable','off')
    case 3 % MLP kernel
        set(handles.polyGammaStatic,'Enable','off')
        set(handles.polyCoefStatic,'Enable','off')
        set(handles.polyDegStatic,'Enable','off')
        set(handles.polyGammaEdit,'Enable','off')
        set(handles.polyCoefEdit,'Enable','off')
        set(handles.polyDegEdit,'Enable','off')
        set(handles.mlpGammaStatic,'Enable','on')
        set(handles.mlpCoefStatic,'Enable','on')
        set(handles.mlpGammaEdit,'Enable','on')
        set(handles.mlpCoefEdit,'Enable','on')
        set(handles.rbfGammaStatic,'Enable','off')
        set(handles.rbfGammaEdit,'Enable','off')
    case 4 % RBF kernel
        set(handles.polyGammaStatic,'Enable','off')
        set(handles.polyCoefStatic,'Enable','off')
        set(handles.polyDegStatic,'Enable','off')
        set(handles.polyGammaEdit,'Enable','off')
        set(handles.polyCoefEdit,'Enable','off')
        set(handles.polyDegEdit,'Enable','off')
        set(handles.mlpGammaStatic,'Enable','off')
        set(handles.mlpCoefStatic,'Enable','off')
        set(handles.mlpGammaEdit,'Enable','off')
        set(handles.mlpCoefEdit,'Enable','off')
        set(handles.rbfGammaStatic,'Enable','on')
        set(handles.rbfGammaEdit,'Enable','on')
end
guidata(hObject,handles);


function kernelPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function normCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.normalize=true;
else
    handles.normalize=false;
end
guidata(hObject,handles);


function scaleCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.lowStatic,'Enable','on')
    set(handles.lowerEdit,'Enable','on')
    set(handles.upStatic,'Enable','on')
    set(handles.upperEdit,'Enable','on')
    handles.scale=true;
else
    set(handles.lowStatic,'Enable','off')
    set(handles.lowerEdit,'Enable','off')
    set(handles.upStatic,'Enable','off')
    set(handles.upperEdit,'Enable','off')
    handles.scale=false;
end
guidata(hObject,handles);


function lowerEdit_Callback(hObject, eventdata, handles)

low=str2double(get(hObject,'String'));
up=str2double(get(handles.upperEdit,'String'));
if ~isnan(low) && ~isnan(up)
    handles.scalevals=[low up];
else
    uiwait(errordlg('Scale limits must be real numbers!','Bad Input'));
    handles.scalevals=[-1 1];
end
guidata(hObject,handles);


function lowerEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function upperEdit_Callback(hObject, eventdata, handles)

low=str2double(get(handles.lowerEdit,'String'));
up=str2double(get(hObject,'String'));
if ~isnan(low) && ~isnan(up)
    handles.scalevals=[low up];
else
    uiwait(errordlg('Scale limits must be real numbers!','Bad Input'));
    handles.scalevals=[-1 1];
end
guidata(hObject,handles);


function upperEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tolEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if ~isnan(val)
    handles.tol=val;
else
    uiwait(errordlg('Tolerance value must be a real number!','Bad Input'));
    handles.tol=0.001;
end
guidata(hObject,handles);


function tolEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function polyGammaEdit_Callback(hObject, eventdata, handles)


function polyGammaEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function polyCoefEdit_Callback(hObject, eventdata, handles)


function polyCoefEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function polyDegEdit_Callback(hObject, eventdata, handles)


function polyDegEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mlpGammaEdit_Callback(hObject, eventdata, handles)


function mlpGammaEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mlpCoefEdit_Callback(hObject, eventdata, handles)


function mlpCoefEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rbfGammaEdit_Callback(hObject, eventdata, handles)


function rbfGammaEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function okButton_Callback(hObject, eventdata, handles)

% Get the parameters here, easier than in each edit box
val=get(handles.kernelPopup,'Value');
switch val
    case 1 % Linear
        % Do nothing, no parameters for linear
    case 2 % Polynomial
        g=str2double(get(handles.polyGammaEdit,'String'));
        c=str2double(get(handles.polyCoefEdit,'String'));
        d=str2double(get(handles.polyDegEdit,'String'));
        if ~isnan(g) && ~isnan(c) && ~isnan(d)
            handles.params=[g c d];
        else
            uiwait(errordlg('Polynomial kernel parameters must be real numbers!',...
                            'Bad Input'));
            handles.params=[1 0 3]; % Defaults
            set(handles.polyGammaEdit,'String','1')
            set(handles.polyCoefEdit,'String','0')
            set(handles.polyDegEdit,'String','3')
            guidata(hObject,handles);
            return
        end
    case 3 % MLP
        g=str2double(get(handles.mlpGammaEdit,'String'));
        c=str2double(get(handles.mlpCoefEdit,'String'));
        if ~isnan(g) && ~isnan(c)
            handles.params=[g c];
        else
            uiwait(errordlg('MLP kernel parameters must be real numbers!',...
                            'Bad Input'));
            handles.params=[1 0]; % Defaults
            set(handles.mlpGammaEdit,'String','1')
            set(handles.mlpCoefEdit,'String','0')
            guidata(hObject,handles);
            return
        end
    case 4 % RBF
        g=str2double(get(handles.rbfGammaEdit,'String'));
        if ~isnan(g)
            handles.params=g;
        else
            uiwait(errordlg('RBF kernel parameter must be a real number!',...
                            'Bad Input'));
            handles.params=1; % Default
            set(handles.rbfGammaEdit,'String','1')
            guidata(hObject,handles);
            return
        end
end
guidata(hObject,handles);
uiresume(handles.SVMTrainEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.kernel='linear';
handles.kernelName='Linear';
handles.normalize=false;
handles.scale=false;
handles.scalevals=[-1 1];
handles.tol=0.001;
handles.params=[];
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.SVMTrainEditor);
