function varargout = FilteringEditor(varargin)
% FILTERINGEDITOR M-file for FilteringEditor.fig
%      FILTERINGEDITOR, by itself, creates a new FILTERINGEDITOR or raises the existing
%      singleton*.
%
%      H = FILTERINGEDITOR returns the handle to a new FILTERINGEDITOR or the handle to
%      the existing singleton*.
%
%      FILTERINGEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILTERINGEDITOR.M with the given input arguments.
%
%      FILTERINGEDITOR('Property','Value',...) creates a new FILTERINGEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FilteringEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FilteringEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FilteringEditor

% Last Modified by GUIDE v2.5 10-May-2007 19:44:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FilteringEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @FilteringEditor_OutputFcn, ...
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


% --- Executes just before FilteringEditor is made visible.
function FilteringEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Take as input the image analysis software in order to control whether to use means or
% medians
handles.imgsw=varargin{1};

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.FilteringEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.FilteringEditor,'Position',winpos);

% Set default outputs
handles.export=0;          % By default, do not export filtered spots
handles.meanmedian=1;      % Use means by default
handles.filterMethod=1;    % Signal to noise filter
handles.filterParameter=2; % For signal to noise
handles.outlierTest=0;     % None
handles.pval=[];           % Since test defaults to none
handles.dishis=0;          % Do not display histograms
handles.cancel=false;      % Cancel not pressed

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FilteringEditor wait for user response (see UIRESUME)
uiwait(handles.FilteringEditor);


% --- Outputs from this function are returned to the command line.
function varargout = FilteringEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.FilteringEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.FilteringEditor);
end

% Get default command line output from handles structure
varargout{1}=handles.export;
varargout{2}=handles.meanmedian;
varargout{3}=handles.filterMethod;
varargout{4}=handles.filterParameter;
varargout{5}=handles.outlierTest;
varargout{6}=handles.pval;
varargout{7}=handles.dishis;
varargout{8}=handles.cancel;


% --- Executes on button press in meanmedianCheck.
function meanmedianCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.meanmedian=2;
else
    handles.meanmedian=1;
end
guidata(hObject,handles);


% --- Executes on button press in exportExcel.
function exportExcel_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.export=1;
else
    handles.export=0;
end
guidata(hObject,handles);


% --- Executes on button press in noFilterRadio.
function noFilterRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    % In case user leaves the default values
    handles.filterMethod=4;
    handles.filterParameter=[];
    % Disable improper textboxes
    set(handles.s2nthreshEdit,'Enable','off')
    set(handles.text1,'Enable','off')
    set(handles.sigbackDistSigEdit,'Enable','off')
    set(handles.text2,'Enable','off')
    set(handles.sigbackDistBackEdit,'Enable','off')
    set(handles.customEdit,'Enable','off')
end
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of noFilterRadio


