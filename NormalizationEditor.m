function varargout = NormalizationEditor(varargin)
% NORMALIZATIONEDITOR M-file for NormalizationEditor.fig
%      NORMALIZATIONEDITOR, by itself, creates a new NORMALIZATIONEDITOR or raises the existing
%      singleton*.
%
%      H = NORMALIZATIONEDITOR returns the handle to a new NORMALIZATIONEDITOR or the handle to
%      the existing singleton*.
%
%      NORMALIZATIONEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NORMALIZATIONEDITOR.M with the given input arguments.
%
%      NORMALIZATIONEDITOR('Property','Value',...) creates a new NORMALIZATIONEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NormalizationEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NormalizationEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NormalizationEditor

% Last Modified by GUIDE v2.5 17-Apr-2012 15:28:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NormalizationEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @NormalizationEditor_OutputFcn, ...
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


% --- Executes just before NormalizationEditor is made visible.
function NormalizationEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.NormalizationEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.NormalizationEditor,'Position',winpos);

% Get inputs
if isempty(varargin) || length(varargin)==1
    set(handles.orStatic,'Enable','off')
    set(handles.launchDyeSwapEditor,'Enable','off')
else
    handles.conds=varargin{1};
    handles.exprp=varargin{2};
    handles.channels=varargin{3};
end

% Choose default command line output for NormalizationEditor
if handles.channels==2 || isempty(handles.channels)
    handles.normalization=1;            % Linear LOWESS
    handles.normName='Linear LOWESS';   % Default Normalization Name
elseif handles.channels==1
    handles.normalization=8;            % Only none
    handles.normName='None';            % Default Normalization Name
end
handles.channel=1;                  % Cy5 is channel 2
handles.chanStr='Cy5 is Channel 2'; % Default text for channel-colour choice
handles.span=0.1;                   % Span for LOWESS/LOESS
handles.subgrid=2;                  % Do not perform subgrid normalization
handles.usetimebar=0;               % Do not use timebar
handles.rankopts=[];                % Rank invariant normalization options
handles.sumprobes=1;                % Summarize probes by default
handles.sumhow='mean';              % Summarization method
handles.sumwhen=0;                  % Summarize before or after normalization
handles.cancel=false;               % Do not proceed to normalization if cancel is pressed

% Just disable the normalization popup in order to avoid further implications
if handles.channels==1
    set(handles.normalizationPopup,'String',{'None'},'Value',1,'Enable','off')
    set(handles.spanEdit,'Enable','off')
    set(handles.spanText,'Enable','off')
    set(handles.subgridCheck,'Enable','off')
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NormalizationEditor wait for user response (see UIRESUME)
uiwait(handles.NormalizationEditor);


% --- Outputs from this function are returned to the command line.
function varargout = NormalizationEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.NormalizationEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.NormalizationEditor);
end

% Get default command line output from handles structure
varargout{1}=handles.normalization;
varargout{2}=handles.span;
varargout{3}=handles.channel;
varargout{4}=handles.subgrid;
varargout{5}=handles.normName;
varargout{6}=handles.chanStr;
varargout{7}=handles.usetimebar;
varargout{8}=handles.rankopts;
varargout{9}=handles.sumprobes;
varargout{10}=handles.sumhow;
varargout{11}=handles.sumwhen;
varargout{12}=handles.cancel;


% --- Executes on selection change in normalizationPopup.
function normalizationPopup_Callback(hObject, eventdata, handles)

