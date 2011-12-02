function varargout = ExportDEEditor(varargin)
% EXPORTDEEDITOR M-file for ExportDEEditor.fig
%      EXPORTDEEDITOR, by itself, creates a new EXPORTDEEDITOR or raises the existing
%      singleton*.
%
%      H = EXPORTDEEDITOR returns the handle to a new EXPORTDEEDITOR or the handle to
%      the existing singleton*.
%
%      EXPORTDEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTDEEDITOR.M with the given input arguments.
%
%      EXPORTDEEDITOR('Property','Value',...) creates a new EXPORTDEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExportDEEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExportDEEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExportDEEditor

% Last Modified by GUIDE v2.5 19-Oct-2007 18:22:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExportDEEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @ExportDEEditor_OutputFcn, ...
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


% --- Executes just before ExportDEEditor is made visible.
function ExportDEEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.ExportDEEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.ExportDEEditor,'Position',winpos);

% Get input arguments (if any)
if ~isempty(varargin{1})
    handles.in=varargin{1};
    handles.hasinput=true;
else
    handles.hasinput=false;
end

% Set checkbox states according to previously defined input
if handles.hasinput
    if handles.in.sp
        set(handles.spCheck,'Value',1)
    else
        set(handles.spCheck,'Value',0)
    end
    if handles.in.genenames
        set(handles.namesCheck,'Value',1)
    else
        set(handles.namesCheck,'Value',0)
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
        set(handles.fcCheck,'Value',1)
    else
        set(handles.fcCheck,'Value',0)
    end
    if handles.in.rawratio
        set(handles.ratioRawCheck,'Value',1)
    else
        set(handles.ratioRawCheck,'Value',0)
    end
    if handles.in.logratio
        set(handles.ratioLogCheck,'Value',1)
    else
        set(handles.ratioLogCheck,'Value',0)
    end
    if handles.in.meanrawratio
        set(handles.meanRatioRawCheck,'Value',1)
    else
        set(handles.meanRatioRawCheck,'Value',0)
    end
    if handles.in.meanlogratio
        set(handles.meanRatioLogCheck,'Value',1)
    else
        set(handles.meanRatioLogCheck,'Value',0)
    end
    if handles.in.medianrawratio
        set(handles.medianRatioRawCheck,'Value',1)
    else
        set(handles.medianRatioRawCheck,'Value',0)
    end
    if handles.in.medianlogratio
        set(handles.medianRatioLogCheck,'Value',1)
    else
        set(handles.meanRatioRawCheck,'Value',0)
    end
    if handles.in.stdevrawratio
        set(handles.stdevRatioRawCheck,'Value',1)
    else
        set(handles.stdevRatioRawCheck,'Value',0)
    end
    if handles.in.stdevlogratio
        set(handles.stdevRatioLogCheck,'Value',1)
    else
        set(handles.stdevRatioLogCheck,'Value',0)
    end
    if handles.in.intensity
        set(handles.intenCheck,'Value',1)
    else
        set(handles.intenCheck,'Value',0)
    end
    if handles.in.meanintensity
        set(handles.meanIntenCheck,'Value',1)
    else
        set(handles.meanIntenCheck,'Value',0)
    end
    if handles.in.medianintensity
        set(handles.medianIntenCheck,'Value',1)
    else
        set(handles.medianIntenCheck,'Value',0)
    end
    if handles.in.stdevintensity
        set(handles.stdevIntenCheck,'Value',1)
    else
        set(handles.stdevIntenCheck,'Value',0)
    end
    if handles.in.normrawratio
        set(handles.ratioNormNatCheck,'Value',1)
    else
        set(handles.ratioNormNatCheck,'Value',0)
    end
    if handles.in.meannormrawratio
        set(handles.meanRatioNormNatCheck,'Value',1)
    else
        set(handles.meanRatioNormNatCheck,'Value',0)
    end
    if handles.in.mediannormrawratio
        set(handles.medianRatioNormNatCheck,'Value',1)
    else
        set(handles.medianRatioNormNatCheck,'Value',0)
    end
    if handles.in.stdevnormrawratio
        set(handles.stdevRatioNormNatCheck,'Value',1)
    else
        set(handles.stdevRatioNormNatCheck,'Value',0)
    end
    if handles.in.normlogratio
        set(handles.ratioNormLogCheck,'Value',1)
    else
        set(handles.ratioNormLogCheck,'Value',0)
    end
    if handles.in.meannormlogratio
        set(handles.meanRatioNormLogCheck,'Value',1)
    else
        set(handles.meanRatioNormLogCheck,'Value',0)
    end
    if handles.in.mediannormlogratio
        set(handles.medianRatioNormLogCheck,'Value',1)
    else
        set(handles.medianRatioNormLogCheck,'Value',0)
    end
    if handles.in.stdevnormlogratio
        set(handles.stdevRatioNormLogCheck,'Value',1)
    else
        set(handles.stdevRatioNormLogCheck,'Value',0)
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
    if strcmpi(handles.in.outtype,'text')
        set(handles.textRadio,'Value',1)
        set(handles.excelRadio,'Value',0)
    elseif strcmpi(handles.in.outtype,'excel')
        set(handles.textRadio,'Value',0)
        set(handles.excelRadio,'Value',1)
    end
    handles.out=handles.in;
