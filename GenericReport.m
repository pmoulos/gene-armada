function varargout = GenericReport(varargin)
% GENERICREPORT M-file for GenericReport.fig
%      GENERICREPORT, by itself, creates a new GENERICREPORT or raises the existing
%      singleton*.
%
%      H = GENERICREPORT returns the handle to a new GENERICREPORT or the handle to
%      the existing singleton*.
%
%      GENERICREPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GENERICREPORT.M with the given input arguments.
%
%      GENERICREPORT('Property','Value',...) creates a new GENERICREPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GenericReport_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GenericReport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GenericReport

% Last Modified by GUIDE v2.5 21-Mar-2008 19:45:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GenericReport_OpeningFcn, ...
                   'gui_OutputFcn',  @GenericReport_OutputFcn, ...
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


% --- Executes just before GenericReport is made visible.
function GenericReport_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.GenericReport,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.GenericReport,'Position',winpos);

% Get inputs
if length(varargin)==1
    handles.text=varargin{1};
    handles.title='Report';
elseif length(varargin)==2
    handles.text=varargin{1};
    handles.title=varargin{2};
end

% Display text
set(handles.mainEdit,'String',handles.text,...
                     'Max',length(handles.text),...
                     'FontName','Monospaced',...
                     'FontSize',9)

% Correct title
set(handles.titleStatic,'String',handles.title)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GenericReport wait for user response (see UIRESUME)
% uiwait(handles.GenericReport);


% --- Outputs from this function are returned to the command line.
function varargout = GenericReport_OutputFcn(hObject, eventdata, handles) 

varargout{1}=[];


function mainEdit_Callback(hObject, eventdata, handles)


function mainEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rightClick_Callback(hObject, eventdata, handles)


function rightExport_Callback(hObject, eventdata, handles)

str=char(get(handles.mainEdit,'String'));
[filename,pathname]=uiputfile('*.txt','Export report');
if filename==0
    return
else
    line1='ARMADA v.1.0 Report';
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


function rightClear_Callback(hObject, eventdata, handles)

set(handles.mainEdit,'String','')


function okButton_Callback(hObject, eventdata, handles)

delete(handles.GenericReport);
