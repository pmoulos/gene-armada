function varargout = NormalizationEditorIllumina(varargin)
% NORMALIZATIONEDITORILLUMINA M-file for NormalizationEditorIllumina.fig
%      NORMALIZATIONEDITORILLUMINA, by itself, creates a new NORMALIZATIONEDITORILLUMINA or raises the existing
%      singleton*.
%
%      H = NORMALIZATIONEDITORILLUMINA returns the handle to a new NORMALIZATIONEDITORILLUMINA or the handle to
%      the existing singleton*.
%
%      NORMALIZATIONEDITORILLUMINA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NORMALIZATIONEDITORILLUMINA.M with the given input arguments.
%
%      NORMALIZATIONEDITORILLUMINA('Property','Value',...) creates a new NORMALIZATIONEDITORILLUMINA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NormalizationEditorAffy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NormalizationEditorIllumina_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NormalizationEditorIllumina

% Last Modified by GUIDE v2.5 14-May-2010 18:50:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NormalizationEditorIllumina_OpeningFcn, ...
                   'gui_OutputFcn',  @NormalizationEditorIllumina_OutputFcn, ...
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


% --- Executes just before NormalizationEditorIllumina is made visible.
function NormalizationEditorIllumina_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.NormalizationEditorIllumina,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.NormalizationEditorIllumina,'Position',winpos);

% Get input
handles.arrays=varargin{1};

% Default output struct for normalization
normopts.usemedian=false;
normopts.display=false;

% Default output struct for summarization
summopts.output='log2';

% Set defaults
handles.norm='quantile';       % Normalization
handles.normName='Quantile';   % Normalization name
handles.normopts=normopts;     % Default normalization options
handles.summ='log2';           % Summarization method
handles.summName='log base 2'; % Summarization method name
handles.summopts=summopts;     % Default summarization options
handles.cancel=false;          % Cancel not pressed

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NormalizationEditorIllumina wait for user response (see UIRESUME)
uiwait(handles.NormalizationEditorIllumina);


% --- Outputs from this function are returned to the command line.
function varargout = NormalizationEditorIllumina_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.NormalizationEditorIllumina);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.NormalizationEditorIllumina);
end

varargout{1}=handles.norm;
varargout{2}=handles.normName;
varargout{3}=handles.normopts;
varargout{4}=handles.summ;
varargout{5}=handles.summName;
varargout{6}=handles.summopts;
varargout{7}=handles.cancel;


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
        [normopts.lowrank,normopts.uprank,normopts.exclude,normopts.percentage,...
         normopts.iterate,normopts.baseline,name,normopts.method,normopts.span,...
         normopts.showplot,cancel]=RankInvariantIlluminaEditor(handles.arrays);
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
switch summ;
    case 1
        handles.summ='log';
        handles.summName='natural log';
    case 2
        handles.summ='log2';
        handles.summName='log base 2';
    case 3
        handles.summ='log10';
        handles.summName='log base 10';
    case 4
        handles.summ='natural';
        handles.summName='physical';
end
guidata(hObject,handles);


function summPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.NormalizationEditorIllumina);


function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
normopts.usemedian=false;
normopts.display=false;
summopts.output='log2';

handles.norm='quantile';
handles.normName='Quantile';
handles.normopts=normopts;
handles.summ='log2';
handles.summName='log base 2';
handles.summopts=summopts;
handles.cancel=true; % Cancel pressed
guidata(hObject, handles);
uiresume(handles.NormalizationEditorIllumina);
