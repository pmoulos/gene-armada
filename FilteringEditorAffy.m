function varargout = FilteringEditorAffy(varargin)
% FILTERINGEDITORAFFY M-file for FilteringEditorAffy.fig
%      FILTERINGEDITORAFFY, by itself, creates a new FILTERINGEDITORAFFY or raises the existing
%      singleton*.
%
%      H = FILTERINGEDITORAFFY returns the handle to a new FILTERINGEDITORAFFY or the handle to
%      the existing singleton*.
%
%      FILTERINGEDITORAFFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILTERINGEDITORAFFY.M with the given input arguments.
%
%      FILTERINGEDITORAFFY('Property','Value',...) creates a new FILTERINGEDITORAFFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FilteringEditorAffy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FilteringEditorAffy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FilteringEditorAffy

% Last Modified by GUIDE v2.5 22-Oct-2008 18:15:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FilteringEditorAffy_OpeningFcn, ...
                   'gui_OutputFcn',  @FilteringEditorAffy_OutputFcn, ...
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


% --- Executes just before FilteringEditorAffy is made visible.
function FilteringEditorAffy_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.FilteringEditorAffy,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.FilteringEditorAffy,'Position',winpos);

% Set defaults
handles.alpha=0.05;            % Present call Wilcoxon cutoff
handles.tau=0.015;             % MAS5 constant cutoff
handles.alphalims=[0.04 0.06]; % Limits for MAS5 P, A, or M
handles.margasabs=true;        % Marginal as absents
handles.iqr=[];                % IQR below percentile
handles.var=[];                % Variance below percentile  
handles.inten=[];              % Intensity cutoff
handles.custom='';             % No custom filter
handles.nofilt=false;          % Filtering or not 
handles.export=false;          % Do not export filtered genes
handles.usewaitbar=true;       % Do not use waitbars
handles.outlierTest='none';    % None
handles.pval=[];               % Since test defaults to none
handles.dishis=false;          % Do not display histograms
handles.cancel=false;          % Cancel not pressed

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FilteringEditorAffy wait for user response (see UIRESUME)
uiwait(handles.FilteringEditorAffy);


% --- Outputs from this function are returned to the command line.
function varargout = FilteringEditorAffy_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.FilteringEditorAffy);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.FilteringEditorAffy);
end

varargout{1}=handles.alpha;
varargout{2}=handles.tau;
varargout{3}=handles.alphalims;
varargout{4}=handles.margasabs;
varargout{5}=handles.iqr;
varargout{6}=handles.var;
varargout{7}=handles.inten;
varargout{8}=handles.custom;
varargout{9}=handles.nofilt;
varargout{10}=handles.export;
varargout{11}=handles.usewaitbar;
varargout{12}=handles.outlierTest;
varargout{13}=handles.pval;
varargout{14}=handles.dishis;
varargout{15}=handles.cancel;


function pCallCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.pCallAlphaStatic,'Enable','on')
    set(handles.pCallTauStatic,'Enable','on')
    set(handles.pCallMarginStatic,'Enable','on')
    set(handles.pCallLowStatic,'Enable','on')
    set(handles.pCallUpStatic,'Enable','on')
    set(handles.pCallAlphaEdit,'Enable','on')
    set(handles.pCallTauEdit,'Enable','on')
    set(handles.pCallLowEdit,'Enable','on')
    set(handles.pCallUpEdit,'Enable','on')
    set(handles.margAsAbsCheck,'Enable','on')
    handles.alpha=str2double(get(handles.pCallAlphaEdit,'String'));
    handles.tau=str2double(get(handles.pCallTauEdit,'String'));
    handles.alphalims(1)=str2double(get(handles.pCallLowEdit,'String'));
    handles.alphalims(2)=str2double(get(handles.pCallUpEdit,'String'));
