function varargout = SVMTuneEditor(varargin)
% SVMTUNEEDITOR M-file for SVMTuneEditor.fig
%      SVMTUNEEDITOR, by itself, creates a new SVMTUNEEDITOR or raises the existing
%      singleton*.
%
%      H = SVMTUNEEDITOR returns the handle to a new SVMTUNEEDITOR or the handle to
%      the existing singleton*.
%
%      SVMTUNEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SVMTUNEEDITOR.M with the given input arguments.
%
%      SVMTUNEEDITOR('Property','Value',...) creates a new SVMTUNEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SVMTuneEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SVMTuneEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SVMTuneEditor

% Last Modified by GUIDE v2.5 27-Mar-2008 15:47:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SVMTuneEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @SVMTuneEditor_OutputFcn, ...
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


% --- Executes just before SVMTuneEditor is made visible.
function SVMTuneEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.SVMTuneEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.SVMTuneEditor,'Position',winpos);

% Get input
handles.maxs=varargin{1}; % Should not exceed number of available samples

% Set default outputs
handles.kernel={'linear'};                     % Default kernel linear
handles.kernelName={'Linear'};                 % Default kernel name
handles.normalize=false;                       % Do not normalize input matrix
handles.scale=false;                           % Do not scale input matrix
handles.scalevals=[-1 1];                      % Defaults if we choose scale
handles.tol=0.001;                             % Default termination tolerance
handles.polyParams={[1 0 3]};                  % Default polynomial kernel parameters
handles.mlpParams={[1 0]};                     % Default MLP parameters
handles.rbfParams=1;                           % Default RBF parameters
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

% UIWAIT makes SVMTuneEditor wait for user response (see UIRESUME)
uiwait(handles.SVMTuneEditor);


% --- Outputs from this function are returned to the command line.
function varargout = SVMTuneEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.SVMTuneEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.SVMTuneEditor);
end

varargout{1}=handles.kernel;
varargout{2}=handles.kernelName;
varargout{3}=handles.normalize;
varargout{4}=handles.scale;
varargout{5}=handles.scalevals;
varargout{6}=handles.tol;
varargout{7}=handles.polyParams;
varargout{8}=handles.mlpParams;
varargout{9}=handles.rbfParams;
varargout{10}=handles.validmethod;
varargout{11}=handles.validparam;
varargout{12}=handles.validname;
varargout{13}=handles.showplot;
varargout{14}=handles.showresult;
varargout{15}=handles.verbose;
varargout{16}=handles.cancel;


function kernelList_Callback(hObject, eventdata, handles)

kernels={'linear','polynomial','mlp','rbf'};
kernelNames=get(hObject,'String');
val=get(hObject,'Value');
handles.kernel=kernels(val);
handles.kernelName=kernelNames(val);
% Enable and disable panels according to kernel choices
if ismember(2,val)
    set(handles.polyGammaStatic,'Enable','on')
    set(handles.polyCoefStatic,'Enable','on')
    set(handles.polyDegStatic,'Enable','on')
    set(handles.polyGammaEdit,'Enable','on')
    set(handles.polyCoefEdit,'Enable','on')
    set(handles.polyDegEdit,'Enable','on')
    set(handles.polyAdd,'Enable','on')
    set(handles.polyRemove,'Enable','on')
    set(handles.polyListStatic,'Enable','on')
    set(handles.polyParamList,'Enable','on')
    set(handles.polyRead,'Enable','on')
else
    set(handles.polyGammaStatic,'Enable','off')
    set(handles.polyCoefStatic,'Enable','off')
    set(handles.polyDegStatic,'Enable','off')
    set(handles.polyGammaEdit,'Enable','off')
    set(handles.polyCoefEdit,'Enable','off')
    set(handles.polyDegEdit,'Enable','off')
    set(handles.polyAdd,'Enable','off')
    set(handles.polyRemove,'Enable','off')
    set(handles.polyListStatic,'Enable','off')
    set(handles.polyParamList,'Enable','off')
    set(handles.polyRead,'Enable','off')
