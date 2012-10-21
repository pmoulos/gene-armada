function varargout = StatisticalSelectionBatchEditor(varargin)
% STATISTICALSELECTIONBATCHEDITOR M-file for StatisticalSelectionBatchEditor.fig
%      STATISTICALSELECTIONBATCHEDITOR, by itself, creates a new STATISTICALSELECTIONBATCHEDITOR or raises the existing
%      singleton*.
%
%      H = STATISTICALSELECTIONBATCHEDITOR returns the handle to a new STATISTICALSELECTIONBATCHEDITOR or the handle to
%      the existing singleton*.
%
%      STATISTICALSELECTIONBATCHEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STATISTICALSELECTIONBATCHEDITOR.M with the given input arguments.
%
%      STATISTICALSELECTIONBATCHEDITOR('Property','Value',...) creates a new STATISTICALSELECTIONBATCHEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StatisticalSelectionBatchEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StatisticalSelectionBatchEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StatisticalSelectionBatchEditor

% Last Modified by GUIDE v2.5 19-Jun-2012 10:42:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StatisticalSelectionBatchEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @StatisticalSelectionBatchEditor_OutputFcn, ...
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


% --- Executes just before StatisticalSelectionBatchEditor is made visible.
function StatisticalSelectionBatchEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.StatisticalSelectionBatchEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.StatisticalSelectionBatchEditor,'Position',winpos);

% Get the inputs from ARMADA's analysisInfo structure (only its length and the field
% numberOfConditions required
handles.len=varargin{1};
handles.nocond=varargin{2};    % A vector of length len containing the number of conditions
                               % for each analysis object
handles.noarr=varargin{3};     % A vector of length len containing the number of arrays for
                               % each analysis object
handles.condnames=varargin{4}; % A cell array of strings containing the condition names
soft=varargin{5};

% Set analysis listbox contents
handles.contents=cell(1,handles.len);
for i=1:handles.len
    handles.contents{i}=['Analysis ',num2str(i)];
end
set(handles.analysisList,'String',handles.contents);
set(handles.analysisList,'Value',1)

% Initialize current selection indicator
handles.currentSelection=1;

% Set control and treated popup menus contents
set(handles.controlPopup,'String',handles.condnames{1});
set(handles.treatedPopup,'String',handles.condnames{1});

% Check if the first analysis object should have t-test available or not
if handles.nocond(1)==1
    set(handles.statTestPopup,'String','t-test','Value',1)
    handles.statTest=2;
    handles.statTestName={'t-test'};
elseif handles.nocond(1)==2
    z=strmatch('t-test',get(handles.statTestPopup,'String'));
    if isempty(z)
        newstr=get(handles.statTestPopup,'String');
        newstr=[newstr;'t-test'];
        set(handles.statTestPopup,'String',newstr)
    end
else
    newstr=get(handles.statTestPopup,'String');
    z=strmatch('t-test',newstr);
    if ~isempty(z)
        newstr(z)=[];
        set(handles.statTestPopup,'String',newstr)
    end
end

% Intialize handles fields as arrays so as to support multiple output
handles.scale=cell(1,handles.len);
handles.scaleOpts=cell(1,handles.len);
handles.scaleName=cell(1,handles.len);
handles.impute=cell(1,handles.len);
handles.imputeOpts=cell(1,handles.len);
handles.imputeName=cell(1,handles.len);
handles.imputeBefOrAft=zeros(1,handles.len);
handles.imputeBefOrAftName=cell(1,handles.len);
handles.statTest=zeros(1,handles.len);
handles.statTestName=cell(1,handles.len);
handles.multiCorr=zeros(1,handles.len);
handles.multiCorrName=cell(1,handles.len);
handles.thecut=zeros(1,handles.len);
handles.tf=zeros(1,handles.len);
handles.stf=zeros(1,handles.len);
handles.controlIndices=cell(1,handles.len);
handles.treatedIndices=cell(1,handles.len);
handles.currentControl=cell(1,handles.len);
handles.currentTreated=cell(1,handles.len);
handles.currentFCListContents=cell(1,handles.len);

% Give initial values to current control and treated cells
handles.currentControl{1}=handles.condnames{1}{1};
handles.currentTreated{1}=handles.condnames{1}{1};

