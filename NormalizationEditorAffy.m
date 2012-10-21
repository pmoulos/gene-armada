function varargout = NormalizationEditorAffy(varargin)
% NORMALIZATIONEDITORAFFY M-file for NormalizationEditorAffy.fig
%      NORMALIZATIONEDITORAFFY, by itself, creates a new NORMALIZATIONEDITORAFFY or raises the existing
%      singleton*.
%
%      H = NORMALIZATIONEDITORAFFY returns the handle to a new NORMALIZATIONEDITORAFFY or the handle to
%      the existing singleton*.
%
%      NORMALIZATIONEDITORAFFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NORMALIZATIONEDITORAFFY.M with the given input arguments.
%
%      NORMALIZATIONEDITORAFFY('Property','Value',...) creates a new NORMALIZATIONEDITORAFFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NormalizationEditorAffy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NormalizationEditorAffy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NormalizationEditorAffy

% Last Modified by GUIDE v2.5 12-Jul-2012 16:43:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NormalizationEditorAffy_OpeningFcn, ...
                   'gui_OutputFcn',  @NormalizationEditorAffy_OutputFcn, ...
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


% --- Executes just before NormalizationEditorAffy is made visible.
function NormalizationEditorAffy_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.NormalizationEditorAffy,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.NormalizationEditorAffy,'Position',winpos);

% Get input
handles.arrays=varargin{1};

% Default output struct for background adjustment (GCRMA)
backopts.optcorr=true;
backopts.corrconst=0.7;
backopts.method='MLE';
backopts.tuningpar=5;
backopts.addvar=false;
backopts.eachaffin=false;
backopts.gsbcorr=true;
backopts.alpha=0.5;
backopts.steps=128;
backopts.showplot=false;
backopts.seqfile='';
backopts.affinfile='';

% Default output struct for normalization
normopts.usemedian=false;
normopts.display=false;

% Default output struct for summarization
summopts.output='log2';

% Default behavior of negative values correction
zeros.strategy='constant';
zeros.offset=1;

% Set defaults
handles.back='gcrma';                            % Background adjustment
handles.backName='GC-Robust Multiarray Average'; % Background adjustment name
handles.backopts=backopts;                       % Default background adjustment options
handles.norm='quantile';                         % Normalization
handles.normName='Quantile';                     % Normalization name
handles.normopts=normopts;                       % Default normalization options
handles.summ='medianpolish';                     % Summarization method
handles.summName='Median Polish';                % Summarization method name
handles.summopts=summopts;                       % Default summarization options
handles.zeros=zeros;                             % Default correction of negative values
handles.cancel=false;                            % Cancel not pressed

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NormalizationEditorAffy wait for user response (see UIRESUME)
uiwait(handles.NormalizationEditorAffy);


% --- Outputs from this function are returned to the command line.
function varargout = NormalizationEditorAffy_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.NormalizationEditorAffy);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.NormalizationEditorAffy);
end

varargout{1}=handles.back;
varargout{2}=handles.backName;
varargout{3}=handles.backopts;
varargout{4}=handles.norm;
varargout{5}=handles.normName;
varargout{6}=handles.normopts;
varargout{7}=handles.summ;
varargout{8}=handles.summName;
varargout{9}=handles.summopts;
varargout{10}=handles.zeros;
varargout{11}=handles.cancel;


function backPopup_Callback(hObject, eventdata, handles)

back=get(hObject,'Value');
backNames=get(hObject,'String');
switch back;
    case 1
        handles.back='gcrma';
        % Get options
        [backopts.seqfile,backopts.affinfile,backopts.optcorr,backopts.gsbcorr,backopts.addvar,...
         backopts.eachaffin,backopts.corrconst,backopts.method,name,backopts.tuningpar,backopts.alpha,...
         backopts.steps,cancel]=GCRMAEditor;
        if ~cancel
            backopts.showplot=false;
            handles.backopts=backopts;
        end
    case 2
        handles.back='rma';
        % Get options
        [backopts.method,name,backopts.trunc,cancel]=RMAEditor;
        if ~cancel
            backopts.showplot=false;
            handles.backopts=backopts;
        end
%     case 3
%         handles.back='plier';
%         handles.backopts=[];
    case 3
        handles.back='none';
        handles.backopts=[];
end
handles.backName=backNames{back};
guidata(hObject,handles);


function backPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function normPopup_Callback(hObject, eventdata, handles)

norm=get(hObject,'Value');
normNames=get(hObject,'String');
switch norm;
    case 1
        handles.norm='quantile';
        [normopts,cancel]=QuantileProps;
        if ~cancel
            handles.normopts=normopts;
        end
    case 2
        handles.norm='rankinvariant';
        [normopts.lowrank,normopts.uprank,normopts.maxdata,normopts.maxinvar,...
         normopts.baseline,name,normopts.method,normopts.span,normopts.showplot,...
         cancel]=RankInvariantAffyEditor(handles.arrays);
        if ~cancel
            handles.normopts=normopts;
        end
    case 3
        handles.norm='none';
        handles.normopts=[];
end
handles.normName=normNames{norm};
guidata(hObject,handles);


function normPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function summPopup_Callback(hObject, eventdata, handles)

summ=get(hObject,'Value');
summNames=get(hObject,'String');
switch summ;
    case 1
        handles.summ='medianpolish';
    case 2
        handles.summ='mas5';
end
handles.summName=summNames{summ};
guidata(hObject,handles);


function summPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.NormalizationEditorAffy);


function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
backopts.optcorr=true;
backopts.corrconst=0.7;
backopts.method='MLE';
backopts.tuningpar=5;
backopts.addvar=false;
backopts.gsbcorr=true;
backopts.eachaffin=false;
backopts.alpha=0.5;
backopts.steps=128;
backopts.showplot=false;
backopts.seqfile='';
backopts.affinfile='';
normopts.usemedian=false;
normopts.display=false;
summopts.output='log2';

handles.back='gcrma';
handles.backName='GC-Robust Multiarray Average';
handles.backopts=backopts;
handles.norm='quantile';
handles.normName='Quantile';
handles.normopts=normopts;
handles.summ='medianpolish';
handles.summName='Robust Multiarray Average';
handles.summopts=summopts;
handles.cancel=true; % Cancel pressed
guidata(hObject, handles);
uiresume(handles.NormalizationEditorAffy);


% --- Executes on selection change in zerosPopup.
function zerosPopup_Callback(hObject, eventdata, handles)

ind=get(hObject,'Value');
switch ind
    case 1
        handles.zeros.strategy='constant';
        set(handles.offsetStatic,'Enable','off')
        set(handles.offsetEdit,'Enable','off')
    case 2
        handles.zeros.strategy='offset';
        set(handles.offsetStatic,'Enable','on')
        set(handles.offsetEdit,'Enable','on')
    case 3
        handles.zeros.strategy='minpos';
        set(handles.offsetStatic,'Enable','off')
        set(handles.offsetEdit,'Enable','off')
    case 4
        handles.zeros.strategy='rnoise';
        set(handles.offsetStatic,'Enable','off')
        set(handles.offsetEdit,'Enable','off')
    case 5
        handles.zeros.strategy='none';
        set(handles.offsetStatic,'Enable','off')
        set(handles.offsetEdit,'Enable','off')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function zerosPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function offsetEdit_Callback(hObject, eventdata, handles)

offset=str2double(get(hObject,'String'));
if isnan(offset) || offset<=0
    uiwait(errordlg('Offset must be a positive number','Bad Input','modal'));
    set(hObject,'String','1');
else
    handles.zeros.offset=offset;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function offsetEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
