function varargout = StatisticalSelectionEditor(varargin)
% STATISTICALSELECTIONEDITOR M-file for StatisticalSelectionEditor.fig
%      STATISTICALSELECTIONEDITOR, by itself, creates a new STATISTICALSELECTIONEDITOR or raises the existing
%      singleton*.
%
%      H = STATISTICALSELECTIONEDITOR returns the handle to a new STATISTICALSELECTIONEDITOR or the handle to
%      the existing singleton*.
%
%      STATISTICALSELECTIONEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STATISTICALSELECTIONEDITOR.M with the given input arguments.
%
%      STATISTICALSELECTIONEDITOR('Property','Value',...) creates a new STATISTICALSELECTIONEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StatisticalSelectionEditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StatisticalSelectionEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StatisticalSelectionEditor

% Last Modified by GUIDE v2.5 18-Jun-2012 18:29:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StatisticalSelectionEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @StatisticalSelectionEditor_OutputFcn, ...
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


% --- Executes just before StatisticalSelectionEditor is made visible.
function StatisticalSelectionEditor_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.StatisticalSelectionEditor,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.StatisticalSelectionEditor,'Position',winpos);

% Get the inputs from ARMADA's analysisInfo structure (only its length and the field
% numberOfConditions required
handles.len=varargin{1};
handles.nocond=varargin{2}; % A vector of length len containing the number of conditions
                            % for each analysis object
handles.noarr=varargin{3};  % A vector of length len containing the number of arrays for
                            % each analysis object
handles.names=varargin{4};  % A cell containing cell arrays of strings, each carrying the 
                            % condition names for each analysis
soft=varargin{5};           % What array? Affymetrix?

% Set analysis listbox contents
handles.contents=cell(1,handles.len);
for i=1:handles.len
    handles.contents{i}=['Analysis ',num2str(i)];
end
set(handles.analysisRemainList,'String',handles.contents,'Max',handles.len);
set(handles.analysisRemainList,'Value',1)

% Check if the first analysis object should have t-test available or not
if handles.nocond(1)==1
    set(handles.statTestPopup,'String','t-test','Value',1)
elseif handles.nocond(1)==2
    z=strmatch('t-test',get(handles.statTestPopup,'String'));
    if isempty(z)
        newstr=get(handles.statTestPopup,'String');
        newstr=[newstr;'t-test'];
        set(handles.statTestPopup,'String',newstr)
    end
else
    newstr=get(handles.statTestPopup,'String');
    z=strmatch('t-test',newstr);
    if ~isempty(z)
        newstr(z)=[];
        set(handles.statTestPopup,'String',newstr)
    end
end

% Intialize handles fields as arrays so as to support multiple output
handles.scale=cell(1,handles.len);
handles.scaleOpts=cell(1,handles.len);
handles.scaleName=cell(1,handles.len);
handles.impute=cell(1,handles.len);
handles.imputeOpts=cell(1,handles.len);
handles.imputeName=cell(1,handles.len);
handles.imputeBefOrAft=zeros(1,handles.len);
handles.imputeBefOrAftName=cell(1,handles.len);
handles.statTest=zeros(1,handles.len);
handles.statTestName=cell(1,handles.len);
handles.multiCorr=zeros(1,handles.len);
handles.multiCorrName=cell(1,handles.len);
handles.thecut=zeros(1,handles.len);
handles.tf=zeros(1,handles.len);
handles.stf=zeros(1,handles.len);
handles.disbox=zeros(1,handles.len);
handles.controlIndices=cell(1,handles.len);
handles.treatedIndices=cell(1,handles.len);
handles.currentPairListContents=cell(1,handles.len);

% Main return variable, to be used in listboxes
handles.tempOldIndices=1:handles.len;
handles.tempNewIndices=[];

% Set Default output
handles.indices=1:handles.len;                        % Default statistical selection number of runs
for i=1:handles.len
    handles.scale{i}='mad';                           % Perform MAD centering by default
    handles.scaleName{i}='MAD';                       % If performed MAD or not
    handles.impute{i}='conditionmean';                % Default imputation method, means
    handles.imputeName{i}='Average within condition'; % its name
    handles.imputeBefOrAft(i)=2;                      % Impute missing values AFTER MAD
    handles.imputeBefOrAftName{i}='After scaling';    % A name for the impitation process
    handles.statTest(i)=2;                            % ANOVA by default
    handles.statTestName{i}='1-way ANOVA';            % Default name
    handles.multiCorr(i)=1;                           % No multiple correction testing by default
    handles.multiCorrName{i}='None';                  % Default name
    handles.thecut(i)=0.05;                           % Default p-value or FDR threshold output
    handles.tf(i)=0.6;                                % Default value for the Trust Factor cutoff
    %handles.stf(i)=1;                                 % Default value for the strict TF cutoff option
    handles.disbox(i)=false;                          % Display boxplots before and after MAD
