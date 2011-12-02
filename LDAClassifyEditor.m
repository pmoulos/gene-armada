function varargout = LDAClassifyEditor(varargin)
% LDACLASSIFYEDITOR M-file for LDAClassifyEditor.fig
%      LDACLASSIFYEDITOR, by itself, creates a new LDACLASSIFYEDITOR or raises the existing
%      singleton*.
%
%      H = LDACLASSIFYEDITOR returns the handle to a new LDACLASSIFYEDITOR or the handle to
%      the existing singleton*.
%
%      LDACLASSIFYEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LDACLASSIFYEDITOR.M with the given input arguments.
%
%      LDACLASSIFYEDITOR('Property','Value',...) creates a new LDACLASSIFYEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LDAClassifyEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LDAClassifyEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LDAClassifyEditor

% Last Modified by GUIDE v2.5 14-Mar-2008 18:40:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LDAClassifyEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @LDAClassifyEditor_OutputFcn, ...
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


% --- Executes just before LDAClassifyEditor is made visible.
function LDAClassifyEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.LDAClassifyEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.LDAClassifyEditor,'Position',winpos);

% Set default outputs
handles.type='linear';        % Default discriminant function type
handles.typeName='Linear';    % Default discriminant function type name
handles.prior=[];             % Default prior - uniform
handles.priorName='Uniform';  % Default tie break rule
handles.samplenames=[];       % Default names for new samples
handles.newdata=[];           % Sample data to be classified
handles.cancel=false;         % User did not press cancel 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LDAClassifyEditor wait for user response (see UIRESUME)
uiwait(handles.LDAClassifyEditor);


% --- Outputs from this function are returned to the command line.
function varargout = LDAClassifyEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.LDAClassifyEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.LDAClassifyEditor);
end

varargout{1}=handles.type;
varargout{2}=handles.typeName;
varargout{3}=handles.prior;
varargout{4}=handles.priorName;
varargout{5}=handles.samplenames;
varargout{6}=handles.newdata;
varargout{7}=handles.cancel;


function fileEdit_Callback(hObject, eventdata, handles)


function fileEdit_KeyPressFcn(hObject, eventdata, handles)

currpress=get(handles.LDAClassifyEditor,'CurrentCharacter');
z=regexp(currpress,'\r+','once');
if ~isempty(z)
    % Find the names of the columns
    sfile=get(hObject,'String');
    if ~isempty(strfind(sfile,'.txt'))
        try
            try
                % We suppose that the input file has one line of headers containing sample names
                % (the 1st) and one column of feature names (the 1st). All other data are numeric.
                fid=fopen(sfile);
                fline=fgetl(fid);
                colnames=textscan(fline,'%s','Delimiter','\t');
                colnames=colnames{1};
                frmt=repmat('%f',[1 length(colnames)-1]);
                frmt=['%*s',frmt];
                data=textscan(fid,frmt,'Delimiter','\t');
                handles.newdata=cell2mat(data);
                handles.samplenames=colnames(2:end);
            catch
                uiwait(errordlg('The file should contain only numeric data.',...
                                'Bad Input'));
                return
            end
        catch
            uiwait(errordlg('You must provide valid text tab delimited file.','Error'));
            return
        end
    elseif ~isempty(strfind(sfile,'.xls'))
        try
            % Same things apply for Excel files
            [num,txt]=xlsread(sfile,1);
            colnames=txt(1,2:end);
            colnames=colnames';
            handles.newdata=num;
            handles.samplenames=colnames;
        catch
            uiwait(errordlg('You must provide valid Excel file.','Error'));
            return
        end
    else
        uiwait(errordlg('You must provide valid text tab delimited or Excel file.','Error'));
        return
    end
    set(handles.okButton,'Enable','on')
    guidata(hObject,handles);
end


function fileEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function broButton_Callback(hObject, eventdata, handles)

[sfile,pname,findex]=uigetfile({'*.txt','Text tab delimited files (*.txt)';...
                                '*.xls','Excel files (*.xls)'},...
                                'Select Sample file');
if sfile==0
    return
end

sfile=strcat(pname,sfile);
set(handles.fileEdit,'String',sfile,'Max',1)

% Find the names of the columns
if findex==1 % Text file
    try
        % We suppose that the input file has one line of headers containing sample names
        % (the 1st) and one column of feature names (the 1st). All other data are numeric.
        fid=fopen(sfile);
        fline=fgetl(fid);
        colnames=textscan(fline,'%s','Delimiter','\t');
        colnames=colnames{1};
        frmt=repmat('%f',[1 length(colnames)-1]);
        frmt=['%*s',frmt];
        data=textscan(fid,frmt,'Delimiter','\t');
        handles.newdata=cell2mat(data);
        handles.samplenames=colnames(2:end);
    catch
        uiwait(errordlg('The file should contain only numeric data.',...
                        'Bad Input'));
        return
    end
elseif findex==2 % Excel file
    % Same things apply for Excel files
    [num,txt]=xlsread(sfile,1);
    colnames=txt(1,2:end);
    colnames=colnames';
    handles.newdata=num;
    handles.samplenames=colnames;
end
set(handles.okButton,'Enable','on')
guidata(hObject,handles);


function typePopup_Callback(hObject, eventdata, handles)

