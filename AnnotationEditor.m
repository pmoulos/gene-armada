function varargout = AnnotationEditor(varargin)
% ANNOTATIONEDITOR M-file for AnnotationEditor.fig
%      ANNOTATIONEDITOR, by itself, creates a new ANNOTATIONEDITOR or raises the existing
%      singleton*.
%
%      H = ANNOTATIONEDITOR returns the handle to a new ANNOTATIONEDITOR or the handle to
%      the existing singleton*.
%
%      ANNOTATIONEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATIONEDITOR.M with the given input arguments.
%
%      ANNOTATIONEDITOR('Property','Value',...) creates a new ANNOTATIONEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnnotationEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnnotationEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnnotationEditor

% Last Modified by GUIDE v2.5 09-Dec-2007 21:05:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnnotationEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @AnnotationEditor_OutputFcn, ...
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


% --- Executes just before AnnotationEditor is made visible.
function AnnotationEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.AnnotationEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.AnnotationEditor,'Position',winpos);

% Set default outputs
handles.flist='';     % Default gene list file(s) (none)
handles.fann='';      % Default annotation file (none)
handles.unidg=[];     % Unique ID in gene list file(s)
handles.unida=[];     % Unique ID in annotation file
handles.anncols='';   % Annotation elements to be added
handles.cancel=false; % User did not press cancel

% If all ok
handles.sets=false(1,5);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AnnotationEditor wait for user response (see UIRESUME)
uiwait(handles.AnnotationEditor);


% --- Outputs from this function are returned to the command line.
function varargout = AnnotationEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.AnnotationEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.AnnotationEditor);
end

varargout{1}=handles.flist;
varargout{2}=handles.fann;
varargout{3}=handles.unidg;
varargout{4}=handles.unida;
varargout{5}=handles.anncols;
varargout{6}=handles.cancel;


function geneListEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function geneListEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on geneListEdit and no controls selected.
function geneListEdit_KeyPressFcn(hObject, eventdata, handles)

currpress=get(handles.AnnotationEditor,'CurrentCharacter');
z=regexp(currpress,'\r+','once');
if ~isempty(z)
    % Find the names of the columns
    flist=get(hObject,'String');
    if ~isempty(strfind(flist,'.txt'))
        try
            fid=fopen(flist);
            fline=fgetl(fid);
            fclose(fid);
            colnames=textscan(fline,'%s','Delimiter','\t');
            colnames=colnames{1};
        catch
            uiwait(errordlg('You must provide valid text tab delimited files.','Error'));
            return
        end
    elseif ~isempty(strfind(flist,'.xls'))
        % Read the maximum number of column names in and Excel file (256) from the 1st
        % line
        try
            [num,txt,raw]=xlsread(flist,1,'A1:IV1');
            for i=1:length(raw)
                if isnan(raw{i})
                    nanind=i;
                    break; % We don't have to finish the loop, since everythin else is NaN
                end
            end
            colnames=raw(1:nanind-1);
            colnames=colnames';
        catch
            uiwait(errordlg('You must provide valid Excel files.','Error'));
            return
        end
    else
        uiwait(errordlg('You must provide valid text tab delimited or Excel files','Error'));
        return
    end
    % If all succesfull, fill the gene list column names list
    set(handles.listIDPopup,'String',colnames)
    handles.flist=flist;
    handles.sets(1)=true;
    % Default column, the 1st
    handles.unidg=colnames{1};
    if all(handles.sets)
        set(handles.okButton,'Enable','on')
    end
    guidata(hObject,handles);
end


function annFileEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function annFileEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on annFileEdit and no controls selected.
function annFileEdit_KeyPressFcn(hObject, eventdata, handles)

currpress=get(handles.AnnotationEditor,'CurrentCharacter');
z=regexp(currpress,'\r+','once');
if ~isempty(z)
    % Find the names of the columns
    fann=get(hObject,'String');
    if ~isempty(strfind(fann,'.txt'))
        try
            fid=fopen(fann);
            fline=fgetl(fid);
            fclose(fid);
            colnames=textscan(fline,'%s','Delimiter','\t');
            colnames=colnames{1};
        catch
            uiwait(errordlg('You must provide valid text tab delimited files.','Error'));
            return
        end
    elseif ~isempty(strfind(fann,'.xls'))
        % Read the maximum number of column names in and Excel file (256) from the 1st
        % line
        try
            [num,txt,raw]=xlsread(fann,1,'A1:IV1');
            for i=1:length(raw)
                if isnan(raw{i})
                    nanind=i;
                    break; % We don't have to finish the loop, since everythin else is NaN
                end
            end
            colnames=raw(1:nanind-1);
            colnames=colnames';
        catch
            uiwait(errordlg('You must provide valid Excel files.','Error'));
            return
        end
    else
        uiwait(errordlg('You must provide valid text tab delimited or Excel files','Error'));
        return
    end
    % Fill the gene list column names list
    handles.fann=fann;
    handles.allanncols=colnames;
    set(handles.annIDPopup,'String',colnames)
    currstr=get(handles.annIDPopup,'String');
    currid=currstr{1};
    curranncols=colnames;
    z=strmatch(currid,colnames,'exact');
    if ~isempty(z)
        curranncols(z)=[];
    end
    set(handles.annColumnsList,'String',curranncols,'Max',length(curranncols))
    handles.sets(2)=true;
    % Default column, the 1st
    handles.unida=colnames{1};
    % Also annotation columns
    handles.anncols=curranncols{1};
    if all(handles.sets)
        set(handles.okButton,'Enable','on')
    end
    guidata(hObject,handles);