norm=get(hObject,'Value');
normNames=get(hObject,'String');
switch norm;
    case 1
        handles.normalization=1; % Linear LOWESS
        handles.normName=normNames{1};
        set(handles.spanText,'Enable','on')
        set(handles.spanEdit,'Enable','on')
        %set(handles.channelPopup,'Enable','on')
        set(handles.subgridCheck,'Enable','on')
        set(handles.sumProbesCheck,'Enable','on')
        if get(handles.sumProbesCheck,'Value')==1
            set(handles.beforeRadio,'Enable','on')
            set(handles.afterRadio,'Enable','on')
        end
    case 2
        handles.normalization=2; % Robust Linear LOWESS
        handles.normName=normNames{2};
        set(handles.spanText,'Enable','on')
        set(handles.spanEdit,'Enable','on')
        %set(handles.channelPopup,'Enable','on')
        set(handles.subgridCheck,'Enable','on')
        set(handles.sumProbesCheck,'Enable','on')
        if get(handles.sumProbesCheck,'Value')==1
            set(handles.beforeRadio,'Enable','on')
            set(handles.afterRadio,'Enable','on')
        end
    case 3
        handles.normalization=3; % Quadratic LOESS
        handles.normName=normNames{3};
        set(handles.spanText,'Enable','on')
        set(handles.spanEdit,'Enable','on')
        %set(handles.channelPopup,'Enable','on')
        set(handles.subgridCheck,'Enable','on')
        set(handles.sumProbesCheck,'Enable','on')
        if get(handles.sumProbesCheck,'Value')==1
            set(handles.beforeRadio,'Enable','on')
            set(handles.afterRadio,'Enable','on')
        end
    case 4
        handles.normalization=4; % Quadratic LOESS
        handles.normName=normNames{4};
        set(handles.spanText,'Enable','on')
        set(handles.spanEdit,'Enable','on')
        %set(handles.channelPopup,'Enable','on')
        set(handles.subgridCheck,'Enable','on')
        set(handles.sumProbesCheck,'Enable','on')
        if get(handles.sumProbesCheck,'Value')==1
            set(handles.beforeRadio,'Enable','on')
            set(handles.afterRadio,'Enable','on')
        end
    case 5
        handles.normalization=5; % Global Mean
        handles.normName=normNames{5};
        handles.span=[];
        set(handles.spanText,'Enable','off')
        set(handles.spanEdit,'Enable','off')
        %set(handles.channelPopup,'Enable','on')
        set(handles.subgridCheck,'Enable','on')
        set(handles.sumProbesCheck,'Enable','on')
        if get(handles.sumProbesCheck,'Value')==1
            set(handles.beforeRadio,'Enable','on')
            set(handles.afterRadio,'Enable','on')
        end
    case 6
        handles.normalization=6; % Global Median
        handles.normName=normNames{6};
        handles.span=[];
        set(handles.spanText,'Enable','off')
        set(handles.spanEdit,'Enable','off')
        %set(handles.channelPopup,'Enable','on')
        set(handles.subgridCheck,'Enable','on')
        set(handles.sumProbesCheck,'Enable','on')
         if get(handles.sumProbesCheck,'Value')==1
            set(handles.beforeRadio,'Enable','on')
            set(handles.afterRadio,'Enable','on')
        end
    case 7
        handles.normalization=7; % Rank Invariant
        handles.normName=normNames{7};
        handles.span=[];
        set(handles.spanText,'Enable','off')
        set(handles.spanEdit,'Enable','off')
        %set(handles.channelPopup,'Enable','on')
        set(handles.subgridCheck,'Enable','off')
        set(handles.sumProbesCheck,'Enable','on')
        if get(handles.sumProbesCheck,'Value')==1
            set(handles.beforeRadio,'Enable','off')
            set(handles.afterRadio,'Enable','off')
        end
        
        % ...and get rank invariant normalization inputs
        [rankopts,cancel]=RankInvariantOpts;
        if ~cancel
            handles.rankopts=rankopts;
        else
            handles.rankopts=[];
            % Restore to defaults
            set(hObject,'Value',1);
            handles.normalization=1;
            handles.normName=normNames{1};
            handles.span=0.1;
            set(handles.spanText,'Enable','on')
            set(handles.spanEdit,'Enable','on')
            %set(handles.channelPopup,'Enable','on')
            set(handles.subgridCheck,'Enable','on')
            set(handles.sumProbesCheck,'Enable','on')
            if get(handles.sumProbesCheck,'Value')==1
                set(handles.beforeRadio,'Enable','on')
                set(handles.afterRadio,'Enable','on')
            end
        end
    case 8
        handles.normalization=8; % No normalization
        handles.normName=normNames{8};
        handles.span=[];
        set(handles.spanText,'Enable','off')
        set(handles.spanEdit,'Enable','off')
        %set(handles.channelPopup,'Enable','off')
        set(handles.subgridCheck,'Enable','off')
        set(handles.sumProbesCheck,'Enable','on')
        if get(handles.sumProbesCheck,'Value')==1
            set(handles.beforeRadio,'Enable','on')
            set(handles.afterRadio,'Enable','on')
        end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function normalizationPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function spanEdit_Callback(hObject, eventdata, handles)