types={'linear','diaglinear','quadratic','diagquadratic','mahalanobis'};
val=get(hObject,'Value');
typeNames=get(hObject,'String');
handles.type=types{val};
handles.typeName=typeNames{val};
guidata(hObject,handles);


function typePopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function priorPopup_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
priors=get(hObject,'String');
handles.priorName=priors{val};
switch val
    case 1 % Uniform
        handles.prior=[];
        set(handles.pstatic,'Enable','off')
        set(handles.priorEdit,'Enable','off')
        set(handles.broPrior,'Enable','off')
    case 2 % Empirical
        handles.prior='empirical';
        set(handles.pstatic,'Enable','off')
        set(handles.priorEdit,'Enable','off')
        set(handles.broPrior,'Enable','off')
    case 3 % External
        % Structure will be set through the external priors file
        set(handles.pstatic,'Enable','on')
        set(handles.priorEdit,'Enable','on')
        set(handles.broPrior,'Enable','on')
end
        
guidata(hObject,handles);


function priorPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function priorEdit_Callback(hObject, eventdata, handles)


function priorEdit_KeyPressFcn(hObject, eventdata, handles)

currpress=get(handles.LDAClassifyEditor,'CurrentCharacter');
z=regexp(currpress,'\r+','once');
if ~isempty(z)
    pfile=get(hObject,'String');
    if ~isempty(strfind(pfile,'.txt'))
        try
            try
                % If a text file, it should have two columns, the 1st text and the 2nd numeric
                fid=fopen(pfile,'r');
                data=textscan(fid,'%s%f','Delimiter','\t');
                % Check if the sum of probabilities is 1
                if sum(data{2})~=1
                    uiwait(errordlg('The sum of prior probabilities should equal to 1!','Bad Input'));
                    return
                else
                    handles.pstruct.group=data{1};
                    handles.pstruct.prob=data{2};
                end
            catch
                uiwait(errordlg({'The external priors file should follow a specific format.',...
                                 'Please consult the user guide.'},...
                                 'Bad Input'));
                return
            end
        catch
            uiwait(errordlg('You must provide valid text tab delimited file.','Error'));
            return
        end
    elseif ~isempty(strfind(pfile,'.xls'))
        try
            try
                [num,txt]=xlsread(pfile,1);
                if sum(num)~=1
                    uiwait(errordlg('The sum of prior probabilities should equal to 1!','Bad Input'));
                    return
                else
                    handles.pstruct.group=txt;
                    handles.pstruct.prob=num;
                end
            catch
                uiwait(errordlg({'The external priors file should follow a specific format.',...
                                 'Please consult the user guide.'},...
                                 'Bad Input'));
                return
            end
        catch
            uiwait(errordlg('You must provide valid Excel file.','Error'));
            return
        end
    else
        uiwait(errordlg('You must provide valid text tab delimited or Excel file.','Error'));
        return
    end
    guidata(hObject,handles);
end


function priorEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function broPrior_Callback(hObject, eventdata, handles)

[pfile,pname,findex]=uigetfile({'*.txt','Text tab delimited files (*.txt)';...
                                '*.xls','Excel files (*.xls)'},...
                                'Select Sample file');
if pfile==0
    return
end

pfile=strcat(pname,pfile);
set(handles.priorEdit,'String',pfile,'Max',1)

% Find the names of the columns
if findex==1 % Text file
    try
        % If a text file, it should have two columns, the 1st text and the 2nd numeric
        fid=fopen(pfile,'r');
        data=textscan(fid,'%s%f','Delimiter','\t');
        % Check if the sum of probabilities is 1
        if sum(data{2})~=1
            uiwait(errordlg('The sum of prior probabilities should equal to 1!','Bad Input'));
            return
        else
            handles.pstruct.group=data{1};
            handles.pstruct.prob=data{2};
        end
    catch
        uiwait(errordlg({'The external priors file should follow a specific format.',...
                         'Please consult the user guide.'},...
                        'Bad Input'));
        return
    end
elseif findex==2 % Excel file
    try
        [num,txt]=xlsread(pfile,1);
        if sum(num)~=1
            uiwait(errordlg('The sum of prior probabilities should equal to 1!','Bad Input'));
            return
        else
            handles.pstruct.group=txt;
            handles.pstruct.prob=num;
        end
    catch
        uiwait(errordlg({'The external priors file should follow a specific format.',...
                         'Please consult the user guide.'},...
                         'Bad Input'));
        return
    end
end
guidata(hObject,handles);


function okButton_Callback(hObject, eventdata, handles)

switch get(handles.priorPopup,'Value');
    case 1 % Uniform
        handles.prior=[];
    case 2 % Empirical
        handles.prior='empirical';
    case 3 % External
        if isfield(handles,'pstruct') % If it is, then already checked if properly defined
            handles.prior=handles.pstruct;
        else
            uiwait(errordlg('External priors have not been defined yet!','Bad Input'));
            return
        end
end
guidata(hObject,handles);
uiresume(handles.LDAClassifyEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.type='linear';
handles.typeName='Linear';
handles.prior=[];
handles.priorName='Uniform';
handles.samplenames=[];
handles.newdata=[];
handles.cancel=true; % User pressed cancel 
guidata(hObject,handles);
uiresume(handles.LDAClassifyEditor);
