function varargout = ExternalImportEditor(varargin)
% EXTERNALIMPORTEDITOR M-file for ExternalImportEditor.fig
%      EXTERNALIMPORTEDITOR, by itself, creates a new EXTERNALIMPORTEDITOR or raises the existing
%      singleton*.
%
%      H = EXTERNALIMPORTEDITOR returns the handle to a new EXTERNALIMPORTEDITOR or the handle to
%      the existing singleton*.
%
%      EXTERNALIMPORTEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXTERNALIMPORTEDITOR.M with the given input arguments.
%
%      EXTERNALIMPORTEDITOR('Property','Value',...) creates a new EXTERNALIMPORTEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExternalImportEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExternalImportEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExternalImportEditor

% Last Modified by GUIDE v2.5 21-Nov-2007 11:55:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExternalImportEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @ExternalImportEditor_OutputFcn, ...
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


% --- Executes just before ExternalImportEditor is made visible.
function ExternalImportEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.ExternalImportEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.ExternalImportEditor,'Position',winpos);

% Get inputs
handles.colNames=varargin{1};
set(handles.columnPopup,'String',sort(handles.colNames))

% Set default outputs
handles.nocond=[];        % Number of conditions
handles.condNames=[];     % Condition names
handles.exprp=[];         % exprp
handles.inten=[];         % Intensity columns
handles.datatable=[];     % Datatable
handles.normalized=false; % Un-normalized data
handles.measures='rri';   % Raw ratio-intensity pairs by default (rri,lri,rr,lr)
handles.howmanyann=0;    % How many more annotattion columns apart from the IDs
handles.cancel=false;     % User did not press cancel

% Asssign some internal use variables
handles.condSet=false;
handles.condStateChanged=false;
handles.condStateTimes=0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ExternalImportEditor wait for user response (see UIRESUME)
uiwait(handles.ExternalImportEditor);


% --- Outputs from this function are returned to the command line.
function varargout = ExternalImportEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.ExternalImportEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.ExternalImportEditor);
end

varargout{1}=handles.nocond;
varargout{2}=handles.condNames;
varargout{3}=handles.exprp;
varargout{4}=handles.inten;
varargout{5}=handles.datatable;
varargout{6}=handles.normalized;
varargout{7}=handles.measures;
varargout{8}=handles.howmanyann;
varargout{9}=handles.cancel;


function numberCondEdit_Callback(hObject, eventdata, handles)

% nocond=str2double(get(hObject,'String'));
% if isnan(nocond) || nocond<=0 || mod(nocond,1)>0
%     uiwait(errordlg('You must enter a positive integer','Bad Input','modal'));
%     set(hObject,'String',num2str(length(handles.condNames)));
%     handles.nocond=str2double(get(hObject,'String'));
%     handles.condIndex=1:handles.nocond;
%     handles.exprp=cell(1,handles.nocond);
%     handles.inten=cell(1,handles.nocond);
% else
%     handles.nocond=nocond;
%     handles.condIndex=1:handles.nocond;
%     handles.exprp=cell(1,handles.nocond);
%     handles.inten=cell(1,handles.nocond);
% end
% guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function numberCondEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function namesCondEdit_Callback(hObject, eventdata, handles)

condnames=cellstr(get(hObject,'String'));
% if ~isempty(handles.nocond)
%     if handles.nocond~=length(condnames) || isempty(char(condnames))
%         uiwait(errordlg('The number of names specified must be equal to the number of conditions',...
%                         'Bad Input','modal'));
%         def=createConditionNames(handles.nocond);
%         set(hObject,'String',def);
%         handles.condNames=cellstr(get(hObject,'String'))';
%     else
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
% In the case where user restarts condition list
if isempty(condnames)
    set(handles.addRatio,'Enable','off')
    set(handles.removeRatio,'Enable','off')
    set(handles.addIntensity,'Enable','off')
    set(handles.removeIntensity,'Enable','off')
    set(handles.ratStatic,'Enable','off')
    set(handles.ratList,'Enable','off')
    set(handles.intenStatic,'Enable','off')
    set(handles.intenList,'Enable','off')
    handles.condStateTimes=0;
    set(handles.columnPopup,'String',sort(handles.colNames));
    handles.condSet=false;
    return