end
if ismember(3,val)
    set(handles.mlpGammaStatic,'Enable','on')
    set(handles.mlpCoefStatic,'Enable','on')
    set(handles.mlpGammaEdit,'Enable','on')
    set(handles.mlpCoefEdit,'Enable','on')
    set(handles.mlpAdd,'Enable','on')
    set(handles.mlpRemove,'Enable','on')
    set(handles.mlpListStatic,'Enable','on')
    set(handles.mlpParamList,'Enable','on')
    set(handles.mlpRead,'Enable','on')
else
    set(handles.mlpGammaStatic,'Enable','off')
    set(handles.mlpCoefStatic,'Enable','off')
    set(handles.mlpGammaEdit,'Enable','off')
    set(handles.mlpCoefEdit,'Enable','off')
    set(handles.mlpAdd,'Enable','off')
    set(handles.mlpRemove,'Enable','off')
    set(handles.mlpListStatic,'Enable','off')
    set(handles.mlpParamList,'Enable','off')
    set(handles.mlpRead,'Enable','off')
end
if ismember(4,val)
    set(handles.rbfGammaStatic,'Enable','on')
    set(handles.rbfGammaEdit,'Enable','on')
    set(handles.rbfAdd,'Enable','on')
    set(handles.rbfRemove,'Enable','on')
    set(handles.rbfListStatic,'Enable','on')
    set(handles.rbfParamList,'Enable','on')
    set(handles.rbfRead,'Enable','on')
else
    set(handles.rbfGammaStatic,'Enable','off')
    set(handles.rbfGammaEdit,'Enable','off')
    set(handles.rbfAdd,'Enable','off')
    set(handles.rbfRemove,'Enable','off')
    set(handles.rbfListStatic,'Enable','off')
    set(handles.rbfParamList,'Enable','off')
    set(handles.rbfRead,'Enable','off')
end
guidata(hObject,handles);


function kernelList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function normCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.normalize=true;
else
    handles.normalize=false;
end
guidata(hObject,handles);


function scaleCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.lowStatic,'Enable','on')
    set(handles.lowerEdit,'Enable','on')
    set(handles.upStatic,'Enable','on')
    set(handles.upperEdit,'Enable','on')
    handles.scale=true;
else
    set(handles.lowStatic,'Enable','off')
    set(handles.lowerEdit,'Enable','off')
    set(handles.upStatic,'Enable','off')
    set(handles.upperEdit,'Enable','off')
    handles.scale=false;
end
guidata(hObject,handles);


function lowerEdit_Callback(hObject, eventdata, handles)

low=str2double(get(hObject,'String'));
up=str2double(get(handles.upperEdit,'String'));
if ~isnan(low) && ~isnan(up)
    handles.scalevals=[low up];
else
    uiwait(errordlg('Scale limits must be real numbers!','Bad Input'));
    handles.scalevals=[-1 1];
end
guidata(hObject,handles);


function lowerEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function upperEdit_Callback(hObject, eventdata, handles)

low=str2double(get(handles.lowerEdit,'String'));
up=str2double(get(hObject,'String'));
if ~isnan(low) && ~isnan(up)
    handles.scalevals=[low up];
else
    uiwait(errordlg('Scale limits must be real numbers!','Bad Input'));
    handles.scalevals=[-1 1];
end
guidata(hObject,handles);


function upperEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tolEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if ~isnan(val)
    handles.tol=val;
else
    uiwait(errordlg('Tolerance value must be a real number!','Bad Input'));
    handles.tol=0.001;
end
guidata(hObject,handles);


function tolEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function polyGammaEdit_Callback(hObject, eventdata, handles)


function polyGammaEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function polyCoefEdit_Callback(hObject, eventdata, handles)


function polyCoefEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function polyDegEdit_Callback(hObject, eventdata, handles)


function polyDegEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function polyParamList_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
if length(val)==1
    strs=get(hObject,'String');
    vec=str2num(strs{val});
    set(handles.polyGammaEdit,'String',vec(1));
    set(handles.polyCoefEdit,'String',vec(2));
    set(handles.polyDegEdit,'String',vec(3));
end


function polyParamList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function polyAdd_Callback(hObject, eventdata, handles)