% Set Default output
handles.indices=1:handles.len;                        % Default statistical selection number of runs
for i=1:handles.len
    handles.scale{i}='mad';                           % Perform MAD centering by default
    handles.scaleName{i}='MAD';                       % If performed MAD or not
    handles.impute{i}='conditionmean';                % Default imputation method, means
    handles.imputeName{i}='Average within condition'; % its name
    handles.imputeBefOrAft(i)=2;                      % Impute missing values AFTER MAD
    handles.imputeBefOrAftName{i}='After scaling';    % A name for the impitation process
    handles.statTest(i)=2;                            % ANOVA by default
    handles.statTestName{i}='1-way ANOVA';            % Default name
    handles.multiCorr(i)=1;                           % No multiple correction testing by default
    handles.multiCorrName{i}='None';                  % Default name
    handles.thecut(i)=0.05;                           % Default p-value or FDR threshold output
    handles.tf(i)=0.6;                                % Default value for the Trust Factor cutoff
    %handles.stf(i)=1;                                 % Default value for the Trust Factor srict cutoff
end
handles.cancel=false;                                 % Cancel is not pressed

% In case of Affymetrix or Illumina, deactivate scaling between arrays, already done
if soft==99 || soft==99
    set(handles.text9,'Enable','off')
    set(handles.scaleMethodPopup,'Enable','off')
    set(handles.beforeScaling,'Enable','off')
    set(handles.afterScaling,'Enable','off')
    for i=1:handles.len
        handles.scale{i}='none';
        handles.scaleName{i}='None';
    end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StatisticalSelectionBatchEditor wait for user response (see UIRESUME)
uiwait(handles.StatisticalSelectionBatchEditor);


% --- Outputs from this function are returned to the command line.
function varargout = StatisticalSelectionBatchEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.StatisticalSelectionBatchEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.StatisticalSelectionBatchEditor);
end

varargout{1}=handles.scale;
varargout{2}=handles.scaleOpts;
varargout{3}=handles.scaleName;
varargout{4}=handles.impute;
varargout{5}=handles.imputeOpts;
varargout{6}=handles.imputeName;
varargout{7}=handles.imputeBefOrAft;
varargout{8}=handles.imputeBefOrAftName;
varargout{9}=handles.statTest;
varargout{10}=handles.statTestName;
varargout{11}=handles.multiCorr;
varargout{12}=handles.multiCorrName;
varargout{13}=handles.thecut;
varargout{14}=handles.tf;
varargout{15}=handles.stf;
varargout{16}=handles.controlIndices;
varargout{17}=handles.treatedIndices;
varargout{18}=handles.cancel;


% --- Executes on selection change in analysisList.
function analysisList_Callback(hObject, eventdata, handles)

ind=get(hObject,'Value');
handles.currentSelection=ind;

% Fix when t-test should not be available
if handles.nocond(ind)==1
    set(handles.statTestPopup,'String','t-test','Value',1)
    handles.statTest=2;
    handles.statTestName={'t-test'};
elseif handles.nocond(ind)==2
    z=strmatch('t-test',get(handles.statTestPopup,'String'));
    if isempty(z)
        newstr=get(handles.statTestPopup,'String');
        newstr=[newstr;'t-test'];
        set(handles.statTestPopup,'String',newstr)
    end
else
    newstr=get(handles.statTestPopup,'String');
    z=strmatch('t-test',newstr);
    if ~isempty(z)
        newstr(z)=[];
        set(handles.statTestPopup,'String',newstr)
    end
end
guidata(hObject,handles);

% Recall the setings for each analysis
set(handles.tfCut,'String',num2str(handles.tf(ind)))
set(handles.controlPopup,'String',handles.condnames{ind},'Value',1);
set(handles.treatedPopup,'String',handles.condnames{ind},'Value',1);
set(handles.FCList,'String',handles.currentFCListContents{ind},...
                   'Max',length(handles.currentFCListContents{ind}))
cstr=get(handles.controlPopup,'String');
tstr=get(handles.treatedPopup,'String');
handles.currentControl{ind}=cstr{get(handles.controlPopup,'Value')};
handles.currentTreated{ind}=tstr{get(handles.treatedPopup,'Value')};

if strcmp(handles.scale(ind),'mad')
    set(handles.scaleMethodPopup,'Value',1)
    set(handles.beforeScaling,'Enable','on')
    set(handles.afterScaling,'Enable','on')