else
    set(handles.pCallAlphaStatic,'Enable','off')
    set(handles.pCallTauStatic,'Enable','off')
    set(handles.pCallMarginStatic,'Enable','off')
    set(handles.pCallLowStatic,'Enable','off')
    set(handles.pCallUpStatic,'Enable','off')
    set(handles.pCallAlphaEdit,'Enable','off')
    set(handles.pCallTauEdit,'Enable','off')
    set(handles.pCallLowEdit,'Enable','off')
    set(handles.pCallUpEdit,'Enable','off')
    set(handles.margAsAbsCheck,'Enable','off')
    handles.alpha=[];
    handles.tau=[];
    handles.alphalims=[];
end
checkCheck(handles);
guidata(hObject,handles);


function margAsAbsCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.margasabs=true;
else
    handles.margasabs=false;
end
guidata(hObject,handles);


function iqrCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.iqrStatic,'Enable','on')
    set(handles.iqrEdit,'Enable','on')
    handles.iqr=str2double(get(handles.iqrEdit,'String'));
else
    set(handles.iqrStatic,'Enable','off')
    set(handles.iqrEdit,'Enable','off')
    handles.iqr=[];
end
checkCheck(handles);
guidata(hObject,handles);


function varCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.varStatic,'Enable','on')
    set(handles.varEdit,'Enable','on')
    handles.var=str2double(get(handles.varEdit,'String'));
else
    set(handles.varStatic,'Enable','off')
    set(handles.varEdit,'Enable','off')
    handles.var=[];
end
checkCheck(handles);
guidata(hObject,handles);


function intenCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.intenStatic,'Enable','on')
    set(handles.intenEdit,'Enable','on')
    handles.inten=str2double(get(handles.intenEdit,'String'));
else
    set(handles.intenStatic,'Enable','off')
    set(handles.intenEdit,'Enable','off')
    handles.inten=[];
end
guidata(hObject,handles);


function customCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.customEdit,'Enable','on')
    set(handles.pCallCheck,'Enable','off')
    set(handles.pCallAlphaStatic,'Enable','off')
    set(handles.pCallTauStatic,'Enable','off')
    set(handles.pCallMarginStatic,'Enable','off')
    set(handles.pCallLowStatic,'Enable','off')
    set(handles.pCallUpStatic,'Enable','off')
    set(handles.pCallAlphaEdit,'Enable','off')
    set(handles.pCallTauEdit,'Enable','off')
    set(handles.pCallLowEdit,'Enable','off')
    set(handles.pCallUpEdit,'Enable','off')
    set(handles.margAsAbsCheck,'Enable','off')
    set(handles.iqrCheck,'Enable','off')
    set(handles.iqrStatic,'Enable','off')
    set(handles.iqrEdit,'Enable','off')
    set(handles.varCheck,'Enable','off')
    set(handles.varStatic,'Enable','off')
    set(handles.varEdit,'Enable','off')
    set(handles.intenCheck,'Enable','off')
    set(handles.intenStatic,'Enable','off')
    set(handles.intenEdit,'Enable','off')
    handles.alpha=[];
    handles.tau=[];
    handles.alphalims=[];
    handles.iqr=[];
    handles.var=[];
    handles.inten=[];
else
    set(handles.customEdit,'Enable','off')
    set(handles.pCallCheck,'Enable','on')
    set(handles.iqrCheck,'Enable','on')
    set(handles.varCheck,'Enable','on')
    set(handles.intenCheck,'Enable','on')
    if get(handles.pCallCheck,'Value')==1
        set(handles.pCallAlphaStatic,'Enable','on')
        set(handles.pCallTauStatic,'Enable','on')
        set(handles.pCallMarginStatic,'Enable','on')
        set(handles.pCallLowStatic,'Enable','on')
        set(handles.pCallUpStatic,'Enable','on')
        set(handles.pCallAlphaEdit,'Enable','on')
        set(handles.pCallTauEdit,'Enable','on')
        set(handles.pCallLowEdit,'Enable','on')
        set(handles.pCallUpEdit,'Enable','on')
        set(handles.margAsAbsCheck,'Enable','on')
        handles.alpha=str2double(get(handles.pCallAlphaEdit,'String'));
        handles.tau=str2double(get(handles.pCallTauEdit,'String'));
        handles.alphalims(1)=str2double(get(handles.pCallLowEdit,'String'));
        handles.alphalims(2)=str2double(get(handles.pCallUpEdit,'String'));
    end
    if get(handles.iqrCheck,'Value')==1
        set(handles.iqrStatic,'Enable','on')
        set(handles.iqrEdit,'Enable','on')
        handles.iqr=str2double(get(handles.iqrEdit,'String'));
    end
    if get(handles.varCheck,'Value')==1
        set(handles.varStatic,'Enable','on')
        set(handles.varEdit,'Enable','on')
        handles.var=str2double(get(handles.varEdit,'String'));
    end
    if get(handles.intenCheck,'Value')==1
        set(handles.intenStatic,'Enable','on')
        set(handles.intenEdit,'Enable','on')
        handles.inten=str2double(get(handles.intenEdit,'String'));
    end