% Get parameters and check validity
gamma=str2double(get(handles.polyGammaEdit,'String'));
coef=str2double(get(handles.polyCoefEdit,'String'));
deg=str2double(get(handles.polyDegEdit,'String'));
if isnan(gamma) || isnan(coef) || isnan(deg)
    uiwait(errordlg('Polynomial kernel parameters must be real numbers.',...
                    'Bad Input'));
    return
end
% If valid add them to list
parset=[gamma coef deg];
str=get(handles.polyParamList,'String');
if isempty(str)
    str={num2str(parset)};
else
    str=[str;num2str(parset)];
end
set(handles.polyParamList,'String',str,'Max',length(str))
% And update parameter set
handles.polyParams=cell(1,length(str));
for i=1:length(str)
    handles.polyParams{i}=str2num(str{i});
end
% Enable remove button
set(handles.polyRemove,'Enable','on')
guidata(hObject,handles);


function polyRemove_Callback(hObject, eventdata, handles)

% Get some initial parameters
val=get(handles.polyParamList,'Value');
str=get(handles.polyParamList,'String');
% Remove those not wanted
str(val)=[];
handles.polyParams(val)=[];
% Check validity of the new list value
newval=checkval(val);
% Update    
set(handles.polyParamList,'String',str,'Value',newval,'Max',length(str))
if isempty(str)
    set(hObject,'Enable','off')
end
guidata(hObject,handles);


function polyRead_Callback(hObject, eventdata, handles)

[pfile,pname,findex]=uigetfile({'*.txt','Text tab delimited files (*.txt)';...
                                '*.xls','Excel files (*.xls)'},...
                                'Select Parameters file');
if pfile==0
    return
end

pfile=strcat(pname,pfile);

% Read and convert parameters
if findex==1 % Text file
    try
        % If a text file, it should have 3 columns
        fid=fopen(pfile,'r');
        data=textscan(fid,'%f%f%f','Delimiter','\t');
        fclose(fid);
        data=cell2mat(data);
        if size(data,2)~=3
            uiwait(errordlg('The Polynomial kernel parameters file should have 3 columns!',...
                            'Bad Input'));
            return
        end
    catch
        uiwait(errordlg({'The external Polynomial kernel parameters file should be a',...
                         'proper text tab delimited file and contain only numeric data.'},...
                         'Bad Input'));
        return
    end
elseif findex==2 % Excel file
    try
        data=xlsread(pfile,1);
        if size(data,2)~=3
            uiwait(errordlg('The Polynomial kernel parameters file should have 3 columns!',...
                            'Bad Input'));
            return
        end
    catch
        uiwait(errordlg({'The external Polynomial kernel parameters file should',...
                         'be a proper Excel file and contain only numeric data.'},...
                         'Bad Input'));
        return
    end
end
% Obtain parameters and update parameters list
polyprms=cell(1,size(data,1));
listconts=cell(size(data,1),1);
for i=1:size(data,1)
    polyprms{i}=data(i,:);
    listconts{i}=num2str(data(i,:));
end
currconts=get(handles.polyParamList,'String');
if isempty(currconts)
    handles.polyParams=polyprms;
    set(handles.polyParamList,'String',listconts)
else
    handles.polyParams=[handles.polyParams,polyprms];
    set(handles.polyParamList,'String',[currconts;listconts])
end
set(handles.polyRemove,'Enable','on')
guidata(hObject,handles);


function mlpGammaEdit_Callback(hObject, eventdata, handles)


function mlpGammaEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mlpCoefEdit_Callback(hObject, eventdata, handles)


function mlpCoefEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mlpParamList_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
if length(val)==1
    strs=get(hObject,'String');
    vec=str2num(strs{val});
    set(handles.mlpGammaEdit,'String',vec(1));
    set(handles.mlpCoefEdit,'String',vec(2));
end


function mlpParamList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mlpAdd_Callback(hObject, eventdata, handles)

% Get parameters and check validity
gamma=str2double(get(handles.mlpGammaEdit,'String'));
coef=str2double(get(handles.mlpCoefEdit,'String'));
if isnan(gamma) || isnan(coef)
    uiwait(errordlg('MLP kernel parameters must be real numbers.',...
                    'Bad Input'));
    return
end
% If valid add them to list
parset=[gamma coef];
str=get(handles.mlpParamList,'String');
if isempty(str)
    str={num2str(parset)};