else
    % Set default outputs
    handles.out.sp=true;
    handles.out.genenames=true;
    handles.out.pvalues=true;
    handles.out.qvalues=false;
    handles.out.fdr=false;
    handles.out.foldchange=true;
    handles.out.rawratio=false;
    handles.out.logratio=false;
    handles.out.meanrawratio=false;
    handles.out.meanlogratio=false;
    handles.out.medianrawratio=false;
    handles.out.medianlogratio=false;
    handles.out.stdevrawratio=false;
    handles.out.stdevlogratio=false;
    handles.out.intensity=false;
    handles.out.meanintensity=true;
    handles.out.medianintensity=false;
    handles.out.stdevintensity=true;
    handles.out.normlogratio=true;
    handles.out.meannormlogratio=true;
    handles.out.mediannormlogratio=false;
    handles.out.stdevnormlogratio=true;
    handles.out.normrawratio=false;
    handles.out.meannormrawratio=false;
    handles.out.mediannormrawratio=false;
    handles.out.stdevnormrawratio=false;
    handles.out.trustfactors=true;
    handles.out.cvs=true;
    handles.out.outtype='text';
end
handles.cancel=false;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ExportDEEditor wait for user response (see UIRESUME)
uiwait(handles.ExportDEEditor);


% --- Outputs from this function are returned to the command line.
function varargout = ExportDEEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.ExportDEEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.ExportDEEditor);
end

varargout{1}=handles.out;
varargout{2}=handles.cancel;


% --- Executes on button press in ratioRawCheck.
function ratioRawCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.rawratio=true;
else
    handles.out.rawratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in ratioLogCheck.
function ratioLogCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.logratio=true;
else
    handles.out.logratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in meanRatioRawCheck.
function meanRatioRawCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.meanrawratio=true;
else
    handles.out.meanrawratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in meanRatioLogCheck.
function meanRatioLogCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.meanlogratio=true;
else
    handles.out.meanlogratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in medianRatioRawCheck.
function medianRatioRawCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.medianrawratio=true;
else
    handles.out.medianrawratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in medianRatioLogCheck.
function medianRatioLogCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.medianlogratio=true;
else
    handles.out.medianlogratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in stdevRatioRawCheck.
function stdevRatioRawCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.stdevrawratio=true;
else
    handles.out.stdevrawratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in stdevRatioLogCheck.
function stdevRatioLogCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.stdevlogratio=true;
else
    handles.out.stdevlogratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in intenCheck.
function intenCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.intensity=true;
else
    handles.out.intensity=false;
end
guidata(hObject,handles);


% --- Executes on button press in meanIntenCheck.
function meanIntenCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.meanintensity=true;
else
    handles.out.meanintensity=false;