end
guidata(hObject,handles);


function nofiltCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.pCallCheck,'Enable','off')
    set(handles.pCallAlphaStatic,'Enable','off')
    set(handles.pCallTauStatic,'Enable','off')
    set(handles.pCallMarginStatic,'Enable','off')
    set(handles.pCallLowStatic,'Enable','off')
    set(handles.pCallUpStatic,'Enable','off')
    set(handles.pCallAlphaEdit,'Enable','off')
    set(handles.pCallTauEdit,'Enable','off')
    set(handles.pCallLowEdit,'Enable','off')
    set(handles.pCallUpEdit,'Enable','off')
    set(handles.margAsAbsCheck,'Enable','off')
    set(handles.iqrCheck,'Enable','off')
    set(handles.iqrStatic,'Enable','off')
    set(handles.iqrEdit,'Enable','off')
    set(handles.varCheck,'Enable','off')
    set(handles.varStatic,'Enable','off')
    set(handles.varEdit,'Enable','off')
    set(handles.intenCheck,'Enable','off')
    set(handles.intenStatic,'Enable','off')
    set(handles.intenEdit,'Enable','off')
    set(handles.customCheck,'Enable','off')
    set(handles.customEdit,'Enable','off')
    set(handles.outlierPopup,'Enable','off')
    set(handles.pcutStatic,'Enable','off')
    set(handles.pcutEdit,'Enable','off')
    set(handles.disphistCheck,'Enable','off')
    handles.nofilt=true;
    handles.alpha=[];
    handles.tau=[];
    handles.alphalims=[];
    handles.iqr=[];
    handles.var=[];
    handles.inten=[];
    handles.custom='';
else
    set(handles.pCallCheck,'Enable','on')
    set(handles.iqrCheck,'Enable','on')
    set(handles.varCheck,'Enable','on')
    set(handles.intenCheck,'Enable','on')
    set(handles.customCheck,'Enable','on')
    if get(handles.pCallCheck,'Value')==1
        set(handles.pCallAlphaStatic,'Enable','on')
        set(handles.pCallTauStatic,'Enable','on')
        set(handles.pCallMarginStatic,'Enable','on')
        set(handles.pCallLowStatic,'Enable','on')
        set(handles.pCallUpStatic,'Enable','on')
        set(handles.pCallAlphaEdit,'Enable','on')
        set(handles.pCallTauEdit,'Enable','on')
        set(handles.pCallLowEdit,'Enable','on')
        set(handles.pCallUpEdit,'Enable','on')
        set(handles.margAsAbsCheck,'Enable','on')
        handles.alpha=str2double(get(handles.pCallAlphaEdit,'String'));
        handles.tau=str2double(get(handles.pCallTauEdit,'String'));
        handles.alphalims(1)=str2double(get(handles.pCallLowEdit,'String'));
        handles.alphalims(2)=str2double(get(handles.pCallUpEdit,'String'));
    end
    if get(handles.iqrCheck,'Value')==1
        set(handles.iqrStatic,'Enable','on')
        set(handles.iqrEdit,'Enable','on')
        handles.iqr=str2double(get(handles.iqrEdit,'String'));
    end
    if get(handles.varCheck,'Value')==1
        set(handles.varStatic,'Enable','on')
        set(handles.varEdit,'Enable','on')
        handles.var=str2double(get(handles.varEdit,'String'));
    end
    if get(handles.intenCheck,'Value')==1
        set(handles.intenStatic,'Enable','on')
        set(handles.intenEdit,'Enable','on')
        handles.inten=str2double(get(handles.intenEdit,'String'));
    end
    if get(handles.customCheck,'Value')==1
        set(handles.customEdit,'Enable','on')
        handles.custom=get(handles.customEdit,'String');
    end
    set(handles.outlierPopup,'Enable','on')
    if get(handles.outlierPopup,'Value')==1
        set(handles.pcutStatic,'Enable','off')
        set(handles.pcutEdit,'Enable','off')
        set(handles.disphistCheck,'Enable','off')
    else
        set(handles.pcutStatic,'Enable','on')
        set(handles.pcutEdit,'Enable','on')
        set(handles.disphistCheck,'Enable','on')
    end
    handles.nofilt=false;
