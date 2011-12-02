function varargout = GCRMAEditor(varargin)
% GCRMAEDITOR M-file for GCRMAEditor.fig
%      GCRMAEDITOR, by itself, creates a new GCRMAEDITOR or raises the existing
%      singleton*.
%
%      H = GCRMAEDITOR returns the handle to a new GCRMAEDITOR or the handle to
%      the existing singleton*.
%
%      GCRMAEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GCRMAEDITOR.M with the given input arguments.
%
%      GCRMAEDITOR('Property','Value',...) creates a new GCRMAEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GCRMAEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GCRMAEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GCRMAEditor

% Last Modified by GUIDE v2.5 07-Oct-2008 16:10:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GCRMAEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @GCRMAEditor_OutputFcn, ...
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


% --- Executes just before GCRMAEditor is made visible.
function GCRMAEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.GCRMAEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.GCRMAEditor,'Position',winpos);

% Set default outputs
handles.seqfile='';                      % Probe sequence file, not given
handles.affinfile='';                    % Probe affinities file (if already calculated)
handles.optcorr=true;                    % Do optical correction
handles.gsbcorr=true;                    % Do gene specific binding correction
handles.addvar=false;                    % Add variance
handles.eachaffin=false;                 % Calculate affinities for each chip
handles.rho=0.7;                         % Correlation coefficient constant
handles.method='MLE';                    % Signal estimation using MLE
handles.methodName='Maximum Likelihood'; % Its name
handles.tunparam=0.5;                    % Its tuning parameter
handles.alpha=1;                         % Alpha for EB
handles.steps=128;                       % Steps for MLE
handles.cancel=false;                    % User did not press Cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GCRMAEditor wait for user response (see UIRESUME)
uiwait(handles.GCRMAEditor);


% --- Outputs from this function are returned to the command line.
function varargout = GCRMAEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.GCRMAEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.GCRMAEditor);
end

varargout{1}=handles.seqfile;
varargout{2}=handles.affinfile;
varargout{3}=handles.optcorr;
varargout{4}=handles.gsbcorr;
varargout{5}=handles.addvar;
varargout{6}=handles.eachaffin;
varargout{7}=handles.rho;
varargout{8}=handles.method;
varargout{9}=handles.methodName;
varargout{10}=handles.tunparam;
varargout{11}=handles.alpha;
varargout{12}=handles.steps;
varargout{13}=handles.cancel;


function seqFileEdit_Callback(hObject, eventdata, handles)


function seqFileEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function seqFileEdit_KeyPressFcn(hObject, eventdata, handles)

currpress=get(handles.GCRMAEditor,'CurrentCharacter');
z=regexp(currpress,'\r+','once');
if ~isempty(z)
    seqfile=get(hObject,'String');
    set(hObject,'Max',1)
    handles.seqfile=seqfile;
    guidata(hObject,handles);
end


function browseSeq_Callback(hObject, eventdata, handles)

[seqfile,pname]=uigetfile({'*.*','All files (*.*)'},...
                           'Select Probe Sequences file');
if seqfile==0
    return
end

seqfile=strcat(pname,seqfile);
set(handles.seqFileEdit,'String',seqfile,'Max',1)
handles.seqfile=seqfile;
guidata(hObject,handles);


function affinFileEdit_Callback(hObject, eventdata, handles)


function affinFileEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function affinFileEdit_KeyPressFcn(hObject, eventdata, handles)

currpress=get(handles.GCRMAEditor,'CurrentCharacter');
z=regexp(currpress,'\r+','once');
if ~isempty(z)
    afffile=get(hObject,'String');
    set(hObject,'Max',1)
    handles.affinfile=afffile;
    guidata(hObject,handles);
end


function browseAffin_Callback(hObject, eventdata, handles)

[afffile,pname]=uigetfile({'*.*','All files (*.*)'},...
                           'Select Probe Affinities file');
if afffile==0
    return
end

afffile=strcat(pname,afffile);
set(handles.affinFileEdit,'String',afffile,'Max',1)
handles.affinfile=afffile;
guidata(hObject,handles);


function optCorrCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.optcorr=true;
else
    handles.optcorr=false;
end
guidata(hObject,handles);


function GSBCorrCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.gsbcorr=true;
else
    handles.gsbcorr=false;
end
guidata(hObject,handles);


function addVarCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.addvar=true;
else
    handles.addvar=false;
end
guidata(hObject,handles);


function calcAffinEachCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.eachaffin=true;
else
    handles.eachaffin=false;
end
guidata(hObject,handles);


function rhoEdit_Callback(hObject, eventdata, handles)

r=str2double(get(hObject,'String'));
if isnan(r) || r<0 || r>1
    uiwait(errordlg('rho must be a number between 0 and 1','Bad Input','modal'));
    set(hObject,'String','0.7');
else
    handles.rho=r;
end
guidata(hObject,handles);


function rhoEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function methodPopup_Callback(hObject, eventdata, handles)

mets=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1
        handles.method='MLE';
        set(handles.tunParamEdit,'String','5')
        set(handles.stepsStatic,'Enable','on')
        set(handles.stepsEdit,'Enable','on')
        set(handles.alphaStatic,'Enable','off')
        set(handles.alphaEdit,'Enable','off')
        handles.tunparam=5;
    case 2
        handles.method='EB';
        set(handles.tunParamEdit,'String','0.5')
        set(handles.stepsStatic,'Enable','off')
        set(handles.stepsEdit,'Enable','off')
        set(handles.alphaStatic,'Enable','on')
        set(handles.alphaEdit,'Enable','on')
        handles.tunparam=0.5;
end
handles.methodName=mets{val};
guidata(hObject,handles);


function methodPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tunParamEdit_Callback(hObject, eventdata, handles)

tp=str2double(get(hObject,'String'));
if isnan(tp) || tp<=0
    uiwait(errordlg('The tuning parameter must be a positive number','Bad Input','modal'));
    if strcmp(handles.method,'MLE')
        set(hObject,'String','5');
    elseif strcmp(handles.method,'EB')
        set(hObject,'String','0.5')
    end
else
    handles.tunparam=tp;
end
guidata(hObject,handles);


function tunParamEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function alphaEdit_Callback(hObject, eventdata, handles)

a=str2double(get(hObject,'String'));
if isnan(a)
    uiwait(errordlg('alpha must be a number','Bad Input','modal'));
    set(hObject,'String','1');
else
    handles.alpha=a;
end
guidata(hObject,handles);


function alphaEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function stepsEdit_Callback(hObject, eventdata, handles)

s=str2double(get(hObject,'String'));
if isnan(s) || s<=0 || rem(s,1)~=0
    uiwait(errordlg('steps must be a positive integer','Bad Input','modal'));
    set(hObject,'String','128');
else
    handles.steps=s;
end
guidata(hObject,handles);


function stepsEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.GCRMAEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Restore defaults
handles.seqfile='';
handles.affinfile='';
handles.optcorr=true; 
handles.gsbcorr=true;
handles.addvar=false;
handles.eachaffin=false;
handles.rho=0.7;
handles.method='MLE';
handles.methodName='Maximum Likelihood';
handles.tunparam=0.5;
handles.alpha=1;
handles.steps=128;
handles.cancel=true; % User pressed Cancel
guidata(hObject,handles);
uiresume(handles.GCRMAEditor);
