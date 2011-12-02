function varargout = NotesEditor(varargin)
% NOTESEDITOR M-file for NotesEditor.fig
%      NOTESEDITOR, by itself, creates a new NOTESEDITOR or raises the existing
%      singleton*.
%
%      H = NOTESEDITOR returns the handle to a new NOTESEDITOR or the handle to
%      the existing singleton*.
%
%      NOTESEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NOTESEDITOR.M with the given input arguments.
%
%      NOTESEDITOR('Property','Value',...) creates a new NOTESEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NotesEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NotesEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NotesEditor

% Last Modified by GUIDE v2.5 29-Aug-2008 11:56:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NotesEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @NotesEditor_OutputFcn, ...
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


% --- Executes just before NotesEditor is made visible.
function NotesEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.NotesEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.NotesEditor,'Position',winpos);

% Get inputs
if ~isempty(varargin)
    handles.notes=varargin{1};
    set(handles.notesEdit,'String',handles.notes);
else
    handles.notes={};
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NotesEditor wait for user response (see UIRESUME)
uiwait(handles.NotesEditor);


% --- Outputs from this function are returned to the command line.
function varargout = NotesEditor_OutputFcn(hObject, eventdata, handles)

if (get(handles.closeButton,'Value')==0)
    delete(handles.NotesEditor);
end

varargout{1}=handles.notes;


function notesEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function notesEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function rightClick_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function rightExport_Callback(hObject, eventdata, handles)

str=char(get(handles.notesEdit,'String'));
[filename,pathname]=uiputfile('*.txt','Export notes');
if filename==0
    return
else
    line1='ARMADA v.2.0 Project Notes';
    line2=repmat('-',[1 50]);
    line3=['Created on ',datestr(now)];
    line4=repmat('=',[1 50]);
    fid=fopen(strcat(pathname,filename),'wt');
    fprintf(fid,'%s\n',line1);
    fprintf(fid,'%s\n',line2);
    fprintf(fid,'%s\n',line3);
    fprintf(fid,'%s\n',line4);
    fprintf(fid,'\n\n');
    for i=1:size(str,1)
        fprintf(fid,'%s\n',str(i,:));
    end
    fclose(fid);
end


% --------------------------------------------------------------------
function rightClear_Callback(hObject, eventdata, handles)

set(handles.notesEdit,'String','')


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)

handles.notes=cellstr(get(handles.notesEdit,'String'));
guidata(hObject,handles);


% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)

uiresume(handles.NotesEditor);
