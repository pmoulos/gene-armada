function varargout = FilteringEditorIllumina(varargin)
% FILTERINGEDITORILLUMINA M-file for FilteringEditorIllumina.fig
%      FILTERINGEDITORILLUMINA, by itself, creates a new FILTERINGEDITORILLUMINA or raises the existing
%      singleton*.
%
%      H = FILTERINGEDITORILLUMINA returns the handle to a new FILTERINGEDITORILLUMINA or the handle to
%      the existing singleton*.
%
%      FILTERINGEDITORILLUMINA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILTERINGEDITORILLUMINA.M with the given input arguments.
%
%      FILTERINGEDITORILLUMINA('Property','Value',...) creates a new FILTERINGEDITORILLUMINA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FilteringEditorIllumina_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FilteringEditorIllumina_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FilteringEditorIllumina

% Last Modified by GUIDE v2.5 12-Feb-2010 15:30:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FilteringEditorIllumina_OpeningFcn, ...
                   'gui_OutputFcn',  @FilteringEditorIllumina_OutputFcn, ...
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


% --- Executes just before FilteringEditorIllumina is made visible.
function FilteringEditorIllumina_OpeningFcn(hObject, eventdata, handles, varargin)
% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.FilteringEditorIllumina,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.FilteringEditorIllumina,'Position',winpos);

% Set defaults
handles.alphalims=[0.98 0.99]; % Limits for MAS5 P, A, or M
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
uiwait(handles.FilteringEditorIllumina);


% --- Outputs from this function are returned to the command line.
function varargout = FilteringEditorIllumina_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.FilteringEditorIllumina);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.FilteringEditorIllumina);
end

varargout{1}=handles.alphalims;
varargout{2}=handles.margasabs;
varargout{3}=handles.iqr;
varargout{4}=handles.var;
varargout{5}=handles.inten;
varargout{6}=handles.custom;
varargout{7}=handles.nofilt;
varargout{8}=handles.export;
varargout{9}=handles.usewaitbar;
varargout{10}=handles.outlierTest;
varargout{11}=handles.pval;
varargout{12}=handles.dishis;
varargout{13}=handles.cancel;


function pCallCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    set(handles.pCallMarginStatic,'Enable','on')
    set(handles.pCallLowStatic,'Enable','on')
    set(handles.pCallUpStatic,'Enable','on')
    set(handles.pCallLowEdit,'Enable','on')
    set(handles.pCallUpEdit,'Enable','on')
    set(handles.margAsAbsCheck,'Enable','on')
    handles.alphalims(1)=str2double(get(handles.pCallLowEdit,'String'));
    handles.alphalims(2)=str2double(get(handles.pCallUpEdit,'String'));
else
    set(handles.pCallMarginStatic,'Enable','off')
    set(handles.pCallLowStatic,'Enable','off')
    set(handles.pCallUpStatic,'Enable','off')
    set(handles.pCallLowEdit,'Enable','off')
    set(handles.pCallUpEdit,'Enable','off')
    set(handles.margAsAbsCheck,'Enable','off')
    handles.alphalims=[];
end
checkCheck(handles);
guidata(hObject,handles);


function pCallLowEdit_Callback(hObject, eventdata, handles)

p=str2double(get(hObject,'String'));
if isnan(p) || p<0 || p>1
    uiwait(errordlg('Lower detection limit must be a number between 0 and 1','Bad Input','modal'));
    set(hObject,'String','0.98');
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
    uiwait(errordlg('Upper detection limit must be a number between 0 and 1','Bad Input','modal'));
    set(hObject,'String','0.99');
else
    handles.alphalims(2)=p;
end
guidata(hObject,handles);


function pCallUpEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
    set(handles.pCallMarginStatic,'Enable','off')
    set(handles.pCallLowStatic,'Enable','off')
    set(handles.pCallUpStatic,'Enable','off')
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
        set(handles.pCallMarginStatic,'Enable','on')
        set(handles.pCallLowStatic,'Enable','on')
        set(handles.pCallUpStatic,'Enable','on')
        set(handles.pCallLowEdit,'Enable','on')
        set(handles.pCallUpEdit,'Enable','on')
        set(handles.margAsAbsCheck,'Enable','on')
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
    set(handles.pCallMarginStatic,'Enable','off')
    set(handles.pCallLowStatic,'Enable','off')
    set(handles.pCallUpStatic,'Enable','off')
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
        set(handles.pCallLowStatic,'Enable','on')
        set(handles.pCallUpStatic,'Enable','on')
        set(handles.pCallLowEdit,'Enable','on')
        set(handles.pCallUpEdit,'Enable','on')
        set(handles.margAsAbsCheck,'Enable','on')
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


function iqrEdit_Callback(hObject, eventdata, handles)




function iqrEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function varEdit_Callback(hObject, eventdata, handles)


function varEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function intenEdit_Callback(hObject, eventdata, handles)


function intenEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function customEdit_Callback(hObject, eventdata, handles)


function customEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function exportFiltCheck_Callback(hObject, eventdata, handles)


function useWaitCheck_Callback(hObject, eventdata, handles)


function outlierPopup_Callback(hObject, eventdata, handles)


function outlierPopup_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pcutEdit_Callback(hObject, eventdata, handles)


function pcutEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function disphistCheck_Callback(hObject, eventdata, handles)


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.FilteringEditorIllumina);


function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
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
uiresume(handles.FilteringEditorIllumina);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   HELP FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allok = checkExpression(expr)

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
pl=1;
pu=1;
ir=1;
vr=1;
in=1;

expr=strrep(expr,'*','.*');
expr=strrep(expr,'/','./');
expr=strrep(expr,'=','==');
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