end
handles.cancel=false;                                 % Cancel is not pressed

% In case of Affymetrix or Illumina, deactivate scaling between arrays, already done
if soft==99 || soft==98
    set(handles.text9,'Enable','off')
    set(handles.scaleMethodPopup,'Enable','off')
    set(handles.beforeScaling,'Enable','off')
    set(handles.afterScaling,'Enable','off')
    set(handles.displayBox,'Enable','off')
    for i=1:handles.len
        handles.scale{i}='none';
        handles.scaleName{i}='None';
    end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StatisticalSelectionEditor wait for user response (see UIRESUME)
uiwait(handles.StatisticalSelectionEditor);


% --- Outputs from this function are returned to the command line.
function varargout = StatisticalSelectionEditor_OutputFcn(hObject, eventdata, handles) 

if (get(handles.cancelButton,'Value')==0)
    delete(handles.StatisticalSelectionEditor);
elseif (get(handles.okButton,'Value')==0)
    delete(handles.StatisticalSelectionEditor);
end

varargout{1}=handles.indices;
varargout{2}=handles.scale;
varargout{3}=handles.scaleOpts;
varargout{4}=handles.scaleName;
varargout{5}=handles.impute;
varargout{6}=handles.imputeOpts;
varargout{7}=handles.imputeName;
varargout{8}=handles.imputeBefOrAft;
varargout{9}=handles.imputeBefOrAftName;
varargout{10}=handles.statTest;
varargout{11}=handles.statTestName;
varargout{12}=handles.multiCorr;
varargout{13}=handles.multiCorrName;
varargout{14}=handles.thecut;
varargout{15}=handles.tf;
varargout{16}=handles.stf;
varargout{17}=handles.disbox;
varargout{18}=handles.controlIndices;
varargout{19}=handles.treatedIndices;
varargout{20}=handles.cancel;


