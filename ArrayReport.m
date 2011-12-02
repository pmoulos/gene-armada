function varargout = ArrayReport(varargin)
% ARRAYREPORT M-file for ArrayReport.fig
%      ARRAYREPORT, by itself, creates a new ARRAYREPORT or raises the existing
%      singleton*.
%
%      H = ARRAYREPORT returns the handle to a new ARRAYREPORT or the handle to
%      the existing singleton*.
%
%      ARRAYREPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARRAYREPORT.M with the given input arguments.
%
%      ARRAYREPORT('Property','Value',...) creates a new ARRAYREPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ArrayReport_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ArrayReport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ArrayReport

% Last Modified by GUIDE v2.5 29-Aug-2008 13:02:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ArrayReport_OpeningFcn, ...
                   'gui_OutputFcn',  @ArrayReport_OutputFcn, ...
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


% --- Executes just before ArrayReport is made visible.
function ArrayReport_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.ArrayReport,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.ArrayReport,'Position',winpos);

% Get inputs
handles.name=varargin{1};
header=varargin{2};

% Correct title
set(handles.titleStatic,'String',['Report for Array ',char(handles.name)])

% Start filling textbox
if isstruct(header) % cDNAs
    if ~iscell(header.Type)
        maintext=cellstr(header.Type);
    else
        maintext=header.Type;
    end
    if isstruct(header.Text)
        fnames=fieldnames(header.Text);
        rest=struct2cell(header.Text);
        for i=1:length(rest)
            if isnumeric(rest{i})
                rest{i}=num2str(rest{i});
            end
            rest{i}=[fnames{i},' : ',rest{i}];
        end
    else
        if ~iscell(header.Text)
            rest=cellstr(header.Text);
        else
            rest=header.Text;
        end
    end
    maintext=[maintext;' ';rest];
    set(handles.reportMainEdit,'String',maintext,'Max',length(maintext))
else % Affymetrix
    maintext=header;
    set(handles.reportMainEdit,'String',maintext,'Max',length(maintext))
end



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ArrayReport wait for user response (see UIRESUME)
uiwait(handles.ArrayReport);


% --- Outputs from this function are returned to the command line.
function varargout = ArrayReport_OutputFcn(hObject, eventdata, handles) 


function reportMainEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function reportMainEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function rightClick_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function rightExport_Callback(hObject, eventdata, handles)

str=char(get(handles.reportMainEdit,'String'));
[filename,pathname]=uiputfile('*.txt','Export report');
if filename==0
    return
else
    line1='ARMADA v.2.0 Array Report';
    line2=repmat('-',[1 50]);
    line3=['INFORMATION ON ARRAY ',char(handles.name)];
    line4=line2;
    line5=['Created on ',datestr(now)];
    line6=repmat('=',[1 50]);
    fid=fopen(strcat(pathname,filename),'wt');
    fprintf(fid,'%s\n',line1);
    fprintf(fid,'%s\n',line2);
    fprintf(fid,'%s\n',line3);
    fprintf(fid,'%s\n',line4);
    fprintf(fid,'%s\n',line5);
    fprintf(fid,'%s\n',line6);
    fprintf(fid,'\n\n');
    for i=1:size(str,1)
        fprintf(fid,'%s\n',str(i,:));
    end
    fclose(fid);
end


% --------------------------------------------------------------------
function rightClear_Callback(hObject, eventdata, handles)

set(handles.reportMainEdit,'String','')


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.ArrayReport);
delete(handles.ArrayReport);
