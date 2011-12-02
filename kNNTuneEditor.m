function varargout = kNNTuneEditor(varargin)
% KNNTUNEEDITOR M-file for kNNTuneEditor.fig
%      KNNTUNEEDITOR, by itself, creates a new KNNTUNEEDITOR or raises the existing
%      singleton*.
%
%      H = KNNTUNEEDITOR returns the handle to a new KNNTUNEEDITOR or the handle to
%      the existing singleton*.
%
%      KNNTUNEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KNNTUNEEDITOR.M with the given input arguments.
%
%      KNNTUNEEDITOR('Property','Value',...) creates a new KNNTUNEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kNNTuneEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kNNTuneEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kNNTuneEditor

% Last Modified by GUIDE v2.5 27-Mar-2008 15:09:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kNNTuneEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @kNNTuneEditor_OutputFcn, ...
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


% --- Executes just before kNNTuneEditor is made visible.
function kNNTuneEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.kNNTuneEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.kNNTuneEditor,'Position',winpos);

% Get inputs
handles.maxs=varargin{1}; % Should not exceed number of available samples

% Set default outputs
handles.krange=1:10;                           % Default range of NNs
handles.distance={'euclidean'};                % Default distance
handles.rule={'nearest'};                      % Default tie break rule
handles.validmethod={'kfold'};                 % Default validation - n-fold cross validation
handles.validparam=[5 NaN NaN];                % Default n (5) for n-fold cross validation
handles.validname={'N-fold cross validation'}; % Default model validation
handles.showplot=true;                         % Display evaluation plots
handles.showresult=true;                       % Display evaluation results
handles.verbose=false;                         % Do not display verbose messages
handles.cancel=false;                          % User did not press cancel 

% If the number of available samples is less than the default krange, adjust the latter
if max(handles.krange)>handles.maxs-1
    handles.krange=1:handles.maxs-1;
    set(handles.kRangeEdit,'String',['1:',num2str(handles.maxs-1)])
end
% If the number of available samples is less than the default n in n-fold validation,
% adjust it
if handles.validparam>handles.maxs
    handles.validparam=handles.maxs;
    set(handles.nfoldEdit,'String',num2str(handles.maxs))
end
% If the number of nearest neighbors conflicts with n in n-fold validation, adjust it.
% Generally, if we have n samples, m fold validation and k nns, then k<=floor(n/m)
if max(handles.krange)>floor(handles.maxs/handles.validparam(~isnan(handles.validparam)))
    kk=floor(handles.maxs/handles.validparam(~isnan(handles.validparam)));
    handles.krange=1:kk;
    set(handles.kRangeEdit,'String',['1:',num2str(kk)])
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes kNNTuneEditor wait for user response (see UIRESUME)
uiwait(handles.kNNTuneEditor);


% --- Outputs from this function are returned to the command line.
function varargout = kNNTuneEditor_OutputFcn(hObject, eventdata, handles)

if (get(handles.cancelButton,'Value')==0)
    delete(handles.kNNTuneEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.kNNTuneEditor);
end

varargout{1}=handles.krange;
varargout{2}=handles.distance;
varargout{3}=handles.rule;
varargout{4}=handles.validmethod;
varargout{5}=handles.validparam;
varargout{6}=handles.validname;
varargout{7}=handles.showplot;
varargout{8}=handles.showresult;
varargout{9}=handles.verbose;
varargout{10}=handles.cancel;


function kRangeEdit_Callback(hObject, eventdata, handles)

val=str2num(get(hObject,'String'));
if isempty(val) || max(val)<=0 || ~all(rem(val,1)==0)
    uiwait(errordlg('The range of nearest neighbors must contain positive integer values.',...
                    'Bad Input'));
    set(hObject,'String','1:10')
    handles.krange=str2num(get(hObject,'String'));
elseif max(val)>handles.maxs-1
    uiwait(errordlg({'The range of nearest neighbors cannot be larger than',...
                     'the number of samples in the training set minus one.'},...
                     'Bad Input'));
    set(hObject,'String',['1:',num2str(handles.maxs-1)])
    handles.krange=str2num(get(hObject,'String'));
elseif get(handles.nfoldCheck,'Value')==1 && max(val)>floor(handles.maxs/handles.validparam(1))
    uiwait(errordlg({'The maximum number of nearest neighbors cannot be larger than',...
                     '#Samples/#Fold Validations - 1. Range will be auto-adjusted.'},...
                     'Bad Input'));
    kk=floor(handles.maxs/handles.validparam(1));
    set(hObject,'String',['1:',num2str(kk)])
    handles.krange=str2num(get(hObject,'String'));
else
    handles.krange=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function kRangeEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in distanceList.
function distanceList_Callback(hObject, eventdata, handles)

distances=get(hObject,'String');
handles.distance=distances(get(hObject,'Value'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function distanceList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ruleList_Callback(hObject, eventdata, handles)

rules=get(hObject,'String');
handles.rule=rules(get(hObject,'Value'));
guidata(hObject,handles);


function ruleList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nfoldCheck.
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
z=[get(hObject,'Value') get(handles.leaveMoutCheck,'Value') get(handles.ttCheck,'Value')];
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
elseif val>handles.maxs/max(str2num(get(handles.kRangeEdit,'String')));
    uiwait(errordlg({'The number of cross validation times cannot be larger',...
                     'than #Samples/#NNs. Value will be auto adjusted.'},...
                     'Bad Input'));
    set(hObject,'String',num2str(floor(handles.maxs/max(str2num(get(handles.kRangeEdit,'String'))))));
    handles.validparam(1)=str2double(get(hObject,'String'));
else
    handles.validparam(1)=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function nfoldEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in leaveMoutCheck.
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
elseif val>handles.maxs/max(str2num(get(handles.kRangeEdit,'String')));
    uiwait(errordlg({'The number of leave out samples cannot be larger',...
                     'than #Samples/#NNs. Value will be auto adjusted.'},...
                     'Bad Input'));
    set(hObject,'String',num2str(floor(handles.maxs/max(str2num(get(handles.kRangeEdit,'String'))))));
    handles.validparam(2)=str2double(get(hObject,'String'));
else
    handles.validparam(2)=val;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function moutEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ttCheck.
function ttCheck_Callback(hObject, eventdata, handles)

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


% --- Executes during object creation, after setting all properties.
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

if max(handles.krange)==0 || ~any(handles.validparam)
    uiwait(warndlg({'Number of nearest neighbors, cross validation times and leave out',...
                    'samples cannot be 0. Your dataset might not be suitable for this',...
                    'kind of analysis. Consider simple statistical selection either.'},...
                    'Warning'));
    return
end
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
uiresume(handles.kNNTuneEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.krange=1:10; 
handles.distance={'euclidean'};
handles.rule={'nearest'};
handles.validmethod={'kfold'};
handles.validparam=5;
handles.validname={'N-fold cross validation'};
handles.showplot=true;
handles.showresult=true;
handles.verbose=false;
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.kNNTuneEditor);