end
% In case user adds/removes from condition list - restart assigning
if handles.condStateTimes>0 && (length(condnames)~=length(handles.condNames) || ~all(strcmp(condnames,handles.condNames)))
    wmsg1={'You have made changes to condition names.',...
           'Column assignment will be restarted.'};
    uiwait(warndlg(wmsg1,'Warning','modal'));
    set(handles.columnPopup,'String',sort(handles.colNames))
    handles.condStateTimes=handles.condStateTimes+1;
end
handles.condNames=condnames';
%     end
% else
%     handles.condNames=condnames';
% end
handles.nocond=length(handles.condNames);
handles.condIndex=1:handles.nocond;
handles.exprp=cell(1,handles.nocond);
handles.inten=cell(1,handles.nocond);
set(handles.condList,'String',handles.condNames,'Max',1)
set(handles.addRatio,'Enable','on')
set(handles.ratStatic,'Enable','on')
set(handles.ratList,'Enable','on')
handles.condSet=true;
if get(handles.rawRatRadio,'Value')==1 || get(handles.logRatRadio,'Value')==1
    set(handles.addIntensity,'Enable','off')
    set(handles.intenStatic,'Enable','off')
    set(handles.intenList,'Enable','off')
else
    set(handles.addIntensity,'Enable','on')
    set(handles.intenStatic,'Enable','on')
    set(handles.intenList,'Enable','on')
end
handles.condStateTimes=handles.condStateTimes+1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function namesCondEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in unnormRadio.
function unnormRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.rawRatRadio,'Enable','off')
    set(handles.logRatRadio,'Enable','off')
    handles.normalized=false;
end
guidata(hObject,handles);


% --- Executes on button press in normRadio.
function normRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.rawRatRadio,'Enable','on')
    set(handles.logRatRadio,'Enable','on')
    handles.normalized=true;
end
guidata(hObject,handles);
    
    
% --- Executes on button press in rawRatIntenRadio.
function rawRatIntenRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1 && handles.condSet
    set(handles.intenList,'Enable','on')
    set(handles.intenStatic,'Enable','on')
    set(handles.addIntensity,'Enable','on')
    if ~isempty(get(handles.intenList,'String'))
        set(handles.removeIntensity,'Enable','on')
    else
        set(handles.removeIntensity,'Enable','off')
    end
    handles.measures='rri';
end
guidata(hObject,handles);


% --- Executes on button press in logRatIntenRadio.
function logRatIntenRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1 && handles.condSet
    set(handles.intenList,'Enable','on')
    set(handles.intenStatic,'Enable','on')
    set(handles.addIntensity,'Enable','on')
    if ~isempty(get(handles.intenList,'String'))
        set(handles.removeIntensity,'Enable','on')
    else
        set(handles.removeIntensity,'Enable','off')
    end
    handles.measures='lri';
end
guidata(hObject,handles);


% --- Executes on button press in rawRatRadio.
function rawRatRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.intenList,'Enable','off')
    set(handles.intenStatic,'Enable','off')
    set(handles.addIntensity,'Enable','off')
    set(handles.removeIntensity,'Enable','off')
    handles.measures='rr';
end
guidata(hObject,handles);


% --- Executes on button press in logRatRadio.
function logRatRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.intenList,'Enable','off')
    set(handles.intenStatic,'Enable','off')
    set(handles.addIntensity,'Enable','off')
    set(handles.removeIntensity,'Enable','off')
    handles.measures='lr';
end
guidata(hObject,handles);


% --- Executes on selection change in columnPopup.
function columnPopup_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function columnPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in condList.
function condList_Callback(hObject, eventdata, handles)