elseif strcmp(handles.scale(ind),'quantile')
    set(handles.scaleMethodPopup,'Value',2)
    set(handles.beforeScaling,'Enable','on')
    set(handles.afterScaling,'Enable','on')
elseif strcmp(handles.scale(ind),'none')
    set(handles.scaleMethodPopup,'Value',3)
    set(handles.beforeScaling,'Enable','off')
    set(handles.afterScaling,'Enable','off')
end
if strcmp(handles.impute(ind),'conditionmean')
    set(handles.missingPopup,'Value',1)
elseif strcmp(handles.impute(ind),'knn')
    set(handles.missingPopup,'Value',2)
end
if handles.imputeBefOrAft(ind)==1
    set(handles.beforeScaling,'Value',1)
    set(handles.afterScaling,'Value',0)
elseif handles.imputeBefOrAft(ind)==2
    set(handles.beforeScaling,'Value',0)
    set(handles.afterScaling,'Value',1)
end
if handles.stf(ind)
    set(handles.stfPopup,'Value',2)
else
    set(handles.stfPopup,'Value',1)
end
switch handles.statTest(ind)
    case 1 % Kruskal-Wallis
        set(handles.statTestPopup,'Value',2)
    case 2 % ANOVA
        set(handles.statTestPopup,'Value',1)
    case 3 %t-test
        set(handles.statTestPopup,'Value',3)
end
switch handles.multiCorr(ind)
    case 1 % None
        set(handles.pvalStatic,'Enable','on')
        set(handles.FDRStatic,'Enable','off')
        set(handles.pvalThresh,'Enable','on','String',num2str(handles.thecut(ind)))
        set(handles.FDRThresh,'Enable','off')
        set(handles.multiCorrPopup,'Value',1)
    case 2 % Bonferroni
        set(handles.pvalStatic,'Enable','on')
        set(handles.FDRStatic,'Enable','off')
        set(handles.pvalThresh,'Enable','on','String',num2str(handles.thecut(ind)))
        set(handles.FDRThresh,'Enable','off')
        set(handles.multiCorrPopup,'Value',2)
    case 3 % Benjamini-Hochberg
        set(handles.pvalStatic,'Enable','off')
        set(handles.FDRStatic,'Enable','on')
        set(handles.pvalThresh,'Enable','off')
        set(handles.FDRThresh,'Enable','on','String',num2str(handles.thecut(ind)))
        set(handles.multiCorrPopup,'Value',3)
    case 4 % Storey pFDR Bootstrap
        handles.multiCorr(ind)=4;
        set(handles.pvalStatic,'Enable','off')
        set(handles.FDRStatic,'Enable','on')
        set(handles.pvalThresh,'Enable','off')
        set(handles.FDRThresh,'Enable','on','String',num2str(handles.thecut(ind)))
        set(handles.multiCorrPopup,'Value',4)
    case 5 % Storey pFDR Polynomial
        set(handles.pvalStatic,'Enable','off')
        set(handles.FDRStatic,'Enable','on')
        set(handles.pvalThresh,'Enable','off')
        set(handles.FDRThresh,'Enable','on','String',num2str(handles.thecut(ind)))
        set(handles.multiCorrPopup,'Value',5)
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function analysisList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in missingPopup.
function missingPopup_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
mismet=get(hObject,'Value');
mismetnames=get(hObject,'String');
switch mismet
    case 1
        handles.impute(ind)={'conditionmean'}; % Means
        handles.imputeName(ind)=mismetnames(1);
    case 2
        handles.impute(ind)={'knn'}; % kNN
        handles.imputeName(ind)=mismetnames(2);

        % Now we have to call the external editor to get kNN parameters
        [out,cancel]=kNNImputeProps(handles.noarr,handles.imputeOpts(ind));

        if ~cancel
            handles.imputeOpts{ind}=out;
        end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function missingPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tfCut_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
tf=str2double(get(hObject,'String'));
if isnan(tf) || tf<0 || tf>1
    uiwait(errordlg('You must enter a number between 0 and 1','Bad Input','modal'));
    set(hObject,'String','0.6');
    handles.tf(ind)=0.6; % Back to the default
else
    handles.tf(ind)=tf;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function tfCut_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stfPopup.
