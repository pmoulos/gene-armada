function varargout = ExpressionProfileEditor(varargin)
% EXPRESSIONPROFILEEDITOR M-file for ExpressionProfileEditor.fig
%      EXPRESSIONPROFILEEDITOR, by itself, creates a new EXPRESSIONPROFILEEDITOR or raises the existing
%      singleton*.
%
%      H = EXPRESSIONPROFILEEDITOR returns the handle to a new EXPRESSIONPROFILEEDITOR or the handle to
%      the existing singleton*.
%
%      EXPRESSIONPROFILEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPRESSIONPROFILEEDITOR.M with the given input arguments.
%
%      EXPRESSIONPROFILEEDITOR('Property','Value',...) creates a new EXPRESSIONPROFILEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExpressionProfileEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExpressionProfileEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExpressionProfileEditor

% Last Modified by GUIDE v2.5 13-Dec-2007 16:28:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExpressionProfileEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @ExpressionProfileEditor_OutputFcn, ...
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


% --- Executes just before ExpressionProfileEditor is made visible.
function ExpressionProfileEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.ExpressionProfileEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.ExpressionProfileEditor,'Position',winpos);

% Get inputs
switch length(varargin)
    case 2
        handles.genes=varargin{1};
        handles.ind=varargin{2};
        handles.statind=[];
        handles.clusters=[];
        handles.ishier=true;
    case 3
        handles.genes=varargin{1};
        handles.ind=varargin{2};
        handles.statind=varargin{3};
        handles.clusters=[];
        handles.ishier=true;
    case 4
        handles.genes=varargin{1};
        handles.ind=varargin{2};
        handles.statind=varargin{3};
        handles.clusters=varargin{4};
        handles.ishier=true;
    case 5
        handles.genes=varargin{1};
        handles.ind=varargin{2};
        handles.statind=varargin{3};
        handles.clusters=varargin{4};
        handles.ishier=varargin{5};
    otherwise
        error('Incorrect number of arguments to %s',mfilename)
end

% Check uicontrol states
if isempty(handles.statind)
    set(handles.statGenesRadio,'Enable','off')
else
    set(handles.statGenesRadio,'Enable','on')
end
if isempty(handles.clusters)
    set(handles.clusterRadio,'Enable','off')
else
    set(handles.clusterRadio,'Enable','on')
end
set(handles.elemList,'String',handles.genes(handles.ind),'Max',length(handles.ind))

% Default outputs
val=get(handles.elemList,'Value');
str=get(handles.elemList,'String');
handles.outelem=str(val);            % Default elements to plot
handles.outelemind=handles.ind(val); % Default output values 
handles.plotwhat=1;                  % Plot all genes
handles.centro=false;                % Do not plot only centroids
handles.centrotoo=false;             % Do not plot centroids with errorbars in clusters
handles.multi=false;                 % Do not plot all clusters under the same plot
handles.diffcol=false;               % Do not color differently each gene
handles.showleg=false;               % Do not display legend
handles.plot=2;                      % Plot replicates
handles.title='';                    % Default title
handles.cancel=false;                % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ExpressionProfileEditor wait for user response (see UIRESUME)
uiwait(handles.ExpressionProfileEditor);


% --- Outputs from this function are returned to the command line.
function varargout = ExpressionProfileEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.ExpressionProfileEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.ExpressionProfileEditor);
end

varargout{1}=handles.outelem;
varargout{2}=handles.outelemind;
varargout{3}=handles.plotwhat;
varargout{4}=handles.centro;
varargout{5}=handles.centrotoo;
varargout{6}=handles.multi;
varargout{7}=handles.diffcol;
varargout{8}=handles.showleg;
varargout{9}=handles.plot;
varargout{10}=handles.title;
varargout{11}=handles.cancel;


% --- Executes on button press in allGenesRadio.
function allGenesRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.plotwhat=1; % Display all genes
    set(handles.statGenesRadio,'Value',0)
    set(handles.clusterRadio,'Value',0)
    set(handles.centroCheck,'Enable','off')
    set(handles.multiCheck,'Enable','off')
    set(handles.elemList,'String',handles.genes(handles.ind),...
                         'Max',length(handles.genes),...
                         'Value',1)