span=str2double(get(hObject,'String'));
if isnan(span) || span<=0
    uiwait(errordlg('You must enter a positive number','Bad Input','modal'));
    set(hObject,'String','0.1');
elseif span>1 && rem(span,1)~=0
    uiwait(errordlg('If > 1 the span must be a positive integer.','Bad Input','modal'));
    set(hObject,'String','0.1');
else
    handles.span=span;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function spanEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channelPopup.
function channelPopup_Callback(hObject, eventdata, handles)

chan=get(hObject,'Value');
chanStrs=get(hObject,'String');
switch chan;
    case 1
        handles.channel=1; % Cy5-->ch2
        handles.chanStr=chanStrs{1};
    case 2
        handles.channel=2; % Cy5-->ch1
        handles.chanStr=chanStrs{2};
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function channelPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function launchDyeSwapEditor_Callback(hObject, eventdata, handles)

[handles.channel,cancel]=DyeSwapEditor(handles.conds,handles.exprp);
if ~cancel
    handles.chanStr='Dye-Swap matrix created by user';
    guidata(hObject,handles);
end


% --- Executes on button press in subgridCheck.
function subgridCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.subgrid=1;
     if get(handles.sumProbesCheck,'Value')==1
        set(handles.beforeRadio,'Enable','off')
        set(handles.afterRadio,'Enable','off')
    end
else
    handles.subgrid=2;
    if get(handles.sumProbesCheck,'Value')==1
        set(handles.beforeRadio,'Enable','on')
        set(handles.afterRadio,'Enable','on')
    end
end
guidata(hObject,handles);


% --- Executes on button press in sumProbesCheck.
function sumProbesCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.meanRadio,'Enable','on')
    set(handles.medianRadio,'Enable','on')
    set(handles.beforeRadio,'Enable','on')
    set(handles.afterRadio,'Enable','on')
    handles.sumprobes=1;
else
    set(handles.meanRadio,'Enable','off')
    set(handles.medianRadio,'Enable','off')
    set(handles.beforeRadio,'Enable','off')
    set(handles.afterRadio,'Enable','off')
    handles.sumprobes=0;
end
guidata(hObject,handles);


% --- Executes on button press in meanRadio.
function meanRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.sumhow='mean';
end
guidata(hObject,handles);


% --- Executes on button press in medianRadio.
function medianRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.sumhow='median';
end
guidata(hObject,handles);


% --- Executes on button press in meanRadio.
function beforeRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.sumwhen=0;
end
guidata(hObject,handles);


% --- Executes on button press in medianRadio.
function afterRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.sumwhen=1;
end
guidata(hObject,handles);


% % --- Executes on button press in sumProbesCheck.
% function timebarCheck_Callback(hObject, eventdata, handles)
% 
% if get(hObject,'Value')==1
%     handles.usetimebar=1;
% else
%     handles.usetimebar=0;
% end
% guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.NormalizationEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
handles.normalization=1;
handles.span=0.1;
handles.channel=1;
handles.subgrid=2;
handles.normName='Linear LOWESS';   
handles.chanStr='Cy5 is Channel 1';
handles.usetimebar=0;
handles.rankopts=[];
handles.sumprobes=1;
handles.sumhow='mean';
handles.sumwhen=0;
handles.cancel=true; % Cancel pressed
guidata(hObject,handles)
uiresume(handles.NormalizationEditor);