% --- Executes on button press in s2nthreshRadio.
function s2nthreshRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    % Enable proper textboxes
    set(handles.s2nthreshEdit,'Enable','on')
    % In case user leaves the default values
    handles.filterMethod=1;
    handles.filterParameter=2;
    % Disable improper textboxes
    set(handles.text1,'Enable','off')
    set(handles.sigbackDistSigEdit,'Enable','off')
    set(handles.text2,'Enable','off')
    set(handles.sigbackDistBackEdit,'Enable','off')
    set(handles.customEdit,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in sigbackDistRadio.
function sigbackDistRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    % Enable proper textboxes
    set(handles.text1,'Enable','on')
    set(handles.sigbackDistSigEdit,'Enable','on')
    set(handles.text2,'Enable','on')
    set(handles.sigbackDistBackEdit,'Enable','on')
    % In case user leaves the default values
    handles.filterMethod=2;
    handles.filterParameter=[0 0];
    % Disable improper textboxes
    set(handles.s2nthreshEdit,'Enable','off')
    set(handles.customEdit,'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in customRadio.
function customRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    % Enable proper textboxes
    set(handles.customEdit,'Enable','on')
    handles.filterMethod=2;
    % Disable improper textboxes
    set(handles.s2nthreshEdit,'Enable','off')
    set(handles.text1,'Enable','off')
    set(handles.sigbackDistSigEdit,'Enable','off')
    set(handles.text2,'Enable','off')
    set(handles.sigbackDistBackEdit,'Enable','off')
end
guidata(hObject,handles);


function s2nthreshEdit_Callback(hObject, eventdata, handles)

t=str2double(get(hObject,'String'));
if isnan(t) || t<=0
    uiwait(errordlg('You must enter a positive number','Bad Input','modal'));
    set(hObject,'String','2');
else
    handles.filterMethod=1;
    handles.filterParameter=2;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function s2nthreshEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sigbackDistSigEdit_Callback(hObject, eventdata, handles)

x=str2double(get(hObject,'String'));
if isnan(x)
    uiwait(errordlg('You must enter a number','Bad Input','modal'));
    set(hObject,'String','0');
else
    handles.filterMethod=2;
    handles.filterParameter(1)=x;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function sigbackDistSigEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sigbackDistBackEdit_Callback(hObject, eventdata, handles)

y=str2double(get(hObject,'String'));
if isnan(y)
    uiwait(errordlg('You must enter a number','Bad Input','modal'));
    set(hObject,'String','0');
else
    handles.filterMethod=2;
    handles.filterParameter(2)=y;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function sigbackDistBackEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function customEdit_Callback(hObject, eventdata, handles)

expr=get(hObject,'String');
exprok=checkExpression(expr,handles.imgsw,handles.meanmedian);
if exprok
    handles.filterMethod=3;
    handles.filterParameter=expr;
else
    set(handles.customEdit,'String','Your filter here')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function customEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in outlierPopup.
function outlierPopup_Callback(hObject, eventdata, handles)

outstat=get(hObject,'Value');
switch outstat;
    case 1
        handles.outlierTest=0; % No test
    case 2
        handles.outlierTest=2; % t-test
        set(handles.text4,'Enable','on')
        set(handles.pvalcutoff,'Enable','on')
        handles.pval=str2double(get(handles.pvalcutoff,'String'));
        set(handles.dispOutlierHist,'Enable','on')
    case 3
        handles.outlierTest=1; % Wilcoxon
        set(handles.text4,'Enable','on')
        set(handles.pvalcutoff,'Enable','on')
        handles.pval=str2double(get(handles.pvalcutoff,'String'));
        set(handles.dispOutlierHist,'Enable','on')
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function outlierPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pvalcutoff_Callback(hObject, eventdata, handles)

p=str2double(get(hObject,'String'));
if isnan(p) || p<0 || p>1
    uiwait(errordlg('You must enter a number between 0 and 1','Bad Input','modal'));
    set(hObject,'String','0.05');
else
    handles.pval=p;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function pvalcutoff_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dispOutlierHist.
function dispOutlierHist_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dishis=1;
else
    handles.dishis=0;
end
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.FilteringEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
handles.export=0;  
handles.meanmedian=1; 
handles.filterMethod=1; 
handles.filterParameter=2;
handles.outlierTest=0;
handles.pval=[]; 
handles.dishis=0;
handles.cancel=true; % Cancel pressed
guidata(hObject,handles);
uiresume(handles.FilteringEditor);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   HELP FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allok = checkExpression(expr,imgsw,mm)

% If the expression is OK allok is true else false
allok=true;

% Form error messages
errmsg1={'Your filter expression is probably malformed.',...
         'Please check your expression again.'};
errmsg2={'You cannot use parameters that are not supported by the',...
         'image analysis software (e.g. QuantArray does not have a',...
         'Median'' field. Also check your choice about using medians',...
         'instead of means. Note that you cannot use standard deviations',...
         'with medians.'};

% Preallocate some random numbers to check the validity of the expression
sigme=ones(3,1);
backme=ones(3,1);
sigmedi=ones(3,1);
backmedi=ones(3,1);
sigst=ones(3,1);
backst=ones(3,1);

if imgsw==1 || mm==1
    if ~isempty(strmatch('SigMedian',expr)) | ...
       ~isempty(strmatch('BackMedian',expr))
        uiwait(errordlg([errmsg2,lasterr],'Bad Input','modal'));
        allok=false;
        return
    end
elseif imgsw==2 || imgsw==3 || imgsw==4 || mm==2
        if ~isempty(strmatch('SigMean',expr))  | ...
           ~isempty(strmatch('BackMean',expr)) | ...
           ~isempty(strmatch('SigStd',expr))  | ...
           ~isempty(strmatch('BackStd',expr))
            uiwait(errordlg([errmsg2,lasterr],'Bad Input','modal'));
            allok=false;
            return
        end
end

expr=strrep(expr,'*','.*');
expr=strrep(expr,'/','./');
expr=strrep(expr,'SigMean','sigme');
expr=strrep(expr,'BackMean','backme');
expr=strrep(expr,'SigMedian','sigmedi');
expr=strrep(expr,'BackMedian','backmedi');
expr=strrep(expr,'SigStd','sigst');
expr=strrep(expr,'BackStd','backst');
expr=[expr ';'];
try
    eval(expr);
catch
    allok=false;
    uiwait(errordlg([errmsg1,lasterr],'Bad Input','modal'));
end