else
    str=[str;num2str(parset)];
end
set(handles.mlpParamList,'String',str,'Max',length(str))
% And update parameter set
handles.mlpParams=cell(1,length(str));
for i=1:length(str)
    handles.mlpParams{i}=str2num(str{i});
end
% Enable remove button
set(handles.mlpRemove,'Enable','on')
guidata(hObject,handles);


function mlpRemove_Callback(hObject, eventdata, handles)

% Get some initial parameters
val=get(handles.mlpParamList,'Value');
str=get(handles.mlpParamList,'String');
% Remove those not wanted
str(val)=[];
handles.mlpParams(val)=[];
% Check validity of the new list value
newval=checkval(val);
% Update    
set(handles.mlpParamList,'String',str,'Value',newval,'Max',length(str))
if isempty(str)
    set(hObject,'Enable','off')
end
guidata(hObject,handles);


function mlpRead_Callback(hObject, eventdata, handles)

[pfile,pname,findex]=uigetfile({'*.txt','Text tab delimited files (*.txt)';...
                                '*.xls','Excel files (*.xls)'},...
                                'Select Parameters file');
if pfile==0
    return
end

pfile=strcat(pname,pfile);

% Read and convert parameters
if findex==1 % Text file
    try
        % If a text file, it should have 3 columns
        fid=fopen(pfile,'r');
        data=textscan(fid,'%f%f','Delimiter','\t');
        fclose(fid);
        data=cell2mat(data);
        if size(data,2)~=2
            uiwait(errordlg('The MLP kernel parameters file should have 2 columns!',...
                            'Bad Input'));
            return
        end
    catch
        uiwait(errordlg({'The external MLP kernel parameters file should be a proper',...
                         'text tab delimited file and contain only numeric data.'},...
                         'Bad Input'));
        return
    end
elseif findex==2 % Excel file
    try
        data=xlsread(pfile,1);
        if size(data,2)~=2
            uiwait(errordlg('The MLP kernel parameters file should have 3 columns!',...
                            'Bad Input'));
            return
        end
    catch
        uiwait(errordlg({'The external MLP kernel parameters file should be a',...
                         'proper Excel file and contain only numeric data.'},...
                         'Bad Input'));
        return
    end
end
% Obtain parameters and update parameters list
mlpprms=cell(1,size(data,1));
listconts=cell(size(data,1),1);
for i=1:size(data,1)
    mlpprms{i}=data(i,:);
    listconts{i}=num2str(data(i,:));
end
currconts=get(handles.mlpParamList,'String');
if isempty(currconts)
    handles.mlpParams=mlpprms;
    set(handles.mlpParamList,'String',listconts)
else
    handles.mlpParams=[handles.mlpParams,mlpprms];
    set(handles.mlpParamList,'String',[currconts;listconts])
end
set(handles.mlpRemove,'Enable','on')
guidata(hObject,handles);


function rbfGammaEdit_Callback(hObject, eventdata, handles)


function rbfGammaEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rbfParamList_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
if length(val)==1
    strs=get(hObject,'String');
    vec=str2double(strs{val});
    set(handles.rbfGammaEdit,'String',vec);
end


function rbfParamList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rbfAdd_Callback(hObject, eventdata, handles)

% Get parameters and check validity
gamma=str2double(get(handles.rbfGammaEdit,'String'));
if isnan(gamma)
    uiwait(errordlg('RBF kernel parameter must be real numbers.',...
                    'Bad Input'));
    return
end
% If valid add them to list
parset=gamma;
str=get(handles.rbfParamList,'String');
if isempty(str)
    str={num2str(parset)};
else
    str=[str;num2str(parset)];
end
set(handles.rbfParamList,'String',str,'Max',length(str))
% And update parameter set
handles.rbfParams=zeros(1,length(str));
for i=1:length(str)
    handles.rbfParams(i)=str2double(str{i});
end
% Enable remove button
set(handles.rbfRemove,'Enable','on')
guidata(hObject,handles);


function rbfRemove_Callback(hObject, eventdata, handles)

