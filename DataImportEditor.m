function varargout = DataImportEditor(varargin)
% DATAIMPORTEDITOR M-file for DataImportEditor.fig
%      DATAIMPORTEDITOR, by itself, creates a new DATAIMPORTEDITOR or raises the existing
%      singleton*.
%
%      H = DATAIMPORTEDITOR returns the handle to a new DATAIMPORTEDITOR or the handle to
%      the existing singleton*.
%
%      DATAIMPORTEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAIMPORTEDITOR.M with the given input arguments.
%
%      DATAIMPORTEDITOR('Property','Value',...) creates a new DATAIMPORTEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataImportEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataImportEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataImportEditor

% Last Modified by GUIDE v2.5 29-Apr-2007 18:38:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataImportEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @DataImportEditor_OutputFcn, ...
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


% --- Executes just before DataImportEditor is made visible.
function DataImportEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.DataImportEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.DataImportEditor,'Position',winpos);

% Set default settings
handles.imgsw=1;                % QuantArray
handles.exprp=[];               % the exprp experimental info
handles.t=[];                   % The number of conditions
handles.conditionNames=[];      % The names of condditions
handles.pathnames=[];           % The pathnames of the files to be imported
handles.datatable=[];           % The datatable to be displayed
handles.emSpotImGn=1;           % Mark empty spots as poor for ImaGene
handles.cdfdata={'',''};        % Default locations of affy cdf files
%handles.illufile='';           % Default Illumina file
handles.imgswName='QuantArray'; % Default software name
handles.allOK=0;                % All is OK, user did not press Cancel
handles.counters.nocond=0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataImportEditor wait for user response (see UIRESUME)
uiwait(handles.DataImportEditor);


% --- Outputs from this function are returned to the command line.
function varargout = DataImportEditor_OutputFcn(hObject, eventdata, handles)

if (get(handles.cancelButton,'Value')==0)
    delete(handles.DataImportEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.DataImportEditor);
end

% Get default command line output from handles structure
varargout{1}=handles.imgsw;
varargout{2}=handles.exprp;
varargout{3}=handles.t;
varargout{4}=handles.conditionNames;
varargout{5}=handles.pathnames;
varargout{6}=handles.datatable;
varargout{7}=handles.emSpotImGn;
varargout{8}=handles.cdfdata;
%varargout{9}=handles.illufile;
varargout{9}=handles.imgswName;
varargout{10}=handles.allOK;


% --- Executes on selection change in chooseSoftware.
function chooseSoftware_Callback(hObject, eventdata, handles)

imgsw=get(hObject,'Value');
imgswNames=get(hObject,'String');
switch imgsw
    case 1
        handles.imgsw=1; % QuantArray
        handles.imgswName=imgswNames{1};
        set(handles.checkEmptyImaGene,'Enable','off')
    case 2
        handles.imgsw=2; % ImaGene
        handles.imgswName=imgswNames{2};
        set(handles.checkEmptyImaGene,'Enable','on')
    case 3
        handles.imgsw=3; % GenePix
        handles.imgswName=imgswNames{3};
        set(handles.checkEmptyImaGene,'Enable','off')
    case 4
        handles.imgsw=5; % Agilent
        handles.imgswName=imgswNames{4};
        set(handles.checkEmptyImaGene,'Enable','off')
    case 5
        handles.imgsw=99; % Affymetrix
        handles.imgswName=imgswNames{5};
        set(handles.checkEmptyImaGene,'Enable','off')
    case 6
        handles.imgsw=4; % Tab-delimited
        handles.imgswName=imgswNames{6};
        set(handles.checkEmptyImaGene,'Enable','off')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chooseSoftware_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkEmptyImaGene.
function checkEmptyImaGene_Callback(hObject, eventdata, handles)

if (get(hObject,'Value')==get(hObject,'Max'))
    handles.emSpotImGn=1;
else
    handles.emSpotImGn=2;
end
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of checkEmptyImaGene


function editNumberConditions_Callback(hObject, eventdata, handles)

nocond=str2double(get(hObject,'String'));
% if ~isempty(handles.conditionNames)
if isnan(nocond) || nocond<=0 || mod(nocond,1)>0
    uiwait(errordlg('You must enter a positive integer','Bad Input','modal'));
    set(hObject,'String',num2str(length(handles.conditionNames)));
    handles.t=str2double(get(hObject,'String'));
    set(handles.selectButton,'Enable','on')
    % % Too strict...
    % elseif nocond~=length(handles.conditionNames)
    %    uiwait(errordlg('The number of conditions must be equal to the number of condition names',...
    %                    'Bad Input','modal'));
    %    set(hObject,'String',num2str(length(handles.conditionNames)));
    %    handles.t=str2double(get(hObject,'String'));
    %    set(handles.selectButton,'Enable','on')
else
    handles.t=nocond;
end
% else
%     handles.t=nocond;
% end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editNumberConditions_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press over editNumberConditions with no controls selected.
function editNumberConditions_KeyPressFcn(hObject, eventdata, handles)