end
guidata(hObject,handles);


function pCallAlphaEdit_Callback(hObject, eventdata, handles)

p=str2double(get(hObject,'String'));
if isnan(p) || p<0 || p>1
    uiwait(errordlg('Alpha must be a number between 0 and 1','Bad Input','modal'));
    set(hObject,'String','0.05');
else
    handles.alpha=p;
end
guidata(hObject,handles);


function pCallAlphaEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pCallTauEdit_Callback(hObject, eventdata, handles)

t=str2double(get(hObject,'String'));
if isnan(t) || t<0
    uiwait(errordlg('Tau must be a positive number','Bad Input','modal'));
    set(hObject,'String','0.015');
else
    handles.tau=t;
end
guidata(hObject,handles);


function pCallTauEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pCallLowEdit_Callback(hObject, eventdata, handles)

p=str2double(get(hObject,'String'));
if isnan(p) || p<0 || p>1
    uiwait(errordlg('Lower alpha limit must be a number between 0 and 1','Bad Input','modal'));
    set(hObject,'String','0.04');
else
    handles.alphalims(1)=p;
end
guidata(hObject,handles);


function pCallLowEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pCallUpEdit_Callback(hObject, eventdata, handles)

p=str2double(get(hObject,'String'));
if isnan(p) || p<0 || p>1
    uiwait(errordlg('Upper alpha limit must be a number between 0 and 1','Bad Input','modal'));
    set(hObject,'String','0.06');
else
    handles.alphalims(2)=p;
end
guidata(hObject,handles);


function pCallUpEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function iqrEdit_Callback(hObject, eventdata, handles)

iq=str2double(get(hObject,'String'));
if isnan(iq) || iq<0 || iq>100
    uiwait(errordlg('IQR percentile must be a number between 0 and 100','Bad Input','modal'));
    set(hObject,'String','10');
else
    handles.iqr=iq;
end
guidata(hObject,handles);


function iqrEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function varEdit_Callback(hObject, eventdata, handles)

v=str2double(get(hObject,'String'));
if isnan(v) || v<0 || v>100
    uiwait(errordlg('Variance percentile must be a number between 0 and 100','Bad Input','modal'));
    set(hObject,'String','10');
else
    handles.var=v;
end
guidata(hObject,handles);


function varEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function intenEdit_Callback(hObject, eventdata, handles)

in=str2double(get(hObject,'String'));
if isnan(in) || in<0
    uiwait(errordlg('Intensity cutoff must be a number between 0 and 100','Bad Input','modal'));
    set(hObject,'String','100');
else
    handles.inten=in;
end
guidata(hObject,handles);


function intenEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function customEdit_Callback(hObject, eventdata, handles)

expr=get(hObject,'String');
exprok=checkExpression(expr);
if exprok
    handles.custom=expr;
else
    set(handles.customEdit,'String','Your filter here')