% Get some initial parameters
val=get(handles.rbfParamList,'Value');
str=get(handles.rbfParamList,'String');
% Remove those not wanted
str(val)=[];
handles.rbfParams(val)=[];
% Check validity of the new list value
newval=checkval(val);
% Update    
set(handles.rbfParamList,'String',str,'Value',newval,'Max',length(str))
if isempty(str)
    set(hObject,'Enable','off')
end
guidata(hObject,handles);


function rbfRead_Callback(hObject, eventdata, handles)

[pfile,pname,findex]=uigetfile({'*.txt','Text tab delimited files (*.txt)';...
                                '*.xls','Excel files (*.xls)'},...
                                'Select Parameters file');
if pfile==0
    return
end

pfile=strcat(pname,pfile);

% Read and convert parameters
if findex==1 % Text file
    try
        % If a text file, it should have 3 columns
        fid=fopen(pfile,'r');
        data=textscan(fid,'%f','Delimiter','\t');
        fclose(fid);
        data=data{1};
        if size(data,2)~=1
            uiwait(errordlg('The RBF kernel parameters file should have 1 column!',...
                            'Bad Input'));
            return
        end
    catch
        uiwait(errordlg({'The external RBF kernel parameters file should be a proper',...
                         'text tab delimited file and contain only numeric data.'},...
                         'Bad Input'));
        return
    end
elseif findex==2 % Excel file
    try
        data=xlsread(pfile,1);
        if size(data,2)~=1
            uiwait(errordlg('The RBF kernel parameters file should have 1 column!',...
                            'Bad Input'));
            return
        end
    catch
        uiwait(errordlg({'The external RBF kernel parameters file should be a',...
                         'proper Excel file and contain only numeric data.'},...
                         'Bad Input'));
        return
    end
end
% Obtain parameters and update parameters list
rbfprms=zeros(1,size(data,1));
listconts=cell(size(data,1),1);
for i=1:size(data,1)
    rbfprms(i)=data(i,:);
    listconts{i}=num2str(data(i,:));
end
currconts=get(handles.rbfParamList,'String');
if isempty(currconts)
    handles.rbfParams=rbfprms;
    set(handles.rbfParamList,'String',listconts)
else
    handles.rbfParams=[handles.rbfParams,rbfprms];
    set(handles.rbfParamList,'String',[currconts;listconts])
end
set(handles.rbfRemove,'Enable','on')
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
z=[get(hObject,'Value') get(handles.moutCheck,'Value') get(handles.ttCheck,'Value')];
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


function moutCheck_Callback(hObject, eventdata, handles)

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
z=[get(handles.nfoldCheck,'Value') get(hObject,'Value') get(handles.ttCheck,'Value')];
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


function ttCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.ttstatic,'Enable','on')
    set(handles.ttEdit,'Enable','on')
    handles.validmethod{3}='holdout';
    handles.validparam(3)=str2double(get(handles.ttEdit,'String'))/100;
    handles.validname{3}='Training and Test Hold Out';
else
    set(handles.ttstatic,'Enable','off')
    set(handles.ttEdit,'Enable','off')
    handles.validmethod{3}='';
    handles.validparam(3)=NaN;
    handles.validname{3}='';
end
z=[get(handles.nfoldCheck,'Value') get(handles.moutCheck,'Value') get(hObject,'Value')];
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


function ttEdit_Callback(hObject, eventdata, handles)

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


function ttEdit_CreateFcn(hObject, eventdata, handles)

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

% Return properly arranged validation methods (for tunesvm)
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
uiresume(handles.SVMTuneEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.kernel={'linear'};
handles.kernelName={'Linear'};
handles.normalize=false;
handles.scale=false;
handles.scalevals=[];
handles.tol=0.001;
handles.polyParams={[1 0 3]};
handles.mlpParams={[1 0]};
handles.rbfParams=1;
handles.validmethod={'kfold'};
handles.validparam=5;
handles.validname={'N-fold cross validation'};
handles.showplot=true;
handles.showresult=true;
handles.verbose=false;
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.SVMTuneEditor);


%%%%%%%%%% HELP FUNCTIONS %%%%%%%%%%

function n = checkval(v)

if length(v)>1
    if ismember(1,v)
        n=1;
    else
        n=min(v)-1;
    end
else
    if v==1
        n=1;
    else
        n=v-1;
    end
end