% Recreate the contents of ratio list
val=get(hObject,'Value');
currreps=handles.exprp{val}(:);
set(handles.ratList,'String',currreps,'Value',1)
if ~isempty(currreps)
    set(handles.removeRatio,'Enable','on')
else
    set(handles.removeRatio,'Enable','off')
end

if strcmp(get(handles.intenList,'Enable'),'on')
    currintens=handles.inten{val}(:);
    set(handles.intenList,'String',currintens,'Value',1)
    if ~isempty(currintens)
        set(handles.removeIntensity,'Enable','on')
    else
        set(handles.removeIntensity,'Enable','off')
    end
end


% --- Executes during object creation, after setting all properties.
function condList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ratList.
function ratList_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ratList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in intenList.
function intenList_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function intenList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addRatio.
function addRatio_Callback(hObject, eventdata, handles)

% Get necessary variables in order to fill ratio list
colstr=get(handles.columnPopup,'String');
colval=get(handles.columnPopup,'Value');
condval=get(handles.condList,'Value');
currcol=colstr{colval};
currrat=get(handles.ratList,'String');

% Fill ratio list
if isempty(currrat)
    currrat={currcol};
else
    currrat=[currrat;currcol];
end
set(handles.ratList,'String',currrat)

% Remove selected column from columns list
colstr(colval)=[];
if colval==length(colstr)+1;
    newval=length(colstr);
elseif colval==1;
    if length(colstr)==2
        newval=colval+1;
    else
        newval=1;
    end
else
    newval=colval;
end
set(handles.columnPopup,'String',colstr,'Value',newval)

% Update exprp
listlen=length(get(handles.ratList,'String'));
handles.exprp{condval}{listlen}=currcol;

% Perform a check if the columns list contains only one column (which should be the
% annotation) and if yes disable add
if length(get(handles.columnPopup,'String'))==1
    set(hObject,'Enable','off')
    set(handles.addIntensity,'Enable','off')
end

% Enable remove button if inactive
if strcmp(get(handles.removeRatio,'Enable'),'off')
    set(handles.removeRatio,'Enable','on')
end

% Check if we have to enable/disable the import button:conflag
empties=zeros(1,handles.nocond);
for i=1:length(handles.exprp)
    if ~isempty(handles.exprp{i})
        empties(i)=1;
    end
end
if ~any(empties==0)
    set(handles.okButton,'Enable','on')
else
    set(handles.okButton,'Enable','off')
end
    
guidata(hObject,handles);


% --- Executes on button press in removeRatio.
function removeRatio_Callback(hObject, eventdata, handles)

% Get some input values
currstr=get(handles.ratList,'String');
currval=get(handles.ratList,'Value');
currcond=get(handles.condList,'Value');

% Update string in list
newstr=currstr;
remstr=currstr{currval};
newstr(currval)=[];
if currval==length(currstr)
    newval=currval-1;
elseif currval==1
    if length(newstr)==2
        newval=currval+1;
    else
        newval=1;
    end
else
    newval=currval;
end
if isempty(newstr)
    newval=1;
end    
set(handles.ratList,'String',newstr,'Value',newval)

% Put the removed string back in the columns list
colstr=get(handles.columnPopup,'String');
colstr=[colstr;remstr];
set(handles.columnPopup,'String',sort(colstr))

% Update the exprp
handles.exprp{currcond}(currval)=[];

% Perform a check if the columns list contains only more than one column (which should be
% the annotation) and if yes enable add
if length(get(handles.columnPopup,'String'))>1
    set(handles.addRatio,'Enable','on')
end

% If the ratio list is empty, disable remove button
if isempty(newstr)
    set(hObject,'Enable','off')
end

% Check if we have to enable/disable the import button
empties=zeros(1,handles.nocond);
for i=1:length(handles.exprp)   
    if ~isempty(handles.exprp{i})
        empties(i)=1;
    end
end
if ~any(empties==0)
    set(handles.okButton,'Enable','on')
else
    set(handles.okButton,'Enable','off')
end

guidata(hObject,handles);


% --- Executes on button press in addIntensity.
function addIntensity_Callback(hObject, eventdata, handles)

