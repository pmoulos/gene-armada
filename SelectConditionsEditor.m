function varargout = SelectConditionsEditor(varargin)
% SELECTCONDITIONSEDITOR M-file for SelectConditionsEditor.fig
%      SELECTCONDITIONSEDITOR, by itself, creates a new SELECTCONDITIONSEDITOR or raises the existing
%      singleton*.
%
%      H = SELECTCONDITIONSEDITOR returns the handle to a new SELECTCONDITIONSEDITOR or the handle to
%      the existing singleton*.
%
%      SELECTCONDITIONSEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTCONDITIONSEDITOR.M with the given input arguments.
%
%      SELECTCONDITIONSEDITOR('Property','Value',...) creates a new SELECTCONDITIONSEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectConditionsEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectConditionsEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectConditionsEditor

% Last Modified by GUIDE v2.5 18-May-2007 15:26:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectConditionsEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectConditionsEditor_OutputFcn, ...
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


% --- Executes just before SelectConditionsEditor is made visible.
function SelectConditionsEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.SelectConditionsEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.SelectConditionsEditor,'Position',winpos);

% Get data for listboxes
handles.conditionNames=varargin{1};
handles.exprp=varargin{2};
preproDone=varargin{3};

% Set repeat state and listbox contents
if ~preproDone
    set(handles.repeatPreprocess,'Enable','off')
end
set(handles.conditionList,'String',handles.conditionNames')
handles.repliNames=cell(max(size(handles.exprp{1})),1);
for i=1:max(size(handles.exprp{1}))
    handles.repliNames{i}=handles.exprp{1}{i};
end
set(handles.replicateList,'String',handles.repliNames','Max',length(handles.repliNames))
temp=zeros(1,length(handles.conditionNames));
for i=1:length(handles.conditionNames)
    temp(i)=max(size(handles.exprp{i}));
end
set(handles.chosenReplicateList,'Value',1,'Max',max(temp))

% Choose default command line output for SelectConditionsEditor
handles.repeat=0;                                  % Do not repeat preprocessing steps
handles.newConditions=handles.conditionNames;      % Default output all conditions
defReps=cell(1,length(handles.conditionNames));
for i=1:length(handles.conditionNames)
    defReps{i}=1:max(size(handles.exprp{i}));
end
handles.newReplicates=defReps;                     % Default output all replicates
handles.newExprp=handles.exprp;                    % Default exprp
handles.newNumber=length(handles.conditionNames);  % Default number of conditions
handles.newIndex=1:length(handles.conditionNames); % Default index of conditions
handles.takeAllReps=0;                             % By default do not take all replicates for
                                                   % each conditions if user acts
handles.cancel=false;                              % Do not proceed to normalization if 
                                                   % cancel is pressed

% Initialize temporary variables for selected conditions in the case of not taking all the
% replicates for each condition. When OK is pressed, if they are not empty,
% handloes.newSomething variables take these values, else the defaults
handles.tempNewNumber=0;
handles.tempNewIndex=[];
handles.tempNewConditions={};
handles.tempNewReplicates={};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectConditionsEditor wait for user response (see UIRESUME)
uiwait(handles.SelectConditionsEditor);


% --- Outputs from this function are returned to the command line.
function varargout = SelectConditionsEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.SelectConditionsEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.SelectConditionsEditor);
end

% Get default command line output from handles structure
varargout{1}=handles.repeat;
varargout{2}=handles.newNumber;     % New number of conditions
varargout{3}=handles.newIndex;      % New index of condition names
varargout{4}=handles.newConditions; % New condition names
varargout{5}=handles.newReplicates; % New indices of replicates
varargout{6}=handles.newExprp;      % New exprp output
varargout{7}=handles.cancel;        % If user presses cancel 


% --- Executes on button press in repeatPreprocess.
function repeatPreprocess_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.repeat=1;
else
    handles.repeat=0;
end
guidata(hObject,handles);


% --- Executes on button press in selectAllReplicates.
function selectAllReplicates_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.text2,'Enable','off')
    set(handles.conditionList,'Max',length(handles.conditionNames))
    set(handles.replicateList,'String',' ','Value',1,'Enable','off',...
                              'BackgroundColor',[235/255 233/255 237/255])
    set(handles.text3,'Enable','off')
    set(handles.chosenReplicateList,'String',' ','Value',1,'Enable','off',...
                                    'BackgroundColor',[235/255 233/255 237/255])
    set(handles.addReplicate,'Enable','off')
    set(handles.removeReplicate,'Enable','off')
    handles.takeAllReps=1;
