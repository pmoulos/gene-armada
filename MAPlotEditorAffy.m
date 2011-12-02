function varargout = MAPlotEditorAffy(varargin)
% MAPLOTEDITORAFFY M-file for MAPlotEditorAffy.fig
%      MAPLOTEDITORAFFY, by itself, creates a new MAPLOTEDITORAFFY or raises the existing
%      singleton*.
%
%      H = MAPLOTEDITORAFFY returns the handle to a new MAPLOTEDITORAFFY or the handle to
%      the existing singleton*.
%
%      MAPLOTEDITORAFFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAPLOTEDITORAFFY.M with the given input arguments.
%
%      MAPLOTEDITORAFFY('Property','Value',...) creates a new MAPLOTEDITORAFFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MAPlotEditorAffy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MAPlotEditorAffy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MAPlotEditorAffy

% Last Modified by GUIDE v2.5 29-Mar-2009 21:46:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MAPlotEditorAffy_OpeningFcn, ...
                   'gui_OutputFcn',  @MAPlotEditorAffy_OutputFcn, ...
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


% --- Executes just before MAPlotEditorAffy is made visible.
function MAPlotEditorAffy_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.MAPlotEditorAffy,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.MAPlotEditorAffy,'Position',winpos);

% Plot options for Affymetrix and Illumina
affyChoice={'Intensity','Standard Deviation',...
            'PM','MM',...
            'BackAdjusted PM','Normalized PM',...
            'Expression (raw)','Expression (back)','Expression (norm)'};
illuChoice={'Expression (raw)','Expression (norm)'};

% Get inputs
handles.arrays=varargin{1};
handles.imgsw=varargin{2};

% Fill lists
if handles.imgsw==99 % Affymetrix
    set(handles.dataPlotPopup,'String',affyChoice)
elseif handles.imgsw==98 % Illumina
    set(handles.dataPlotPopup,'String',illuChoice)
end
set(handles.whArrayList,'String',handles.arrays)
set(handles.vsArrayList,'String',handles.arrays)
handles.dispNames=get(handles.dataPlotPopup,'String');

plat=get(handles.dataPlotPopup,'String');
% Set default outputs
handles.wharrays={};          % Default array to plot from non-normalized
handles.vsarrays={};          % Default array to plot from normalized
handles.type='ava';           % 'ava', 'avma','avms', 'maxy'
handles.plotwhat=1;           % What quantity to plot
handles.plotwhatName=plat{1}; % Its name
handles.titles='';            % The title(s)
handles.displine=false;       % Display a cutoff line where colors change
handles.linecut=2;            % The above cutoff
handles.cancel=false;         % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MAPlotEditorAffy wait for user response (see UIRESUME)
uiwait(handles.MAPlotEditorAffy);


% --- Outputs from this function are returned to the command line.
function varargout = MAPlotEditorAffy_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.MAPlotEditorAffy);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.MAPlotEditorAffy);
end

% Get default command line output from handles structure
varargout{1}=handles.wharrays;
varargout{2}=handles.vsarrays;
varargout{3}=handles.type;
varargout{4}=handles.plotwhat;
varargout{5}=handles.plotwhatName;
varargout{6}=handles.titles;
varargout{7}=handles.displine;
varargout{8}=handles.linecut;
varargout{9}=handles.cancel;


function whArrayList_Callback(hObject, eventdata, handles)

if get(handles.vsArrayRadio,'Value')~=1
    val=get(hObject,'Value');
    str=get(hObject,'String');
    handles.wharrays=str(val);
    set(handles.titlesEdit,'Max',length(val))
end
guidata(hObject,handles);
    
    
function whArrayList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function vsArrayList_Callback(hObject, eventdata, handles)

if get(handles.vsArrayRadio,'Value')~=1
    val=get(hObject,'Value');
    str=get(hObject,'String');
    handles.vsarrays=str(val);
end
guidata(hObject,handles);


function vsArrayList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pairArrayList_Callback(hObject, eventdata, handles)

if ~isempty(get(hObject,'String'))
    set(handles.removePair,'Enable','on')
else
    set(handles.removePair,'Enable','off')
end
guidata(hObject,handles);


function pairArrayList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function addPair_Callback(hObject, eventdata, handles)

% Get the wanted indices
arrs1=get(handles.whArrayList,'String');
val1=get(handles.whArrayList,'Value');
arrs2=get(handles.vsArrayList,'String');
val2=get(handles.vsArrayList,'Value');
arr1=arrs1{val1};
arr2=arrs2{val2};

% Check if already selected. If not, include else not
selPairs=get(handles.pairArrayList,'String');
if ~isempty(strmatch([arr1,' vs ',arr2],selPairs))
    return
end
handles.wharrays=[handles.wharrays arr1];
handles.vsarrays=[handles.vsarrays arr2];