% --- Executes on selection change in analysisRemainList.
function analysisRemainList_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function analysisRemainList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in analysisAddList.
function analysisAddList_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(hObject,'Value');
    inds=realinds(plasminds);

    % Fix when t-test should not be available
    if length(plasminds)==1
        if handles.nocond(inds)==1
            set(handles.statTestPopup,'String','t-test','Value',1)
            handles.statTest(inds)=2;
            handles.statTestName={'t-test'};
        elseif handles.nocond(inds)==2
            z=strmatch('t-test',get(handles.statTestPopup,'String'));
            if isempty(z)
                newstr=get(handles.statTestPopup,'String');
                newstr=[newstr;'t-test'];
                set(handles.statTestPopup,'String',newstr)
            end
        else
            newstr=get(handles.statTestPopup,'String');
            z=strmatch('t-test',newstr);
            if ~isempty(z)
                newstr(z)=[];
                set(handles.statTestPopup,'String',newstr)
            end
        end
    else
        set(handles.statTestPopup,'String',{'1-way ANOVA','Kruskal-Wallis'})
    end
    guidata(hObject,handles);

    % Do the hard part of recalling the setings for each analysis

    % Check if we are able to see multiple selections at once. Do not allow if not.
    if length(inds)==2
        allscale=strcmp(handles.scale(inds(1)),handles.scale(inds(2)));
        allimpute=strcmp(handles.impute(inds(1)),handles.impute(inds(2)));
        allimputewhen=handles.imputeBefOrAft(inds(2))==handles.imputeBefOrAft(inds(2));
        allstat=handles.statTest(inds(1))==handles.statTest(inds(2));
        allcorr=handles.multiCorr(inds(1))==handles.multiCorr(inds(2));
        allcut=handles.thecut(inds(1))==handles.thecut(inds(2));
        alltf=handles.tf(inds(1))==handles.tf(inds(2));
        allstf=handles.stf(inds(1))==handles.stf(inds(2));
        alliopts=isstruct(handles.imputeOpts{1}) && isstruct(handles.imputeOpts{2});
        allsopts=isstruct(handles.scaleOpts{1}) && isstruct(handles.scaleOpts{2});
        if ~allscale || ~allimpute || ~allimputewhen || ~allstat || ~allcorr || ~allcut || ~alltf ...
            || ~allstf || ~alliopts || ~allsopts    
            warnmsg={'You have changed the default statistical selection settings for',...
                     'at least one of the Analysis objects. You cannot further select',...
                     'multiple contents from the list on the right. Please set your',...
                     'parameters one at a time'};
            uiwait(warndlg(warnmsg,'Warning'));
            set(hObject,'Value',plasminds(1),'Max',1)
            inds=inds(1);
        end
    elseif length(inds)>2
        allscale=checkallsame(handles.scale(inds));
        allimpute=checkallsame(handles.impute(inds));
        allimputewhen=checkallsame(handles.imputeBefOrAft(inds));
        allstat=checkallsame(handles.statTest(inds));
        allcorr=checkallsame(handles.multiCorr(inds));
        allcut=checkallsame(handles.thecut(inds));
        alltf=checkallsame(handles.tf(inds));
        allstf=checkallsame(handles.stf(inds));
        if ~allscale || ~allimpute || ~allimputewhen || ~allstat || ~allcorr || ~allcut || ~alltf || ~allstf
            warnmsg={'You have changed the default statistical selection settings for',...
                     'at least one of the Analysis objects. You cannot further select',...
                     'multiple contents from the list on the right. Please set your',...
                     'parameters one at a time'};
            uiwait(warndlg(warnmsg,'Warning'));
            set(hObject,'Value',plasminds(1),'Max',1)
            inds=inds(1);
        end
        % See what is happening with scale and impute options
        for j=1:length(inds)
            if isstruct(handles.scaleOpts{j}) || isstruct(handles.imputeOpts{j})
                set(hObject,'Value',plasminds(1),'Max',1)
                inds=inds(1);
            end
        end
    end
    
    set(handles.tfCut,'String',num2str(handles.tf(inds)))
    
    if strcmp(handles.scale(inds),'mad')
        set(handles.scaleMethodPopup,'Value',1)
        % set(handles.MADYes,'Value',1)
        % set(handles.MADNo,'Value',0)
        set(handles.beforeScaling,'Enable','on')
        set(handles.afterScaling,'Enable','on')
        set(handles.displayBox,'Enable','on')
    elseif strcmp(handles.scale(inds),'quantile')
        set(handles.scaleMethodPopup,'Value',2)
        % set(handles.MADYes,'Value',0)
        % set(handles.MADNo,'Value',1)
        set(handles.beforeScaling,'Enable','on')
        set(handles.afterScaling,'Enable','on')
        set(handles.displayBox,'Enable','on')
    elseif strcmp(handles.scale(inds),'none')
        set(handles.scaleMethodPopup,'Value',3)
        % set(handles.MADYes,'Value',0)
        % set(handles.MADNo,'Value',1)
        set(handles.beforeScaling,'Enable','off')
        set(handles.afterScaling,'Enable','off')
        set(handles.displayBox,'Enable','off')
    end
    if strcmp(handles.impute(inds),'conditionmean')
        set(handles.missingPopup,'Value',1)
    elseif strcmp(handles.impute(inds),'knn')
        set(handles.missingPopup,'Value',2)
    end 
    if handles.imputeBefOrAft(inds)==1
        set(handles.beforeScaling,'Value',1)
        set(handles.afterScaling,'Value',0)
    elseif handles.imputeBefOrAft(inds)==2
        set(handles.beforeScaling,'Value',0)
        set(handles.afterScaling,'Value',1)
    end
    if handles.disbox(inds)
        set(handles.displayBox,'Value',1)
    else
        set(handles.displayBox,'Value',0)
    end
    if handles.stf(inds)
        set(handles.stfPopup,'Value',2)
    else
        set(handles.stfPopup,'Value',1)
    end
    switch handles.statTest(inds(1))
        case 1 % Kruskal-Wallis
            str=get(handles.statTestPopup,'String');
            m=strmatch('Kruskal-Wallis',str);
            if ~isempty(m)
                set(handles.statTestPopup,'Value',m)
            end
        case 2 % ANOVA
            str=get(handles.statTestPopup,'String');
            m=strmatch('1-way ANOVA',str);
            if ~isempty(m)
                set(handles.statTestPopup,'Value',m)
            end
        case 3 % t-test
            str=get(handles.statTestPopup,'String');
            m=strmatch('t-test',str);
            if ~isempty(m)
                set(handles.statTestPopup,'Value',m)
            end
        case 4 % Time Course ANOVA
            str=get(handles.statTestPopup,'String');
            m=strmatch('Time Course ANOVA',str);
            if ~isempty(m)
                set(handles.statTestPopup,'Value',m)
            end
    end
    switch handles.multiCorr(inds(1))
        case 1 % None
            set(handles.pvalStatic,'Enable','on')
            set(handles.FDRStatic,'Enable','off')
            set(handles.pvalThresh,'Enable','on','String',num2str(handles.thecut(inds)))
            set(handles.FDRThresh,'Enable','off')
            set(handles.multiCorrPopup,'Value',1)
        case 2 % Bonferroni
            set(handles.pvalStatic,'Enable','on')
            set(handles.FDRStatic,'Enable','off')
            set(handles.pvalThresh,'Enable','on','String',num2str(handles.thecut(inds)))
            set(handles.FDRThresh,'Enable','off')
            set(handles.multiCorrPopup,'Value',2)
        case 3 % Benjamini-Hochberg
            set(handles.pvalStatic,'Enable','off')
            set(handles.FDRStatic,'Enable','on')
            set(handles.pvalThresh,'Enable','off')
            set(handles.FDRThresh,'Enable','on','String',num2str(handles.thecut(inds)))
            set(handles.multiCorrPopup,'Value',3)
        case 4 % Storey pFDR Bootstrap
            handles.multiCorr(inds)=4;
            set(handles.pvalStatic,'Enable','off')
            set(handles.FDRStatic,'Enable','on')
            set(handles.pvalThresh,'Enable','off')
            set(handles.FDRThresh,'Enable','on','String',num2str(handles.thecut(inds)))
            set(handles.multiCorrPopup,'Value',4)
        case 5 % Storey pFDR Polynomial
            set(handles.pvalStatic,'Enable','off')
            set(handles.FDRStatic,'Enable','on')
            set(handles.pvalThresh,'Enable','off')
            set(handles.FDRThresh,'Enable','on','String',num2str(handles.thecut(inds)))
            set(handles.multiCorrPopup,'Value',5)
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function analysisAddList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in missingPopup.
function missingPopup_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    mismet=get(hObject,'Value');
    mismetnames=get(hObject,'String');
    switch mismet
        case 1
            handles.impute(inds)={'conditionmean'}; % Means
            handles.imputeName(inds)=mismetnames(1);
        case 2
            handles.impute(inds)={'knn'}; % kNN
            handles.imputeName(inds)=mismetnames(2);
            
            % Now we have to call the external editor to get kNN parameters
            [out,cancel]=kNNImputeProps(handles.noarr,handles.imputeOpts(inds));
            
            if ~cancel
                for i=1:length(inds)
                    handles.imputeOpts{inds(i)}=out;
                end
            end
    end