end 
guidata(hObject,handles);


% --- Executes on button press in statGenesRadio.
function statGenesRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.plotwhat=2; % Display stat genes
    set(handles.allGenesRadio,'Value',0)
    set(handles.clusterRadio,'Value',0)
    set(handles.centroCheck,'Enable','off')
    set(handles.multiCheck,'Enable','off')
    set(handles.elemList,'String',handles.genes(handles.statind),...
                         'Max',length(handles.genes(handles.statind)),...
                         'Value',1)
end
guidata(hObject,handles);


% --- Executes on button press in clusterRadio.
function clusterRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.plotwhat=3; % Display clusters
    set(handles.allGenesRadio,'Value',0)
    set(handles.statGenesRadio,'Value',0)
    if handles.ishier
        set(handles.centroCheck,'Enable','off')
        set(handles.multiCheck,'Enable','on')
    else
        set(handles.centroCheck,'Enable','on')
        set(handles.multiCheck,'Enable','on')
    end
    set(handles.elemList,'String',handles.clusters,...
                         'Max',length(handles.clusters),...
                         'Value',1)
end
guidata(hObject,handles);


% --- Executes on button press in meanRadio.
function meanRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.plot=1;
end
guidata(hObject,handles);


% --- Executes on button press in repliRadio.
function repliRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.plot=2;
end
guidata(hObject,handles);


% --- Executes on button press in centroCheck.
function centroCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.centro=true;
    set(handles.centroAlsoCheck,'Enable','off')
    set(handles.meanRadio,'Enable','off') % Centroids have been calculated from clus algo
    set(handles.repliRadio,'Enable','off')
else
    handles.centro=false;
    set(handles.centroAlsoCheck,'Enable','on')
    set(handles.meanRadio,'Enable','on')
    set(handles.repliRadio,'Enable','on')
end
guidata(hObject,handles);


% --- Executes on button press in centroAlsoCheck.
function centroAlsoCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.centrotoo=true;
else
    handles.centrotoo=false;
end
guidata(hObject,handles);


% --- Executes on button press in multiCheck.
function multiCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.multi=true;
else
    handles.multi=false;
end
guidata(hObject,handles);


% --- Executes on button press in diffcolCheck.
function diffcolCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.diffcol=true;
else
    handles.diffcol=false;
end
guidata(hObject,handles);


% --- Executes on button press in dispLegCheck.
function dispLegCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.showleg=true;
else
    handles.showleg=false;
end
guidata(hObject,handles);


function titleEdit_Callback(hObject, eventdata, handles)

if handles.plotwhat==1 || handles.plotwhat==2
    handles.title=get(hObject,'String');
elseif handles.plotwhat==3
    len=length(get(handles.elemList,'Value'));
    tit=cellstr(get(hObject,'String'));
    if length(tit)~=len
        uiwait(errordlg({'Please provide a number of titles equal to the number of clusters',...
                         ['you selected (',num2str(len),') or else leave the field completely'],...
                         'empty for automated title generation.'},'Bad Input'));
        set(hObject,'String','')
        handles.title='';
    else
        handles.title=tit;
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function titleEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in elemList.
function elemList_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
cont=get(hObject,'String');
handles.outelem=cont(val);
handles.outelemind=val;
% if get(handles.allGenesRadio,'Value')==1
%     handles.outelemind=handles.ind(val);
% elseif get(handles.statGenesRadio,'Value')==1
%     handles.outelemind=handles.statind(val);
% end
if handles.plotwhat==1 || handles.plotwhat==2
    set(handles.titleEdit,'Max',1)
elseif handles.plotwhat==3
    set(handles.titleEdit,'Max',length(val))
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function elemList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.ExpressionProfileEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

val=get(handles.elemList,'Value');
str=get(handles.elemList,'String');
handles.outelem=str(val);
handles.outelem=handles.ind(val);
handles.plotwhat=1;
handles.centro=false;
handles.centrotoo=false;
handles.multi=false;
handles.diffcol=false;
handles.showleg=false;
handles.plot=2;
handles.title='';
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.ExpressionProfileEditor);