% Update the list of calculations
oldstr=get(handles.pairArrayList,'String');
newstr=[oldstr;[arr1,' vs ',arr2]];
set(handles.pairArrayList,'String',newstr,'Max',length(newstr))
set(handles.removePair,'Enable','on')

guidata(hObject,handles);


function removePair_Callback(hObject, eventdata, handles)

% Get indices to remove
reminds=get(handles.pairArrayList,'Value');
str=cellstr(get(handles.pairArrayList,'String'));

% Update output arrays
handles.wharrays(reminds)=[];
handles.vsarrays(reminds)=[];
str(reminds)=[];

% Update list
if ~isempty(str)
    set(handles.pairArrayList,'String',str,'Value',1,'Max',length(str))
else
    set(handles.pairArrayList,'String','','Value',[],'Max',1)
end

% Check if empty so as to disable remove button
if isempty(get(handles.pairArrayList,'String'))
    set(hObject,'Enable','off')
end

guidata(hObject,handles);


function clearwhArrays_Callback(hObject, eventdata, handles)

set(handles.whArrayList,'Value',[])
set(handles.titlesEdit,'Max',1)
set(handles.removePair,'Enable','off')
handles.wharrays={};
guidata(hObject,handles);


function clearvsArrays_Callback(hObject, eventdata, handles)

set(handles.vsArrayList,'Value',[])
handles.vsarrays={};
guidata(hObject,handles);


function clearPairs_Callback(hObject, eventdata, handles)

set(handles.pairArrayList,'String','','Value',[])
handles.wharrays={};
handles.vsarrays={};
guidata(hObject,handles);


function vsArrayRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.type='ava';
    handles.wharrays={};
    handles.vsarrays={};
    clearPairs_Callback(hObject, eventdata, handles)
    set(handles.whArrayList,'Max',1,'Value',1)
    set(handles.vsArrayList,'Max',1,'Value',1)
    set(handles.vsStatic,'Enable','on')
    set(handles.vsArrayStatic,'Enable','on')
    set(handles.vsArrayList,'Enable','on')
    set(handles.clearvsArrays,'Enable','on')
    set(handles.pairStatic,'Enable','on')
    set(handles.pairArrayList,'Enable','on')
    set(handles.clearPairs,'Enable','on')
    set(handles.addPair,'Enable','on')
    set(handles.removePair,'Enable','off')
    set(handles.dataPlotPopup,'String',handles.dispNames)
    set(handles.titlesStatic,'Enable','on')
    set(handles.titlesEdit,'Enable','on')
    set(handles.cutCheck,'Enable','on')
    if get(handles.cutCheck,'Value')==1
        set(handles.cutStatic,'Enable','on')
        set(handles.cutEdit,'Enable','on')
    else
        set(handles.cutStatic,'Enable','off')
        set(handles.cutEdit,'Enable','off')
    end
    set(handles.clearwhArrays,'Enable','off');
    set(handles.clearvsArrays,'Enable','off');
end
guidata(hObject,handles);
    

function vsMedianAllRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.type='avm';
    cv=get(handles.whArrayList,'Value');
    cs=get(handles.whArrayList,'String');
    handles.wharrays=cs(cv);
    handles.vsarrays=handles.arrays;
    clearPairs_Callback(hObject, eventdata, handles)
    set(handles.whArrayList,'Enable','on','Max',2)
    set(handles.vsArrayList,'Enable','on','Max',2)
    set(handles.vsStatic,'Enable','off')
    set(handles.vsArrayStatic,'Enable','off')
    set(handles.vsArrayList,'Enable','off')
    set(handles.clearvsArrays,'Enable','off')
    set(handles.pairStatic,'Enable','off')
    set(handles.pairArrayList,'Enable','off')
    set(handles.clearPairs,'Enable','off')
    set(handles.addPair,'Enable','off')
    set(handles.removePair,'Enable','off')
    set(handles.dataPlotPopup,'String',handles.dispNames(3:end),'Value',1)
    set(handles.titlesStatic,'Enable','on')
    set(handles.titlesEdit,'Enable','on')
    set(handles.cutCheck,'Enable','on')
    if get(handles.cutCheck,'Value')==1
        set(handles.cutStatic,'Enable','on')
        set(handles.cutEdit,'Enable','on')
    else
        set(handles.cutStatic,'Enable','off')
        set(handles.cutEdit,'Enable','off')
    end
    set(handles.clearwhArrays,'Enable','on');
    set(handles.clearvsArrays,'Enable','on');
end
guidata(hObject,handles);


function vsMedianSelRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.type='avm';
    cvw=get(handles.whArrayList,'Value');
    csw=get(handles.whArrayList,'String');
    handles.wharrays=csw(cvw);
    cvv=get(handles.vsArrayList,'Value');
    csv=get(handles.vsArrayList,'String');
    handles.vsarrays=csv(cvv);
    clearPairs_Callback(hObject, eventdata, handles)
    set(handles.whArrayList,'Enable','on','Max',2)
    set(handles.vsArrayList,'Enable','on','Max',2)
    set(handles.vsStatic,'Enable','on')
    set(handles.vsArrayStatic,'Enable','on')
    set(handles.vsArrayList,'Enable','on')
    set(handles.clearvsArrays,'Enable','on')
    set(handles.pairStatic,'Enable','off')
    set(handles.pairArrayList,'Enable','off')
    set(handles.clearPairs,'Enable','off')
    set(handles.addPair,'Enable','off')
    set(handles.removePair,'Enable','off')
    set(handles.dataPlotPopup,'String',handles.dispNames(3:end),'Value',1)
    set(handles.titlesStatic,'Enable','on')
    set(handles.titlesEdit,'Enable','on')
    set(handles.cutCheck,'Enable','on')
    if get(handles.cutCheck,'Value')==1
        set(handles.cutStatic,'Enable','on')
        set(handles.cutEdit,'Enable','on')
    else
        set(handles.cutStatic,'Enable','off')
        set(handles.cutEdit,'Enable','off')
    end
    set(handles.clearwhArrays,'Enable','on');
    set(handles.clearvsArrays,'Enable','on');
end
guidata(hObject,handles);


function MAXYRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.type='maxy';
    cv=get(handles.whArrayList,'Value');
    cs=get(handles.whArrayList,'String');
    handles.wharrays=cs(cv);
    handles.vsarrays={};
    clearPairs_Callback(hObject, eventdata, handles)
    set(handles.whArrayList,'Enable','on','Max',2)
    set(handles.vsArrayList,'Enable','on','Max',2)
    set(handles.vsStatic,'Enable','off')
    set(handles.vsArrayStatic,'Enable','off')
    set(handles.vsArrayList,'Enable','off')
    set(handles.clearvsArrays,'Enable','off')
    set(handles.pairStatic,'Enable','off')
    set(handles.pairArrayList,'Enable','off')
    set(handles.clearPairs,'Enable','off')
    set(handles.addPair,'Enable','off')
    set(handles.removePair,'Enable','off')
    set(handles.dataPlotPopup,'String',handles.dispNames(3:end),'Value',1)
    set(handles.titlesStatic,'Enable','off')
    set(handles.titlesEdit,'Enable','off')
    set(handles.cutCheck,'Enable','off')
    set(handles.cutStatic,'Enable','off')
    set(handles.cutEdit,'Enable','off')
    set(handles.clearwhArrays,'Enable','off');
end
guidata(hObject,handles);


function dataPlotPopup_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
handles.plotwhat=val;
handles.plotwhatName=contents{val};
guidata(hObject,handles);


function dataPlotPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function titlesEdit_Callback(hObject, eventdata, handles)

tit=cellstr(get(hObject,'String'));
len=length(get(handles.whArrayList,'Value'));
if length(tit)~=len
    uiwait(errordlg({'Please provide a number of titles equal to the number of arrays',...
                     ['you selected (',num2str(len),') or else leave the field completely'],... 
                     'empty for automated title generation.'},'Bad Input'));
    set(hObject,'String','')
    handles.titles='';
else
    handles.titles=tit;
end
guidata(hObject,handles);


function titlesEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function cutCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.displine=true;
    set(handles.cutStatic,'Enable','on')
    set(handles.cutEdit,'Enable','on')
else
    handles.displine=false;
    set(handles.cutStatic,'Enable','off')
    set(handles.cutEdit,'Enable','off')
end
guidata(hObject,handles);


function cutEdit_Callback(hObject, eventdata, handles)

c=str2double(get(hObject,'String'));
if isnan(c) || c<=0
    uiwait(errordlg('The cutoff line must be a positive value.',...
                    'Bad Input'));
    set(hObject,'String','2');
    handles.linecut=str2double(get(hObject,'String'));
else
    handles.linecut=c;
end
guidata(hObject,handles);


function cutEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function okButton_Callback(hObject, eventdata, handles)

% Some protection for out of memory errors
if (strcmp(handles.type,'avm') || strcmp(handles.type,'maxy')) && handles.imgsw==99
    handles.plotwhat=handles.plotwhat+2;
end
% Transformation for Affymetrix and Illumina data, for use with retrieveArrayData inside 
% ARMADA main
if handles.imgsw==99
    handles.plotwhat=handles.plotwhat+100;
elseif handles.imgsw==98
    handles.plotwhat=handles.plotwhat+200;
end
guidata(hObject,handles);
uiresume(handles.MAPlotEditorAffy);


function cancelButton_Callback(hObject, eventdata, handles)

plat=get(handles.dataPlotPopup,'String');
% Resume defaults
handles.wharrays='';
handles.vsarrays='';
handles.type='ava';
handles.plotwhat=1;
handles.plotwhatName=plat{1}; 
handles.titles='';
handles.displine=false;
handles.linecut=2;
handles.cancel=true; % User pressed cancel 
guidata(hObject,handles);   
uiresume(handles.MAPlotEditorAffy);
