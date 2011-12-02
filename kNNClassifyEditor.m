function varargout = kNNClassifyEditor(varargin)
% KNNCLASSIFYEDITOR M-file for kNNClassifyEditor.fig
%      KNNCLASSIFYEDITOR, by itself, creates a new KNNCLASSIFYEDITOR or raises the existing
%      singleton*.
%
%      H = KNNCLASSIFYEDITOR returns the handle to a new KNNCLASSIFYEDITOR or the handle to
%      the existing singleton*.
%
%      KNNCLASSIFYEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KNNCLASSIFYEDITOR.M with the given input arguments.
%
%      KNNCLASSIFYEDITOR('Property','Value',...) creates a new KNNCLASSIFYEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kNNClassifyEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kNNClassifyEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kNNClassifyEditor

% Last Modified by GUIDE v2.5 09-Mar-2008 21:04:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kNNClassifyEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @kNNClassifyEditor_OutputFcn, ...
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


% --- Executes just before kNNClassifyEditor is made visible.
function kNNClassifyEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.kNNClassifyEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.kNNClassifyEditor,'Position',winpos);

% Get inputs
handles.maxs=varargin{1}; % Should not exceed number of available samples

% Set default outputs
handles.k=3;                  % Default range of NNs
handles.distance='Euclidean'; % Default distance
handles.rule='Nearest';       % Default tie break rule
handles.newdata=[];           % Sample data to be classified
handles.samplenames=[];       % Names for new samples to be classified
handles.cancel=false;         % User did not press cancel  

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes kNNClassifyEditor wait for user response (see UIRESUME)
uiwait(handles.kNNClassifyEditor);


% --- Outputs from this function are returned to the command line.
function varargout = kNNClassifyEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.kNNClassifyEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.kNNClassifyEditor);
end

varargout{1}=handles.k;
varargout{2}=handles.distance;
varargout{3}=handles.rule;
varargout{4}=handles.samplenames;
varargout{5}=handles.newdata;
varargout{6}=handles.cancel;


function fileEdit_Callback(hObject, eventdata, handles)


function fileEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fileEdit_KeyPressFcn(hObject, eventdata, handles)

currpress=get(handles.kNNClassifyEditor,'CurrentCharacter');
z=regexp(currpress,'\r+','once');
if ~isempty(z)
    % Find the names of the columns
    sfile=get(hObject,'String');
    if ~isempty(strfind(sfile,'.txt'))
        try
            try
                % We suppose that the input file has one line of headers containing sample names
                % (the 1st) and one column of feature names (the 1st). All other data are numeric.
                fid=fopen(sfile);
                fline=fgetl(fid);
                colnames=textscan(fline,'%s','Delimiter','\t');
                colnames=colnames{1};
                frmt=repmat('%f',[1 length(colnames)-1]);
                frmt=['%*s',frmt];
                data=textscan(fid,frmt,'Delimiter','\t');
                handles.newdata=cell2mat(data);
                handles.samplenames=colnames;
            catch
                uiwait(errordlg('The file should contain only numeric data.',...
                                'Bad Input'));
                return
            end
        catch
            uiwait(errordlg('You must provide valid text tab delimited file.','Error'));
            return
        end
    elseif ~isempty(strfind(sfile,'.xls'))
        try
            % Same things apply for Excel files
            [num,txt]=xlsread(sfile,1);
            colnames=txt(1,2:end);
            colnames=colnames';
            handles.newdata=num;
            handles.samplenames=colnames;
        catch
            uiwait(errordlg('You must provide valid Excel file.','Error'));
            return
        end
    else
        uiwait(errordlg('You must provide valid text tab delimited or Excel file.','Error'));
        return
    end
    set(handles.okButton,'Enable','on')
    guidata(hObject,handles);
end


function broButton_Callback(hObject, eventdata, handles)

[sfile,pname,findex]=uigetfile({'*.txt','Text tab delimited files (*.txt)';...
                                '*.xls','Excel files (*.xls)'},...
                                'Select Sample file');
if sfile==0
    return
end

sfile=strcat(pname,sfile);
set(handles.fileEdit,'String',sfile,'Max',1)

% Find the names of the columns
if findex==1 % Text file
    try
        % We suppose that the input file has one line of headers containing sample names
        % (the 1st) and one column of feature names (the 1st). All other data are numeric.
        fid=fopen(sfile);
        fline=fgetl(fid);
        colnames=textscan(fline,'%s','Delimiter','\t');
        colnames=colnames{1};
        frmt=repmat('%f',[1 length(colnames)-1]);
        frmt=['%*s',frmt];
        data=textscan(fid,frmt,'Delimiter','\t');
        handles.newdata=cell2mat(data);
        handles.samplenames=colnames(2:end);
    catch
        uiwait(errordlg('The file should be in proper format.',...
                        'Bad Input'));
        return
    end
elseif findex==2 % Excel file
    % Same things apply for Excel files
    [num,txt]=xlsread(sfile,1);
    colnames=txt(1,2:end);
    colnames=colnames';
    handles.newdata=num;
    handles.samplenames=colnames;
end
set(handles.okButton,'Enable','on')
guidata(hObject,handles);


function kEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<=0 || rem(val,1)~=0
    uiwait(errordlg('The number of nearest neighbors must be a positive integer value.',...
                    'Bad Input'));
    set(hObject,'String','3')
    handles.k=str2double(get(hObject,'String'));
elseif max(val)>handles.maxs-1
    uiwait(errordlg({'The number of nearest neighbors cannot be larger than',...
                     'the number of samples in the training set minus one.'},...
                     'Bad Input'));
    set(hObject,'String','3')
    handles.ke=str2double(get(hObject,'String'));
else
    handles.k=val;
end
guidata(hObject,handles);


function kEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function distancePopup_Callback(hObject, eventdata, handles)

distances=get(hObject,'String');
handles.distance=distances{get(hObject,'Value')};
guidata(hObject,handles);


function distancePopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rulePopup_Callback(hObject, eventdata, handles)

rules=get(hObject,'String');
handles.rule=rules{get(hObject,'Value')};
guidata(hObject,handles);


function rulePopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.kNNClassifyEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Return defaults
handles.k=3; 
handles.distance='Euclidean';
handles.rule='Nearest';
handles.newdata=[];
handles.samplenames=[];
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.kNNClassifyEditor);