end


% --- Executes on button press in browseGeneList.
function browseGeneList_Callback(hObject, eventdata, handles)

[flist,pname,findex]=uigetfile({'*.txt','Text tab delimited files (*.txt)';...
                                '*.xls','Excel files (*.xls)'},...
                                'Select ARMADA gene list file(s)',...
                                'MultiSelect','on');
if ~iscell(flist) & flist==0
    handles.flist='';
    guidata(hObject,handles);
    return
end

if ischar(flist)
    flist=strcat(pname,flist);
    set(handles.geneListEdit,'String',flist,'Max',1)
    onefile=true;
elseif iscell(flist)
    for i=1:length(flist)
        flist{i}=strcat(pname,flist{i});
    end
    onefile=false;
    set(handles.geneListEdit,'String',flist','Max',length(flist))
end

% Find the names of the columns
if findex==1 % Text files
    if onefile
        fid=fopen(flist);
    else
        fid=fopen(flist{1});
    end
    fline=fgetl(fid);
    fclose(fid);
    colnames=textscan(fline,'%s','Delimiter','\t');
    colnames=colnames{1};
elseif findex==2 % Excel files
    % Read the maximum number of column names in and Excel file (256) from the 1st line
    if onefile
        [num,txt,raw]=xlsread(flist,1,'A1:IV1');
    else
        [num,txt,raw]=xlsread(flist{1},1,'A1:IV1');
    end
    for i=1:length(raw)
        if isnan(raw{i})
            nanind=i;
            break; % We don't have to finish the loop, since everythin else is NaN
        end
    end
    colnames=raw(1:nanind-1);
    colnames=colnames';
end

% Fill the gene list column names list
set(handles.listIDPopup,'String',colnames)
handles.flist=flist;
handles.sets(1)=true;
% Default column, the 1st
handles.unidg=colnames{1};
if all(handles.sets)
    set(handles.okButton,'Enable','on')
end
guidata(hObject,handles);
    

% --- Executes on button press in browseAnnFile.
function browseAnnFile_Callback(hObject, eventdata, handles)

[fann,pname,findex]=uigetfile({'*.txt','Text tab delimited files (*.txt)';...
                               '*.xls','Excel files (*.xls)'},...
                               'Select Annotation file');
if fann==0
    handles.fann='';
    guidata(hObject,handles);
    return
end

fann=strcat(pname,fann);
set(handles.annFileEdit,'String',fann,'Max',1)

% Find the names of the columns
if findex==1 % Text file
    fid=fopen(fann);
    fline=fgetl(fid);
    fclose(fid);
    colnames=textscan(fline,'%s','Delimiter','\t');
    colnames=colnames{1};
elseif findex==2 % Excel file
    % Read the maximum number of column names in and Excel file (256) from the 1st line
    [num,txt,raw]=xlsread(fann,1,'A1:IV1');
    for i=1:length(raw)
        if isnan(raw{i})
            nanind=i;
            break; % We don't have to finish the loop, since everythin else is NaN
        end
    end
    colnames=raw(1:nanind-1);
    colnames=colnames';
end

% Fill the gene list column names list
handles.fann=fann;
handles.allanncols=colnames;
set(handles.annIDPopup,'String',colnames)
currstr=get(handles.annIDPopup,'String');
currid=currstr{1};
curranncols=colnames;
z=strmatch(currid,curranncols,'exact');
if ~isempty(z)
    curranncols(z)=[];
end
set(handles.annColumnsList,'String',curranncols,'Max',length(curranncols))
handles.sets(2)=true;
% Default column, the 1st
handles.unida=colnames{1};
% Also annotation columns
handles.anncols=curranncols{1};
if all(handles.sets)
    set(handles.okButton,'Enable','on')
end
guidata(hObject,handles);


% --- Executes on selection change in listIDPopup.
function listIDPopup_Callback(hObject, eventdata, handles)

strs=get(hObject,'String');
val=get(hObject,'Value');
handles.unidg=strs{val};
handles.sets(3)=true;
if all(handles.sets)
    set(handles.okButton,'Enable','on')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function listIDPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in annIDPopup.
function annIDPopup_Callback(hObject, eventdata, handles)

strs=get(hObject,'String');
val=get(hObject,'Value');
unida=strs{val};
allanncols=handles.allanncols;
z=strmatch(unida,allanncols,'exact');
if ~isempty(z)
    allanncols(z)=[];
end
set(handles.annColumnsList,'String',allanncols)
handles.unida=unida;
handles.sets(4)=true;
if all(handles.sets)
    set(handles.okButton,'Enable','on')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function annIDPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in annColumnsList.
function annColumnsList_Callback(hObject, eventdata, handles)

strs=get(hObject,'String');
val=get(hObject,'Value');
handles.anncols=strs(val);
handles.sets(5)=true;
if all(handles.sets)
    set(handles.okButton,'Enable','on')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function annColumnsList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.AnnotationEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Restore defaults
handles.flist='';
handles.fann='';
handles.unidg=[];
handles.unida=[];
handles.anncols='';
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.AnnotationEditor);