function stfPopup_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    if get(hObject,'Value')==1
        handles.stf(inds)=0;
    elseif get(hObject,'Value')==2
        handles.stf(inds)=1;
    end
end
guidata(hObject,handles);


% --- Executes on selection change in scaleMethodPopup.
function scaleMethodPopup_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
scamet=get(hObject,'Value');
scametnames=get(hObject,'String');
switch scamet
    case 1
        handles.scale(ind)={'mad'}; % MAD
        handles.scaleName(ind)=scametnames(1);
        set(handles.beforeScaling,'Enable','on')
        set(handles.afterScaling,'Enable','on')
    case 2
        handles.scale(ind)={'quantile'}; % Quantile
        handles.scaleName(ind)=scametnames(2);
        set(handles.beforeScaling,'Enable','on')
        set(handles.afterScaling,'Enable','on')

        % Now we have to call the external editor to get Quantile parameters
        [out,cancel]=QuantileProps(handles.scaleOpts(ind));

        if ~cancel
            for i=1:length(ind)
                handles.scaleOpts{ind(i)}=out;
            end
        end
    case 3
        handles.scale(ind)={'none'}; % None
        handles.scaleName(ind)=scametnames(3);
        set(handles.beforeScaling,'Enable','off')
        set(handles.afterScaling,'Enable','off')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function scaleMethodPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in beforeScaling.
function beforeScaling_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
if get(hObject,'Value')==1
    handles.imputeBefOrAft(ind)=1;
    handles.imputeBefOrAftName(ind)={'Before scaling'};
else
    handles.imputeBefOrAft(ind)=2;
    handles.imputeBefOrAftName(ind)={'After scaling'};
end
guidata(hObject,handles);


% --- Executes on button press in afterScaling.
function afterScaling_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
if get(hObject,'Value')==1
    handles.imputeBefOrAft(ind)=2;
    handles.imputeBefOrAftName(ind)={'After scaling'};
else
    handles.imputeBefOrAft(ind)=1;
    handles.imputeBefOrAftName(ind)={'Before scaling'};
end
guidata(hObject,handles);


% --- Executes on selection change in statTestPopup.
function statTestPopup_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
statest=get(hObject,'Value');
statestnames=get(hObject,'String');
if handles.nocond(ind)==1
    handles.statTest(ind)=3; % t-test, we have 1 condition (is t-test anyway...)
    handles.statTestName(ind)={'t-test'};
else
    switch statest
        case 1
            handles.statTest(ind)=2; % ANOVA
            handles.statTestName(ind)=statestnames(1);
        case 2
            handles.statTest(ind)=1; % Kruskal-Wallis
            handles.statTestName(ind)=statestnames(2);
        case 3
            handles.statTest(ind)=3; % t-test (only if we have 2 conditions!)
            handles.statTestName(ind)=statestnames(3);
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function statTestPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in multiCorrPopup.
function multiCorrPopup_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
multicorr=get(hObject,'Value');
mutlicorrnames=get(hObject,'String');
switch multicorr
    case 1
        handles.multiCorr(ind)=1; % None
        handles.multiCorrName(ind)=mutlicorrnames(1);
        set(handles.pvalStatic,'Enable','on')
        set(handles.FDRStatic,'Enable','off')
        set(handles.pvalThresh,'Enable','on')
        set(handles.FDRThresh,'Enable','off')
    case 2
        handles.multiCorr(ind)=2; % Bonferroni
        handles.multiCorrName(ind)=mutlicorrnames(2);
        set(handles.pvalStatic,'Enable','on')
        set(handles.FDRStatic,'Enable','off')
        set(handles.pvalThresh,'Enable','on')
        set(handles.FDRThresh,'Enable','off')
    case 3
        handles.multiCorr(ind)=3; % Benjamini-Hochberg FDR
        handles.multiCorrName(ind)=mutlicorrnames(3);
        set(handles.pvalStatic,'Enable','off')
        set(handles.FDRStatic,'Enable','on')
        set(handles.pvalThresh,'Enable','off')
        set(handles.FDRThresh,'Enable','on')
    case 4
        handles.multiCorr(ind)=4; % Storey pFDR Bootstrap
        handles.multiCorrName(ind)=mutlicorrnames(4);
        set(handles.pvalStatic,'Enable','off')
        set(handles.FDRStatic,'Enable','on')
        set(handles.pvalThresh,'Enable','off')
        set(handles.FDRThresh,'Enable','on')
    case 5
        handles.multiCorr(ind)=5; % Storey pFDR Polynomial
        handles.multiCorrName(ind)=mutlicorrnames(5);
        set(handles.pvalStatic,'Enable','off')
        set(handles.FDRStatic,'Enable','on')
        set(handles.pvalThresh,'Enable','off')
        set(handles.FDRThresh,'Enable','on')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function multiCorrPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pvalThresh_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || val>1
    uiwait(errordlg('You must enter a number between 0 and 1!','Bad Input','modal'));
    set(hObject,'String','0.05')
    handles.thecut(ind)=str2double(get(hObject,'String'));