end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function missingPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tfCut_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    tf=str2double(get(hObject,'String'));
    if isnan(tf) || tf<0 || tf>1
        uiwait(errordlg('You must enter a number between 0 and 1','Bad Input','modal'));
        set(hObject,'String','0.6');
        handles.tf(inds)=0.6; % Back to the default
    else
        handles.tf(inds)=tf;
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function tfCut_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stfPopup.
function stfPopup_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    if get(hObject,'Value')==1
        handles.stf(inds)=0;
    elseif get(hObject,'Value')==2
        handles.stf(inds)=1;
    end
end
guidata(hObject,handles);


% --- Executes on selection change in scaleMethodPopup.
function scaleMethodPopup_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    scamet=get(hObject,'Value');
    scametnames=get(hObject,'String');
    switch scamet
        case 1
            handles.scale(inds)={'mad'}; % MAD
            handles.scaleName(inds)=scametnames(1);
            set(handles.beforeScaling,'Enable','on')
            set(handles.afterScaling,'Enable','on')
            set(handles.displayBox,'Enable','on')
        case 2
            handles.scale(inds)={'quantile'}; % Quantile
            handles.scaleName(inds)=scametnames(2);
            set(handles.beforeScaling,'Enable','on')
            set(handles.afterScaling,'Enable','on')
            set(handles.displayBox,'Enable','on')
            
            % Now we have to call the external editor to get kNN parameters
            [out,cancel]=QuantileProps(handles.scaleOpts(inds));

            if ~cancel
                for i=1:length(inds)
                    handles.scaleOpts{inds(i)}=out;
                end
            end
        case 3
            handles.scale(inds)={'none'}; % None
            handles.scaleName(inds)=scametnames(3);
            set(handles.beforeScaling,'Enable','off')
            set(handles.afterScaling,'Enable','off')
            set(handles.displayBox,'Enable','off')
            
    end