% Get necessary variables in order to fill intensity list
colstr=get(handles.columnPopup,'String');
colval=get(handles.columnPopup,'Value');
condval=get(handles.condList,'Value');
currcol=colstr{colval};
currinten=get(handles.intenList,'String');

% Fill intensity list
if isempty(currinten)
    currinten={currcol};
else
    currinten=[currinten;currcol];
end
set(handles.intenList,'String',currinten)

% Remove selected column from columns list
colstr(colval)=[];
if colval==length(colstr)+1;
    newval=length(colstr);
elseif colval==1;
    if length(colstr)==2
        newval=colval+1;
    else
        newval=1;
    end
else
    newval=colval;
end
set(handles.columnPopup,'String',colstr,'Value',newval)

% Update intensity list
listlen=length(get(handles.intenList,'String'));
handles.inten{condval}{listlen}=currcol;

% Perform a check if the columns list contains only one column (which should be the
% annotation) and if yes disable add
if length(get(handles.columnPopup,'String'))==1
    set(hObject,'Enable','off')
    set(handles.addRatio,'Enable','off')
end

% Enable remove button if inactive
if strcmp(get(handles.removeIntensity,'Enable'),'off')
    set(handles.removeIntensity,'Enable','on')
end

guidata(hObject,handles);


% --- Executes on button press in removeIntensity.
function removeIntensity_Callback(hObject, eventdata, handles)

% Get some input values
currstr=get(handles.intenList,'String');
currval=get(handles.intenList,'Value');
currcond=get(handles.condList,'Value');

% Update string in list
newstr=currstr;
remstr=currstr{currval};
newstr(currval)=[];
if currval==length(currstr)
    newval=currval-1;
elseif currval==1
    if length(newstr)==2
        newval=currval+1;
    else
        newval=1;
    end
else
    newval=currval;
end
if isempty(newstr)
    newval=1;
end    
set(handles.intenList,'String',newstr,'Value',newval)

% Put the removed string back in the columns list
colstr=get(handles.columnPopup,'String');
colstr=[colstr;remstr];
set(handles.columnPopup,'String',sort(colstr))

% Update the intensity list
handles.inten{currcond}(currval)=[];

% Perform a check if the columns list contains only more than one column (which should be
% the annotation) and if yes enable add
if length(get(handles.columnPopup,'String'))>1
    set(handles.addIntensity,'Enable','on')
end

% If the intensity list is empty, disable remove button
if isempty(newstr)
    set(hObject,'Enable','off')
end

guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

% Check if exprp and inten have the same sizes in case of both selected
if get(handles.rawRatIntenRadio,'Value')==1 || get(handles.logRatIntenRadio,'Value')==1
    allok=ones(1,length(handles.exprp));
    for i=1:length(handles.exprp)
        if length(handles.exprp{i})~=length(handles.inten{i})
            allok(i)=0;
        end
    end
    if ~all(allok)
        errmsg={'The ratio columns must be exactly paired with intensity columns.',...
                'Please review your selections and make sure that the number of',...
                'ratio columns is the same as the intensity columns.'};
        uiwait(errordlg(errmsg,'Bad Input'));
        return
    end
end

% Create datatable
for i=1:length(handles.exprp)
    for j=1:length(handles.exprp{i})
        handles.datatable{j,i}=handles.exprp{i}{j};
    end
end
% How many annotation columns left
strleft=get(handles.columnPopup,'String');
handles.howmanyann=length(strleft);
guidata(hObject,handles);
uiresume(handles.ExternalImportEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Restore defaults
handles.nocond=[];
handles.condNames=[];
handles.exprp=[];
handles.inten=[];
handles.datatable=[];
handles.normalized=false;
handles.measures='rri';
handles.howmanyann=0;
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.ExternalImportEditor);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   HELP FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function con = createConditionNames(t)
% 
% pref='Condition ';
% con=cell(t,1);
% for i=1:t
%     con{i}=strcat(pref,num2str(i));
% end


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