end
guidata(hObject,handles);


% --- Executes on button press in medianIntenCheck.
function medianIntenCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.medianintensity=true;
else
    handles.out.medianintensity=false;
end
guidata(hObject,handles);


% --- Executes on button press in stdevIntenCheck.
function stdevIntenCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.stdevintensity=true;
else
    handles.out.stdevintensity=false;
end
guidata(hObject,handles);


% --- Executes on button press in ratioNormNatCheck.
function ratioNormNatCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.normrawratio=true;
else
    handles.out.normrawratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in meanRatioNormNatCheck.
function meanRatioNormNatCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.meannormrawratio=true;
else
    handles.out.meannormrawratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in medianRatioNormNatCheck.
function medianRatioNormNatCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.mediannormrawratio=true;
else
    handles.out.mediannormrawratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in stdevRatioNormNatCheck.
function stdevRatioNormNatCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.stdevnormrawratio=true;
else
    handles.out.stdevnormrawratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in ratioNormLogCheck.
function ratioNormLogCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.normlogratio=true;
else
    handles.out.normlogratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in meanRatioNormLogCheck.
function meanRatioNormLogCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.meannormlogratio=true;
else
    handles.out.meannormlogratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in medianRatioNormLogCheck.
function medianRatioNormLogCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.mediannormlogratio=true;
else
    handles.out.mediannormlogratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in stdevRatioNormLogCheck.
function stdevRatioNormLogCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.stdevnormlogratio=true;
else
    handles.out.stdevnormlogratio=false;
end
guidata(hObject,handles);


% --- Executes on button press in pvalCheck.
function pvalCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.pvalues=true;
else
    handles.out.pvalues=false;
end
guidata(hObject,handles);


% --- Executes on button press in tfCheck.
function tfCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.trustfactors=true;
else
    handles.out.trustfactors=false;
end
guidata(hObject,handles);


% --- Executes on button press in cvCheck.
function cvCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.cvs=true;
else
    handles.out.cvs=false;
end
guidata(hObject,handles);


% --- Executes on button press in namesCheck.
function namesCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.genenames=true;
else
    handles.out.genenames=false;
end
guidata(hObject,handles);


% --- Executes on button press in spCheck.
function spCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.sp=true;
else
    handles.out.sp=false;
end
guidata(hObject,handles);


% --- Executes on button press in qvalCheck.
function qvalCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.qvalues=true;
else
    handles.out.qvalues=false;
end
guidata(hObject,handles);


% --- Executes on button press in fcCheck.
function fcCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.foldchange=true;
else
    handles.out.foldchange=false;
end
guidata(hObject,handles);


% --- Executes on button press in fdrCheck.
function fdrCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.fdr=true;
else
    handles.out.fdr=false;
end
guidata(hObject,handles)


% --- Executes on button press in textRadio.
function textRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.outtype='text';
else
    handles.out.outtype='excel';
end
guidata(hObject,handles);


% --- Executes on button press in excelRadio.
function excelRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.out.outtype='excel';
else
    handles.out.outtype='text';
end
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.ExportDEEditor);


% --- Executes on button press in cancelButton.
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
    out.rawratio=false;
    out.logratio=false;
    out.meanrawratio=false;
    out.meanlogratio=false;
    out.medianrawratio=false;
    out.medianlogratio=false;
    out.stdevrawratio=false;
    out.stdevlogratio=false;
    out.intensity=false;
    out.meanintensity=true;
    out.medianintenisty=false;
    out.stdevintensity=true;
    out.normlogratio=true;
    out.meannormlogratio=true;
    out.mediannormlogratio=false;
    out.stdevnormlogratio=true;
    out.normrawratio=false;
    out.meannormrawratio=false;
    out.mediannormrawratio=false;
    out.stdevnormrawratio=false;
    out.trustfactors=true;
    out.cvs=true;
    out.outtype='text';
    handles.out=out;
end
handles.cancel=true;
guidata(hObject,handles);
uiresume(handles.ExportDEEditor);