else
    handles.thecut(ind)=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function pvalThresh_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FDRThresh_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || val>1
    uiwait(errordlg('You must enter a number between 0 and 1!','Bad Input','modal'));
    set(hObject,'String','0.05')
    handles.thecut(ind)=str2double(get(hObject,'String'));
else
    handles.thecut(ind)=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function FDRThresh_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in controlPopup.
function controlPopup_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
val=get(hObject,'Value');
conts=get(hObject,'String');
handles.currentControl{ind}=conts{val};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function controlPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in treatedPopup.
function treatedPopup_Callback(hObject, eventdata, handles)

ind=handles.currentSelection;
val=get(hObject,'Value');
conts=get(hObject,'String');
handles.currentTreated{ind}=conts{val};
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function treatedPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FCList.
function FCList_Callback(hObject, eventdata, handles)

if ~isempty(get(hObject,'String'))
    set(handles.removeFCButton,'Enable','on')
else
    set(handles.removeFCButton,'Enable','off')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function FCList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addFCButton.
function addFCButton_Callback(hObject, eventdata, handles)

% Get current index
ind=handles.currentSelection;

% Get the wanted indices
indControl=strmatch(handles.currentControl{ind},handles.condnames{ind});
indTreated=strmatch(handles.currentTreated{ind},handles.condnames{ind});
handles.controlIndices{ind}=[handles.controlIndices{ind} indControl];
handles.treatedIndices{ind}=[handles.treatedIndices{ind} indTreated];

% Update the list of calculations
oldstr=get(handles.FCList,'String');
p1=['FC is: ',handles.condnames{ind}{indTreated},'/',handles.condnames{ind}{indControl}];
newstr=[oldstr;{p1}];
set(handles.FCList,'String',newstr,'Max',length(newstr))
set(handles.removeFCButton,'Enable','on')

% Update the content of the current list object
handles.currentFCListContents{ind}=newstr;

% Update handles structure
guidata(hObject,handles);


% --- Executes on button press in removeFCButton.
function removeFCButton_Callback(hObject, eventdata, handles)

% Get current index
ind=handles.currentSelection;

% Get indices to remove
reminds=get(handles.FCList,'Value');
str=get(handles.FCList,'String');

% Update condition indices
handles.controlIndices{ind}(reminds)=[];
handles.treatedIndices{ind}(reminds)=[];
str(reminds)=[];

% Update list
set(handles.FCList,'String',str,'Value',1,'Max',length(str))

% Update the content of the current list object
handles.currentFCListContents{ind}=str;

% Check if empty so as to disable remove button
if isempty(get(handles.FCList,'String'))
    set(hObject,'Enable','off')
end

% Update handles structure
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.StatisticalSelectionBatchEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
handles.indices=1:handles.len;
for i=1:handles.len
    handles.scale{i}='mad';
    handles.scaleName{i}='MAD';
    handles.impute{i}='conditionmean';
    handles.imputeName{i}='Average within condition';
    handles.imputeBefOrAft(i)=2;
    handles.imputeBefOrAftName{i}='After scaling'; 
    handles.statTest(i)=2;
    handles.statTestName{i}='1-way ANOVA';
    handles.multiCorr(i)=1;
    handles.multiCorrName{i}='None';
    handles.thecut(i)=0.05;
    handles.tf(i)=0.6;
    handles.stf(i)=0;
end
handles.scaleOpts=cell(1,3);
handles.imputeOpts=cell(1,3);
handles.cancel=true; % Cancel pressed
guidata(hObject,handles);
uiresume(handles.StatisticalSelectionBatchEditor);