currpress=get(handles.DataImportEditor,'CurrentCharacter');
z=regexp(currpress,'\d+','once');
v=regexp(currpress,'\b+','once');
if ~isempty(z)
    set(handles.selectButton,'Enable','on')
    handles.counters.nocond=handles.counters.nocond+1;
end
if ~isempty(v)
    handles.counters.nocond=handles.counters.nocond-1;
end
if handles.counters.nocond<=0
    set(handles.selectButton,'Enable','off')
    handles.counters.nocond=0;
end
guidata(hObject,handles);


function editConditionNames_Callback(hObject, eventdata, handles)

condnames=cellstr(get(hObject,'String'));
if ~isempty(handles.t)
    if handles.t~=length(condnames);
        uiwait(errordlg('The number of names specified must be equal to the number of conditions',...
                        'Bad Input','modal'));
        def=createConditionNames(handles.t);
        set(hObject,'String',def);
        handles.conditionNames=cellstr(get(hObject,'String'))';
    else
        z=cell2mat(regexp(condnames,'[<>/;,''''\[\]"|?.\s!@#\$%^&*()-+=`~\\]','once'));
        if ~isempty(z)
            wmsg1={'The condition names should not contain any of the following characters:',...
                   '< > / \ , ; '''' [ ] " | ? . ! @ # $ % ^ & * ( ) - + = ` ~ or white spaces.',...
                   'These characters will be automatically replaced by underscores (_).'};
            uiwait(warndlg(wmsg1,'Bad Input','modal'));
            condnames=regexprep(condnames,'[<>/;,''''\[\]"|?.\s!@#$%^&*()-+=`~\\]','_');
            set(hObject,'String',condnames);
        end
        v=cell2mat(regexp(condnames,'^\d','once'));
        if ~isempty(v)
            wmsg1={'The condition names should not start with a digit.',...
                   'It will be automatically replaced by its character value.'};
            uiwait(warndlg(wmsg1,'Bad Input','modal'));
            condnames=replaceDigits(condnames);
            set(hObject,'String',condnames);
        end
        handles.conditionNames=condnames';
    end
else
    handles.conditionNames=condnames';
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editConditionNames_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.DataImportEditor);


% --- Executes on button press in selectButton.
function selectButton_Callback(hObject, eventdata, handles)

okflag=0;
if ~isempty(handles.conditionNames)
    if handles.t~=length(handles.conditionNames)
        uiwait(errordlg('The number of names specified must be equal to the number of conditions.',...
                        'Bad Input','modal'));
    else    
        okflag=1;
    end
else
    cstr={'You did not specify names for experimental conditions or',...
          'there is a problem with the condition names you specified.',...
          'Do you wish that ARMADA creates them for you?'};
    yesno=questdlg(cstr,'Condition Names','Yes');
    if strcmp(yesno,'Yes')
        def=createConditionNames(handles.t);
        set(handles.editConditionNames,'String',def);
        handles.conditionNames=def';
        guidata(hObject,handles);
        okflag=1;
    elseif strcmp(yesno,'No')
        uiwait(warndlg('You must specify condition names!','Warning'));
        okflag=0;
    elseif strcmp(yesno,'Cancel') || isempty(yesno)
        okflag=0;
    end
end

if okflag
    switch handles.imgsw
        case 99 % Affymetrix
            [handles.exprp,handles.cdfdata{1},handles.pathnames,handles.cdfdata{2},...
            handles.datatable,]=selectFilesAffy(handles.conditionNames);
        otherwise
            [handles.exprp,handles.datatable,handles.pathnames]=selectFiles(handles.t,...
                                                                handles.imgsw,handles.conditionNames);
    end
    if ~(isempty(handles.exprp) || isempty(handles.datatable) || isempty(handles.pathnames))
        set(handles.okButton,'Enable','on')
        handles.allOK=1;
    end
end
guidata(hObject,handles);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% If user presses 'Cancel' the figure is deleted and the default values are returned
handles.imgsw=1;
handles.exprp=[];      
handles.t=[];
handles.conditionNames=[];
handles.pathnames=[];
handles.datatable=[];
handles.emSpotImGn=1;
handles.cdfdata={'',''};
%handles.illufile='';
handles.imgswName='QuantArray';
handles.allOK=0;
handles.counters.nocond=0;
guidata(hObject,handles)
uiresume(handles.DataImportEditor);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   HELP FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function con = createConditionNames(t)

pref='Condition ';
con=cell(t,1);
for i=1:t
    con{i}=strcat(pref,num2str(i));
end


function newcon = replaceDigits(con)

newcon=con(:);
newcon=strrep(newcon,'0','Zero');
newcon=strrep(newcon,'1','One');
newcon=strrep(newcon,'2','Two');
newcon=strrep(newcon,'3','Three');
newcon=strrep(newcon,'4','Four');
newcon=strrep(newcon,'5','Five');
newcon=strrep(newcon,'6','Six');
newcon=strrep(newcon,'7','Seven');
newcon=strrep(newcon,'8','Eight');
newcon=strrep(newcon,'9','Nine');
