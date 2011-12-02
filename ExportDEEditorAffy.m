function varargout = ExportDEEditorAffy(varargin)
% EXPORTDEEDITORAFFY M-file for ExportDEEditorAffy.fig
%      EXPORTDEEDITORAFFY, by itself, creates a new EXPORTDEEDITORAFFY or raises the existing
%      singleton*.
%
%      H = EXPORTDEEDITORAFFY returns the handle to a new EXPORTDEEDITORAFFY or the handle to
%      the existing singleton*.
%
%      EXPORTDEEDITORAFFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTDEEDITORAFFY.M with the given input arguments.
%
%      EXPORTDEEDITORAFFY('Property','Value',...) creates a new EXPORTDEEDITORAFFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExportDEEditorAffy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExportDEEditorAffy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExportDEEditorAffy

% Last Modified by GUIDE v2.5 12-Nov-2008 22:42:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExportDEEditorAffy_OpeningFcn, ...
                   'gui_OutputFcn',  @ExportDEEditorAffy_OutputFcn, ...
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


% --- Executes just before ExportDEEditorAffy is made visible.
function ExportDEEditorAffy_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.ExportDEEditorAffy,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.ExportDEEditorAffy,'Position',winpos);

% Get input arguments (if any)
if ~isempty(varargin)
    handles.in=varargin{1};
    handles.hasinput=true;
else
    handles.hasinput=false;
end

if handles.hasinput
    if handles.in.sp
        set(handles.spCheck,'Value',1)
    else
        set(handles.spCheck,'Value',0)
    end
    if handles.in.genenames
        set(handles.genenamesCheck,'Value',1)
    else
        set(handles.genenamesCheck,'Value',0)
    end
    if handles.in.pvalues
        set(handles.pvalCheck,'Value',1)
    else
        set(handles.pvalCheck,'Value',0)
    end
    if handles.in.qvalues
        set(handles.qvalCheck,'Value',1)
    else
        set(handles.qvalCheck,'Value',0)
    end
    if handles.in.fdr
        set(handles.fdrCheck,'Value',1)
    else
        set(handles.fdrCheck,'Value',0)
    end
    if handles.in.foldchange
        set(handles.foldchangeCheck,'Value',1)
    else
        set(handles.foldchangeCheck,'Value',0)
    end
    if handles.in.rawint
        set(handles.rawintCheck,'Value',1)
    else
        set(handles.rawintCheck,'Value',0)
    end
    if handles.in.meanrawint
        set(handles.meanrawintCheck,'Value',1)
    else
        set(handles.meanrawintCheck,'Value',0)
    end
    if handles.in.medianrawint
        set(handles.medianrawintCheck,'Value',1)
    else
        set(handles.medianrawintCheck,'Value',0)
    end
    if handles.in.stdevrawint
        set(handles.stdevrawintCheck,'Value',1)
    else
        set(handles.stdevrawintCheck,'Value',0)
    end
    if handles.in.backint
        set(handles.backintCheck,'Value',1)
    else
        set(handles.backintCheck,'Value',0)
    end
    if handles.in.meanbackint
        set(handles.meanbackintCheck,'Value',1)
    else
        set(handles.meanbackintCheck,'Value',0)
    end
    if handles.in.medianbackint
        set(handles.medianbackintCheck,'Value',1)
    else
        set(handles.medianbackintCheck,'Value',0)
    end
    if handles.in.stdevbackint
        set(handles.stdevbackintCheck,'Value',1)
    else
        set(handles.stdevbackintCheck,'Value',0)
    end
    if handles.in.normint
        set(handles.normintCheck,'Value',1)
    else
        set(handles.normintCheck,'Value',0)
    end
    if handles.in.meannormint
        set(handles.meannormintCheck,'Value',1)
    else
        set(handles.meannormintCheck,'Value',0)
    end
    if handles.in.mediannormint
        set(handles.mediannormintCheck,'Value',1)
    else
        set(handles.mediannormintCheck,'Value',0)
    end
    if handles.in.stdevnormint
        set(handles.stdevnormintCheck,'Value',1)
    else
        set(handles.stdevnormintCheck,'Value',0)
    end
    if handles.in.trustfactors
        set(handles.tfCheck,'Value',1)
    else
        set(handles.tfCheck,'Value',0)
    end
    if handles.in.cvs
        set(handles.cvCheck,'Value',1)
    else
        set(handles.cvCheck,'Value',0)
    end
    if handles.in.calls
        set(handles.callsCheck,'Value',1)
    else
        set(handles.callsCheck,'Value',0)
    end
    if handles.in.scale.natural
        set(handles.naturalCheck,'Value',1)
    else
        set(handles.naturalCheck,'Value',0)
    end
    if handles.in.scale.log
        set(handles.lnCheck,'Value',1)
    else
        set(handles.lnCheck,'Value',0)
    end
    if handles.in.scale.log2
        set(handles.log2Check,'Value',1)
    else
        set(handles.log2Check,'Value',0)
    end
    if handles.in.scale.log10
        set(handles.log10Check,'Value',1)
    else
        set(handles.log10Check,'Value',0)
    end
    if strcmpi(handles.in.outtype,'text')
        set(handles.textRadio,'Value',1)
        set(handles.excelRadio,'Value',0)
    elseif strcmpi(handles.in.outtype,'excel')
        set(handles.textRadio,'Value',0)
        set(handles.excelRadio,'Value',1)
    end
    handles.out=handles.in;