end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function scaleMethodPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in MADYes.
% function MADYes_Callback(hObject, eventdata, handles)
% 
% if ~isempty(handles.tempNewIndices)
%     realinds=handles.tempNewIndices;
%     plasminds=get(handles.analysisAddList,'Value');
%     inds=realinds(plasminds);
%     if get(hObject,'Value')==1
%         handles.mad(inds)={'mad'};
%         handles.madYesNo(inds)={'Yes'};
%         set(handles.beforeScaling,'Enable','on')
%         set(handles.afterScaling,'Enable','on')
%         set(handles.displayBox,'Enable','on')
%     else
%         handles.mad(inds)={'nomad'};
%         handles.madYesNo(inds)={'No'};
%         set(handles.beforeScaling,'Enable','off')
%         set(handles.afterScaling,'Enable','off')
%         set(handles.displayBox,'Enable','off')
%     end
% end
% guidata(hObject,handles);
% 
% 
% % --- Executes on button press in MADNo.
% function MADNo_Callback(hObject, eventdata, handles)
% 
% if ~isempty(handles.tempNewIndices)
%     realinds=handles.tempNewIndices;
%     plasminds=get(handles.analysisAddList,'Value');
%     inds=realinds(plasminds);
%     if get(hObject,'Value')==1
%         handles.mad(inds)={'nomad'};
%         handles.madYesNo(inds)={'No'};
%         set(handles.beforeScaling,'Enable','off')
%         set(handles.afterScaling,'Enable','off')
%         set(handles.displayBox,'Enable','off')
%     else
%         handles.mad(inds)={'mad'};
%         handles.madYesNo(inds)={'Yes'};
%         set(handles.beforeScaling,'Enable','on')
%         set(handles.afterScaling,'Enable','on')
%         set(handles.displayBox,'Enable','on')
%     end
% end
% guidata(hObject,handles);


% --- Executes on button press in beforeScaling.
function beforeScaling_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    if get(hObject,'Value')==1
        handles.imputeBefOrAft(inds)=1;
        handles.imputeBefOrAftName(inds)={'Before scaling'};
    else
        handles.imputeBefOrAft(inds)=2;
        handles.imputeBefOrAftName(inds)={'After scaling'};
    end
end
guidata(hObject,handles);


% --- Executes on button press in afterScaling.
function afterScaling_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    if get(hObject,'Value')==1
        handles.imputeBefOrAft(inds)=2;
        handles.imputeBefOrAftName(inds)={'After scaling'};
    else
        handles.imputeBefOrAft(inds)=1;
        handles.imputeBefOrAftName(inds)={'Before scaling'};
    end
end
guidata(hObject,handles);


% --- Executes on button press in displayBox.
function displayBox_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    if get(hObject,'Value')==1
        handles.disbox(inds)=true;
    else
        handles.disbox(inds)=false;
    end
end
guidata(hObject,handles);