else
    set(handles.text2,'Enable','on')
    set(handles.conditionList,'Value',1)
    set(handles.conditionList,'Max',1)
    set(handles.replicateList,'Enable','on','String',handles.repliNames,...
                              'BackgroundColor','white')
    set(handles.text3,'Enable','on')
    set(handles.chosenReplicateList,'String',' ','Enable','on',...
                                    'BackgroundColor','white')
    set(handles.addReplicate,'Enable','on')
    % set(handles.removeReplicate,'Enable','on')
    handles.takeAllReps=0;
end
guidata(hObject,handles);


% --- Executes on selection change in conditionList.
function conditionList_Callback(hObject, eventdata, handles)

selected=get(hObject,'Value');
allItems=get(hObject,'String');
set(handles.replicateList,'Value',1) % Avoid leave previous selections highlighted
if ~handles.takeAllReps
    corrReps=cell(max(size(handles.exprp{selected})),1);
    for i=1:max(size(handles.exprp{selected}))
        corrReps{i}=handles.exprp{selected}{i};
    end
    set(handles.replicateList,'String',corrReps)
    set(handles.chosenReplicateList,'String','')
    [mbr,loc]=ismember(selected,handles.tempNewIndex);
    if mbr
        selRepsInd=handles.tempNewReplicates{loc};
        if ~isempty(selRepsInd)
            selReps=handles.exprp{selected}(selRepsInd);
            set(handles.chosenReplicateList,'String',selReps)
        end
    end
else
    handles.newNumber=length(selected);
    handles.newIndex=selected;
    handles.newConditions=allItems(selected)';
    defReps=cell(1,length(handles.conditionNames));
    for i=1:length(handles.conditionNames)
        defReps{i}=1:max(size(handles.exprp{i}));
    end
    handles.newReplicates=defReps(selected);
    handles.newExprp=handles.exprp(selected);
    set(handles.okButton,'Enable','on')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function conditionList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in replicateList.
function replicateList_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function replicateList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in chosenReplicateList.
function chosenReplicateList_Callback(hObject, eventdata, handles)

% If the list is not empty enable remove button
if ~isempty(get(hObject,'String'))
    set(handles.removeReplicate,'Enable','on')
end


% --- Executes during object creation, after setting all properties.
function chosenReplicateList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addReplicate.
function addReplicate_Callback(hObject, eventdata, handles)

% Do some preallocation
tempNames=cell(1,length(handles.conditionNames));
tempReps=cell(1,length(handles.conditionNames));

% Get some variables
allConds=get(handles.conditionList,'String');
allReps=get(handles.replicateList,'String');
selectedCond=get(handles.conditionList,'Value');
selectedReps=get(handles.replicateList,'Value');
selectedCondName=allConds(selectedCond);

% Do the job
oldstr=get(handles.chosenReplicateList,'String');
addstr=allReps(selectedReps);
verify=ismember(addstr,oldstr);
if isempty(oldstr)
    newstr=[oldstr;addstr];
elseif length(verify)==1
    if ~ismember(addstr,oldstr)
        newstr=[oldstr;addstr];
    else
        newstr=oldstr;
    end
elseif any(verify)
    newind=find(verify==0);
    newstr=[oldstr;addstr(newind)];
elseif ~all(verify)
    newstr=[oldstr;addstr];
else
    newstr=oldstr;
end
set(handles.chosenReplicateList,'String',newstr)

tempNames{selectedCond}=selectedCondName;
tempReps{selectedCond}=selectedReps;
[handles.tempNewNumber,handles.tempNewIndex,handles.tempNewConditions,...
 handles.tempNewReplicates]=updateCondsReps(handles.tempNewNumber,handles.tempNewIndex,...
 handles.tempNewConditions,handles.tempNewReplicates,tempNames,tempReps,1);

% Enable Remove and OK buttons
if handles.tempNewNumber~=0
    set(handles.removeReplicate,'Enable','on')
    set(handles.okButton,'Enable','on')
end

guidata(hObject,handles);

% disp('------------------------------')
% disp(handles.tempNewNumber)
% disp(handles.tempNewIndex)
% disp(handles.tempNewConditions)
% for i=1:length(handles.tempNewReplicates)
%     disp(handles.tempNewReplicates{i})
% end
% disp('------------------------------')
% disp(' ')

