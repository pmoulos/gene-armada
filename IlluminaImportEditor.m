function varargout = IlluminaImportEditor(varargin)
% ILLUMINAIMPORTEDITOR M-file for IlluminaImportEditor.fig
%      ILLUMINAIMPORTEDITOR, by itself, creates a new ILLUMINAIMPORTEDITOR or raises the existing
%      singleton*.
%
%      H = ILLUMINAIMPORTEDITOR returns the handle to a new ILLUMINAIMPORTEDITOR or the handle to
%      the existing singleton*.
%
%      ILLUMINAIMPORTEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ILLUMINAIMPORTEDITOR.M with the given input arguments.
%
%      ILLUMINAIMPORTEDITOR('Property','Value',...) creates a new ILLUMINAIMPORTEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IlluminaImportEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IlluminaImportEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IlluminaImportEditor

% Last Modified by GUIDE v2.5 26-Oct-2009 19:18:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IlluminaImportEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @IlluminaImportEditor_OutputFcn, ...
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


% --- Executes just before IlluminaImportEditor is made visible.
function IlluminaImportEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IlluminaImportEditor (see VARARGIN)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.IlluminaImportEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.IlluminaImportEditor,'Position',winpos);

% Get inputs
handles.colNames=varargin{1};
set(handles.columnPopup,'String',sort(handles.colNames))

% Set default outputs
handles.nocond=[];    % Number of conditions
handles.condNames=[]; % Condition names
handles.exprp=[];     % exprp
handles.datatable=[]; % Datatable
handles.cancel=false; % User did not press cancel

% Asssign some internal use variables
handles.condSet=false;
handles.condStateChanged=false;
handles.condStateTimes=0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IlluminaImportEditor wait for user response (see UIRESUME)
uiwait(handles.IlluminaImportEditor);


% --- Outputs from this function are returned to the command line.
function varargout = IlluminaImportEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.IlluminaImportEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.IlluminaImportEditor);
end

varargout{1}=handles.nocond;
varargout{2}=handles.condNames;
varargout{3}=handles.exprp;
varargout{4}=handles.datatable;
varargout{5}=handles.cancel;


function namesCondEdit_Callback(hObject, eventdata, handles)

condnames=cellstr(get(hObject,'String'));
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
    set(handles.addIntensity,'Enable','off')
    set(handles.removeIntensity,'Enable','off')
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
handles.nocond=length(handles.condNames);
handles.condIndex=1:handles.nocond;
handles.exprp=cell(1,handles.nocond);
set(handles.condList,'String',handles.condNames,'Max',1)
set(handles.addIntensity,'Enable','on')
set(handles.intenStatic,'Enable','on')
set(handles.intenList,'Enable','on')
handles.condSet=true;
handles.condStateTimes=handles.condStateTimes+1;
guidata(hObject,handles);


function namesCondEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function columnPopup_Callback(hObject, eventdata, handles)


function columnPopup_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function condList_Callback(hObject, eventdata, handles)

% Recreate the contents of intensity list
val=get(hObject,'Value');
currreps=handles.exprp{val}(:);
set(handles.intenList,'String',currreps,'Value',1)
if ~isempty(currreps)
    set(handles.removeIntensity,'Enable','on')
else
    set(handles.removeIntensity,'Enable','off')
end


function condList_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function intenList_Callback(hObject, eventdata, handles)


function intenList_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function addIntensity_Callback(hObject, eventdata, handles)

% Get necessary variables in order to fill ratio list
colstr=get(handles.columnPopup,'String');
colval=get(handles.columnPopup,'Value');
condval=get(handles.condList,'Value');
currcol=colstr{colval};
currinten=get(handles.intenList,'String');

% Fill ratio list
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
if isempty(colstr)
    set(handles.columnPopup,'String',{''},'Value',1,'Enable','off')
    set(handles.colStatic,'Enable','off')
else
    set(handles.columnPopup,'String',colstr,'Value',newval)
end

% Update exprp
listlen=length(get(handles.intenList,'String'));
handles.exprp{condval}{listlen}=currcol;

% Perform a check if the columns list contains no columns
if isempty(get(handles.columnPopup,'String'))
    set(hObject,'Enable','off')
end

% Enable remove button if inactive
if strcmp(get(handles.removeIntensity,'Enable'),'off')
    set(handles.removeIntensity,'Enable','on')
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
if ~iscell(newstr)
    newstr={newstr};
end
set(handles.intenList,'String',newstr,'Value',newval)

% Put the removed string back in the columns list
if strcmp(get(handles.columnPopup,'Enable'),'off')
    set(handles.columnPopup,'Enable','on')
    set(handles.colStatic,'Enable','on')
end
colstr=cellstr(get(handles.columnPopup,'String'));
if ~isempty(colstr{1})
    colstr=[colstr;remstr];
else
    colstr=cellstr(remstr);
end
set(handles.columnPopup,'String',sort(colstr))

% Update the exprp
handles.exprp{currcond}(currval)=[];

% Perform a check if the columns list contains only more than one column (which should be
% the annotation) and if yes enable add
if length(get(handles.columnPopup,'String'))>1
    set(handles.addIntensity,'Enable','on')
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


function okButton_Callback(hObject, eventdata, handles)

% Create datatable
for i=1:length(handles.exprp)
    for j=1:length(handles.exprp{i})
        handles.datatable{j,i}=handles.exprp{i}{j};
    end
end
% How many annotation columns left
guidata(hObject,handles);
uiresume(handles.IlluminaImportEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Restore defaults
handles.nocond=[];
handles.condNames=[];
handles.exprp=[];
handles.datatable=[];
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.IlluminaImportEditor);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   HELP FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