% --- Executes on selection change in statTestPopup.
function statTestPopup_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    val=get(hObject,'Value');
    statestnames=cellstr(get(hObject,'String'));
    statest=statestnames{val};
    if handles.nocond(inds)==1
        handles.statTest(inds)=3; % t-test, we have 1 condition (is t-test anyway...)
        handles.statTestName(inds)={'t-test'};
    else
        switch statest
            case '1-way ANOVA'
                handles.statTest(inds)=2; % ANOVA
                handles.statTestName(inds)={'1-way ANOVA'};
            case 'Kruskal-Wallis'
                handles.statTest(inds)=1; % Kruskal-Wallis
                handles.statTestName(inds)={'Kruskal-Wallis'};
            case 't-test'
                handles.statTest(inds)=3; % t-test (only if we have 2 conditions!)
                handles.statTestName(inds)={'t-test'};
            case 'Time Course ANOVA'
                handles.statTest(inds)=4; % Time Course 1-way ANOVA
                handles.statTestName(inds)={'Time Course ANOVA'};
                
                % Call the editor to get control and treated values
                if length(inds)>1
                    warnmsg={'You must select only one analysis item to perform Time Course',...
                             'ANOVA. Analysis multiple selection possibility is turned off.'};
                    uiwait(warndlg(warnmsg,'Warning'));
                    set(handles.analysisAddList,'Value',plasminds(1),'Max',1)
                    inds=inds(1);
                end
                [handles.controlIndices{inds},handles.treatedIndices{inds},...
                 handles.currentPairListContents{inds}]=...
                    TimeCourseANOVAEditor(handles.names{inds},...
                                          handles.controlIndices{inds},...
                                          handles.treatedIndices{inds},...
                                          handles.currentPairListContents{inds});
        end
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function statTestPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in multiCorrPopup.
function multiCorrPopup_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    multicorr=get(hObject,'Value');
    mutlicorrnames=get(hObject,'String');
    switch multicorr
        case 1
            handles.multiCorr(inds)=1; % None
            handles.multiCorrName(inds)=mutlicorrnames(1);
            set(handles.pvalStatic,'Enable','on')
            set(handles.FDRStatic,'Enable','off')
            set(handles.pvalThresh,'Enable','on')
            set(handles.FDRThresh,'Enable','off')
        case 2
            handles.multiCorr(inds)=2; % Bonferroni
            handles.multiCorrName(inds)=mutlicorrnames(2);
            set(handles.pvalStatic,'Enable','on')
            set(handles.FDRStatic,'Enable','off')
            set(handles.pvalThresh,'Enable','on')
            set(handles.FDRThresh,'Enable','off')
        case 3
            handles.multiCorr(inds)=3; % Benjamini-Hochberg FDR
            handles.multiCorrName(inds)=mutlicorrnames(3);
            set(handles.pvalStatic,'Enable','off')
            set(handles.FDRStatic,'Enable','on')
            set(handles.pvalThresh,'Enable','off')
            set(handles.FDRThresh,'Enable','on')
        case 4
            handles.multiCorr(inds)=4; % Storey pFDR Bootstrap
            handles.multiCorrName(inds)=mutlicorrnames(4);
            set(handles.pvalStatic,'Enable','off')
            set(handles.FDRStatic,'Enable','on')
            set(handles.pvalThresh,'Enable','off')
            set(handles.FDRThresh,'Enable','on')
        case 5
            handles.multiCorr(inds)=5; % Storey pFDR Polynomial
            handles.multiCorrName(inds)=mutlicorrnames(5);
            set(handles.pvalStatic,'Enable','off')
            set(handles.FDRStatic,'Enable','on')
            set(handles.pvalThresh,'Enable','off')
            set(handles.FDRThresh,'Enable','on')
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function multiCorrPopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pvalThresh_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    val=str2double(get(hObject,'String'));
    if isnan(val) || val<=0 || val>1
        uiwait(errordlg('You must enter a number between 0 and 1!','Bad Input','modal'));
        set(hObject,'String','0.05')
        handles.thecut(inds)=str2double(get(hObject,'String'));
    else
        handles.thecut(inds)=val;
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function pvalThresh_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FDRThresh_Callback(hObject, eventdata, handles)

if ~isempty(handles.tempNewIndices)
    realinds=handles.tempNewIndices;
    plasminds=get(handles.analysisAddList,'Value');
    inds=realinds(plasminds);
    val=str2double(get(hObject,'String'));
    if isnan(val) || val<=0 || val>1
        uiwait(errordlg('You must enter a number between 0 and 1!','Bad Input','modal'));
        set(hObject,'String','0.05')
        handles.thecut(inds)=str2double(get(hObject,'String'));
    else
        handles.thecut(inds)=val;
    end
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function FDRThresh_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addButton.
function addButton_Callback(hObject, eventdata, handles)

% Determine what remains and what is to be added
analysisNames=get(handles.analysisRemainList,'String');
analysisToAddInd=get(handles.analysisRemainList,'Value');
analysisToAddNames=analysisNames(analysisToAddInd);

% Do the job
oldstr=get(handles.analysisAddList,'String');
addstr=analysisToAddNames;
verify=ismember(addstr,oldstr);
if isempty(oldstr)
    newstr=[oldstr;addstr];
elseif length(verify)==1
    if ~ismember(addstr,oldstr)
        newstr=[oldstr;addstr];
    else
        newstr=oldstr;
    end