% --- Executes on button press in removeReplicate.
function removeReplicate_Callback(hObject, eventdata, handles)

% Do some preallocation
tempNames=cell(1,length(handles.conditionNames));
tempReps=cell(1,length(handles.conditionNames));

% Get some variables
allConds=get(handles.conditionList,'String');
selectedCond=get(handles.conditionList,'Value');
[mbr,loc]=ismember(selectedCond,handles.tempNewIndex);
selectedCondName=allConds(selectedCond);
selectedChosenRepsPre=get(handles.chosenReplicateList,'Value');
selectedChosenReps=handles.tempNewReplicates{loc}(selectedChosenRepsPre);

% Do the job
str=get(handles.chosenReplicateList,'String');
set(handles.chosenReplicateList,'Value',1)
str(selectedChosenRepsPre)=[];
set(handles.chosenReplicateList,'String',str)

% If the list is empty disable the Remove button
if isempty(get(handles.chosenReplicateList,'String'))
    set(handles.removeReplicate,'Enable','off')
end

tempNames{selectedCond}=selectedCondName;
tempReps{selectedCond}=selectedChosenReps;
[handles.tempNewNumber,handles.tempNewIndex,handles.tempNewConditions,...
 handles.tempNewReplicates]=updateCondsReps(handles.tempNewNumber,handles.tempNewIndex,...
 handles.tempNewConditions,handles.tempNewReplicates,tempNames,tempReps,0);

% If everything empty disable OK button
if handles.tempNewNumber==0
    set(handles.okButton,'Enable','off')
end

guidata(hObject,handles);

% disp('------------------------------')
% disp(handles.tempNewNumber)
% disp(handles.tempNewIndex)
% disp(handles.tempNewConditions)
% for i=1:length(handles.tempNewReplicates)
%     disp(handles.tempNewReplicates{i})
% end
% disp('------------------------------')
% disp(' ')


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

% Return the final values
if handles.tempNewNumber~=0 && ~handles.takeAllReps
    handles.newNumber=handles.tempNewNumber;
    handles.newIndex=handles.tempNewIndex;
    handles.newConditions=handles.tempNewConditions;
    handles.newReplicates=handles.tempNewReplicates;
    for i=1:length(handles.newIndex)
        handles.tempNewExprp{i}=handles.exprp{handles.newIndex(i)}(handles.newReplicates{i});
    end
    handles.newExprp=handles.tempNewExprp;
    guidata(hObject,handles);
end
uiresume(handles.SelectConditionsEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Resume default outputs
handles.repeat=0;
handles.newConditions=handles.conditionNames;
defReps=cell(1,length(handles.conditionNames));
for i=1:length(handles.conditionNames)
    defReps{i}=1:max(size(handles.exprp{i}));
end
handles.newReplicates=defReps;
handles.newNumber=length(handles.conditionNames);
handles.newIndex=1:length(handles.conditionNames);
handles.takeAllReps=0;
handles.cancel=true; % Cancel pressed
guidata(hObject,handles);
uiresume(handles.SelectConditionsEditor);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   HELP FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [newNumber,newIndex,newConditions,newReplicates] = updateCondsReps(newNumber,...
                                                                            newIndex,...
                                                                            newConditions,...
                                                                            newReplicates,...
                                                                            nams,reps,add)

% If add=1 then add to list else if add=0 remove from list
                                                                        
ind=newNumber;
if add
    for i=1:length(nams)
        if ~isempty(nams{i}) && ~isempty(reps{i})
            [mbr,loc]=ismember(nams{i},newConditions);
            if ~mbr
                newConditions=[newConditions,nams{i}];
                ind=ind+1;
                newNumber=ind;
                newIndex=[newIndex,i];
                newReplicates=[newReplicates,reps{i}];
            else
                if ~isempty(setdiff(reps{i},newReplicates{loc}))
                    newReplicates{loc}=union(reps{i},newReplicates{loc});
                end
            end
        end
    end
else
    for i=1:length(nams)
        if ~isempty(reps{i})
            [mbr,loc]=ismember(nams{i},newConditions);
            newreps=setdiff(newReplicates{loc},reps{i});
            if ~isempty(newreps)
                newReplicates{loc}=newreps;
            else
                newConditions(loc)=[];
                ind=ind-1;
                newNumber=ind;
                newIndex(loc)=[];
                newReplicates(loc)=[];
            end
        end
    end
end
