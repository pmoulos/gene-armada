function varargout = LDATuneEditor(varargin)
% LDATUNEEDITOR M-file for LDATuneEditor.fig
%      LDATUNEEDITOR, by itself, creates a new LDATUNEEDITOR or raises the existing
%      singleton*.
%
%      H = LDATUNEEDITOR returns the handle to a new LDATUNEEDITOR or the handle to
%      the existing singleton*.
%
%      LDATUNEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LDATUNEEDITOR.M with the given input arguments.
%
%      LDATUNEEDITOR('Property','Value',...) creates a new LDATUNEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LDATuneEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LDATuneEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LDATuneEditor

% Last Modified by GUIDE v2.5 27-Mar-2008 15:30:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LDATuneEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @LDATuneEditor_OutputFcn, ...
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


% --- Executes just before LDATuneEditor is made visible.
function LDATuneEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.LDATuningEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.LDATuningEditor,'Position',winpos);

% Get inputs
handles.maxs=varargin{1}; % Should not exceed number of available samples

% Set default outputs
handles.type={'linear'};                       % Default discriminant function type
handles.typeName={'Linear'};                   % Default type name 
handles.priors={[]};                           % Default priors [] -> uniform
handles.priorName={'Uniform'};                 % Default name for priors
handles.validmethod={'kfold'};                 % Default validation - n-fold cross validation
handles.validparam=[5 NaN NaN];                % Default n (5) for n-fold cross validation
handles.validname={'N-fold cross validation'}; % Default model validation
handles.showplot=true;                         % Display evaluation plots
handles.showresult=true;                       % Display evaluation results
handles.verbose=false;                         % Do not display verbose messages
handles.cancel=false;                          % User did not press cancel  

% If the number of available samples is less than the default n in n-fold validation
if handles.validparam>handles.maxs
    handles.validparam=handles.maxs;
    set(handles.nfoldEdit,'String',num2str(handles.maxs))
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LDATuneEditor wait for user response (see UIRESUME)
uiwait(handles.LDATuningEditor);


% --- Outputs from this function are returned to the command line.
function varargout = LDATuneEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.LDATuningEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.LDATuningEditor);
end

varargout{1}=handles.type;
varargout{2}=handles.typeName;
varargout{3}=handles.priors;
varargout{4}=handles.priorName;
varargout{5}=handles.validmethod;
varargout{6}=handles.validparam;
varargout{7}=handles.validname;
varargout{8}=handles.showplot;
varargout{9}=handles.showresult;
varargout{10}=handles.verbose;
varargout{11}=handles.cancel;


function typeList_Callback(hObject, eventdata, handles)

types={'linear';'diaglinear';'quadratic';'diagquadratic';'mahalanobis'};
typeNames=get(hObject,'String');
handles.type=types(get(hObject,'Value'));
handles.typeName=typeNames(get(hObject,'Value'));
guidata(hObject,handles);


function typeList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function priorList_Callback(hObject, eventdata, handles)

priors=get(hObject,'String');
val=get(hObject,'Value');
handles.priorName=priors(val);
% If external priors are selected, enable file selection
if ismember(3,val)
    set(handles.priorStatic,'Enable','on')
    set(handles.priorEdit,'Enable','on')
    set(handles.broPrior,'Enable','on')
else
    set(handles.priorStatic,'Enable','off')
    set(handles.priorEdit,'Enable','off')
    set(handles.broPrior,'Enable','off')
end
guidata(hObject,handles);


function priorList_CreateFcn(hObject, eventdata, handles)

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


function nfoldCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.nstatic,'Enable','on')
    set(handles.nfoldEdit,'Enable','on')
    handles.validmethod{1}='kfold';
    handles.validparam(1)=str2double(get(handles.nfoldEdit,'String'));
    handles.validname{1}='N-fold cross validation';
else
    set(handles.nstatic,'Enable','off')
    set(handles.nfoldEdit,'Enable','off')
    handles.validmethod{1}='';
    handles.validparam(1)=NaN;
    handles.validname{1}='';
end
z=[get(hObject,'Value') get(handles.leaveMoutCheck,'Value') get(handles.holdCheck,'Value')];
if ~any(z)
    uiwait(warndlg({'You must select at least one validation method',...
                   'for the classifier tuning to be performed.'},...
                   'Warning'));
    set(hObject,'Value',1);
    set(handles.nstatic,'Enable','on')
    set(handles.nfoldEdit,'Enable','on')
    handles.validmethod{1}='kfold';
    handles.validparam(1)=str2double(get(handles.nfoldEdit,'String'));
    handles.validname{1}='N-fold cross validation';
end
guidata(hObject,handles);


function nfoldEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The number of cross validation times must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','5')
    handles.validparam(1)=str2double(get(hObject,'String'));
elseif val>handles.maxs
    uiwait(errordlg({'The number of cross validation times cannot be',...
                     'larger than the number of samples in the dataset.'},...
                     'Bad Input'));
    set(hObject,'String',num2str(handles.maxs))
    handles.validparam(1)=str2double(get(hObject,'String'));
