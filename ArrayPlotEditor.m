function varargout = ArrayPlotEditor(varargin)
% ARRAYPLOTEDITOR M-file for ArrayPlotEditor.fig
%      ARRAYPLOTEDITOR, by itself, creates a new ARRAYPLOTEDITOR or raises the existing
%      singleton*.
%
%      H = ARRAYPLOTEDITOR returns the handle to a new ARRAYPLOTEDITOR or the handle to
%      the existing singleton*.
%
%      ARRAYPLOTEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARRAYPLOTEDITOR.M with the given input arguments.
%
%      ARRAYPLOTEDITOR('Property','Value',...) creates a new ARRAYPLOTEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ArrayPlotEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ArrayPlotEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ArrayPlotEditor

% Last Modified by GUIDE v2.5 22-Aug-2008 18:03:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ArrayPlotEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @ArrayPlotEditor_OutputFcn, ...
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


% --- Executes just before ArrayPlotEditor is made visible.
function ArrayPlotEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.ArrayPlotEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.ArrayPlotEditor,'Position',winpos);

% Get inputs
handles.arrays=varargin{1};
handles.normarrays=varargin{2};
handles.software=varargin{3};
handles.normpfmd=varargin{4};

% Fill lists
set(handles.allArrayList,'String',handles.arrays,'Max',2,'Value',[])
set(handles.normArrayList,'String',handles.normarrays,'Value',[])

% Set some names to be displayed in the popup
if handles.software==99 % Affymetrix
    handles.dispNames={'Intensity',...
                       'Standard Deviation',...
                       'PM',...
                       'MM',...
                       'BackAdjusted PM',...
                       'Normalized PM',...
                       'Expression (raw)',...
                       'Expression (back)',...
                       'Expression (norm)'};
elseif handles.software==98 % Illumina
    handles.dispNames={'Expression (raw)',...
                       'Expression (norm)'};
else % 2-channel
    handles.dispNames={'log_2 Ratio',...
                       'Intensity',...
                       'Channel 1 Foreground Mean',...
                       'Channel 2 Foreground Mean',...
                       'Channel 1 Foreground Median',...
                       'Channel 2 Foreground Median',...
                       'Channel 1 Background Mean',...
                       'Channel 2 Background Mean',...
                       'Channel 1 Background Median',...
                       'Channel 2 Background Median',...
                       'Channel 1 Foreground Standard Deviation',...
                       'Channel 2 Foreground Standard Deviation',...
                       'Channel 1 Background Standard Deviation',...
                       'Channel 2 Background Standard Deviation',...
                       'Channel 1 Foreground - Background (Mean)',...
                       'Channel 2 Foreground - Background (Mean)',...
                       'Channel 1 Foreground - Background (Median)',...
                       'Channel 2 Foreground - Background (Median)',...
                       'Channel 1 Foreground / Background (Mean)',...
                       'Channel 2 Foreground / Background (Mean)',...
                       'Channel 1 Foreground / Background (Median)',...
                       'Channel 2 Foreground / Background (Median)'};
end

% Fill popups
set(handles.plotwhatPopup,'String',handles.dispNames)
set(handles.vsplotPopup,'String',handles.dispNames)

% Set default outputs
handles.finalarrays='';                    % Default array to plot from non-normalized 
handles.finalnormarrays='';                % Default array to plot from normalized
handles.plotwhat=1;                        % What quantity to plot 
handles.plotwhatName=handles.dispNames{1}; % Its name
if handles.software==98 || handles.software==99
    handles.vswhat=1;
    handles.vswhatName=handles.dispNames{1};
else
    handles.vswhat=3;                      % Plot vs what in case of single arrays
    handles.vswhatName=handles.dispNames{3};   % Its name
end
handles.titles='';                         % The title(s) 
handles.ntitle='';                         % Normalized title
handles.dispcorr=true;                     % Calculate correlation to put on plot
handles.logscale=false;                    % Plot in log2 scale
handles.displine=false;                    % Display a cutoff line where colors change
handles.linecut=2;                         % The above cutoff
handles.issingle=false;                    % Plot for single arrays 
handles.cancel=false;                      % User did not press cancel 
               
