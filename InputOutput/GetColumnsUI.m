function varargout = GetColumnsUI(varargin)
% GETCOLUMNSUI M-file for GetColumnsUI.fig
%      GETCOLUMNSUI, by itself, creates a new GETCOLUMNSUI or raises the existing
%      singleton*.
%
%      H = GETCOLUMNSUI returns the handle to a new GETCOLUMNSUI or the handle to
%      the existing singleton*.
%
%      GETCOLUMNSUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETCOLUMNSUI.M with the given input arguments.
%
%      GETCOLUMNSUI('Property','Value',...) creates a new GETCOLUMNSUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GetColumnsUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GetColumnsUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GetColumnsUI

% Last Modified by GUIDE v2.5 14-Nov-2007 16:41:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GetColumnsUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GetColumnsUI_OutputFcn, ...
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


% --- Executes just before GetColumnsUI is made visible.
function GetColumnsUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.GetColumnsUI,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.GetColumnsUI,'Position',winpos);

% Get inputs
colnames=varargin{1};
hlst=findobj('Style','popupmenu');
set(hlst,'String',colnames);

% Default output

% Out has the following contents
% out(1)  : Gene Numbers
% out(2)  : Array Blocks
% out(3)  : Meta Rows
% out(4)  : Meta Columns
% out(5)  : Rows
% out(6)  : Columns
% out(7)  : Gene Names
% out(8)  : Array Spot Flags
% out(9)  : Cy3 Signal Mean
% out(10) : Cy3 Signal Median
% out(11) : Cy3 Signal Standard Deviation
% out(12) : Cy3 Background Mean
% out(13) : Cy3 Background Median
% out(14) : Cy3 Background Standard Deviation
% out(15) : Cy5 Signal Mean
% out(16) : Cy5 Signal Median
% out(17) : Cy5 Signal Standard Deviation
% out(18) : Cy5 Background Mean
% out(19) : Cy5 Background Median
% out(20) : Cy5 Background Standard Deviation

handles.out=zeros(1,20); % Null indices, the user selects
handles.cancel=false;    % User did not press cancel


guidata(hObject, handles);

% UIWAIT makes GetColumnsUI wait for user response (see UIRESUME)
uiwait(handles.GetColumnsUI);


% --- Outputs from this function are returned to the command line.
function varargout = GetColumnsUI_OutputFcn(hObject, eventdata, handles)

if (get(handles.cancelButton,'Value')==0)
    delete(handles.GetColumnsUI);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.GetColumnsUI);
end

varargout{1}=handles.out;
varargout{2}=handles.cancel;


% --- Executes on selection change in geneNumberList.
function geneNumberList_Callback(hObject, eventdata, handles)

handles.out(1)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function geneNumberList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in blockList.
function blockList_Callback(hObject, eventdata, handles)

handles.out(2)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function blockList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in metaRowList.
function metaRowList_Callback(hObject, eventdata, handles)

handles.out(3)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function metaRowList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in metaColumnList.
function metaColumnList_Callback(hObject, eventdata, handles)

handles.out(4)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function metaColumnList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in rowList.
function rowList_Callback(hObject, eventdata, handles)

handles.out(5)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function rowList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in columnList.
function columnList_Callback(hObject, eventdata, handles)

handles.out(6)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function columnList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in geneNamesList.
function geneNamesList_Callback(hObject, eventdata, handles)

handles.out(7)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function geneNamesList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in flagList.
function flagList_Callback(hObject, eventdata, handles)

handles.out(8)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function flagList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy3SigMeanList.
function Cy3SigMeanList_Callback(hObject, eventdata, handles)

handles.out(9)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy3SigMeanList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy3SigMedianList.
function Cy3SigMedianList_Callback(hObject, eventdata, handles)

handles.out(10)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy3SigMedianList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy3SigStdList.
function Cy3SigStdList_Callback(hObject, eventdata, handles)

handles.out(11)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy3SigStdList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy3BackMeanList.
function Cy3BackMeanList_Callback(hObject, eventdata, handles)

handles.out(12)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy3BackMeanList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy3BackMedianList.
function Cy3BackMedianList_Callback(hObject, eventdata, handles)

handles.out(13)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy3BackMedianList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy3BackStdList.
function Cy3BackStdList_Callback(hObject, eventdata, handles)

handles.out(14)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy3BackStdList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy5SigMeanList.
function Cy5SigMeanList_Callback(hObject, eventdata, handles)

handles.out(15)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy5SigMeanList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy5SigMedianList.
function Cy5SigMedianList_Callback(hObject, eventdata, handles)

handles.out(16)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy5SigMedianList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy5SigStdList.
function Cy5SigStdList_Callback(hObject, eventdata, handles)

handles.out(17)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy5SigStdList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy5BackMeanList.
function Cy5BackMeanList_Callback(hObject, eventdata, handles)

handles.out(18)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy5BackMeanList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy5BackMedianList.
function Cy5BackMedianList_Callback(hObject, eventdata, handles)

handles.out(19)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy5BackMedianList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cy5BackStdList.
function Cy5BackStdList_Callback(hObject, eventdata, handles)

handles.out(20)=get(hObject,'Value')-1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Cy5BackStdList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

% Perform a check over which variables are mandatory
allfields=cell(20,1);
allfields{1}='Gene Numbers';
allfields{2}='Array Blocks';
allfields{3}='Meta Rows';
allfields{4}='Meta Columns';
allfields{5}='Rows';
allfields{6}='Columns';
allfields{7}='Gene Names';
allfields{8}='Array Spot Flags';
allfields{9}='Cy3 Signal Mean';
allfields{10}='Cy3 Signal Median';
allfields{11}='Cy3 Signal Standard Deviation';
allfields{12}='Cy3 Background Mean';
allfields{13}='Cy3 Background Median';
allfields{14}='Cy3 Background Standard Deviation';
allfields{15}='Cy5 Signal Mean';
allfields{16}='Cy5 Signal Median';
allfields{17}='Cy5 Signal Standard Deviation';
allfields{18}='Cy5 Background Mean';
allfields{19}='Cy5 Background Median';
allfields{20}='Cy5 Background Standard Deviation';
zeroind=find(handles.out==0);
% mandind=[5 6 7 9 11 12 14 15 17 18 20];
% mandind=[7 9 12 15 18];
mandind=[7 9 12];
membership=ismember(zeroind,mandind);
selected=handles.out(handles.out>0);
uselected=unique(selected);
if any(membership)
    errmsg={'The following missing fields are mandatory:'};
    addfields=allfields(membership);
    errmsg=[errmsg;' ';addfields];
    uiwait(errordlg(errmsg,'Isufficient Input'));
elseif length(uselected)<length(selected)
    uiwait(errordlg({'One or more columns are included more than once!'},'Bad Input'));
else
    uiresume(handles.GetColumnsUI);
end


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

handles.out=zeros(1,20);
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.GetColumnsUI);
