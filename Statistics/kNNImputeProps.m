function varargout = kNNImputeProps(varargin)
% KNNIMPUTEPROPS M-file for kNNImputeProps.fig
%      KNNIMPUTEPROPS, by itself, creates a new KNNIMPUTEPROPS or raises the existing
%      singleton*.
%
%      H = KNNIMPUTEPROPS returns the handle to a new KNNIMPUTEPROPS or the handle to
%      the existing singleton*.
%
%      KNNIMPUTEPROPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KNNIMPUTEPROPS.M with the given input arguments.
%
%      KNNIMPUTEPROPS('Property','Value',...) creates a new KNNIMPUTEPROPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kNNImputeProps_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kNNImputeProps_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kNNImputeProps

% Last Modified by GUIDE v2.5 20-Oct-2013 12:04:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kNNImputeProps_OpeningFcn, ...
                   'gui_OutputFcn',  @kNNImputeProps_OutputFcn, ...
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


% --- Executes just before kNNImputeProps is made visible.
function kNNImputeProps_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.kNNImputeProps,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.kNNImputeProps,'Position',winpos);

% Get input
if length(varargin)==1
    handles.numreps=varargin{1};
    handles.presel={[]};
elseif length(varargin)==2
    handles.numreps=varargin{1};
    handles.presel=varargin{2};
end

handles.presel=handles.presel{1};
if ~isempty(handles.presel)
    set(handles.kEdit,'String',handles.presel.k);
    handles.k=handles.presel.k;
    if handles.presel.usemedian
        set(handles.medianCheck,'Value',1)
    else
        set(handles.medianCheck,'Value',0)
    end
    handles.usemedian=handles.presel.usemedian;
    distances=get(handles.distSelectPopup,'String');
    switch handles.presel.distance
        case 'euclidean'
            handles.distance='euclidean';
            handles.distanceName=distances{1};
            set(handles.distSelectPopup,'Value',1)
        case 'seuclidean'
            handles.distance='seuclidean';
            handles.distanceName=distances{2};
            set(handles.distSelectPopup,'Value',2)
        case 'correlation'
            handles.distance='correlation';
            handles.distanceName=distances{3};
            set(handles.distSelectPopup,'Value',3)
        case 'mahalanobis'
            handles.distance='mahalanobis';
            handles.distanceName=distances{4};
            set(handles.distSelectPopup,'Value',4)
        case 'cityblock'
            handles.distance='cityblock';
            handles.distanceName=distances{5};
            set(handles.distSelectPopup,'Value',5)
        case 'cosine'
            handles.distance='cosine';
            handles.distanceName=distances{6};
            set(handles.distSelectPopup,'Value',6)
        case 'jaccard'
            handles.distance='jaccard';
            handles.distanceName=distances{7};
            set(handles.distSelectPopup,'Value',7)
        case 'chebychev'
            handles.distance='chebychev';
            handles.distanceName=distances{8};
            set(handles.distSelectPopup,'Value',8)
        case 'hamming'
            handles.distance='hamming';
            handles.distanceName=distances{9};
            set(handles.distSelectPopup,'Value',9)
    end
    spaces=get(handles.imputeSpacePopup,'String');
    switch handles.presel.imputespace
        case 'sample'
            handles.imputespace='sample';
            handles.imputeSpaceName=spaces{1};
            set(handles.imputeSpacePopup,'Value',1)
        case 'gene'
            handles.imputespace='gene';
            handles.imputeSpaceName=spaces{2};
            set(handles.imputeSpacePopup,'Value',2)
    end
    
else
    
    % Set default outputs
    handles.imputespace='sample';                % Sample space by MatLab's default
    handles.imputeSpaceName='Closest sample(s)'; % Its name
    handles.distance='euclidean';                % Euclidean by default
    handles.distanceName='Euclidean';            % Its name
    handles.k=1;                                 % One NN
    handles.usemedian=false;                     % Don't use median, just weighted mean
    
end

handles.cancel=false; % User did not press cancel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes kNNImputeProps wait for user response (see UIRESUME)
uiwait(handles.kNNImputeProps);


% --- Outputs from this function are returned to the command line.
function varargout = kNNImputeProps_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.kNNImputeProps);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.kNNImputeProps);
end

out.imputespace=handles.imputespace;
out.distance=handles.distance;
out.k=handles.k;
out.usemedian=handles.usemedian;
out.distancename=handles.distanceName;
out.imputespacename=handles.imputeSpaceName;

varargout{1}=out;
varargout{2}=handles.cancel;


% --- Executes on selection change in imputeSpacePopup.
function imputeSpacePopup_Callback(hObject, eventdata, handles)

spaces=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1 % Sample
        handles.imputespace='sample';
        handles.imputeSpaceName=spaces{1};
    case 2 % Standardized Euclidean
        handles.imputespace='gene';
        handles.imputeSpaceName=spaces{2};
end
    
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function imputeSpacePopup_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in distSelectPopup.
function distSelectPopup_Callback(hObject, eventdata, handles)

distances=get(hObject,'String');
val=get(hObject,'Value');
switch val
    case 1 % Euclidean
        handles.distance='euclidean';
        handles.distanceName=distances{1};
    case 2 % Standardized Euclidean
        handles.distance='seuclidean';
        handles.distanceName=distances{2};
    case 3
        handles.distance='correlation';
        handles.distanceName=distances{3};
    case 4
        handles.distance='mahalanobis';
        handles.distanceName=distances{4};
    case 5
        handles.distance='cityblock';
        handles.distanceName=distances{5};
    case 6
        handles.distance='cosine';
        handles.distanceName=distances{6};
    case 7
        handles.distance='jaccard';
        handles.distanceName=distances{7};
    case 8
        handles.distance='chebychev';
        handles.distanceName=distances{8};
    case 9
        handles.distance='hamming';
        handles.distanceName=distances{9};
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function distSelectPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kEdit_Callback(hObject, eventdata, handles)

val=str2double(get(hObject,'String'));
if isnan(val) || val<0 || rem(val,1)~=0
    uiwait(errordlg('Number of nearest neighbors must a positive integer!','Bad Input'));
    set(hObject,'String','1');
    handles.k=str2double(get(hObject,'String'));
else
    problem=false;
    if length(handles.numreps)>1
        chk=val<handles.numreps;
        if ~all(chk)
            msg=['At least one of the analysis objects you selected contains a smaller ',...
                 'number of arrays than the number of nearest neighbors you entered. Please ',...
                 'set a smaller number of nearest neighbors.'];
            problem=true;
        end
    elseif isscalar(handles.numreps)
        if val>handles.numreps-1
            msg=['Number of nearest neighbors must be a positive number between 1 and ',...
                 'the number of arrays for this condition minus one (',num2str(handles.numreps-1),').'];
            problem=true;
        end
    end
    if problem
        uiwait(errordlg(msg,'Bad Input'));
        set(hObject,'String','1');
        handles.k=str2double(get(hObject,'String'));
    else
        handles.k=val;
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function kEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in medianCheck.
function medianCheck_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1
    handles.usemedian=true;
else
    handles.usemedian=false;
end
guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.kNNImputeProps);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

if isempty(handles.presel)
    % Restore defaults
    handles.imputespace='sample';
    handles.distance='euclidean';
    handles.distanceName='Euclidean';
    handles.imputeSpaceName='Closest sample(s)';
    handles.k=1;
    handles.usemedian=false;
end
handles.cancel=true; % Used pressed cancel
guidata(hObject,handles);
uiresume(handles.kNNImputeProps);