% See what happens if normalization has not been performed
if ~handles.normpfmd
    set(handles.nStatic,'Enable','off')
    set(handles.normArrayList,'Enable','off')
    if handles.software==99
        set(handles.plotwhatPopup,'String',handles.dispNames(1:2))
        set(handles.vsplotPopup,'String',handles.dispNames(1:2))
    elseif handles.software==98
        set(handles.plotwhatPopup,'String',handles.dispNames(1))
        set(handles.vsplotPopup,'String',handles.dispNames(1))
    else
        set(handles.plotwhatPopup,'String',handles.dispNames(3:end))
        set(handles.vsplotPopup,'String',handles.dispNames(3:end))
    end
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ArrayPlotEditor wait for user response (see UIRESUME)
uiwait(handles.ArrayPlotEditor);


% --- Outputs from this function are returned to the command line.
function varargout = ArrayPlotEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.ArrayPlotEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.ArrayPlotEditor);
end

varargout{1}=handles.finalarrays;
varargout{2}=handles.finalnormarrays;
varargout{3}=handles.plotwhat;
varargout{4}=handles.plotwhatName;
varargout{5}=handles.vswhat;
varargout{6}=handles.vswhatName;
varargout{7}=handles.titles;
varargout{8}=handles.ntitle;
varargout{9}=handles.dispcorr;
varargout{10}=handles.logscale;
varargout{11}=handles.displine;
varargout{12}=handles.linecut;
varargout{13}=handles.issingle;
varargout{14}=handles.cancel;


function allArrayList_Callback(hObject, eventdata, handles)

if get(handles.singleRadio,'Value')==1 && length(get(hObject,'Value'))>1
    set(handles.titleEdit,'Max',length(get(hObject,'Value')))
elseif get(handles.singleRadio,'Value')==1 && length(get(hObject,'Value'))==1
    set(handles.titleEdit,'Max',length(get(hObject,'Value')))
end
conts=get(hObject,'String');
val=get(hObject,'Value');
if get(handles.singleRadio,'Value')==0 
    if length(val)>2
        uiwait(warndlg('Only two arrays can be selected for an array vs array plot.','Warning'));
        val=val(1:2);
        set(hObject,'Value',val);
    end
    
end
handles.finalarrays=conts(val);
if get(handles.vsRadio,'Value')==1
    if handles.software==99 || handles.software==98 % Affymetrix or Illumina
        set(handles.plotwhatPopup,'String',handles.dispNames(1:2))
        if ismember(handles.plotwhat,3:9)
            handles.plotwhat=1;
            handles.plotwhatName='Intensity';
            set(handles.plotwhatPopup,'Value',1)
        end
    else % 2-channel
        % pwval=get(handles.plotwhatPopup,'Value');
        set(handles.plotwhatPopup,'String',handles.dispNames(3:end))
        if handles.plotwhat==1 || handles.plotwhat==2
            handles.plotwhat=3;
            handles.plotwhatName='Channel 1 Foreground Mean';
            set(handles.plotwhatPopup,'Value',1)
        % else
        %     set(handles.plotwhatPopup,'Value',pwval-2)
        end
    end
end
if get(handles.singleRadio,'Value')==1
    if handles.software==99 % Affymetrix
        set(handles.plotwhatPopup,'String',handles.dispNames(1:2))
        set(handles.vsplotPopup,'String',handles.dispNames(1:2))
        if ismember(handles.plotwhat,3:9)
            handles.plotwhat=1;
            handles.plotwhatName='Intensity';
            set(handles.plotwhatPopup,'Value',1)
            handles.vswhatName='Intensity';
            set(handles.vsplotPopup,'Value',1)
        end
    end
end
guidata(hObject,handles);


function allArrayList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function normArrayList_Callback(hObject, eventdata, handles)

conts=get(hObject,'String');
val=get(hObject,'Value');
if get(handles.singleRadio,'Value')==0 && length(val)>2
    uiwait(warndlg('Only two arrays can be selected for an array vs array plot.','Warning'));
    val=val(1:2);
    set(hObject,'Value',val);
end
handles.finalnormarrays=conts(val);
guidata(hObject,handles);


function normArrayList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function clearAll_Callback(hObject, eventdata, handles)

set(handles.allArrayList,'Value',[])
set(handles.titleEdit,'Max',1)
handles.finalarrays='';
if get(handles.vsRadio,'Value')==1 || get(handles.singleRadio,'Value')==1
    set(handles.plotwhatPopup,'String',handles.dispNames,'Value',1)
    set(handles.vsplotPopup,'String',handles.dispNames,'Value',1)
    handles.plotwhat=1;
    if handles.software~=99
        handles.plotwhatName='log_2 Ratio';
    else
        handles.plotwhatName='Intensity';
    end