end
guidata(hObject,handles);


function customEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function exportFiltCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.export=true;
else
    handles.export=false;
end
guidata(hObject,handles);


function useWaitCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.usewaitbar=true;
else
    handles.usewaitbar=false;
end
guidata(hObject,handles);


function outlierPopup_Callback(hObject, eventdata, handles)

outstat=get(hObject,'Value');
switch outstat;
    case 1
        handles.outlierTest='none'; % No test
        handles.pval=[];
        set(handles.pcutStatic,'Enable','off')
        set(handles.pcutEdit,'Enable','off')
        set(handles.disphistCheck,'Enable','off')
    case 2
        handles.outlierTest='t-test'; % t-test
        set(handles.pcutStatic,'Enable','on')
        set(handles.pcutEdit,'Enable','on')
        handles.pval=str2double(get(handles.pcutEdit,'String'));
        set(handles.disphistCheck,'Enable','on')
    case 3
        handles.outlierTest='wilcoxon'; % Wilcoxon
        set(handles.pcutStatic,'Enable','on')
        set(handles.pcutEdit,'Enable','on')
        handles.pval=str2double(get(handles.pcutEdit,'String'));
        set(handles.disphistCheck,'Enable','on')
end
guidata(hObject,handles);


function outlierPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pcutEdit_Callback(hObject, eventdata, handles)

p=str2double(get(hObject,'String'));
if isnan(p) || p<0 || p>1
    uiwait(errordlg('p-value cutoff must be a number between 0 and 1','Bad Input','modal'));
    set(hObject,'String','0.05');
else
    handles.pval=p;
end
guidata(hObject,handles);


function pcutEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function disphistCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dishis=true;
else
    handles.dishis=false;
end
guidata(hObject,handles);


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.FilteringEditorAffy);


function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
handles.alpha=0.05;
handles.tau=0.015;
handles.alphalims=[0.04 0.06];
handles.margasabs=true;
handles.iqr=[];
handles.var=[];
handles.inten=[];
handles.custom='';
handles.export=false;
handles.usewaitbar=true;
handles.nofilt=false;
handles.outlierTest='none';
handles.pval=[];
handles.dishis=false;
handles.cancel=true;  % User pressed cancel
guidata(hObject,handles);
uiresume(handles.FilteringEditorAffy);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   HELP FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allok = checkExpression(expr)

% PA : Present Calls Alpha
% PT : Present Calls Tau
% PL : Present Calls Lower Alpha
% PU : Present Calls Upper Alpha
% IR : Interquartile Range
% VR : VaRiance
% IN : Intensity
% % PM : Perfect Match Intensity
% % MM : MisMatch Intensity

% If the expression is OK allok is true else false
allok=true;

% Form error messages
errmsg1={'Your filter expression is probably malformed.',...
         'Please check your expression again.'};
     
% Preallocate some random numbers to check the validity of the expression
pa=1;
pt=1;
pl=1;
pu=1;
ir=1;
vr=1;
in=1;

expr=strrep(expr,'*','.*');
expr=strrep(expr,'/','./');
expr=strrep(expr,'=','==');
expr=strrep(expr,'PA','pa');
expr=strrep(expr,'PT','pt');
expr=strrep(expr,'PL','pl');
expr=strrep(expr,'PU','pu');
expr=strrep(expr,'IR','ir');
expr=strrep(expr,'VR','vr');
expr=strrep(expr,'IN','in');
expr=[expr ';'];
try
    eval(expr);
catch
    allok=false;
    uiwait(errordlg([errmsg1,lasterr],'Bad Input','modal'));
end


function checkCheck(stru)

if get(stru.pCallCheck,'Value')==0 && get(stru.iqrCheck,'Value')==0 && ...
   get(stru.varCheck,'Value')==0 && get(stru.intenCheck,'Value')==0 && ...
   get(stru.customCheck,'Value')==0 && get(stru.nofiltCheck,'Value')==0
    set(stru.okButton,'Enable','off')
else
    set(stru.okButton,'Enable','on')
end