else    
    handles.out.sp=true;
    handles.out.genenames=true;
    handles.out.pvalues=true;
    handles.out.qvalues=false;
    handles.out.fdr=false;
    handles.out.foldchange=true;
    handles.out.rawint=false;
    handles.out.meanrawint=false;
    handles.out.medianrawint=false;
    handles.out.stdevrawint=false;
    handles.out.backint=false;
    handles.out.meanbackint=false;
    handles.out.medianbackint=false;
    handles.out.stdevbackint=false;
    handles.out.normint=true;
    handles.out.meannormint=true;
    handles.out.mediannormint=false;
    handles.out.stdevnormint=true;
    handles.out.trustfactors=true;
    handles.out.cvs=true;
    handles.out.calls=true;
    handles.out.scale.natural=false;
    handles.out.scale.log=false;
    handles.out.scale.log2=true;
    handles.out.scale.log10=false;
    handles.out.outtype='text';
end
handles.cancel=false;

% Update handles structure
guidata(hObject,handles);

% UIWAIT makes ExportDEEditorAffy wait for user response (see UIRESUME)
uiwait(handles.ExportDEEditorAffy);


% --- Outputs from this function are returned to the command line.
function varargout = ExportDEEditorAffy_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.ExportDEEditorAffy);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.ExportDEEditorAffy);
end

varargout{1}=handles.out;
varargout{2}=handles.cancel;


function rawintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.rawint=true;
else
    handles.out.rawint=false;
end
guidata(hObject,handles);


function meanrawintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.meanrawint=true;
else
    handles.out.meanrawint=false;
end
guidata(hObject,handles);


function medianrawintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.medianrawint=true;
else
    handles.out.medianrawint=false;
end
guidata(hObject,handles);


function stdevrawintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.stdevrawint=true;
else
    handles.out.stdevrawint=false;
end
guidata(hObject,handles);


function backintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.backint=true;
else
    handles.out.backint=false;
end
guidata(hObject,handles);


function meanbackintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.meanbackint=true;
else
    handles.out.meanbackint=false;
end
guidata(hObject,handles);


function medianbackintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.medianbackint=true;
else
    handles.out.medianbackint=false;
end
guidata(hObject,handles);


function stdevbackintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.stdevbackint=true;
else
    handles.out.stdevbackint=false;
end
guidata(hObject,handles);


function normintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.normint=true;
else
    handles.out.normint=false;
end
guidata(hObject,handles);


function meannormintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.meannormint=true;
else
    handles.out.meannormint=false;
end
guidata(hObject,handles);


function mediannormintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.mediannormint=true;
else
    handles.out.mediannormint=false;
end
guidata(hObject,handles);


function stdevnormintCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.stdevnormint=true;
else
    handles.out.stdevnormint=false;
end
guidata(hObject,handles);


function pvalCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.pvalues=true;
else
    handles.out.pvalues=false;
end
guidata(hObject,handles);


function tfCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.trustfactors=true;
else
    handles.out.trustfactors=false;
end
guidata(hObject,handles);


function cvCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.cvs=true;
else
    handles.out.cvs=false;
end
guidata(hObject,handles);


function genenamesCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.genenames=true;
else
    handles.out.genenames=false;
end
guidata(hObject,handles);


function spCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.sp=true;
else
    handles.out.sp=false;
end
guidata(hObject,handles);


function qvalCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.qvalues=true;
else
    handles.out.qvalues=false;
end
guidata(hObject,handles);


function foldchangeCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.foldchange=true;
else
    handles.out.foldchange=false;
end
guidata(hObject,handles);


function fdrCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.fdr=true;
else
    handles.out.fdr=false;
end
guidata(hObject,handles);


function callsCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.calls=true;
else
    handles.out.calls=false;
end
guidata(hObject,handles);


function naturalCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.scale.natural=true;
else
    handles.out.scale.natural=false;
end
checkOutputValues(handles.out.scale);
guidata(hObject,handles);


function log2Check_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.scale.log2=true;
else
    handles.out.scale.log2=false;
end
checkOutputValues(handles.out.scale);
guidata(hObject,handles);


function lnCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.scale.log=true;
else
    handles.out.scale.log=false;
end
checkOutputValues(handles.out.scale);
guidata(hObject,handles);


function log10Check_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.scale.log10=true;
else
    handles.out.scale.log10=false;
end
checkOutputValues(handles.out.scale);
guidata(hObject,handles);


function textRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.outtype='text';
else
    handles.out.outtype='excel';
end
guidata(hObject,handles);


function excelRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.outtype='excel';
else
    handles.out.outtype='text';
end
guidata(hObject,handles);


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.ExportDEEditorAffy);


function cancelButton_Callback(hObject, eventdata, handles)

% Restore defaults
if handles.hasinput
    handles.out=handles.in;
else
    out.sp=true;
    out.genenames=true;
    out.pvalues=true;
    out.qvalues=false;
    out.fdr=false;
    out.foldchange=true;
    out.rawint=false;
    out.meanrawint=false;
    out.medianrawint=false;
    out.stdevrawint=false;
    out.backint=false;
    out.meanbackint=false;
    out.medianbackint=false;
    out.stdevbackint=false;
    out.normint=true;
    out.meannormint=true;
    out.mediannormint=false;
    out.stdevnormint=true;
    out.trustfactors=true;
    out.cvs=true;
    out.calls=true;
    out.scale.natural=false;
    out.scale.log=false;
    out.scale.log2=true;
    out.scale.log10=false;
    out.outtype='text';
    handles.out=out;
end
handles.cancel=true;
guidata(hObject,handles);
uiresume(handles.ExportDEEditorAffy);


function checkOutputValues(stru)

if ~stru.natural && ~stru.log && ~stru.log2 && ~stru.log10
    uiwait(warndlg({'Warning! You have to choose at least one output scale';...
                    'for your data else no expression data will be exported.'},'Warning'));
end