end
guidata(hObject,handles);


function clearNorm_Callback(hObject, eventdata, handles)

set(handles.normArrayList,'Value',[])
handles.finalnormarrays='';
guidata(hObject,handles);


function singleRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.issingle=true;
    set(handles.hStatic,'Visible','on')
    set(handles.vStatic,'Visible','on')
    if handles.software~=99 && handles.software~=98
        set(handles.nStatic,'Enable','off')
        set(handles.normArrayList,'Enable','off')
        set(handles.ntitleEdit,'Enable','off')
    end
    set(handles.allArrayList,'Max',length(handles.arrays))
    set(handles.vsStatic,'Enable','on')
    set(handles.vsplotPopup,'Enable','on')
    if handles.software~=99 && handles.software~=98
        set(handles.plotwhatPopup,'String',handles.dispNames(3:end))
        set(handles.vsplotPopup,'String',handles.dispNames(3:end))
        if handles.plotwhat==1 || handles.plotwhat==2
            handles.plotwhat=3;
            handles.plotwhatName='Channel 1 Foreground Mean';
        end
    else
        if ~isempty(handles.finalarrays)
            set(handles.plotwhatPopup,'String',handles.dispNames(1:2))
            set(handles.vsplotPopup,'String',handles.dispNames(1:2))
            if ismember(handles.plotwhat,3:9)
                handles.plotwhat=1;
                handles.plotwhatName='Intensity';
            end
        end
    end
        
end
guidata(hObject,handles);


function vsRadio_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.issingle=false;
    set(handles.hStatic,'Visible','off')
    set(handles.vStatic,'Visible','off')
    if handles.normpfmd
        set(handles.nStatic,'Enable','on')
        set(handles.normArrayList,'Enable','on')
    end
    set(handles.allArrayList,'Max',2)
    set(handles.plotwhatPopup,'String',handles.dispNames);
    set(handles.vsStatic,'Enable','off');
    set(handles.vsplotPopup,'Enable','off');
    set(handles.ntitleEdit,'Enable','on')
end
guidata(hObject,handles);


function plotwhatPopup_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
if get(handles.singleRadio,'Value')==1 || ~isempty(handles.finalarrays)
    if handles.software~=99 && handles.software~=98
        val=val+2;
    end
end
handles.plotwhat=val;
handles.plotwhatName=handles.dispNames{val};
% Handle the case of QuantArray where there is no Median - CORRECT THIS!!!
if ismember(val,[5 6 9 10 17 18 21 22]) && handles.software==1;
    uiwait(errordlg({'The image analysis software you have used (QuantArray) does not',...
                     'support signal median values. Please select means instead.'},...
                     'Bad Input','modal'));
    set(hObject,'Value',1)
    if get(handles.singleRadio,'Value')==1
        handles.plotwhat=3;
        handles.plotwhatName=contents{3};
    else
        handles.plotwhat=1;
        handles.plotwhatName=contents{1};
    end
elseif ismember(val,3:22) && handles.software==100 % External data
    uiwait(errordlg({'You have imported external data. The information provided is not',...
                     'sufficient to support other than ratio (or intensity) plots.'},...
                     'Bad Input','modal'));
    set(hObject,'Value',1)
    handles.plotwhat=1;
    handles.plotwhatName=contents{1};
end
guidata(hObject,handles);


function plotwhatPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in vsplotPopup.
function vsplotPopup_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
val=get(hObject,'Value');
if handles.software~=99 && handles.software~=98
    val=val+2;
end
handles.vswhat=val;
handles.vswhatName=contents{val};
% Handle the case of QuantArray where there is no Median - CORRECT THIS!!!
if ismember(val,[3 4 7 8 15 16 19 20]) && handles.software==1;
    uiwait(errordlg({'The image analysis software you have used (QuantArray) does not',...
                     'support signal median values. Please select means instead.'},...
                     'Bad Input','modal'));
    set(hObject,'Value',1)
    if get(handles.singleRadio,'Value')==1
        handles.vswhat=3;
        handles.vswhatName=contents{3};
    else
        handles.vswhat=1;
        handles.vswhatName=contents{1};
    end