else
    handles.validparam(1)=val;
end
guidata(hObject,handles);


function nfoldEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function leaveMoutCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.mstatic,'Enable','on')
    set(handles.moutEdit,'Enable','on')
    handles.validmethod{2}='leavemout';
    handles.validparam(2)=str2double(get(handles.moutEdit,'String'));
    handles.validname{2}='Leave-M-out';
else
    set(handles.mstatic,'Enable','off')
    set(handles.moutEdit,'Enable','off')
    handles.validmethod{2}='';
    handles.validparam(2)=NaN;
    handles.validname{2}='';
end
z=[get(handles.nfoldCheck,'Value') get(hObject,'Value') get(handles.holdCheck,'Value')];
if ~any(z)
    uiwait(warndlg({'You must select at least one validation method',...
                   'for the classifier tuning to be performed.'},...
                   'Warning'));
    set(handles.nfoldCheck,'Value',1);
    set(handles.nstatic,'Enable','on')
    set(handles.nfoldEdit,'Enable','on')
    handles.validmethod{1}='kfold';
    handles.validparam(1)=str2double(get(handles.nfoldEdit,'String'));
    handles.validname{1}='N-fold cross validation';
end
guidata(hObject,handles);


function moutEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The number of leave-out samples must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','1')
    handles.validparam(2)=str2double(get(hObject,'String'));
elseif val>handles.maxs
    uiwait(errordlg({'The number of leave-out samples cannot be larger',...
                     'than the number of samples in the dataset.'},...
                     'Bad Input'));
    set(hObject,'String','1')
    handles.validparam(2)=str2double(get(hObject,'String'));
else
    handles.validparam(2)=val;
end
guidata(hObject,handles);


function moutEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function holdCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.pstatic,'Enable','on')
    set(handles.holdEdit,'Enable','on')
    handles.validmethod{3}='holdout';
    handles.validparam(3)=str2double(get(handles.holdEdit,'String'))/100;
    handles.validname{3}='Training and Test Hold Out';
else
    set(handles.pstatic,'Enable','off')
    set(handles.holdEdit,'Enable','off')
    handles.validmethod{3}='';
    handles.validparam(3)=NaN;
    handles.validname{3}='';
end
z=[get(handles.nfoldCheck,'Value') get(handles.leaveMoutCheck,'Value') get(hObject,'Value')];
if ~any(z)
    uiwait(warndlg({'You must select at least one validation method',...
                   'for the classifier tuning to be performed.'},...
                   'Warning'));
    set(handles.nfoldCheck,'Value',1);
    set(handles.nstatic,'Enable','on')
    set(handles.nfoldEdit,'Enable','on')
    handles.validmethod{1}='kfold';
    handles.validparam(1)=str2double(get(handles.nfoldEdit,'String'));
    handles.validname{1}='N-fold cross validation';
end
guidata(hObject,handles);


function holdEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || val>100
    uiwait(errordlg('The percentage of samples to hold out must be between 1 and 100.',...
                    'Bad Input'));
    set(hObject,'String','40')
    handles.validparam(3)=str2double(get(hObject,'String'))/100;
else
    handles.validparam(3)=val/100;
end
guidata(hObject,handles);


function holdEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function showplotCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.showplot=true;
else
    handles.showplot=false;
end
guidata(hObject,handles);


function showresultCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.showresult=true;
else
    handles.showresult=false;
end
guidata(hObject,handles);


function verboseCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.verbose=true;
else
    handles.verbose=false;
end
guidata(hObject,handles);


function okButton_Callback(hObject, eventdata, handles)

% Retrun properly arranged priors
handles.priors=cell(1:length(handles.priorName));
for i=1:length(handles.priorName)
    switch handles.priorName{i}
        case 'Uniform'
            % Do nothing, cell must be empty
        case 'Empirical'
            handles.priors{i}='empirical';
        case 'External'
            if isfield(handles,'pstruct') % If it is, then already checked if properly defined
                handles.priors{i}=handles.pstruct;
            else
                uiwait(errordlg('External priors have not been defined yet!','Bad Input'));
                return
            end
    end
end     
% Return properly arranged validation methods (for tunelda)
emind=true(1,length(handles.validmethod));
for i=1:length(emind)
    if isempty(handles.validmethod{i})
        emind(i)=false;
    end
end
handles.validmethod=handles.validmethod(emind);
handles.validname=handles.validname(emind);
handles.validparam(isnan(handles.validparam))=[];
guidata(hObject,handles);
uiresume(handles.LDATuningEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.type='linear';
handles.typeName='Linear';
handles.priors={[]};
handles.priorName={'Uniform'};
handles.validmethod={'kfold'};
handles.validparam=5;
handles.validname={'N-fold cross validation'};
handles.showplot=true;
handles.showresult=true;
handles.verbose=false;
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.LDATuningEditor);