else
    newstr=[oldstr;addstr];
end

% Fill the add list...
set(handles.analysisAddList,'String',sort(newstr),'Max',length(newstr))
% ...and update the remaining list by removing names
remaining=analysisNames;
remaining(analysisToAddInd)=[];
set(handles.analysisRemainList,'String',sort(remaining),'Max',length(remaining),'Value',1)
% Fix the final indices vectors
newindices=handles.tempOldIndices(analysisToAddInd);
handles.tempOldIndices(analysisToAddInd)=[];
handles.tempOldIndices=sort(handles.tempOldIndices);
handles.tempNewIndices=sort([handles.tempNewIndices,newindices]);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% msgold=['The old indices are : ',num2str(handles.tempOldIndices)];
% msgnew=['The new indices are : ',num2str(handles.tempNewIndices)];
% disp(' ')
% disp(msgold)
% disp(msgnew)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Manage Add/Remove buttons
if ~isempty(get(handles.analysisAddList,'String'))
    set(handles.removeButton,'Enable','on')
    % Also enable OK button
    set(handles.okButton,'Enable','on')
end
if isempty(get(handles.analysisRemainList,'String'))
    set(handles.addButton,'Enable','off')
end

guidata(hObject,handles);


% --- Executes on button press in removeButton.
function removeButton_Callback(hObject, eventdata, handles)

% Determine what exists and what is to be removed
analysisNames=get(handles.analysisAddList,'String');
analysisToRemoveInd=get(handles.analysisAddList,'Value');
analysisToRemoveNames=analysisNames(analysisToRemoveInd);

% Do the job
oldstr=get(handles.analysisRemainList,'String');
addstr=analysisToRemoveNames;
verify=ismember(addstr,oldstr);
if isempty(oldstr)
    newstr=[oldstr;addstr];
elseif length(verify)==1
    if ~ismember(addstr,oldstr)
        newstr=[oldstr;addstr];
    else
        newstr=oldstr;
    end
else
    newstr=[oldstr;addstr];
end

% Fill the remain list...
set(handles.analysisRemainList,'String',sort(newstr),'Max',length(newstr))
% ...and update the add list by removing names
added=analysisNames;
added(analysisToRemoveInd)=[];
set(handles.analysisAddList,'String',sort(added),'Max',length(added),'Value',1)
% Fix the final indices vectors
newindices=handles.tempNewIndices(analysisToRemoveInd);
handles.tempOldIndices=sort([handles.tempOldIndices,newindices]);
handles.tempNewIndices(analysisToRemoveInd)=[];
handles.tempNewIndices=sort(handles.tempNewIndices);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% msgold=['The old indices are : ',num2str(handles.tempOldIndices)];
% msgnew=['The new indices are : ',num2str(handles.tempNewIndices)];
% disp(' ')
% disp(msgold)
% disp(msgnew)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Manage Add/Remove buttons
if ~isempty(get(handles.analysisRemainList,'String'))
    set(handles.addButton,'Enable','on')
end
if isempty(get(handles.analysisAddList,'String'))
    set(handles.removeButton,'Enable','off')
    % Also disable OK button
    set(handles.okButton,'Enable','off')
end

guidata(hObject,handles);


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

% Update indices output
if ~isempty(handles.tempNewIndices)
    handles.indices=handles.tempNewIndices;
    guidata(hObject,handles);
end
uiresume(handles.StatisticalSelectionEditor);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)

% Resume defaults
handles.indices=1:handles.len;
for i=1:handles.len
    handles.scale{i}='mad';
    handles.scaleName{i}='MAD';
    handles.impute{i}='conditionmean';
    handles.imputeName{i}='Average within condition';
    handles.imputeBefOrAft(i)=2;
    handles.imputeBefOrAftName{i}='After scaling'; 
    handles.statTest(i)=2;
    handles.statTestName{i}='1-way ANOVA';
    handles.multiCorr(i)=1;
    handles.multiCorrName{i}='None';
    handles.thecut(i)=0.05;
    handles.tf(i)=0.6;
    handles.stf(i)=0;
    handles.disbox(i)=false;
end
handles.scaleOpts=cell(1,3);
handles.imputeOpts=cell(1,3);
handles.cancel=true; % Cancel pressed
guidata(hObject,handles);
uiresume(handles.StatisticalSelectionEditor);