elseif ismember(val,1:20) && handles.software==100 % External data
    uiwait(errordlg({'You have imported external data. The information provided is not',...
                     'sufficient to support other than ratio (or intensity) plots.'},...
                     'Bad Input','modal'));
    set(hObject,'Value',1)
    handles.vswhat=1;
    handles.vswhatName=contents{1};
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function vsplotPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function titleEdit_Callback(hObject, eventdata, handles)

tit=cellstr(get(hObject,'String'));
len=length(get(handles.allArrayList,'Value'));
if length(tit)~=len
    uiwait(errordlg({'Please provide a number of titles equal to the number of arrays',...
                     ['you selected (',num2str(len),') or else leave the field completely'],... 
                     'empty for automated title generation.'},'Bad Input'));
    set(hObject,'String','')
    handles.titles='';
else
    handles.titles=tit;
end
guidata(hObject,handles);


function titleEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ntitleEdit_Callback(hObject, eventdata, handles)

handles.ntitle=cellstr(get(hObject,'String'));
guidata(hObject,handles);


function ntitleEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dispCorrCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.dispcorr=true;
else
    handles.dispcorr=false;
end
guidata(hObject,handles);


function logScaleCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.logscale=true;
else
    handles.logscale=false;
end
guidata(hObject,handles);


function dispFoldCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.displine=true;
    set(handles.fStatic,'Enable','on')
    set(handles.foldChangeEdit,'Enable','on')
else
    handles.displine=false;
    set(handles.fStatic,'Enable','off')
    set(handles.foldChangeEdit,'Enable','off')
end
guidata(hObject,handles);


function foldChangeEdit_Callback(hObject, eventdata, handles)

fc=str2double(get(hObject,'String'));
if isnan(fc) || fc<=0
    uiwait(errordlg('The cutoff line must be a positive value.',...
                    'Bad Input'));
    set(hObject,'String','2');
    handles.linecut=str2double(get(hObject,'String'));
elseif get(handles.logScaleCheck,'Value')==1
    if fc==1
        uiwait(errordlg('The cutoff line must not equal to 1 when ploting in log scale.',...
                        'Bad Input'));
        set(hObject,'String','2');
        handles.linecut=str2double(get(hObject,'String'));
    end
else
    handles.linecut=fc;
end
guidata(hObject,handles);


function foldChangeEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function okButton_Callback(hObject, eventdata, handles)

% Check that for array vs array at least two have been selected
if get(handles.singleRadio,'Value')==0 && ...
   (length(get(handles.allArrayList,'Value'))==1 || length(get(handles.normArrayList,'Value'))==1)
    uiwait(warndlg('At least two arrays must be selected for an array vs array plot.','Warning'));
    return
end
% Check that we won't get an error because of plotting incompatible data
if handles.issingle && handles.software==99
    if (ismember(handles.plotwhatName,handles.dispNames(1:2)) && ismember(handles.vswhatName,handles.dispNames(3:9))) || ...
       (ismember(handles.plotwhatName,handles.dispNames(3:6)) && ismember(handles.vswhatName,handles.dispNames([1,2,7:9]))) || ...
       (ismember(handles.plotwhatName,handles.dispNames(7:9)) && ismember(handles.vswhatName,handles.dispNames(1:6)))
        uiwait(warndlg([handles.plotwhatName,' can''t be plotted against ',handles.vswhatName,...
                        ' because they are not of same size!'],'Warning'));
        return
    end
end
if handles.software==99 % Other ID's for Affymetrix
    handles.plotwhat=handles.plotwhat+100;
    handles.vswhat=handles.vswhat+100;
elseif handles.software==98
    handles.plotwhat=handles.plotwhat+200+1;
    handles.vswhat=handles.vswhat+200+1;
end
guidata(hObject,handles);
uiresume(handles.ArrayPlotEditor);


function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
handles.finalarrays=handles.arrays(1);
handles.finalnormarrays=handles.normarrays(1);
handles.plotwhat=1;
handles.plotwhatName=handles.dispNames{1};
handles.vswhat=3;
if handles.software~=99 && handles.software~=98
    handles.vswhatName=handles.dispNames{3};
else
    handles.vswhatName=handles.dispNames{1};
end
handles.titles='';
handles.ntitle='';
handles.dispcorr=true;
handles.logscale=false;
handles.displine=false;
handles.linecut=[];
handles.issingle=false;
handles.cancel=true; % User pressed cancel
guidata(hObject,handles);
uiresume(handles.ArrayPlotEditor);
