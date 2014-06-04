function varargout = ARMADA(varargin)
% ARMADA M-file for ARMADA.fig
%      ARMADA, by itself, creates a new ARMADA or raises the existing
%      singleton*.
%
%      H = ARMADA returns the handle to a new ARMADA or the handle to
%      the existing singleton*.
%
%      ARMADA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARMADA.M with the given input arguments.
%
%      ARMADA('Property','Value',...) creates a new ARMADA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ARMADA_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ARMADA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ARMADA

% Last Modified by GUIDE v2.5 24-May-2010 20:25:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ARMADA_OpeningFcn, ...
                   'gui_OutputFcn',  @ARMADA_OutputFcn, ...
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


% --- Executes just before ARMADA is made visible.
function ARMADA_OpeningFcn(hObject, eventdata, handles, varargin)

% Get input arguments, the number of opened sessions
if isempty(varargin)
    % First session
    handles.sessionNumber=1;
else
    % This treatment may cause bug if ARMADA is opened from the command window a second
    % time without input arguments
    handles.sessionNumber=varargin{1};
end

handles.projExp=uicontrol(handles.ARMADA_main,...
                          'String','Project Explorer',...
                          'Units','normalized','Style','Text',...
                          'Position',[0.005 0.975 0.17 0.015],...
                          'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'),...
                          'FontSize',8,...
                          'Tag',['projExpStatic',num2str(handles.sessionNumber)],...
                          'Visible','off');
handles.itemInfo=uicontrol(handles.ARMADA_main,...
                          'String','Item Information',...
                          'Units','normalized',...
                          'Style','Edit',...
                          'Position',[0.005 0.9425 0.17 0.028],...
                          'BackgroundColor',[.925 .914 .847],...
                          'FontSize',9,...
                          'FontWeight','demi',...
                          'Tag',['itemInfoEdit',num2str(handles.sessionNumber)],...
                          'Visible','off');

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.ARMADA_main,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.ARMADA_main,'Position',winpos);

ax=axes('Units','normalized','Tag','splashImage');
im=imread('logo.jpg');
axis image
set(ax,'OuterPosition',[0.45 0.6 0.35 0.35])
image(im)
axis off

% Current version
handles.currentVersion=2.1;
% Initialize Project Info
handles.Project=[];
% Initialize how many times we have chosen subsets of conditions flag (useful for updating
% Project and analysis information in the corresponding structures
handles.selectConditionsIndex=1;
% Initialize the current analysis selection index in the tree
handles.currentSelectionIndex=1;
% Initialize an analysis selection change boolean
handles.analysisIndexChanged=false;
% Initialize project notes
handles.notes={};
% Create a variable indicating that something has changed during program usage (to be used
% in exiting process)
handles.somethingChanged=false;
% Create export settings
opts.sp=false;
opts.genenames=true;
opts.pvalues=true;
opts.qvalues=false;
opts.fdr=false;
opts.foldchange=true;
opts.rawratio=false;
opts.logratio=false;
opts.meanrawratio=false;
opts.meanlogratio=false;
opts.medianrawratio=false;
opts.medianlogratio=false;
opts.stdevrawratio=false;
opts.stdevlogratio=false;
opts.intensity=false;
opts.meanintensity=true;
opts.medianintensity=false;
opts.stdevintensity=true;
opts.normlogratio=true;
opts.meannormlogratio=true;
opts.mediannormlogratio=false;
opts.stdevnormlogratio=true;
opts.normrawratio=false;
opts.meannormrawratio=false;
opts.mediannormrawratio=false;
opts.stdevnormrawratio=false;
opts.trustfactors=true;
opts.cvs=true;
opts.outtype='text';
handles.exportSettings=opts;
% Update handles structure
guidata(hObject,handles);

% UIWAIT makes ARMADA wait for user response (see UIRESUME)
% uiwait(handles.ARMADA_main);


% --- Outputs from this function are returned to the command line.
function varargout = ARMADA_OutputFcn(hObject, eventdata, handles)

varargout{1}=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                    BEGIN MENU ITEMS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function fileNew_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function fileNewSession_Callback(hObject, eventdata, handles)

sesno=handles.sessionNumber;
ARMADA(sesno+1);


% --------------------------------------------------------------------
function fileNewProject_Callback(hObject, eventdata, handles)

% Get a name for the project
[filename,pathname]=uiputfile({'*.apj','ARMADA Project Files'},'New Project');
if filename==0
    uiwait(msgbox('No file specified','Project','modal'));
    return
else
    if handles.somethingChanged
        answer=questdlg('Do you want to save changes in your current project?','Save changes');
        if strcmp(answer,'Yes')
            fileSave_Callback(hObject, eventdata, handles)
            handles=reinit(handles); % Delete old project, reinitiate all data
        elseif strcmp(answer,'No')
            handles=reinit(handles); % Delete old project, reinitiate all data
        elseif strcmp(answer,'Cancel')
            return
        end
    else
        handles=reinit(handles); % Delete old project, reinitiate all data
    end
    handles.Project.Name=strrep(filename,'.apj','');
    if ~isempty(strfind(filename,'.apj'))
        handles.Project.Filename=strcat(pathname,filename);
    else
        handles.Project.Filename=strcat(pathname,filename,'.apj');
    end
    handles.Project.Date=datestr(now);
end

try
    newproj=handles.Project.Filename;
    Project=handles.Project;
    version=handles.currentVersion;
    save(newproj,'Project','version');
    % Activate Save etc.
    set(handles.fileSave,'Enable','on')
    set(handles.fileSaveAs,'Enable','on')
    set(handles.fileDataImport,'Enable','on')
    % Create project tree
    handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                 handles.sessionNumber);
    % Hide splash text
    set(handles.androTitleStatic,'Visible','off')
    set(handles.androGroupInfoStatic,'Visible','off')
catch
    oops={'An error occured while trying to save the following file',...
          newproj,...
          lasterr};
    uiwait(errordlg(oops,'Error Saving File...','modal'));
end

guidata(hObject,handles);


% --------------------------------------------------------------------
function fileOpen_Callback(hObject, eventdata, handles)

try
    
    [fPrevious,fprevpath]=uigetfile({'*.apj','ARMADA Project Files (*.apj)'},...
                                     'Open Project');
    if fPrevious==0
        uiwait(msgbox('No File was selected','Open'));
        return
    end
    
    if handles.somethingChanged
        answer=questdlg('Do you want to save changes in your current project?','Save changes');
        if strcmp(answer,'Yes')
            fileSave_Callback(hObject, eventdata, handles)
            handles=reinit(handles); % Delete old project, reinitiate all data
        elseif strcmp(answer,'No')
            handles=reinit(handles); % Delete old project, reinitiate all data
        elseif strcmp(answer,'Cancel')
            return
        end
    else
        handles=reinit(handles); % Delete old project, reinitiate all data
    end
    
    hh=showinfowindow('Opening project. Please wait...');
    
    fPrevious=strcat(fprevpath,fPrevious);    
    S=load('-mat',fPrevious);
    
    % Check the case of projects derived from Batch Programmer
    if isfield(S,'stru')
        S=S.stru;
    end
    
    % Version
    if isfield(S,'version')
        handles.version=S.version;
    else % Older version by default
        handles.version=1.1;
    end
    
    if isfield(S,'Project')
        handles.Project=S.Project;
        handles.Project.Filename=fPrevious;
    end
    if isfield(S,'experimentInfo')
        handles.experimentInfo=S.experimentInfo;
    end
    if isfield(S,'analysisInfo')
        handles.analysisInfo=S.analysisInfo;
    end
    if isfield(S,'datstruct')
        handles.datstruct=S.datstruct;
    end
    if isfield(S,'selectConditionsIndex')
        handles.selectConditionsIndex=S.selectConditionsIndex;
    end
    if isfield(S,'currentSelectionIndex')
        handles.currentSelectionIndex=S.currentSelectionIndex;
        handles.currentSelectionIndex=1;
    end
    if isfield(S,'selectedConditions')
        handles.selectedConditions=S.selectedConditions;
    end
    if isfield(S,'mainmsg')
        handles.mainmsg=S.mainmsg;
        set(handles.mainTextbox,'String',handles.mainmsg)
    end
    if isfield(S,'attributes')
        handles.attributes=S.attributes;
    end
    if isfield(S,'notes')
        handles.notes=S.notes;
    end
    if isfield(S,'cdfstruct')
        handles.cdfstruct=S.cdfstruct;
    end
    % if isfield(S,'tree')
    %     handles.tree=S.tree;
    % end

    %%%%%%%%%%%%%%% Some compatibility with old projects %%%%%%%%%%%%%%%%%%%%
    if handles.version<2
        if isfield(S,'gnID')
            handles.attributes.gnID=S.gnID;
        end
        if isfield(handles,'datstruct') && ~isempty(handles.datstruct)
            handles.attributes.Indices=handles.datstruct{1}{1}.Indices;
            handles.attributes.Shape=handles.datstruct{1}{1}.Shape;
            for i=1:length(handles.datstruct)
                for j=1:length(handles.datstruct{i})
                    handles.datstruct{i}{j}=rmfield(handles.datstruct{i}{j},{'Indices','Shape'});
                end
            end
            if isfield(handles.datstruct{1}{1},'Number')
                handles.attributes.Number=handles.datstruct{1}{1}.Number;
                for i=1:length(handles.datstruct)
                    for j=1:length(handles.datstruct{i})
                        handles.datstruct{i}{j}=rmfield(handles.datstruct{i}{j},'Number');
                    end
                end
            end
        else
            handles.attributes.Number=[];
            handles.attributes.Indices=[];
            handles.attributes.Shape=[];
            handles.attributes.Channels=[];
        end
    end
    if isfield(handles,'analysisInfo') && ~isfield(handles.analysisInfo,'numberOfSlides')
        for i=1:length(handles.analysisInfo)
            handles.analysisInfo(i).numberOfSlides=handles.Project.Analysis(i).NumberOfSlides;
        end
    end
    
    if handles.version<handles.currentVersion
        if isfield(handles,'experimentInfo') && ~isempty(handles.experimentInfo)
            if ~ismember(handles.experimentInfo.imgsw,[98 99 100]) && ~isfield(handles.attributes,'pbID')
                handles.attributes.pbID=handles.attributes.gnID;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Create experiment tree
    handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                 handles.sessionNumber);
    
    % Fill array listbox and manage buttons that do not require analysis to have been
    % performed
    if isfield(handles,'experimentInfo')
        index=0;
        if isfield(handles.Project,'NumberOfSlides')
            contents=cell(handles.Project.NumberOfSlides,1);
        else
            contents=cell(1,1);
        end
        for i=1:handles.experimentInfo.numberOfConditions
            for j=1:max(size(handles.experimentInfo.exprp{i}))
                index=index+1;
                contents{index}=handles.experimentInfo.exprp{i}{j};
            end
        end
        set(handles.arrayObjectList,'String',contents,'Max',length(contents))
        % Enable some buttons
        % set(handles.imageViewRadio,'Enable','on')
        % set(handles.tableViewRadio,'Enable','on')
        set(handles.view,'Enable','on')
        set(handles.rawImageButton,'Enable','on')
        set(handles.arrayRawButton,'Enable','on')
        set(handles.viewRawImage,'Enable','on')
        set(handles.viewRawData,'Enable','on')
        set(handles.viewArrayReport,'Enable','on')
        % Enable context menus
        set(handles.arrayContextImage,'Enable','on')
        set(handles.arrayContextData,'Enable','on')
        set(handles.arrayContextReport,'Enable','on')
    end
    
    % Fill analysis objects listbox and manage buttons that require analysis steps to have
    % been performed
    if isfield(handles,'analysisInfo')
        anal=cell(length(handles.analysisInfo),1);
        for i=1:length(handles.analysisInfo)
            anal{i}=['Analysis ',num2str(i)];
        end
        set(handles.analysisObjectList,'String',anal)
        set(handles.analysisContextDelete,'Enable','on')
        set(handles.analysisContextReport,'Enable','on')
        set(handles.viewAnalysisReport,'Enable','on')
        % Enable more buttons
        if isfield(handles.analysisInfo,'DataCellNormLo')
            set(handles.normImageButton,'Enable','on')
            % Easier to put context menu control here
            set(handles.arrayContextNormImage,'Enable','on')
            set(handles.analysisContextNormList,'Enable','on')
            set(handles.analysisContextExportNormList,'Enable','on')
        end
        if isfield(handles.analysisInfo,'DataCellFiltered')
           set(handles.toolsPCA,'Enable','on')
        end
        if isfield(handles.analysisInfo,'DataCellStat')
            set(handles.DEListButton,'Enable','on')
            set(handles.exportListButton,'Enable','on')
            % Easier to put context menu control here
            set(handles.analysisContextDEList,'Enable','on')
            set(handles.analysisContextExportDEList,'Enable','on')
        end
        if isfield(handles.analysisInfo,'FinalTable')
            set(handles.clusterListButton,'Enable','on')
            set(handles.exportClusterList,'Enable','on')
            set(handles.viewClusterList,'Enable','on')
            set(handles.fileDataExportClusters,'Enable','on')
            % Easier to put context menu control here
            set(handles.analysisContextClusterList,'Enable','on')
            set(handles.analysisContextExportClusterList,'Enable','on')
        end
    end
   
    % Manage menus
    set(handles.fileSave,'Enable','on')
    set(handles.fileSaveAs,'Enable','on')
    if ~isfield(handles,'experimentInfo')
        % Maybe too strict... possible for removal
        % It forces user to create new project in order to import new data
        set(handles.fileDataImport,'Enable','on')
        set(handles.preprocess,'Enable','off')
        set(handles.plots,'Enable','off')
        set(handles.toolsBatch,'Enable','off')
    else
        set(handles.fileDataImport,'Enable','off')
        set(handles.preprocess,'Enable','on')
        set(handles.plots,'Enable','on')
        set(handles.toolsBatch,'Enable','on')
        
        % Deal with Affy options...
        if handles.experimentInfo.imgsw==99
            set(handles.preprocessAffyBackNormSum,'Visible','on')
            set(handles.preprocessAffyFiltering,'Visible','on')
            set(handles.preprocessNormalizationIllu,'Visible','off')
            set(handles.preprocessFilteringIllu,'Visible','off')
            set(handles.preprocessBackground,'Visible','off')
            set(handles.preprocessFilter,'Visible','off')
            set(handles.preprocessNormalization,'Visible','off')
            % Deal with plot options
            set(handles.plotsMAAffy,'Visible','on')
            set(handles.plotsSlideDistribAffy,'Visible','on')
            set(handles.plotsBoxplotAffy,'Visible','on')
            set(handles.plotsNormUnnorm,'Visible','off')
            set(handles.plotsMA,'Visible','off')
            set(handles.plotsSlideDistrib,'Visible','off')
            set(handles.plotsBoxplot,'Visible','off')
            % Disable raw table view... OUT OF MEMORY...
            set(handles.arrayRawButton,'Enable','off')
            set(handles.viewRawData,'Enable','off')
            set(handles.arrayContextData,'Enable','off')
            % Get the proper default export settings
            handles.exportSettings=change2AffyExport;
        elseif handles.experimentInfo.imgsw==98
            set(handles.preprocessAffyBackNormSum,'Visible','off')
            set(handles.preprocessAffyFiltering,'Visible','off')
            set(handles.preprocessNormalizationIllu,'Visible','on')
            set(handles.preprocessFilteringIllu,'Visible','on')
            set(handles.preprocessBackground,'Visible','off')
            set(handles.preprocessFilter,'Visible','off')
            set(handles.preprocessNormalization,'Visible','off')
            % Deal with plot options
            set(handles.plotsMAAffy,'Visible','on')
            set(handles.plotsSlideDistribAffy,'Visible','on')
            set(handles.plotsBoxplotAffy,'Visible','on')
            set(handles.plotsNormUnnorm,'Visible','off')
            set(handles.plotsMA,'Visible','off')
            set(handles.plotsSlideDistrib,'Visible','off')
            set(handles.plotsBoxplot,'Visible','off')
            % Enable raw table view... feasible in Illus
            set(handles.arrayRawButton,'Enable','on')
            set(handles.viewRawData,'Enable','on')
            set(handles.arrayContextData,'Enable','on')
            % Get the proper default export settings
            handles.exportSettings=change2AffyExport;
        else
            set(handles.preprocessAffyBackNormSum,'Visible','off')
            set(handles.preprocessAffyFiltering,'Visible','off')
            set(handles.preprocessNormalizationIllu,'Visible','off')
            set(handles.preprocessFilteringIllu,'Visible','off')
            set(handles.preprocessBackground,'Visible','on')
            set(handles.preprocessFilter,'Visible','on')
            set(handles.preprocessNormalization,'Visible','on')
            % Deal with plot options
            set(handles.plotsMAAffy,'Visible','off')
            set(handles.plotsSlideDistribAffy,'Visible','off')
            set(handles.plotsBoxplotAffy,'Visible','off')
            set(handles.plotsNormUnnorm,'Visible','on')
            set(handles.plotsMA,'Visible','on')
            set(handles.plotsSlideDistrib,'Visible','on')
            set(handles.plotsBoxplot,'Visible','on')
            % Enable raw table view... feasible in cDNAs
            set(handles.arrayRawButton,'Enable','on')
            set(handles.viewRawData,'Enable','on')
            set(handles.arrayContextData,'Enable','on')
            % Get the proper default export settings
            handles.exportSettings=change2cDNAExport;
        end
        
    end
    if isfield(handles,'analysisInfo')
        set(handles.fileExportSettingsMAT,'Enable','on')
        if isfield(handles.analysisInfo,'DataCellNormLo')
            if handles.analysisInfo(1).numberOfConditions==1 && ...
               handles.analysisInfo(1).numberOfSlides==1
                set(handles.stats,'Enable','off')
            else
                set(handles.stats,'Enable','on')
            end
            if handles.analysisInfo(1).numberOfConditions>1
                set(handles.statsFoldChangeCalc,'Enable','on')
            end
            set(handles.plotsNormUnnorm,'Enable','on')
            set(handles.plotsMA,'Enable','on')
            set(handles.plotsSlideDistrib,'Enable','on')
            set(handles.plotsExprProfile,'Enable','on')
            set(handles.viewNormData,'Enable','on')
            set(handles.viewNormImage,'Enable','on')
            set(handles.fileDataExport,'Enable','on')
            set(handles.fileDataExportNorm,'Enable','on')
        end
        %if isfield(handles.analysisInfo,'DataCellFiltered')
        %    if ~isempty(handles.analysisInfo(1).DataCellFiltered)
        %        set(handles.plotsExprProfile,'Enable','on')
        %    end
        %end
        if isfield(handles.analysisInfo,'DataCellStat')
            if ~isempty(handles.analysisInfo(1).DataCellStat)
                set(handles.statsClustering,'Enable','on')
                set(handles.toolsGap,'Enable','on')
                if handles.analysisInfo(1).numberOfConditions==1 || ...
                   handles.analysisInfo(1).numberOfConditions==2
                    set(handles.plotsVolcano,'Enable','on')
                end
                set(handles.viewDEList,'Enable','on')
                set(handles.fileDataExportDE,'Enable','on')
                set(handles.statsClassification,'Enable','on')
            end
        end
    end
    
    % An additional check in the case of a project created from external data
    if isfield(handles,'datstruct') && isempty(handles.datstruct)
        set(handles.preprocessBackground,'Enable','off')
        set(handles.preprocessFilter,'Enable','off')
        if isempty(handles.experimentInfo.inten{1})
            set(handles.preprocessNormalization,'Enable','off')
        end
        set(handles.plotsArrayImage,'Enable','off')
        set(handles.plotsNormUnnorm,'Enable','off')
        set(handles.plotsArrayPlot,'Enable','off')
        set(handles.toolsBatch,'Enable','off')
    else
        set(handles.preprocessBackground,'Enable','on')
        set(handles.preprocessFilter,'Enable','on')
        set(handles.preprocessNormalization,'Enable','on')
        set(handles.plotsArrayImage,'Enable','on')
        set(handles.plotsNormUnnorm,'Enable','on')
        set(handles.plotsArrayPlot,'Enable','on')
        set(handles.toolsBatch,'Enable','on')
    end
    
    % Hide splash text
    set(handles.androTitleStatic,'Visible','off')
    set(handles.androGroupInfoStatic,'Visible','off')
    
    % Load all parameters by updating handles structure
    guidata(hObject,handles);
    
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    
    if isfield(handles,'experimentInfo')
        % Display an image
        rawImageButton_Callback(hObject,eventdata,handles)
    end
    
catch
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    opmsg={'An error occured while trying to open the following file',...
           fPrevious,...
           'Make sure that this is a valid ARMADA output file',...
           lasterr};
    uiwait(errordlg(opmsg,'Failed to open File','modal'));
    return
end


% --------------------------------------------------------------------
function fileSave_Callback(hObject, eventdata, handles)

% We need to save handles.Project, handles.experimentInfo, handles.analysisInfo,
% handles.datstruct, handles.selectConditionsIndex, handles.mainmsg, handles.gnID,
% handles.tree

hh=showinfowindow('Saving project. Please wait...');

appended=handles.Project.Filename;
% Project always exists
Project=handles.Project;
strsave='''Project''';
if isfield(handles,'experimentInfo')
    experimentInfo=handles.experimentInfo;
    strsave=[strsave,',','''experimentInfo'''];
end
if isfield(handles,'version')
    version=handles.version;
    strsave=[strsave,',','''version'''];
end
if isfield(handles,'analysisInfo')
    analysisInfo=handles.analysisInfo;
    strsave=[strsave,',','''analysisInfo'''];
end
if isfield(handles,'datstruct')
    datstruct=handles.datstruct;
    strsave=[strsave,',','''datstruct'''];
end
if isfield(handles,'selectConditionsIndex')
    selectConditionsIndex=handles.selectConditionsIndex;
    strsave=[strsave,',','''selectConditionsIndex'''];
end
if isfield(handles,'currentSelectionIndex')
    currentSelectionIndex=handles.currentSelectionIndex;
    strsave=[strsave,',','''currentSelectionIndex'''];
end
if isfield(handles,'selectedConditions')
    selectedConditions=handles.selectedConditions;
    strsave=[strsave,',','''selectedConditions'''];
end
if isfield(handles,'mainmsg')
    mainmsg=handles.mainmsg;
    strsave=[strsave,',','''mainmsg'''];
end
if isfield(handles,'attributes')
    attributes=handles.attributes;
    strsave=[strsave,',','''attributes'''];
end
if isfield(handles,'notes')
    notes=handles.notes;
    strsave=[strsave,',','''notes'''];
end
if isfield(handles,'cdfstruct')
    cdfstruct=handles.cdfstruct;
    strsave=[strsave,',','''cdfstruct'''];
end
% if isfield(handles,'tree')
%     tree=handles.tree;
%     strsave=[strsave,',','''tree'''];
% end
% strsave=['save(appended,',strsave,',''-append'');'];
strsave=['save(appended,',strsave,');'];


try 
    eval(strsave)
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    % Indicate that changes were saved
    handles.somethingChanged=false;
    guidata(hObject,handles);
catch
    errmsg={'An error occured while trying to save file',...
            appended,...
            'Please review your settings or report the following error',...
            lasterr};
    uiwait(errordlg(errmsg,'Error Saving File'));
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
end


% --------------------------------------------------------------------
function fileSaveAs_Callback(hObject, eventdata, handles)

% Get a name for the project
[newfilename,newpathname,findex]=uiputfile({'*.apj','ARMADA Project Files (*.apj)';...
                                            '*.mat','MATLAB Workspace Files (*.mat)'},...
                                            'Save Project As...');
if newfilename==0
    uiwait(msgbox('No file specified','Project','modal'));
    return
else
    newfile=strcat(newpathname,newfilename);
    switch findex
        
        case 1 % ARMADA project files
            
            hh=showinfowindow('Saving project. Please wait...');
            
            % Project always exists
            tempProj=handles.Project;
            tempProj.Name=strrep(newfilename,'.apj','');
            tempProj.Filename=newfile;
            Project=tempProj;
            strsave='''Project''';
            if isfield(handles,'experimentInfo')
                experimentInfo=handles.experimentInfo;
                strsave=[strsave,',','''experimentInfo'''];
            end
            if isfield(handles,'version')
                version=handles.version;
                strsave=[strsave,',','''version'''];
            end
            if isfield(handles,'analysisInfo')
                analysisInfo=handles.analysisInfo;
                strsave=[strsave,',','''analysisInfo'''];
            end
            if isfield(handles,'datstruct')
                datstruct=handles.datstruct;
                strsave=[strsave,',','''datstruct'''];
            end
            if isfield(handles,'selectConditionsIndex')
                selectConditionsIndex=handles.selectConditionsIndex;
                strsave=[strsave,',','''selectConditionsIndex'''];
            end
            if isfield(handles,'currentSelectionIndex')
                currentSelectionIndex=handles.currentSelectionIndex;
                strsave=[strsave,',','''currentSelectionIndex'''];
            end
            if isfield(handles,'selectedConditions')
                selectedConditions=handles.selectedConditions;
                strsave=[strsave,',','''selectedConditions'''];
            end
            if isfield(handles,'mainmsg')
                mainmsg=handles.mainmsg;
                strsave=[strsave,',','''mainmsg'''];
            end
            if isfield(handles,'attributes')
                attributes=handles.attributes;
                strsave=[strsave,',','''attributes'''];
            end
            if isfield(handles,'notes')
                notes=handles.notes;
                strsave=[strsave,',','''notes'''];
            end
            if isfield(handles,'cdfstruct')
                cdfstruct=handles.notes;
                strsave=[strsave,',','''cdfstruct'''];
            end
            strsave=['save(newfile,',strsave,');'];

            try
                eval(strsave)
                set(hh,'CloseRequestFcn','closereq')
                close(hh)
                % Re-create experiment tree
                handles.tree=myexplorestruct(handles.ARMADA_main,Project,Project.Name,...
                                             handles.sessionNumber);
            catch
                errmsg={'An error occured while trying to save file',...
                        newfile,...
                        'Please review your settings or report the following error',...
                        lasterr};
                uiwait(errordlg(errmsg,'Error Saving File'));
                set(hh,'CloseRequestFcn','closereq')
                close(hh)
            end
            
        case 2 % MATLAB workspace files
            
            uiwait(helpdlg('Please use File -> Export Data -> MATLAB Workspace'));
            
    end
    
end


% --------------------------------------------------------------------
function fileExportSettings_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function fileExportSettingsMAT_Callback(hObject, eventdata, handles)

% Create input for the export editor
if ~isfield(handles,'analysisInfo')
    uiwait(warndlg({'Please create an Analysis object first.'},'Warning'));
    return
end

if handles.experimentInfo.imgsw==99 % Affymetrix
    
    for i=1:length(handles.analysisInfo)
        if isfield(handles.analysisInfo,'DataCellNormLo') && ~isempty(handles.analysisInfo(i).DataCellNormLo)
            whatisdone(i).adjnormsum=true;
        else
            whatisdone(i).adjnormsum=false;
        end
        if isfield(handles.analysisInfo(i),'DataCellStat') && ~isempty(handles.analysisInfo(i).DataCellStat)
            whatisdone(i).degenes=true;
        else
            whatisdone(i).degenes=false;
        end
    end
    
else % cDNAs
    
    for i=1:length(handles.analysisInfo)
        if ~isempty(handles.datstruct)
            whatisdone(i).raw=true;
        else
            whatisdone(i).raw=false;
        end
        if isfield(handles.analysisInfo(i),'exptab') && ~isempty(handles.analysisInfo(i).exptab)
            whatisdone(i).unnormratio=true;
        else
            whatisdone(i).unnormratio=false;
        end
        if isfield(handles.analysisInfo(i),'DataCellNormLo') && ~isempty(handles.analysisInfo(i).DataCellNormLo)
            whatisdone(i).normratio=true;
        else
            whatisdone(i).normratio=false;
        end
        if isfield(handles.analysisInfo(i),'DataCellStat') && ~isempty(handles.analysisInfo(i).DataCellStat)
            whatisdone(i).degenes=true;
        else
            whatisdone(i).degenes=false;
        end
    end
    
end

contents=get(handles.analysisObjectList,'String');
if ~iscell(contents)
    contents=cellstr(contents);
end
len=length(contents);

try

    % Get export parameters
    if handles.experimentInfo.imgsw==99 % Affymetrix
        [what,cancel]=ExportMATLABEditorAffy(len,whatisdone);
    else
        [what,cancel]=ExportMATLABEditor(len,whatisdone);
    end
    
    if ~cancel
        
        % Silence some warnings concerning dataset names
        warning('off','stats:dataset:setvarnames:ModifiedVarnames')
        
        if handles.experimentInfo.imgsw==99 % Affymetrix
            
            % Initialize the output structure
            for i=1:length(what)
                A(i).ProbesetIDs=[];
                A(i).RawData.PM=[];
                A(i).RawData.MM=[];
                A(i).RawSummarized=[];
                A(i).BackSummarized=[];
                A(i).NormSummarized=[];
                A(i).DEGenesStats=[];
            end
            
            % The hard part... fill with data
            % We assume that data exist because checking has been done in the export editor.
            for i=1:length(what)

                if what(i).genenames
                    A(i).ProbesetIDs=handles.gnID;
                end

                if what(i).rawdata

                    m=handles.analysisInfo(i).numberOfConditions;
                    exprp=handles.analysisInfo(i).exprp;
                    exptab=handles.analysisInfo(i).exptab;

                    % Create PM data
                    cellpm=cell(1,m);
                    for j=1:m
                        n=size(exprp{j},2);
                        cellpm{j}=cell(1,n);
                        for k=1:n
                            cellpm{j}{k}=exptab{j}{k}(:,1);
                        end
                        cellpm{j}=cell2mat(cellpm{j});
                    end
                    cellpm=cell2mat(cellpm);

                    % Create MM data
                    cellmm=cell(1,m);
                    for j=1:m
                        n=size(exprp{j},2);
                        cellmm{j}=cell(1,n);
                        for k=1:n
                            cellmm{j}{k}=exptab{j}{k}(:,2);
                        end
                        cellmm{j}=cell2mat(cellmm{j});
                    end
                    cellmm=cell2mat(cellmm);

                    % Create column names for the dataset
                    count=0;
                    for j=1:m
                        count=count+size(exprp{j},2);
                    end
                    pmnames=cell(1,count);
                    mmnames=cell(1,count);
                    % Fix names of exprp to be valid matlab expressions
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            exprp{j}{k}=strrep(exprp{j}{k},' ','_');
                            exprp{j}{k}=strrep(exprp{j}{k},'%','pct');
                            exprp{j}{k}=strrep(exprp{j}{k},'>','gt');
                            exprp{j}{k}=strrep(exprp{j}{k},'+','_plus_');
                            exprp{j}{k}=strrep(exprp{j}{k},'.','_dot_');
                        end
                    end
                    % Create the names
                    index=0;
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            index=index+1;
                            pmnames{index}=['PM_',exprp{j}{k}];
                            mmnames{index}=['MM_',exprp{j}{k}];
                        end
                    end

                    % Create the dataset
                    newpmnames='';
                    newmmnames='';
                    for z=1:length(mmnames)-1
                        newpmnames=[newpmnames,'''',pmnames{z},''','];
                        newmmnames=[newmmnames,'''',mmnames{z},''','];
                    end
                    newpmnames=[newpmnames,'''',pmnames{end},'''}'];
                    newmmnames=[newmmnames,'''',mmnames{end},'''}'];
                    % Create some observation names...
                    %onames=1:size(cellpm,1);
                    %onames=cellstr(num2str(onames'));
                    %evalstr1=['dataset({cellpm,',newpmnames,',''obsnames'',onames)'];
                    %evalstr2=['dataset({cellmm,',newmmnames,',''obsnames'',onames)'];
                    evalstr1=['dataset({cellpm,',newpmnames,')'];
                    evalstr2=['dataset({cellmm,',newmmnames,')'];
                    A(i).RawData.PM=eval(evalstr1);
                    A(i).RawData.MM=eval(evalstr2);
                    
                end
                
                if what(i).rawsum

                    m=handles.analysisInfo(i).numberOfConditions;
                    exprp=handles.analysisInfo(i).exprp;
                    rawsum=handles.analysisInfo(i).DataCellNormLo{1};

                    % Create raw summarized data
                    cellraw=cell(1,m);
                    for j=1:m
                        cellraw{j}=cell2mat(rawsum{j});
                    end
                    cellraw=cell2mat(cellraw);

                    % Create column names for the dataset
                    count=0;
                    for j=1:m
                        count=count+size(exprp{j},2);
                    end
                    rawnames=cell(1,count);
                    % Fix names of exprp to be valid matlab expressions
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            exprp{j}{k}=strrep(exprp{j}{k},' ','_');
                            exprp{j}{k}=strrep(exprp{j}{k},'%','pct');
                            exprp{j}{k}=strrep(exprp{j}{k},'>','gt');
                            exprp{j}{k}=strrep(exprp{j}{k},'+','_plus_');
                            exprp{j}{k}=strrep(exprp{j}{k},'.','_dot_');
                        end
                    end
                    % Create the names
                    index=0;
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            index=index+1;
                            rawnames{index}=['Raw_Summarized_',exprp{j}{k}];
                        end
                    end

                    % Create the dataset
                    newrawnames='';
                    for z=1:length(rawnames)-1
                        newrawnames=[newrawnames,'''',rawnames{z},''','];
                    end
                    % Check if handles.gnID contains unique names. If not then create them in
                    % order to place them as observations in the dataset to be created.
                    % Bacically not necessary in Affymetrix, but anyway...
                    if length(handles.attributes.gnID)>length(unique(handles.attributes.gnID))
                        onames=createUniqueID(handles.attributes.gnID);
                    else
                        onames=handles.attributes.gnID;
                    end
                    newrawnames=[newrawnames,'''',rawnames{end},'''}'];
                    evalstr1=['dataset({cellraw,',newrawnames,',''obsnames'',onames)'];
                    A(i).RawSummarized=eval(evalstr1);

                end
                
                if what(i).backsum

                    m=handles.analysisInfo(i).numberOfConditions;
                    exprp=handles.analysisInfo(i).exprp;
                    backsum=handles.analysisInfo(i).DataCellNormLo{3};

                    % Create raw summarized data
                    cellback=cell(1,m);
                    for j=1:m
                        cellback{j}=cell2mat(backsum{j});
                    end
                    cellback=cell2mat(cellback);

                    % Create column names for the dataset
                    count=0;
                    for j=1:m
                        count=count+size(exprp{j},2);
                    end
                    backnames=cell(1,count);
                    % Fix names of exprp to be valid matlab expressions
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            exprp{j}{k}=strrep(exprp{j}{k},' ','_');
                            exprp{j}{k}=strrep(exprp{j}{k},'%','pct');
                            exprp{j}{k}=strrep(exprp{j}{k},'>','gt');
                            exprp{j}{k}=strrep(exprp{j}{k},'+','_plus_');
                            exprp{j}{k}=strrep(exprp{j}{k},'.','_dot_');
                        end
                    end
                    % Create the names
                    index=0;
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            index=index+1;
                            backnames{index}=['BackAdjust_Summarized_',exprp{j}{k}];
                        end
                    end

                    % Create the dataset
                    newbacknames='';
                    for z=1:length(backnames)-1
                        newbacknames=[newbacknames,'''',backnames{z},''','];
                    end
                    % Check if handles.gnID contains unique names. If not then create them in
                    % order to place them as observations in the dataset to be created.
                    % Bacically not necessary in Affymetrix, but anyway...
                    if length(handles.attributes.gnID)>length(unique(handles.attributes.gnID))
                        onames=createUniqueID(handles.attributes.gnID);
                    else
                        onames=handles.attributes.gnID;
                    end
                    newbacknames=[newbacknames,'''',backnames{end},'''}'];
                    evalstr1=['dataset({cellback,',newbacknames,',''obsnames'',onames)'];
                    A(i).BackSummarized=eval(evalstr1);

                end
                
                if what(i).normsum

                    m=handles.analysisInfo(i).numberOfConditions;
                    exprp=handles.analysisInfo(i).exprp;
                    normsum=handles.analysisInfo(i).DataCellNormLo{3};

                    % Create raw summarized data
                    cellnorm=cell(1,m);
                    for j=1:m
                        cellnorm{j}=cell2mat(normsum{j});
                    end
                    cellnorm=cell2mat(cellnorm);

                    % Create column names for the dataset
                    count=0;
                    for j=1:m
                        count=count+size(exprp{j},2);
                    end
                    normnames=cell(1,count);
                    % Fix names of exprp to be valid matlab expressions
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            exprp{j}{k}=strrep(exprp{j}{k},' ','_');
                            exprp{j}{k}=strrep(exprp{j}{k},'%','pct');
                            exprp{j}{k}=strrep(exprp{j}{k},'>','gt');
                            exprp{j}{k}=strrep(exprp{j}{k},'+','_plus_');
                            exprp{j}{k}=strrep(exprp{j}{k},'.','_dot_');
                        end
                    end
                    % Create the names
                    index=0;
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            index=index+1;
                            normnames{index}=['AdjustNorm_Summarized_',exprp{j}{k}];
                        end
                    end

                    % Create the dataset
                    newnormnames='';
                    for z=1:length(normnames)-1
                        newnormnames=[newnormnames,'''',normnames{z},''','];
                    end
                    % Check if handles.gnID contains unique names. If not then create them in
                    % order to place them as observations in the dataset to be created.
                    % Bacically not necessary in Affymetrix, but anyway...
                    if length(handles.attributes.gnID)>length(unique(handles.attributes.gnID))
                        onames=createUniqueID(handles.attributes.gnID);
                    else
                        onames=handles.attributes.gnID;
                    end
                    newnormnames=[newnormnames,'''',normnames{end},'''}'];
                    evalstr1=['dataset({cellnorm,',newnormnames,',''obsnames'',onames)'];
                    A(i).NormSummarized=eval(evalstr1);

                end
                
                if what(i).de

                    m=handles.analysisInfo(i).numberOfConditions;

                    exprp=handles.analysisInfo(i).exprp;
                    count=0;
                    for j=1:m
                        count=count+size(exprp{j},2);
                    end
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            exprp{j}{k}=strrep(exprp{j}{k},' ','_');
                            exprp{j}{k}=strrep(exprp{j}{k},'%','pct');
                            exprp{j}{k}=strrep(exprp{j}{k},'>','gt');
                            exprp{j}{k}=strrep(exprp{j}{k},'+','_plus_');
                            exprp{j}{k}=strrep(exprp{j}{k},'.','_dot_');
                        end
                    end

                    means=cell(1,m);
                    stds=cell(1,m);
                    cvs=cell(1,m);

                    slipos=handles.analysisInfo(i).DataCellStat{1}(:,1);
                    pvals=handles.analysisInfo(i).DataCellStat{1}(:,2);
                    gnames=handles.analysisInfo(i).DataCellStat{2};
                    group=handles.analysisInfo(i).DataCellStat{6};
                    tfs=handles.analysisInfo(i).DataCellStat{7}(slipos,:);
                    for j=1:m
                        means{j}=nanmean(handles.analysisInfo(i).DataCellStat{5}{j},2);
                        stds{j}=nanstd(handles.analysisInfo(i).DataCellStat{5}{j},[],2);
                        cvs{j}=stds{j}./means{j};
                    end
                    data=cell2mat(handles.analysisInfo(i).DataCellStat{5});
                    means=cell2mat(means);
                    stds=cell2mat(stds);
                    cvs=cell2mat(cvs);

                    replinames=cell(1,count);
                    meanames=cell(1,m);
                    stdnames=cell(1,m);
                    cvnames=cell(1,m);
                    tfnames=cell(1,m);
                    inindex=0;
                    outindex=0;
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            inindex=inindex+1;
                            replinames{inindex}=exprp{j}{k};
                        end
                        outindex=outindex+1;
                        meanames{outindex}=['Mean_',group{j}];
                        stdnames{outindex}=['StDev_',group{j}];
                        cvnames{outindex}=['CV_',group{j}];
                        tfnames{outindex}=['TF_',group{j}];
                    end

                    allnames='''Index'',''p-value'',';
                    for z=1:length(replinames)
                        allnames=[allnames,'''',replinames{z},''','];
                    end
                    for v=1:length(group)
                        allnames=[allnames,'''',meanames{v},''','];
                    end
                    for v=1:length(group)
                        allnames=[allnames,'''',stdnames{v},''','];
                    end
                    for v=1:length(group)
                        allnames=[allnames,'''',cvnames{v},''','];
                    end
                    for v=1:length(group)
                        allnames=[allnames,'''',tfnames{v},''','];
                    end
                    allnames(end)='}';

                    % Create the dataset
                    alldata=[slipos,pvals,data,means,stds,cvs,tfs];
                    % Check if gnames contains unique names. If not then create them in
                    % order to place them as observations in the dataset to be created.
                    if length(gnames)>length(unique(gnames))
                        onames=createUniqueID(gnames);
                    else
                        onames=gnames;
                    end
                    evalstr=['dataset({alldata,',allnames,',''obsnames'',onames)'];
                    A(i).DEGenesStats=eval(evalstr);

                end
                
            end
            
        else % cDNAs
        
            % Initialize the output structure
            for i=1:length(what)
                A(i).GeneNames=[];
                A(i).RawData=[];
                A(i).UnNormalized.Ratio=[];
                A(i).UnNormalized.Intensity=[];
                A(i).Normalized.Ratio=[];
                A(i).Normalized.Intensity=[];
                A(i).DEGenesStats=[];
            end

            % The hard part... fill with data
            % We assume that data exist because checking has been done in the export editor.
            for i=1:length(what)

                if what(i).genenames
                    A(i).GeneNames=handles.attributes.gnID;
                end

                if what(i).rawdata

                    if length(what)>length(handles.selectedConditions)
                        tempdatstr=cell(1,length(what));
                        tempdatstr{1}=handles.datstruct;
                        for j=2:length(what)
                            for k=1:handles.selectedConditions(j-1).NumberOfConditions
                                tempdatstr{j}=...
                                    handles.datstruct{handles.selectedConditions(j-1).Conditions(k)}...
                                                     (handles.selectedConditions(j-1).Replicates{k});
                            end
                        end
                    else
                        for j=1:handles.selectedConditions(i).NumberOfConditions
                            tempdatstr{j}=handles.datstruct{handles.selectedConditions(i).Conditions(j)}...
                                                           (handles.selectedConditions(i).Replicates{j});
                        end
                    end
                    A(i).RawData=tempdatstr;
                    
                end

                if what(i).unnorm

                    m=handles.analysisInfo(i).numberOfConditions;
                    exprp=handles.analysisInfo(i).exprp;
                    exptab=handles.analysisInfo(i).exptab;

                    % Create ratio data
                    cellrat=cell(1,m);
                    for j=1:m
                        n=size(exprp{j},2);
                        cellrat{j}=cell(1,n);
                        for k=1:n
                            cellrat{j}{k}=exptab{j}{k}(:,3);
                        end
                        cellrat{j}=cell2mat(cellrat{j});
                    end
                    cellrat=cell2mat(cellrat);

                    % Create intensity data
                    cellinten=cell(1,m);
                    for j=1:m
                        n=size(exprp{j},2);
                        cellinten{j}=cell(1,n);
                        for k=1:n
                            cellinten{j}{k}=0.5*(exptab{j}{k}(:,1)+exptab{j}{k}(:,2));
                        end
                        cellinten{j}=cell2mat(cellinten{j});
                    end
                    cellinten=cell2mat(cellinten);

                    % Create column names for the dataset
                    count=0;
                    for j=1:m
                        count=count+size(exprp{j},2);
                    end
                    ratnames=cell(1,count);
                    intenames=cell(1,count);
                    % Fix names of exprp to be valid matlab expressions
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            exprp{j}{k}=strrep(exprp{j}{k},' ','_');
                            exprp{j}{k}=strrep(exprp{j}{k},'%','pct');
                            exprp{j}{k}=strrep(exprp{j}{k},'>','gt');
                            exprp{j}{k}=strrep(exprp{j}{k},'+','_plus_');
                            exprp{j}{k}=strrep(exprp{j}{k},'.','_dot_');
                        end
                    end
                    % Create the names
                    index=0;
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            index=index+1;
                            ratnames{index}=['Raw_Log_Ratio_',exprp{j}{k}];
                            intenames{index}=['Intensity_',exprp{j}{k}];
                        end
                    end

                    % Create the dataset
                    newratnames='';
                    newintenames='';
                    for z=1:length(ratnames)-1
                        newratnames=[newratnames,'''',ratnames{z},''','];
                        newintenames=[newintenames,'''',intenames{z},''','];
                    end
                    newratnames=[newratnames,'''',ratnames{end},'''}'];
                    newintenames=[newintenames,'''',intenames{end},'''}'];
                    % Check if handles.gnID contains unique names. If not then create them in
                    % order to place them as observations in the dataset to be created.
                    if length(handles.attributes.gnID)>length(unique(handles.attributes.gnID))
                        onames=createUniqueID(handles.attributes.gnID);
                    else
                        onames=handles.attributes.gnID;
                    end
                    evalstr1=['dataset({cellrat,',newratnames,',''obsnames'',onames)'];
                    evalstr2=['dataset({cellinten,',newintenames,',''obsnames'',onames)'];
                    A(i).UnNormalized.Ratio=eval(evalstr1);
                    A(i).UnNormalized.Intensity=eval(evalstr2);

                end

                if what(i).norm

                    m=handles.analysisInfo(i).numberOfConditions;
                    exprp=handles.analysisInfo(i).exprp;
                    logratnorm=handles.analysisInfo(i).DataCellNormLo{2};
                    inten=handles.analysisInfo(i).DataCellNormLo{3};

                    % Create ratio data
                    cellrat=cell(1,m);
                    for j=1:m
                        n=size(exprp{j},2);
                        cellrat{j}=cell(1,n);
                        for k=1:n
                            cellrat{j}{k}=logratnorm{j}{k};
                        end
                        cellrat{j}=cell2mat(cellrat{j});
                    end
                    cellrat=cell2mat(cellrat);

                    % Create intensity data
                    cellinten=cell(1,m);
                    for j=1:m
                        n=size(exprp{j},2);
                        cellinten{j}=cell(1,n);
                        for k=1:n
                            cellinten{j}{k}=inten{j}{k};
                        end
                        cellinten{j}=cell2mat(cellinten{j});
                    end
                    cellinten=cell2mat(cellinten);

                    % Create column names for the dataset
                    count=0;
                    for j=1:m
                        count=count+size(exprp{j},2);
                    end
                    ratnames=cell(1,count);
                    intenames=cell(1,count);
                    % Fix names of exprp to be valid matlab expressions
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            exprp{j}{k}=strrep(exprp{j}{k},' ','_');
                            exprp{j}{k}=strrep(exprp{j}{k},'%','pct');
                            exprp{j}{k}=strrep(exprp{j}{k},'>','gt');
                            exprp{j}{k}=strrep(exprp{j}{k},'+','_plus_');
                            exprp{j}{k}=strrep(exprp{j}{k},'.','_dot_');
                        end
                    end
                    % Create the names
                    index=0;
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            index=index+1;
                            ratnames{index}=['Norm_Log_Ratio_',exprp{j}{k}];
                            intenames{index}=['Intensity_',exprp{j}{k}];
                        end
                    end

                    % Create the dataset
                    newratnames='';
                    newintenames='';
                    for z=1:length(ratnames)-1
                        newratnames=[newratnames,'''',ratnames{z},''','];
                        newintenames=[newintenames,'''',intenames{z},''','];
                    end
                    % Check if handles.gnID contains unique names. If not then create them in
                    % order to place them as observations in the dataset to be created.
                    if length(handles.attributes.gnID)>length(unique(handles.attributes.gnID))
                        onames=createUniqueID(handles.attributes.gnID);
                    else
                        onames=handles.attributes.gnID;
                    end
                    newratnames=[newratnames,'''',ratnames{end},'''}'];
                    newintenames=[newintenames,'''',intenames{end},'''}'];
                    evalstr1=['dataset({cellrat,',newratnames,',''obsnames'',onames)'];
                    evalstr2=['dataset({cellinten,',newintenames,',''obsnames'',onames)'];
                    A(i).Normalized.Ratio=eval(evalstr1);
                    A(i).Normalized.Intensity=eval(evalstr2);

                end
            
                if what(i).de

                    m=handles.analysisInfo(i).numberOfConditions;

                    exprp=handles.analysisInfo(i).exprp;
                    count=0;
                    for j=1:m
                        count=count+size(exprp{j},2);
                    end
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            exprp{j}{k}=strrep(exprp{j}{k},' ','_');
                            exprp{j}{k}=strrep(exprp{j}{k},'%','pct');
                            exprp{j}{k}=strrep(exprp{j}{k},'>','gt');
                            exprp{j}{k}=strrep(exprp{j}{k},'+','_plus_');
                            exprp{j}{k}=strrep(exprp{j}{k},'.','_dot_');
                        end
                    end

                    means=cell(1,m);
                    stds=cell(1,m);
                    cvs=cell(1,m);

                    slipos=handles.analysisInfo(i).DataCellStat{1}(:,1);
                    pvals=handles.analysisInfo(i).DataCellStat{1}(:,2);
                    gnames=handles.analysisInfo(i).DataCellStat{2};
                    group=handles.analysisInfo(i).DataCellStat{6};
                    tfs=handles.analysisInfo(i).DataCellStat{7}(slipos,:);
                    for j=1:m
                        means{j}=nanmean(handles.analysisInfo(i).DataCellStat{5}{j},2);
                        stds{j}=nanstd(handles.analysisInfo(i).DataCellStat{5}{j},[],2);
                        cvs{j}=stds{j}./means{j};
                    end
                    data=cell2mat(handles.analysisInfo(i).DataCellStat{5});
                    means=cell2mat(means);
                    stds=cell2mat(stds);
                    cvs=cell2mat(cvs);

                    replinames=cell(1,count);
                    meanames=cell(1,m);
                    stdnames=cell(1,m);
                    cvnames=cell(1,m);
                    tfnames=cell(1,m);
                    inindex=0;
                    outindex=0;
                    for j=1:m
                        for k=1:size(exprp{j},2)
                            inindex=inindex+1;
                            replinames{inindex}=exprp{j}{k};
                        end
                        outindex=outindex+1;
                        meanames{outindex}=['Mean_',group{j}];
                        stdnames{outindex}=['StDev_',group{j}];
                        cvnames{outindex}=['CV_',group{j}];
                        tfnames{outindex}=['TF_',group{j}];
                    end

                    allnames='''Index'',''p-value'',';
                    for z=1:length(replinames)
                        allnames=[allnames,'''',replinames{z},''','];
                    end
                    for v=1:length(group)
                        allnames=[allnames,'''',meanames{v},''','];
                    end
                    for v=1:length(group)
                        allnames=[allnames,'''',stdnames{v},''','];
                    end
                    for v=1:length(group)
                        allnames=[allnames,'''',cvnames{v},''','];
                    end
                    for v=1:length(group)
                        allnames=[allnames,'''',tfnames{v},''','];
                    end
                    allnames(end)='}';

                    % Create the dataset
                    alldata=[slipos,pvals,data,means,stds,cvs,tfs];
                    % Check if gnames contains unique names. If not then create them in
                    % order to place them as observations in the dataset to be created.
                    if length(gnames)>length(unique(gnames))
                        onames=createUniqueID(gnames);
                    else
                        onames=gnames;
                    end
                    evalstr=['dataset({alldata,',allnames,',''obsnames'',onames)'];
                    A(i).DEGenesStats=eval(evalstr);

                end
            
            end
            
        end
        
        Analysis=A;
        [fname,pname]=uiputfile({'*.mat','MATLAB Workspace Files (*.mat)'},...
                                 'Export to MATLAB');
        filename=strcat(pname,fname);
        save(filename,'Analysis')
        
        uiwait(msgbox('.mat file succesfully created!','Success'));
                             
    end
    
catch
    errmsg={'An unexpected error occured while exporting data.',...
            'Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end
                

% --------------------------------------------------------------------
function fileExportSettingsDE_Callback(hObject, eventdata, handles)

if isfield(handles,'experimentInfo')
    if handles.experimentInfo.imgsw==99 || handles.experimentInfo.imgsw==98
        handles.exportSettings=ExportDEEditorAffy(handles.exportSettings);
    else
        handles.exportSettings=ExportDEEditor(handles.exportSettings);
    end
else
    handles.exportSettings=ExportDEEditor(handles.exportSettings);
end     
guidata(hObject,handles);


% --------------------------------------------------------------------
function fileDataImport_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function fileDataImportExternal_Callback(hObject, eventdata, handles)

% Firstly get the input file
[filename,pathname,findex]=uigetfile({'*.txt','Text tab delimited files (*.txt)';...
                                      '*.xls','Excel files (*.xls)'},...
                                      'External data file');
if filename==0
    uiwait(msgbox('No File was selected','Open'));
    return
end
    
filename=[pathname,filename];

if findex==1 % Text
    fid=fopen(filename);
    fline=fgetl(fid);
    fclose(fid);
    colnames=textscan(fline,'%s','Delimiter','\t');
    colnames=colnames{1};
elseif findex==2 % Excel   
    [res,head]=xlsread2xlsread8(filename);
    colnames=head;
end

% Get project info from data file number of conditions and condition names
[handles.experimentInfo.numberOfConditions,handles.experimentInfo.conditionNames,...
 handles.experimentInfo.exprp,handles.experimentInfo.inten,...
 handles.experimentInfo.datatable,handles.experimentInfo.normalized,...
 measures,left,cancel]=ExternalImportEditor(colnames);

if ~cancel
    
%     try
        
        for i=1:length(handles.experimentInfo.exprp)
            for j=1:length(handles.experimentInfo.exprp{i})
                handles.experimentInfo.pathnames{i}{j}=pathname;
            end
        end
        handles.experimentInfo.imgsw=100; % A big value to be used also with other functions
        handles.datstruct=[];

        % Read the data
        if strcmp(measures,'lr') || strcmp(measures,'lri')
            islog=true;
        else
            islog=false;
        end
        [handles.attributes,lograt,intens,DataCellNormLo]=readExternal(filename,...
                                                                       handles.experimentInfo.exprp,...
                                                                       islog,...
                                                                       handles.experimentInfo.inten,...
                                                                       left);                                               
            
        % Create analysisInfo objects (apart from preprocessing steps)
        handles.analysisInfo(1).exprp=handles.experimentInfo.exprp;
        handles.analysisInfo(1).numberOfConditions=handles.experimentInfo.numberOfConditions;
        handles.analysisInfo(1).conditionNames=handles.experimentInfo.conditionNames;
        handles.analysisInfo(1).conditions=1:length(handles.experimentInfo.exprp);
        exptab=cell(1,length(handles.experimentInfo.exprp));
        
        if isempty(handles.experimentInfo.inten{1})
            for i=1:length(handles.experimentInfo.exprp)
                exptab{i}=cell(1,length(handles.experimentInfo.exprp{i}));
                for j=1:length(handles.experimentInfo.exprp{i})
                    exptab{i}{j}=zeros(length(handles.attributes.gnID),3);
                    % CAREFUL! Quick bug fix so names are misleading...
                    exptab{i}{j}(:,1)=intens{i}{j}; % 0.5*2*intensity=intensity (in the
                    exptab{i}{j}(:,2)=intens{i}{j}; % calculations of intensity next...)
                    exptab{i}{j}(:,3)=lograt{i}{j};
                end
            end
        else
            for i=1:length(handles.experimentInfo.exprp)
                exptab{i}=cell(1,length(handles.experimentInfo.exprp{i}));
                for j=1:length(handles.experimentInfo.exprp{i})
                    exptab{i}{j}=zeros(length(handles.attributes.gnID),3);
                    % CAREFUL! Quick bug fix so names are misleading...
                    exptab{i}{j}(:,1)=lograt{i}{j};
                    exptab{i}{j}(:,2)=intens{i}{j};
                    if islog
                        exptab{i}{j}(:,3)=intens{i}{j}-lograt{i}{j};
                    else
                        exptab{i}{j}(:,3)=intens{i}{j}./lograt{i}{j};
                    end
                end
            end
        end
        
        handles.analysisInfo(1).exptab=exptab;
        if handles.experimentInfo.normalized
            handles.analysisInfo(1).normalizationMethod=100; % Big number for external
            handles.analysisInfo(1).DataCellNormLo=DataCellNormLo;
            % Create also DataCellStat from DataCellNormLo to allow direct data clustering
            % (apparently needed as experience shows from Nijmegen). However, the user 
            % must become more responsible. If user performs statistical analysis again,
            % DataCellStat will be re-created.
            ftable=zeros(length(handles.attributes.gnID),length(handles.experimentInfo.exprp)+2);
            DataCellStat=cell(1,8);
            sps=1:length(handles.attributes.gnID);
            ftable(:,1)=sps'; % Create Slide Positions, leave pvalues 0
            for i=1:length(handles.experimentInfo.exprp)
                ftable(:,i+2)=nanmean(cell2mat(DataCellNormLo{2}{i}),2);
                DataCellStat{5}{i}=cell2mat(DataCellNormLo{2}{i});
            end
            DataCellStat{1}=ftable;
            DataCellStat{2}=handles.attributes.gnID;
            DataCellStat{3}=sps';
            DataCellStat{4}=ftable;
            DataCellStat{6}=handles.experimentInfo.conditionNames;
            DataCellStat{7}=zeros(length(handles.attributes.gnID),length(handles.experimentInfo.exprp));
            DataCellStat{8}=nan(length(handles.attributes.gnID),2);
            handles.analysisInfo(1).DataCellStat=DataCellStat;
        end
        
        % Create Project objects (apart from preprocessing steps) and the arrays list
        handles.Project.NumberOfConditions=handles.experimentInfo.numberOfConditions;
        count=0;
        index=0;
        for i=1:handles.experimentInfo.numberOfConditions
            count=count+size(handles.experimentInfo.exprp{i},2);
        end
        handles.Project.NumberOfSlides=count;
        contents=cell(1,count);
        for i=1:handles.experimentInfo.numberOfConditions
            for j=1:max(size(handles.experimentInfo.exprp{i}))
                index=index+1;
                streval=['handles.Project.Slides.',handles.experimentInfo.conditionNames{i},...
                         '.','Slide',num2str(j),'=handles.experimentInfo.exprp{i}{j}',';'];
                eval(streval)
                contents{index}=handles.experimentInfo.exprp{i}{j};
            end
        end
        set(handles.arrayObjectList,'String',contents,'Max',length(contents))
        handles.Project.Analysis(1).NumberOfConditions=handles.analysisInfo(1).numberOfConditions;
        handles.Project.Analysis(1).NumberOfSlides=count;
        handles.Project.Analysis(1).Slides=handles.Project.Slides;
        if handles.experimentInfo.normalized
            handles.Project.Analysis(1).Preprocess.Normalization='External';
        end
        handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                     handles.sessionNumber);
        % Tetoia wra tetoia logia...
        handles.analysisInfo(1).numberOfSlides=handles.Project.Analysis(1).NumberOfSlides;
                                 
        % Set selected conditions and replicates defaults
        ind=handles.selectConditionsIndex;
        handles.selectedConditions(ind).NumberOfConditions=handles.experimentInfo.numberOfConditions;
        handles.selectedConditions(ind).Conditions=1:handles.experimentInfo.numberOfConditions;
        handles.selectedConditions(ind).ConditionNames=handles.experimentInfo.conditionNames;
        handles.selectedConditions(1).numberOfSlides=handles.Project.Analysis(1).NumberOfSlides;
        totalReplicates=cell(1,handles.experimentInfo.numberOfConditions);
        for i=1:handles.experimentInfo.numberOfConditions
            totalReplicates{i}=1:max(size(handles.experimentInfo.exprp{i}));
        end
        handles.selectedConditions(ind).Replicates=totalReplicates;
        handles.selectedConditions(ind).Exprp=handles.experimentInfo.exprp;
        handles.selectedConditions(ind).hasRun=false;
        handles.selectedConditions(ind).prepro=true;
        
        % Start counting Analysis objects...
        set(handles.analysisObjectList,'String',{'Analysis 1'})
        
        % Update message
        msg1=['The name of your project is ',handles.Project.Name];
        handles.mainmsg={msg1};
        msg2=['Your project includes ',num2str(handles.Project.NumberOfConditions),' experimental conditions',...
              ' and ',num2str(handles.Project.NumberOfSlides),' slides.'];
        handles.mainmsg=[handles.mainmsg;' ';msg2;...
            '-----------------------------------------------------------------------------';...
            'This is your data table, columns are the conditions, rows are the replicates';...
            '-----------------------------------------------------------------------------';...
            matfromcell(handles.experimentInfo.datatable);...
            '-----------------------------------------------------------------------------'];
        set(handles.mainTextbox,'String',handles.mainmsg)
        guidata(hObject,handles);
        handles.mainmsg=get(handles.mainTextbox,'String');
        
        % Manage menus
        % Disable all preprocessing steps
        set(handles.preprocess,'Enable','on')
        set(handles.preprocessBackground,'Enable','off')
        set(handles.preprocessFilter,'Enable','off')
        % Enable plots menu...
        set(handles.plots,'Enable','on')
        % ...but disable some of its components
        set(handles.plotsArrayImage,'Enable','off')
        set(handles.plotsNormUnnorm,'Enable','off')
        set(handles.plotsArrayPlot,'Enable','off')
        if handles.experimentInfo.normalized
            set(handles.preprocessNormalization,'Enable','off')
            set(handles.plotsMA,'Enable','on')
            set(handles.plotsSlideDistrib,'Enable','on')
            set(handles.plotsExprProfile,'Enable','on')
            set(handles.stats,'Enable','on')
            set(handles.statsClustering,'Enable','on')
            set(handles.statsClassification,'Enable','on')
            set(handles.normImageButton,'Enable','on')
            set(handles.viewNormImage,'Enable','on')
            set(handles.viewNormData,'Enable','on')
            set(handles.fileDataExportNorm,'Enable','on')
            set(handles.toolsGap,'Enable','on')
            % Enable raw table view... feasible in cDNAs
            set(handles.arrayRawButton,'Enable','on')
            set(handles.viewRawData,'Enable','on')
            set(handles.arrayContextData,'Enable','on')
            % Get the proper default export settings
            handles.exportSettings=change2cDNAExport;
        end
        % Enable View menu
        set(handles.view,'Enable','on')
        % Enable data exporting
        set(handles.fileDataExport,'Enable','on')
        % Disable the Batch Programmer
        set(handles.toolsBatch,'Enable','off')
        % Enable exporting to workspace
        set(handles.fileExportSettingsMAT,'Enable','on')
        % Enable some buttons and context menus
        set(handles.rawImageButton,'Enable','on')
        set(handles.arrayRawButton,'Enable','on')
        set(handles.arrayContextImage,'Enable','on')
        set(handles.arrayContextData,'Enable','on')
        set(handles.arrayContextReport,'Enable','off')
        set(handles.analysisContextReport,'Enable','on')
        set(handles.analysisContextDelete,'Enable','on')
        set(handles.viewRawImage,'Enable','on')
        set(handles.viewRawData,'Enable','on')
        set(handles.viewArrayReport,'Enable','on')
        set(handles.viewAnalysisReport,'Enable','on')
        % Disable further data import
        set(handles.fileDataImport,'Enable','off')
        % Deal with Affy and Illu options...
        set(handles.preprocessAffyBackNormSum,'Visible','off')
        set(handles.preprocessAffyFiltering,'Visible','off')
        set(handles.preprocessNormalizationIllu,'Visible','off')
        set(handles.preprocessFilteringIllu,'Visible','off')
        set(handles.plotsMAAffy,'Visible','off')
        set(handles.plotsSlideDistribAffy,'Visible','off')
        set(handles.plotsBoxplotAffy,'Visible','off')
        % Something changed, data are imported
        handles.somethingChanged=true;
        guidata(hObject,handles);
        % Check the case of only one slide imported
        if handles.experimentInfo.numberOfConditions==1 && count==1
            set(handles.preprocessSelectConditions,'Enable','off')
        end
        % Display an image
        rawImageButton_Callback(hObject,eventdata,handles)

%     catch
%         errmsg={'An error occured while trying to read external data.',...
%                 'Please check your data file and settings and try again.',...
%                 lasterr};
%         uiwait(errordlg(errmsg,'Unexpected Error!'));
%     end
    
end


% --------------------------------------------------------------------
function fileDataImportRaw_Callback(hObject, eventdata, handles)

% Fix error messages if something goes wrong
imperrmsg={'An unexpected error occured while trying to import data to ARMADA.',...
           'Please review your settings and check the image analysis software file formats.'};
usrerrmsg={'You have not specified any experimental conditions or slides',...
           'Please go back and specify information for your experiment'};
      
% Get project info and files
try
    % Get number of conditions and condition names
    [handles.experimentInfo.imgsw,handles.experimentInfo.exprp,...
     handles.experimentInfo.numberOfConditions,handles.experimentInfo.conditionNames,...
     handles.experimentInfo.pathnames,handles.experimentInfo.datatable,...
     handles.experimentInfo.emSpotImGn,handles.experimentInfo.cdfdata,...
     softName,importOK]=DataImportEditor;
    if ~importOK
        uiwait(errordlg(usrerrmsg,'Bad Input'));
        return    
    end    
catch
    uiwait(errordlg([imperrmsg,lasterr],'Unexpected Error!'));
end

% Display a message in the main textbox of ARMADA
% This text will be renewed every now and then so we attach it to handles
handles.mainmsg={['The name of your project is: ',handles.Project.Name];' '};
set(handles.mainTextbox,'String',handles.mainmsg)
guidata(hObject,handles);

% Read the files and incorporate them in datstruct
try 
    h=showinfowindow('Importing data. Please wait...');
    if handles.experimentInfo.imgsw==99 % Affymetrix
        [handles.datstruct,handles.cdfstruct,handles.experimentInfo.exprp,handles.attributes]=...
            CreateDatstructAffy(handles.experimentInfo.exprp,handles.experimentInfo.numberOfConditions,...
                                handles.experimentInfo.pathnames,handles.experimentInfo.cdfdata{1},...
                                handles.experimentInfo.cdfdata{2},handles.mainTextbox,handles.mainmsg);
    else
        [handles.datstruct,handles.experimentInfo.exprp,handles.attributes]=...
            CreateDatstruct(handles.experimentInfo.exprp,handles.experimentInfo.numberOfConditions,...
                            handles.experimentInfo.imgsw,handles.experimentInfo.pathnames,...
                            handles.mainTextbox,handles.mainmsg,handles.experimentInfo.emSpotImGn);
    end

    % Safety switch in case of canceling import (mostly for tab-delimited files)
    if isempty(handles.experimentInfo.exprp)
        return
    end

    % Set selected conditions and replicates defaults
    ind=handles.selectConditionsIndex;
    t=handles.experimentInfo.numberOfConditions;
    exprp=handles.experimentInfo.exprp;
    handles.selectedConditions(ind).NumberOfConditions=t;
    handles.selectedConditions(ind).Conditions=1:t;
    handles.selectedConditions(ind).ConditionNames=handles.experimentInfo.conditionNames;
    totalReplicates=cell(1,t);
    for i=1:t
        totalReplicates{i}=1:max(size(exprp{i}));
    end
    handles.selectedConditions(ind).Replicates=totalReplicates;
    handles.selectedConditions(ind).Exprp=exprp;
    % and a boolean to indicate if select conditions has run
    handles.selectedConditions(ind).hasRun=false;
    % and a boolean to indicate whether to use same preprocessing steps or not
    handles.selectedConditions(ind).prepro=false;
    
    % Update Project Info and the list containing the arrays of the project
    handles.Project.NumberOfConditions=handles.experimentInfo.numberOfConditions;
    count=0;
    index=0;
    for i=1:handles.experimentInfo.numberOfConditions
        count=count+size(handles.experimentInfo.exprp{i},2);
    end
    handles.Project.NumberOfSlides=count;
    contents=cell(1,count);
    for i=1:handles.experimentInfo.numberOfConditions
        for j=1:max(size(handles.experimentInfo.exprp{i}))
            index=index+1;
            streval=['handles.Project.Slides.',handles.experimentInfo.conditionNames{i},...
                '.','Slide',num2str(j),'=handles.experimentInfo.exprp{i}{j}',';'];
            eval(streval)
            contents{index}=handles.experimentInfo.exprp{i}{j};
        end
    end
    
    set(handles.arrayObjectList,'String',contents,'Max',length(contents))
    handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                 handles.sessionNumber);
    handles.somethingChanged=true;
    guidata(hObject,handles);
    
    % Update message
    handles.mainmsg=get(handles.mainTextbox,'String');
    msg1=['Your project includes ',num2str(handles.Project.NumberOfConditions),' experimental conditions',...
          ' and ',num2str(handles.Project.NumberOfSlides),' slides.'];
    handles.mainmsg=[handles.mainmsg;' ';msg1;...
        '-----------------------------------------------------------------------------';...
        'This is your data table, columns are the conditions, rows are the replicates';...
        '-----------------------------------------------------------------------------';...
        matfromcell(handles.experimentInfo.datatable);...
        '-----------------------------------------------------------------------------'];
    set(handles.mainTextbox,'String',handles.mainmsg)
    guidata(hObject,handles);
    
    % Save the new message in the main textbox
    handles.mainmsg=get(handles.mainTextbox,'String');
    % Enable Preprocessing menu
    set(handles.preprocess,'Enable','on')
    % ...and deal with Affy options...
    if handles.experimentInfo.imgsw==99
        disablecDNAItems(handles);
        disableIlluItems(handles);
        enableAffyItems(handles);
        handles.exportSettings=change2AffyExport;
    else
        disableAffyItems(handles);
        disableIlluItems(handles);
        enablecDNAItems(handles);
        handles.exportSettings=change2cDNAExport;
    end
    % Enable plots menu
    set(handles.plots,'Enable','on')
    % Enable View menu
    set(handles.view,'Enable','on')
    % Enable the Batch Programmer
    set(handles.toolsBatch,'Enable','on')
    % Enable exporting to workspace
    set(handles.fileExportSettingsMAT,'Enable','on')
    % Enable some buttons and context menus
    % set(handles.imageViewRadio,'Enable','on')
    % set(handles.tableViewRadio,'Enable','on')
    set(handles.rawImageButton,'Enable','on')
    set(handles.arrayContextImage,'Enable','on')
    set(handles.arrayContextData,'Enable','on')
    set(handles.arrayContextReport,'Enable','on')
    set(handles.viewRawImage,'Enable','on')
    set(handles.viewRawData,'Enable','on')
    set(handles.viewArrayReport,'Enable','on')
    % Disable further data import
    set(handles.fileDataImport,'Enable','off')
    % Check the case of only one slide imported
    if handles.experimentInfo.numberOfConditions==1 && count==1
        set(handles.preprocessSelectConditions,'Enable','off')
    end
    % Something changed, data are imported
    handles.somethingChanged=true;
    guidata(hObject,handles);
    % Close info message
    set(h,'CloseRequestFcn','closereq')
    close(h)
    % Display an image
    rawImageButton_Callback(hObject,eventdata,handles)
catch
    set(h,'CloseRequestFcn','closereq')
    close(h)
    uiwait(errordlg([imperrmsg,lasterr],'Unexpected Error!'));
end


% --------------------------------------------------------------------
function fileDataImportIllumina_Callback(hObject, eventdata, handles)

% Firstly get the input file
[filename,pathname,findex]=uigetfile({'*.txt','BeadStudio profile text files (*.txt)'},...
                                      'External data file');
if filename==0
    uiwait(msgbox('No File was selected','Open'));
    return
end
    
filename=[pathname,filename];

% In this case, initialize handles.mainmsg
handles.mainmsg={''};

h=showinfowindow('Importing data. Please wait...');

[handles.datstruct,handles.experimentInfo,handles.attributes]=...
    readIllumina(filename,handles.mainTextbox,handles.mainmsg);

set(h,'CloseRequestFcn','closereq')
close(h)
    
try

    % Safety switch in case of canceling import (mostly for tab-delimited files)
    if isempty(handles.experimentInfo)
        return
    end

    % Set selected conditions and replicates defaults
    ind=handles.selectConditionsIndex;
    t=handles.experimentInfo.numberOfConditions;
    exprp=handles.experimentInfo.exprp;
    handles.selectedConditions(ind).NumberOfConditions=t;
    handles.selectedConditions(ind).Conditions=1:t;
    handles.selectedConditions(ind).ConditionNames=handles.experimentInfo.conditionNames;
    totalReplicates=cell(1,t);
    for i=1:t
        totalReplicates{i}=1:max(size(exprp{i}));
    end
    handles.selectedConditions(ind).Replicates=totalReplicates;
    handles.selectedConditions(ind).Exprp=exprp;
    % and a boolean to indicate if select conditions has run
    handles.selectedConditions(ind).hasRun=false;
    % and a boolean to indicate whether to use same preprocessing steps or not
    handles.selectedConditions(ind).prepro=false;
    
    % Update Project Info and the list containing the arrays of the project
    handles.Project.NumberOfConditions=handles.experimentInfo.numberOfConditions;
    count=0;
    index=0;
    for i=1:handles.experimentInfo.numberOfConditions
        count=count+size(handles.experimentInfo.exprp{i},2);
    end
    handles.Project.NumberOfSlides=count;
    contents=cell(1,count);
    for i=1:handles.experimentInfo.numberOfConditions
        for j=1:max(size(handles.experimentInfo.exprp{i}))
            index=index+1;
            streval=['handles.Project.Slides.',handles.experimentInfo.conditionNames{i},...
                '.','Slide',num2str(j),'=handles.experimentInfo.exprp{i}{j}',';'];
            eval(streval)
            contents{index}=handles.experimentInfo.exprp{i}{j};
        end
    end
    
    set(handles.arrayObjectList,'String',contents,'Max',length(contents))
    handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                 handles.sessionNumber);
    handles.somethingChanged=true;
    guidata(hObject,handles);
    
    % Update message
    handles.mainmsg=get(handles.mainTextbox,'String');
    if isempty(handles.mainmsg)
        handles.mainmsg={};
    end
    msg1=['Your project includes ',num2str(handles.Project.NumberOfConditions),' experimental conditions',...
          ' and ',num2str(handles.Project.NumberOfSlides),' slides.'];
    handles.mainmsg=[handles.mainmsg;' ';msg1;...
        '-----------------------------------------------------------------------------';...
        'This is your data table, columns are the conditions, rows are the replicates';...
        '-----------------------------------------------------------------------------';...
        matfromcell(handles.experimentInfo.datatable);...
        '-----------------------------------------------------------------------------'];
    set(handles.mainTextbox,'String',handles.mainmsg)
    guidata(hObject,handles);
    
    % Save the new message in the main textbox
    handles.mainmsg=get(handles.mainTextbox,'String');
    % Enable Preprocessing menu
    set(handles.preprocess,'Enable','on')
    % ...and deal with Illumina options...
    disablecDNAItems(handles);
    disableAffyItems(handles);
    enableIlluItems(handles);
    handles.exportSettings=change2AffyExport;
    % Enable plots menu
    set(handles.plots,'Enable','on')
    % Enable View menu
    set(handles.view,'Enable','on')
    % Enable the Batch Programmer
    set(handles.toolsBatch,'Enable','on')
    % Enable exporting to workspace
    set(handles.fileExportSettingsMAT,'Enable','on')
    % Enable some buttons and context menus
    % set(handles.imageViewRadio,'Enable','on')
    % set(handles.tableViewRadio,'Enable','on')
    set(handles.rawImageButton,'Enable','on')
    set(handles.arrayRawButton,'Enable','on')
    set(handles.arrayContextImage,'Enable','on')
    set(handles.arrayContextData,'Enable','on')
    set(handles.arrayContextReport,'Enable','on')
    set(handles.viewRawImage,'Enable','on')
    set(handles.viewRawData,'Enable','on')
    set(handles.viewArrayReport,'Enable','on')
    % Disable further data import
    set(handles.fileDataImport,'Enable','off')
    % Check the case of only one slide imported
    if handles.experimentInfo.numberOfConditions==1 && count==1
        set(handles.preprocessSelectConditions,'Enable','off')
    end
    % Something changed, data are imported
    handles.somethingChanged=true;
    guidata(hObject,handles);
    % Display an image
    rawImageButton_Callback(hObject,eventdata,handles)

catch
    errmsg={'An error occured while trying to read Illumina BeadStudio data.',...
            'Please check your data file and settings and try again.',...
            lasterr};
    uiwait(errordlg(errmsg,'Unexpected Error!'));
end


% --------------------------------------------------------------------
function fileDataExport_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function fileDataExportNorm_Callback(hObject, eventdata, handles)

% Get the current selection in order to export the respective list
ind=handles.currentSelectionIndex;

try
    
    hh=showinfowindow('Exporting normalized gene list - Please wait...','Exporting');
    
    % Get fold change indices
    if isfield(handles.analysisInfo(ind),'fcinds')
        fcinds=handles.analysisInfo(ind).fcinds;
    else
        fcinds=[];
    end
    
    % DataCellNormLo exists?
    if isfield(handles.analysisInfo(ind),'DataCellNormLo')
        if ~isempty(handles.analysisInfo(ind).DataCellNormLo)
            if handles.experimentInfo.imgsw~=99
                if ~isempty(handles.exportSettings) % Run with defined export settings
                    exportNorm(handles.analysisInfo(ind).exprp,...
                               handles.analysisInfo(ind).exptab,...
                               handles.analysisInfo(ind).DataCellNormLo,...
                               handles.attributes.gnID,...
                               handles.analysisInfo(ind).conditionNames,...
                               fcinds,handles.exportSettings);
                else % Run with default settings from within the export routine
                    exportNorm(handles.analysisInfo(ind).exprp,...
                               handles.analysisInfo(ind).exptab,...
                               handles.analysisInfo(ind).DataCellNormLo,...
                               handles.attributes.gnID,...
                               handles.analysisInfo(ind).conditionNames,...
                               fcinds);
                end
            else
                if ~isempty(handles.exportSettings) % Run with defined export settings
                    exportNormAffy(handles.analysisInfo(ind).exprp,...
                                   handles.analysisInfo(ind).DataCellNormLo,...
                                   handles.attributes.gnID,...
                                   handles.analysisInfo(ind).conditionNames,...
                                   fcinds,handles.exportSettings);
                else % Run with default settings from within the export routine
                    exportNormAffy(handles.analysisInfo(ind).exprp,...
                                   handles.analysisInfo(ind).DataCellNormLo,...
                                   handles.attributes.gnID,...
                                   handles.analysisInfo(ind).conditionNames,...
                                   fcinds);
                end
            end
        end
    end
    
    set(hh,'CloseRequestFcn','closereq')
    close(hh)

catch
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    errmsg={'An unexpected error occured during gene list exporting.',...
            'process. Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function fileDataExportDE_Callback(hObject, eventdata, handles)

exportListButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function fileDataExportClusters_Callback(hObject, eventdata, handles)

exportClusterList_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function fileExit_Callback(hObject, eventdata, handles)

if handles.somethingChanged
    answer=questdlg('Do you want to save changes in your project?','Save changes');
    if strcmp(answer,'Yes')
        fileSave_Callback(hObject, eventdata, handles)
    elseif strcmp(answer,'No')
        uiresume(handles.ARMADA_main);
        delete(handles.ARMADA_main);
    elseif strcmp(answer,'Cancel')
        % Do nothing
    end
else
    uiresume(handles.ARMADA_main);
    delete(handles.ARMADA_main);
end


% --------------------------------------------------------------------
function preprocess_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function preprocessSelectConditions_Callback(hObject, eventdata, handles)

% Firstly get how many times user selected different condition sets...
ind=handles.selectConditionsIndex;

% If select conditions has run for first time disable permanently using same preprocessing
% steps
aflag=false;
if ind==1 && ~isfield(handles,'analysisInfo')
    handles.selectedConditions(ind).prepro=false;
    aflag=true;
elseif ind==1 && isfield(handles,'analysisInfo')
    if isfield(handles.analysisInfo(ind),'normalizationMethod') || isfield(handles.analysisInfo(ind),'BackAdj') || isfield(handles.analysisInfo(ind),'Norm')
        handles.selectedConditions(ind).prepro=true;
    end
elseif ind~=1 && ~handles.selectedConditions(1).prepro
    handles.selectedConditions(ind).prepro=false;
elseif ind~=1 && handles.selectedConditions(1).prepro
    handles.selectedConditions(ind).prepro=true;
end

% Run select conditions
[usesame,handles.selectedConditions(ind).NumberOfConditions,...
 handles.selectedConditions(ind).Conditions,...
 handles.selectedConditions(ind).ConditionNames,...
 handles.selectedConditions(ind).Replicates,...
 handles.selectedConditions(ind).Exprp,cancel]=...
    SelectConditionsEditor(handles.experimentInfo.conditionNames,...
                           handles.experimentInfo.exprp,...
                           handles.selectedConditions(ind).prepro);

% Check here too if we are running a project with external data
if isempty(handles.datstruct) && handles.experimentInfo.normalized
    usesame=true;
end
                       
if ~cancel
     
    % Indicate select conditions run
    handles.selectedConditions(ind).hasRun=true;
    % Increase indices
    handles.selectConditionsIndex=handles.selectConditionsIndex+1;
    % Since we have a new analysis object and the analysis list is updated, set the status
    % changed variable to false
    handles.analysisIndexChanged=false;
    % ...but something changes in the program flow
    handles.somethingChanged=true;
    guidata(hObject,handles);

    if usesame
        
        % Update analysis current selection
        handles.currentSelectionIndex=handles.currentSelectionIndex+1;
        
        % Refers to the 1st preprocessing which was done for all conditions and replicates
        handles.analysisInfo(ind+1)=handles.analysisInfo(1);
        handles.Project.Analysis(ind+1)=handles.Project.Analysis(1);
        
        % Change only field of interest: from analysisInfo the fields: exprp
        % We also have to adjust exptab and TotalBadpoints
        tempexp=cell(1,handles.selectedConditions(ind).NumberOfConditions);
        for i=1:handles.selectedConditions(ind).NumberOfConditions
            tempexp{i}=handles.analysisInfo(1).exptab{handles.selectedConditions(ind).Conditions(i)}...
                                                     (handles.selectedConditions(ind).Replicates{i});
            
        end
        handles.analysisInfo(ind+1).exptab=tempexp;
        if isfield(handles.analysisInfo,'TotalBadpoints') && ~isempty(handles.analysisInfo(ind).TotalBadpoints)
            tempbad=cell(1,handles.selectedConditions(ind).NumberOfConditions);
            for i=1:handles.selectedConditions(ind).NumberOfConditions
                tempbad{i}=handles.analysisInfo(1).TotalBadpoints{handles.selectedConditions(ind).Conditions(i)}...
                                                                 (handles.selectedConditions(ind).Replicates{i});
            end
            handles.analysisInfo(ind+1).TotalBadpoints=tempbad;
        end
        handles.analysisInfo(ind+1).exprp=handles.selectedConditions(ind).Exprp;
        handles.analysisInfo(ind+1).numberOfConditions=handles.selectedConditions(ind).NumberOfConditions;
        handles.analysisInfo(ind+1).conditionNames=handles.selectedConditions(ind).ConditionNames;
        handles.analysisInfo(ind+1).conditions=handles.selectedConditions(ind).Conditions;
        handles.analysisInfo(ind+1).numberOfSlides=handles.Project.Analysis(ind).NumberOfSlides;
        if isfield(handles.analysisInfo(1),'DataCellFiltered')
            handles.analysisInfo(ind+1).DataCellFiltered=[];
        end
        if isfield(handles.analysisInfo(1),'DataCellStat') % Include also TC ANOVA...
            if ~isempty(handles.datstruct) || ...
               (isfield(handles.analysisInfo(1),'TCAinds') && ~isempty(handles.analysisInfo(1).TCAinds))
                handles.analysisInfo(ind+1).DataCellStat=[];
            else % To allow clustering of imported data without statistical testing
                handles.analysisInfo(ind+1).DataCellStat{1}=...
                    handles.analysisInfo(1).DataCellStat{1}(:,[1,2,handles.analysisInfo(ind+1).conditions+2]);
                handles.analysisInfo(ind+1).DataCellStat{2}=handles.analysisInfo(1).DataCellStat{2};
                handles.analysisInfo(ind+1).DataCellStat{3}=handles.analysisInfo(1).DataCellStat{3};
                %handles.analysisInfo(ind+1).DataCellStat{4}=...
                %    handles.analysisInfo(1).DataCellStat{4}(:,[1,2,handles.analysisInfo(ind+1).conditions+2]);
                handles.analysisInfo(ind+1).DataCellStat{4}=...
                    handles.analysisInfo(1).DataCellStat{4}(:,[1,handles.analysisInfo(ind+1).conditions]);
                handles.analysisInfo(ind+1).DataCellStat{5}=...
                    handles.analysisInfo(1).DataCellStat{5}(handles.analysisInfo(ind+1).conditions);
                handles.analysisInfo(ind+1).DataCellStat{6}=handles.analysisInfo(ind+1).conditionNames;
                handles.analysisInfo(ind+1).DataCellStat{7}=...
                    handles.analysisInfo(ind+1).DataCellStat{7}(:,handles.analysisInfo(ind+1).conditions);
                handles.analysisInfo(ind+1).DataCellStat{8}=handles.analysisInfo(1).DataCellStat{8};
            end
        end    
        if isfield(handles.analysisInfo(1),'FinalTable')
            handles.analysisInfo(ind+1).FinalTable=[];
        end
        if isfield(handles.analysisInfo(1),'SVMStruct')
            handles.analysisInfo(ind+1).SVMStruct=[];
        end
        
        % ...from Project the fields: number of conditions, number of slides, slides
        handles.Project.Analysis(ind+1).Slides=[];
        if isfield(handles.Project,'Analysis')
            if isfield(handles.Project.Analysis(1),'StatisticalSelection')
                handles.Project.Analysis(ind+1).StatisticalSelection=[];
            end
        end
        if isfield(handles.Project,'Analysis')
            if isfield(handles.Project.Analysis(1),'Clustering')
                handles.Project.Analysis(ind+1).Clustering=[];
            end
        end
        if isfield(handles.Project,'Analysis')
            if isfield(handles.Project.Analysis(1),'SVM')
                handles.Project.Analysis(ind+1).SVM=[];
            end
        end
        handles.Project.Analysis(ind+1).NumberOfConditions=handles.selectedConditions(ind).NumberOfConditions;
        count=0;
        for i=1:handles.selectedConditions(ind).NumberOfConditions
            count=count+size(handles.selectedConditions(ind).Exprp{i},2);
        end
        handles.Project.Analysis(ind+1).NumberOfSlides=count;
        for i=1:handles.selectedConditions(ind).NumberOfConditions
            for j=1:max(size(handles.selectedConditions(ind).Exprp{i}))
                streval=['handles.Project.Analysis(ind+1).Slides.',...
                    handles.selectedConditions(ind).ConditionNames{i},...
                    '.','Slide',num2str(j),'=handles.selectedConditions(ind).Exprp{i}{j}',';'];
                eval(streval)
            end
        end
        
        % Update main message
        line0=['Information on Analysis run ',num2str(ind+1),' : '];
        if handles.experimentInfo.imgsw~=99 % cDNAs
            if isfield(handles.Project.Analysis(ind+1).Preprocess,'BackgroundCorrection')
                line1=['Background Correction Method : ' handles.Project.Analysis(ind+1).Preprocess.BackgroundCorrection];
            else
                line1='No information on background correction.';
            end
            if isfield(handles.Project.Analysis(ind+1).Preprocess,'UseEstimate')
                line2=['Signal estimation using : ',handles.Project.Analysis(ind+1).Preprocess.UseEstimate];
            else
                line2='No information on signal estimation metric.';
            end
            if isfield(handles.Project.Analysis(ind+1).Preprocess,'FilterMethod');
                line3=['Filtering Method used : ',handles.Project.Analysis(ind+1).Preprocess.FilterMethod];
            else
                line3='No information on filters used.';
            end
            if isfield(handles.Project.Analysis(ind+1).Preprocess,'FilterParameter');
                line4=['Filtering Parameter for filtering method : ',handles.Project.Analysis(ind+1).Preprocess.FilterParameter];
            else
                line4='';
            end
            if isfield(handles.Project.Analysis(ind+1).Preprocess,'OutlierTest')
                line5=['Outlier Test performed : ',handles.Project.Analysis(ind+1).Preprocess.OutlierTest];
            else
                line5='';
            end
            handles.mainmsg=[handles.mainmsg;' ';line0;' ';...
                line1;line2;line3;line4;line5;' '];
            set(handles.mainTextbox,'String',handles.mainmsg)
            drawnow;
        else % Affymetrix
            if isfield(handles.Project.Analysis(ind).Preprocess,'BackgroundAdjustment')
                line1=['Background Adjustment method : ',handles.Project.Analysis(ind).Preprocess.BackgroundAdjustment];
            else
                line1='No information on background adjustment';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'BackgroundOptions')    
                line2=['Background Adjustment Options : ',handles.Project.Analysis(ind).Preprocess.BackgroundOptions];
            else
                line2='No information on background adjustment options';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'Normalization')
                line3=['Normalization method : ',handles.Project.Analysis(ind).Preprocess.Normalization];
            else
                line3='No information on normalization';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'NormalizationOptions')
                line4=['Normalization Options : ',handles.Project.Analysis(ind).Preprocess.NormalizationOptions];
            else
                line4='No information on normalization options';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'Summarization')
                line5=['Summarization method : ',handles.Project.Analysis(ind).Preprocess.Summarization];
            else
                line5='No information on summarization';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'SummarizationOptions')
                line6=['Summarization Options : ',handles.Project.Analysis(ind).Preprocess.SummarizationOptions];
            else
                line6='No information on summarization options';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'MAS5Filter')
                line7=['MAS5 Filter : ',handles.Project.Analysis(ind).Preprocess.MAS5Filter];
            else
                line7='No information on MAS5 filtering';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'IQRFilter')
                line8=['IQR Filter : ',handles.Project.Analysis(ind).Preprocess.IQRFilter];
            else
                line8='No information on IQR filtering';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'VarianceFilter')
                line9=['Variance Filter : ',handles.Project.Analysis(ind).Preprocess.VarianceFilter];
            else
                line9='No information on variance filtering';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'IntensityFilter')
                line10=['Intensity Filter : ',handles.Project.Analysis(ind).Preprocess.IntensityFilter];
            else
                line10='No information on intensity filtering';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'CustomFilter')
                line11=['Custom Filter : ',handles.Project.Analysis(ind).Preprocess.CustomFilter];
            else
                line11='No information on custom filtering';
            end
            if isfield(handles.Project.Analysis(ind).Preprocess,'OutlierTest')
                line12=['Outlier Detection test performed : ',handles.Project.Analysis(ind).Preprocess.OutlierTest];
            else
                line12='No information on outlier detection';
            end
            handles.mainmsg=[handles.mainmsg;' ';line0;' ';line1;line2;line3;line4;line5;...
                             line6;line7;line8;line9;line10;line11;line12];
            set(handles.mainTextbox,'String',handles.mainmsg)
            drawnow;
        end
        
        % Update analysis object listbox
        liststr=get(handles.analysisObjectList,'String');
        liststr=[liststr;['Analysis ',num2str(ind+1)]];
        set(handles.analysisObjectList,'String',liststr)
        set(handles.analysisContextReport,'Enable','on')
        
        % Adjust DataCellNormLo
        handles.analysisInfo(ind+1).DataCellNormLo=SelectConditions(handles.analysisInfo(1).DataCellNormLo,...
            handles.selectedConditions(ind).Conditions,...
            handles.selectedConditions(ind).Replicates);
        % Enable statistics menu
        set(handles.stats,'Enable','on')
        % ...but disable Gap statistic since no statistical selection has been performed
        % ...and classification and clustering for the same reason
        % depending on if external data of course...
        if isempty(handles.datstruct) && handles.experimentInfo.normalized
            set(handles.toolsGap,'Enable','on')
            set(handles.statsClustering,'Enable','on')
            set(handles.statsClassification,'Enable','on')
        else
            set(handles.toolsGap,'Enable','off')
            set(handles.statsClustering,'Enable','off')
            set(handles.statsClassification,'Enable','off')
        end
        % Enable plots
        dec=get(handles.plotsArrayImage,'Enable');
        if strcmp(dec,'on')
            set(handles.plotsNormUnnorm,'Enable','on')
        else
            set(handles.plotsNormUnnorm,'Enable','off')
        end
        set(handles.plotsMA,'Enable','on')
        set(handles.plotsSlideDistrib,'Enable','on')
        set(handles.plotsMAAffy,'Enable','on')
        set(handles.plotsSlideDistribAffy,'Enable','on')
        set(handles.plotsExprProfile,'Enable','on')
        % Enable normalized image button
        set(handles.normImageButton,'Enable','on')
        % Enable normalized image context menu
        set(handles.arrayContextNormImage,'Enable','on')
        set(handles.viewNormImage,'Enable','on')
        % Enable analysis report
        set(handles.analysisContextReport,'Enable','on')
        % Enable context and menu view and export normalized data
        set(handles.analysisContextNormList,'Enable','on')
        set(handles.viewNormData,'Enable','on')
        set(handles.analysisContextExportNormList,'Enable','on')
        set(handles.fileDataExportNorm,'Enable','on')
        
    else
        
        if ind==1 && aflag % In the case of selecting conditions the 1st time, before 
                           % conducting any preprocessing steps after importing data. In
                           % this case index MUST be one
            index=1;
            set(handles.fileExportSettingsMAT,'Enable','on')
        elseif ind==1 && ~aflag % In the case of performing preprocessing steps after
                                % importing data and before selecting any condition
                                % subset. In this time index MUST be incremented by one
                                % because the 1st analysis is the one with all conditions
            index=ind+1;
        elseif ind~=1 
            if ~handles.selectedConditions(1).prepro % In this case, we have selected subset
                                                     % of conditions from the 1st time so
                                                     % the index is correct (incremented
                                                     % by one from the beginning of the
                                                     % function selectConditions
                index=ind;
            else               % In this case, we performed preprocessing with all the
                               % conditions and we select conditions after, so the index
                               % is always back by one (since analysis(1) is the one
                               % before selecting any conditions) and index must be
                               % incremented by one
                index=ind+1;
            end
        end
        
        % Update analysis current selection
        handles.currentSelectionIndex=index;
        
        % Put only basic data like number of conditions etc.
        handles.analysisInfo(index).exprp=handles.selectedConditions(ind).Exprp;
        handles.analysisInfo(index).numberOfConditions=handles.selectedConditions(ind).NumberOfConditions;
        handles.analysisInfo(index).conditionNames=handles.selectedConditions(ind).ConditionNames;
        handles.analysisInfo(index).conditions=handles.selectedConditions(ind).Conditions;
        if isfield(handles.analysisInfo(ind),'DataCellFiltered')
            handles.analysisInfo(index).DataCellFiltered=[];
        end
        if isfield(handles.analysisInfo(ind),'DataCellStat')
            handles.analysisInfo(index).DataCellStat=[];
        end
        if isfield(handles.analysisInfo(ind),'FinalTable')
            handles.analysisInfo(index).FinalTable=[];
        end
        if isfield(handles.analysisInfo(ind),'SVMStruct')
            handles.analysisInfo(index).SVMStruct=[];
        end
        
        % Project info
        if isfield(handles.Project,'Analysis')
            if isfield(handles.Project.Analysis(1),'StatisticalSelection')
                handles.Project.Analysis(index).StatisticalSelection=[];
            end
        end
        if isfield(handles.Project,'Analysis')
            if isfield(handles.Project.Analysis(1),'Clustering')
                handles.Project.Analysis(index).Clustering=[];
            end
        end
        if isfield(handles.Project,'Analysis')
            if isfield(handles.Project.Analysis(1),'SVM')
                handles.Project.Analysis(index).SVM=[];
            end
        end
        handles.Project.Analysis(index).NumberOfConditions=handles.selectedConditions(ind).NumberOfConditions;
        count=0;
        for i=1:handles.selectedConditions(ind).NumberOfConditions
            count=count+size(handles.selectedConditions(ind).Exprp{i},2);
        end
        handles.Project.Analysis(index).NumberOfSlides=count;
        handles.Project.Analysis(index).Slides=[];
        for i=1:handles.selectedConditions(ind).NumberOfConditions
            for j=1:max(size(handles.selectedConditions(ind).Exprp{i}))
                streval=['handles.Project.Analysis(index).Slides.',...
                    handles.selectedConditions(ind).ConditionNames{i},...
                    '.','Slide',num2str(j),'=handles.selectedConditions(ind).Exprp{i}{j}',';'];
                eval(streval)
            end
        end
        % An extra
        handles.analysisInfo(index).numberOfSlides=count;
        % Major bug in the case of importing raw ratio-intensity pairs
        if isempty(handles.datstruct)
            tempexp=cell(1,handles.selectedConditions(ind).NumberOfConditions);
            for i=1:handles.selectedConditions(ind).NumberOfConditions
                tempexp{i}=handles.analysisInfo(1).exptab{handles.selectedConditions(ind).Conditions(i)}...
                                                     (handles.selectedConditions(ind).Replicates{i});
            
            end
            handles.analysisInfo(index).exptab=tempexp;
        end
       
        % Update analysis object listbox
        liststr=get(handles.analysisObjectList,'String');
        liststr=[liststr;['Analysis ',num2str(index)]];
        set(handles.analysisObjectList,'String',liststr)
        set(handles.analysisContextReport,'Enable','on')
        % Disable stats menu (normalization must be done prior to statistical selection)
        set(handles.stats,'Enable','off')
        % ...and Gap statistic since no statistical selection can be performed
        set(handles.toolsGap,'Enable','off')
        % ...and classification for the same reason
        set(handles.statsClassification,'Enable','off')
        % Disable boxplot and MA plots
        set(handles.plotsNormUnnorm,'Enable','off')
        set(handles.plotsMA,'Enable','off')
        set(handles.plotsSlideDistrib,'Enable','off')
        set(handles.plotsMAAffy,'Enable','off')
        set(handles.plotsSlideDistribAffy,'Enable','off')
        set(handles.plotsExprProfile,'Enable','off')
        % Disable normalized image button
        set(handles.normImageButton,'Enable','off')
        set(handles.viewNormImage,'Enable','off')
        % Disable normalized image button
        set(handles.arrayContextNormImage,'Enable','off')
        % Disable PCA
        set(handles.toolsPCA,'Enable','off')
        % Enable analysis report
        set(handles.analysisContextReport,'Enable','on')
        % Disable context and menu view and export normalized data
        set(handles.analysisContextNormList,'Enable','off')
        set(handles.viewNormData,'Enable','off')
        set(handles.analysisContextExportNormList,'Enable','off')
        set(handles.fileDataExportNorm,'Enable','off')
    
    end

    % Update the tree
    handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                 handles.sessionNumber);

end
     
guidata(hObject,handles)

% --------------------------------------------------------------------
function preprocessBackground_Callback(hObject, eventdata, handles)

% Firstly get selected analysis object
ind=handles.currentSelectionIndex;
% ...get and set some defaults about selected conditions

if ind==1 && ~handles.selectedConditions(ind).hasRun
    % Indicates that the start of the analysis is being performed on all initially
    % imported slides of the project
    handles.analysisInfo(ind).exprp=handles.experimentInfo.exprp;
    handles.analysisInfo(ind).numberOfConditions=handles.experimentInfo.numberOfConditions;
    handles.analysisInfo(ind).conditionNames=handles.experimentInfo.conditionNames;
    handles.analysisInfo(ind).conditions=1:handles.experimentInfo.numberOfConditions;
    handles.analysisInfo(ind).numberOfSlides=handles.Project.NumberOfSlides;
    handles.Project.Analysis(ind).NumberOfConditions=handles.Project.NumberOfConditions;
    handles.Project.Analysis(ind).NumberOfSlides=handles.Project.NumberOfSlides;
    handles.Project.Analysis(ind).Slides=handles.Project.Slides;
% elseif ~handles.analysisIndexChanged && ~handles.selectedConditions(1).prepro
%     ind=ind-1;
end

% ...and update the structures correspondingly 
[method,step,loess,span,cancel]=BackgroundCorrectionEditor;

if ~cancel
    
    try
        
        if ind==1 && ~handles.selectedConditions(ind).hasRun && ~isfield(handles.analysisInfo,'BackCorr')
            % Update analysis objects listbox
            liststr=get(handles.analysisObjectList,'String');
            liststr=[liststr;['Analysis ',num2str(ind)]];
            set(handles.analysisObjectList,'String',liststr)
        end

        switch method
            case 'NBC'
                corrstr='No Background Correction';
            case 'LBS'
                corrstr='Background Subtraction';
            case 'MBC'
                corrstr='Signal to Noise ratio';
            case 'PBC'
                corrstr='Percentiles Correction';
            case 'LSBC'
                corrstr='LOESS Correction';
        end
        bcStruct.method=method;
        bcStruct.step=step;
        bcStruct.loess=loess;
        bcStruct.span=span;
        handles.analysisInfo(ind).BackCorr=bcStruct;
        handles.Project.Analysis(ind).Preprocess.BackgroundCorrection=corrstr;
        guidata(hObject,handles);

        % Update main message
        newpart=['Background Correction Method : ' corrstr];
        handles.mainmsg=[handles.mainmsg;...
            ' ';...
            newpart];
        set(handles.mainTextbox,'String',handles.mainmsg)

        % Update tree
        handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                     handles.sessionNumber);
        
        % Enable analysis report and delete
        set(handles.analysisContextReport,'Enable','on')
        set(handles.analysisContextDelete,'Enable','on')
        
        % Indicate changes
        handles.somethingChanged=true;
        guidata(hObject,handles);
        
    catch
        errmsg={'An unexpected error occured while trying to correct data for',...
                'background. Please review your settings and check your files.',...
                lasterr};
        uiwait(errordlg(errmsg,'Error'));
    end
    
end


% --------------------------------------------------------------------
function preprocessFilter_Callback(hObject, eventdata, handles)

% Firstly get selected analysis object
ind=handles.currentSelectionIndex;
% ...get and set some defaults about selected conditions
if ind==1 && ~handles.selectedConditions(ind).hasRun
    handles.analysisInfo(ind).exprp=handles.experimentInfo.exprp;
    handles.analysisInfo(ind).numberOfConditions=handles.experimentInfo.numberOfConditions;
    handles.analysisInfo(ind).conditionNames=handles.experimentInfo.conditionNames;
    handles.analysisInfo(ind).conditions=1:handles.experimentInfo.numberOfConditions;
    handles.analysisInfo(ind).numberOfSlides=handles.Project.NumberOfSlides;
    handles.Project.Analysis(ind).NumberOfConditions=handles.Project.NumberOfConditions;
    handles.Project.Analysis(ind).NumberOfSlides=handles.Project.NumberOfSlides;
    handles.Project.Analysis(ind).Slides=handles.Project.Slides;
% elseif ~handles.analysisIndexChanged && ~handles.selectedConditions(1).prepro
%     ind=ind-1;
end

% try    
    % Get required information for FindBadPoints
    [export,handles.analysisInfo(ind).meanOrMedian,handles.analysisInfo(ind).filterMethod,...
     handles.analysisInfo(ind).filterParameter,handles.analysisInfo(ind).outlierTest,...
     handles.analysisInfo(ind).outlierpval,handles.analysisInfo(ind).uori,dishis,cancel]=...
        FilteringEditor(handles.experimentInfo.imgsw);
    
    if ~cancel
        
        if ind==1 && ~handles.selectedConditions(ind).hasRun && ~isfield(handles.analysisInfo(ind),'BackCorr')
            % analysis listbox needs updating
            liststr=get(handles.analysisObjectList,'String');
            liststr=[liststr;['Analysis ',num2str(ind)]];
            set(handles.analysisObjectList,'String',liststr)
        end

        % Handle the case where background correction has not been performed (assuming the user
        % does not wish correction)
        if ~isfield(handles.analysisInfo(ind),'BackCorr') || isempty(handles.analysisInfo(ind).BackCorr)
            bcStruct.method='NBC';
            bcStruct.step=0.1;
            bcStruct.loess='loess';
            bcStruct.span=0.1;
            handles.analysisInfo(ind).BackCorr=bcStruct; % No background correction
            handles.Project.Analysis(ind).Preprocess.BackgroundCorrection='No Background Correction';
            newpart='Background Correction Method : No Background Correction';
            % Update main message
            handles.mainmsg=[handles.mainmsg;...
                             ' ';...
                             newpart];
            set(handles.mainTextbox,'String',handles.mainmsg)
        end
        
        % Update Project analysis Info
        switch handles.analysisInfo(ind).meanOrMedian
            case 1
                eststr='Mean';
            case 2
                eststr='Median';
        end
        switch handles.analysisInfo(ind).filterMethod
            case 1
                filmetstr='Signal to Noise threshold';
            case 2
                filmetstr='Signal-Bacground distribution distance';
            case 3
                filmetstr='Custom Filter';
            case 4
                filmetstr='No filtering';
        end
        switch handles.analysisInfo(ind).outlierTest
            case 0
                teststr='None';
                dorep=false;
                reptest=2;
            case 1
                teststr='Wilcoxon';
                dorep=true;
                reptest=1;
            case 2
                teststr='t-test';
                dorep=true;
                reptest=2;
        end
        switch handles.analysisInfo(ind).uori
            case 'intersect'
                uoristr='Common poor spots in both channels';
            case 'union'
                uoristr='Union of poor spots in any channel';
        end

        handles.Project.Analysis(ind).Preprocess.UseEstimate=eststr;
        handles.Project.Analysis(ind).Preprocess.FilterMethod=filmetstr;
        if isnumeric(handles.analysisInfo(ind).filterParameter)
            filparstr=num2str(handles.analysisInfo(ind).filterParameter);
        else
            filparstr=handles.analysisInfo(ind).filterParameter;
        end
        handles.Project.Analysis(ind).Preprocess.FilterParameter=filparstr;
        handles.Project.Analysis(ind).Preprocess.FinalPoorSpots=uoristr;
        handles.Project.Analysis(ind).Preprocess.OutlierTest=teststr;
        
        % Update the tree
        handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                     handles.sessionNumber);
        guidata(hObject,handles);

        % Update the main message
        handles.mainmsg=get(handles.mainTextbox,'String');
        line1=['Information on Analysis run ',num2str(ind),' : '];
        line2=['Signal estimation using : ',eststr];
        line3=['Filtering Method used : ',filmetstr];
        line4=['Filtering Parameter for filtering method : ',filparstr];
        line5=['Outlier Test performed : ',teststr];
        line6=['Final Number of Poor Spots : ',uoristr];
        handles.mainmsg=[handles.mainmsg;' ';...
            line1;line2;line3;line4;line5;line6;' '];
        set(handles.mainTextbox,'String',handles.mainmsg)
        drawnow;
        
        % Enable analysis report and delete
        set(handles.analysisContextReport,'Enable','on')
        set(handles.analysisContextDelete,'Enable','on')
        
        % Find the appropriate part of datstruct
        lsel=length(handles.selectedConditions);
        linf=length(handles.analysisInfo);
        if ind==1 && lsel<linf
            datstr=handles.datstruct;
        elseif ind~=1 && lsel<linf
            datstr=cell(1,handles.selectedConditions(ind-1).NumberOfConditions);
            for i=1:handles.selectedConditions(ind-1).NumberOfConditions
                datstr{i}=handles.datstruct{handles.selectedConditions(ind-1).Conditions(i)}...
                                               (handles.selectedConditions(ind-1).Replicates{i});
            end
        else
            datstr=cell(1,handles.selectedConditions(ind).NumberOfConditions);
            for i=1:handles.selectedConditions(ind).NumberOfConditions
                datstr{i}=handles.datstruct{handles.selectedConditions(ind).Conditions(i)}...
                                               (handles.selectedConditions(ind).Replicates{i});
            end
        end
        
        % Do not allow other actions while calculating bad points
%         [hmenu,hbtn]=disableActive;
        
%         hh=showinfowindow('Background correcting and filtering. Please wait...');
        
        % Find Bad Points
        [handles.analysisInfo(ind).exptab,handles.analysisInfo(ind).TotalBadpoints]=...
            FindBadpoints(datstr,...
            handles.analysisInfo(ind).numberOfConditions,...
            handles.analysisInfo(ind).exprp,handles.experimentInfo.imgsw,...
            handles.analysisInfo(ind).BackCorr,...
            handles.analysisInfo(ind).filterMethod,...
            handles.analysisInfo(ind).filterParameter,dorep,...
            handles.analysisInfo(ind).meanOrMedian,reptest,...
            handles.analysisInfo(ind).outlierpval,dishis,...
            export,handles.analysisInfo(ind).conditionNames,...
            handles.analysisInfo(ind).uori,handles.mainTextbox);
        
        handles.somethingChanged=true;
        guidata(hObject,handles);
        
%         set(hh,'CloseRequestFcn','closereq')
%         close(hh)
        
        % Allow actions again
        enableActive(hmenu,hbtn);
        
    end
                          
% catch
%     set(hh,'CloseRequestFcn','closereq')
%     close(hh)
%     % Allow actions again in the case of routine failure
%     enableActive(hmenu,hbtn);
%     errmsg={'An unexpected error occured while trying to filter data.',...
%             'Please review your settings and check your files.',...
%             lasterr};
%     uiwait(errordlg(errmsg,'Error'));
% end
    

% --------------------------------------------------------------------
function preprocessNormalization_Callback(hObject, eventdata, handles)

% Firstly get selected analysis object
ind=handles.currentSelectionIndex;
% ...get and set some defaults about selected conditions
if ind==1 && ~handles.selectedConditions(ind).hasRun
    handles.analysisInfo(ind).exprp=handles.experimentInfo.exprp;
    handles.analysisInfo(ind).numberOfConditions=handles.experimentInfo.numberOfConditions;
    handles.analysisInfo(ind).conditionNames=handles.experimentInfo.conditionNames;
    handles.analysisInfo(ind).conditions=1:handles.experimentInfo.numberOfConditions;
    handles.analysisInfo(ind).numberOfSlides=handles.Project.NumberOfSlides;
    handles.Project.Analysis(ind).NumberOfConditions=handles.Project.NumberOfConditions;
    handles.Project.Analysis(ind).NumberOfSlides=handles.Project.NumberOfSlides;
    handles.Project.Analysis(ind).Slides=handles.Project.Slides;
% elseif ~handles.analysisIndexChanged && ~handles.selectedConditions(1).prepro
%     ind=ind-1;
end
    
try

    % Get Normalization parameters
    [handles.analysisInfo(ind).normalizationMethod,handles.analysisInfo(ind).span,...
     handles.analysisInfo(ind).channel,handles.analysisInfo(ind).subgrid,...
     name,channel,usetimebar,rankopts,sumprobes,sumhow,sumwhen,cancel]=...
        NormalizationEditor(handles.analysisInfo(ind).conditionNames,handles.analysisInfo(ind).exprp,...
                            handles.attributes.Channels);
 
    % Update Project analysis Info
    if ~cancel
        
        if ind==1 && ~handles.selectedConditions(ind).hasRun && ~isfield(handles.analysisInfo(ind),'BackCorr') && ~isempty(handles.datstruct)
            liststr=get(handles.analysisObjectList,'String');
            liststr=[liststr;['Analysis ',num2str(ind)]];
            set(handles.analysisObjectList,'String',liststr)
        end

        % Handle the case where filtering has not been performed (assuming the user
        % does not nor wish correction neither filtering but wishes to proceed directly to
        % normalization). FindBadpoints must be called anyway to create exptab.
        % Add an OR to compensate for the case of un-normalized but filtered imported data...
        if ~isempty(handles.datstruct)
            if ~isfield(handles.analysisInfo(ind),'BackCorr') || isempty(handles.analysisInfo(ind).BackCorr)
                bcStruct.method='NBC';
                bcStruct.step=0.1;
                bcStruct.loess='loess';
                bcStruct.span=0.1;
                handles.analysisInfo(ind).BackCorr=bcStruct; % No background correction
                handles.Project.Analysis(ind).Preprocess.BackgroundCorrection='No Background Correction';
                newpart='Background Correction Method : No Background Correction';
                % Update main message
                handles.mainmsg=[handles.mainmsg;...
                                 ' ';...
                                 newpart];
                set(handles.mainTextbox,'String',handles.mainmsg)

            end
            if ~isfield(handles.analysisInfo(ind),'filterMethod') || isempty(handles.analysisInfo(ind).filterMethod)
                % Filtering has not been called
                export=0;                                    % Do not export bad points
                handles.analysisInfo(ind).meanOrMedian=1;    % Use mean
                handles.analysisInfo(ind).filterMethod=4;    % No filtering
                handles.analysisInfo(ind).filterParameter=2; % Does not matter
                dorep=false;                                 % No outlier test
                reptest=2;                                   % Does not matter
                handles.analysisInfo(ind).outlierpval=0.05;  % Does not matter
                dishis=0;                                    % Does not matter
                handles.analysisInfo(ind).uori='intersect';  % Does not matter
                handles.Project.Analysis(ind).Preprocess.UseEstimate='Mean';
                handles.Project.Analysis(ind).Preprocess.FilterMethod='No filtering';
                handles.Project.Analysis(ind).Preprocess.FilterParameter='';
                handles.Project.Analysis(ind).Preprocess.FinalPoorSpots='Common poor spots in both channels';
                handles.Project.Analysis(ind).Preprocess.OutlierTest='None';
                handles.mainmsg=get(handles.mainTextbox,'String');
                line1=['Information on Analysis run ',num2str(ind),' : '];
                line2='Signal estimation using : Mean';
                line3='Filtering Method used : No filtering';
                line4='Filtering Parameter for filtering method : ';
                line5='Outlier Test performed : None';
                line6='Final Number of Poor Spots : Common poor spots in both channels';
                handles.mainmsg=[handles.mainmsg;' ';...
                                 line1;line2;line3;line4;line5;line6;' '];
                set(handles.mainTextbox,'String',handles.mainmsg)
                drawnow;

                % Find the appropriate part of datstruct
                lsel=length(handles.selectedConditions);
                linf=length(handles.analysisInfo);
                if ind==1 && lsel<linf
                    datstr=handles.datstruct;
                elseif ind~=1 && lsel<linf
                    datstr=cell(1,handles.selectedConditions(ind-1).NumberOfConditions);
                    for i=1:handles.selectedConditions(ind-1).NumberOfConditions
                        datstr{i}=handles.datstruct{handles.selectedConditions(ind-1).Conditions(i)}...
                                                   (handles.selectedConditions(ind-1).Replicates{i});
                    end
                else
                    datstr=cell(1,handles.selectedConditions(ind).NumberOfConditions);
                    for i=1:handles.selectedConditions(ind).NumberOfConditions
                        datstr{i}=handles.datstruct{handles.selectedConditions(ind).Conditions(i)}...
                                                   (handles.selectedConditions(ind).Replicates{i});
                    end
                end

                % Do not allow other actions while calculating bad points
                [hmenu,hbtn]=disableActive;

                hh=showinfowindow('Background correcting and filtering. Please wait...');

                % Call FindBadpoints
                [handles.analysisInfo(ind).exptab,handles.analysisInfo(ind).TotalBadpoints]=...
                    FindBadpoints(datstr,...
                        handles.analysisInfo(ind).numberOfConditions,...
                        handles.analysisInfo(ind).exprp,handles.experimentInfo.imgsw,...
                        handles.analysisInfo(ind).BackCorr,...
                        handles.analysisInfo(ind).filterMethod,...
                        handles.analysisInfo(ind).filterParameter,dorep,...
                        handles.analysisInfo(ind).meanOrMedian,reptest,...
                        handles.analysisInfo(ind).outlierpval,dishis,...
                        export,handles.analysisInfo(ind).conditionNames,...
                        handles.analysisInfo(ind).uori,handles.mainTextbox);
                guidata(hObject,handles);

                set(hh,'CloseRequestFcn','closereq')
                close(hh)

                % Allow actions again
                enableActive(hmenu,hbtn);

            end
        end
        
        if handles.analysisInfo(ind).subgrid==1
            substr='Yes';
        elseif handles.analysisInfo(ind).subgrid==2
            substr='No';
        end
        handles.Project.Analysis(ind).Preprocess.Normalization=name;
        if ~ismember(handles.analysisInfo(ind).normalizationMethod,[5 6 7])
            handles.Project.Analysis(ind).Preprocess.Span=num2str(handles.analysisInfo(ind).span);
        end
        handles.Project.Analysis(ind).Preprocess.Subgrid=substr;
        handles.Project.Analysis(ind).Preprocess.ChannelInfo=channel;
        if sumprobes==1
            handles.Project.Analysis(ind).Preprocess.SummarizeProbes.Summarize='yes';
            handles.Project.Analysis(ind).Preprocess.SummarizeProbes.Method=sumhow;
            if sumwhen==0
                handles.Project.Analysis(ind).Preprocess.SummarizeProbes.When='before normalization';
            elseif sumwhen==1
                handles.Project.Analysis(ind).Preprocess.SummarizeProbes.When='after normalization';
            end
        else
            handles.Project.Analysis(ind).Preprocess.SummarizeProbes.Summarize='no';
        end
        
        % Update the tree
        handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                     handles.sessionNumber);
        guidata(hObject,handles);
    
        % Update the main message
        handles.mainmsg=get(handles.mainTextbox,'String');
        line1=['Normalization Method : ',name];
        line2=['Span (if LOWESS/LOESS methods chosen : ',num2str(handles.analysisInfo(ind).span)];
        line3=['Subgrid Normalization (if subgrid present) : ',substr];
        line4=['Channel - Dye correspondence : ',channel];
        if sumprobes==1
            line5='Summarize same probes : yes';
            line6=['Summarize same probes with : ',sumhow];
            if sumwhen==0
                line7='Summarize probes when: before normalization';
            elseif sumwhen==1
                line7='Summarize probes when: after normalization';
            end
        elseif sumprobes==0
            line5='Summarize same probes : no';
            line6=[]; line7=[];
        end
        handles.mainmsg=[handles.mainmsg;' ';...
                         line1;line2;line3;line4;line5;line6;line7;' '];
        set(handles.mainTextbox,'String',handles.mainmsg)
        drawnow;
        
        % Do not allow other actions while normalizing
        [hmenu,hbtn]=disableActive;
        
        hh=showinfowindow('Normalizing... Please wait...');
        
        % Normalize data
        if handles.analysisInfo(ind).subgrid==1
            [uniRow,uniCol,metacords]=checkSubgrid(handles.experimentInfo.imgsw,handles.datstruct);
            if length(uniRow)==1 && length(uniCol)==1
                uiwait(warndlg('No subgrid detected! Proceeding to simple slide normalization...',...
                               'Warning'));
                [handles.analysisInfo(ind).DataCellNormLo,handles.attributes.gnID]=...
                    NormalizationLOAuto(handles.analysisInfo(ind).exptab,...
                    handles.analysisInfo(ind).exprp,...
                    handles.analysisInfo(ind).numberOfConditions,...
                    handles.analysisInfo(ind).normalizationMethod,...
                    handles.analysisInfo(ind).channel,...
                    handles.analysisInfo(ind).span,...
                    usetimebar,handles.attributes.pbID,...
                    sumprobes,sumhow,sumwhen,handles.mainTextbox);
            else
                [handles.analysisInfo(ind).DataCellNormLo,handles.attributes.gnID]=...
                    NormalizationLOAutoSub(metacords,...
                    handles.analysisInfo(ind).exptab,...
                    handles.analysisInfo(ind).exprp,...
                    handles.analysisInfo(ind).numberOfConditions,...
                    handles.experimentInfo.imgsw,...
                    handles.analysisInfo(ind).normalizationMethod,...
                    handles.analysisInfo(ind).channel,...
                    handles.analysisInfo(ind).span,...
                    usetimebar,handles.attributes.pbID,...
                    sumprobes,sumhow,handles.mainTextbox);
            end
        elseif handles.analysisInfo(ind).subgrid==2
            if isempty(rankopts) % Rank invariant not selected
                [handles.analysisInfo(ind).DataCellNormLo,handles.attributes.gnID]=...
                    NormalizationLOAuto(handles.analysisInfo(ind).exptab,...
                    handles.analysisInfo(ind).exprp,...
                    handles.analysisInfo(ind).numberOfConditions,...
                    handles.analysisInfo(ind).normalizationMethod,...
                    handles.analysisInfo(ind).channel,...
                    handles.analysisInfo(ind).span,...
                    usetimebar,handles.attributes.pbID,...
                    sumprobes,sumhow,sumwhen,handles.mainTextbox);
            else % Rank invariant selected
                [handles.analysisInfo(ind).DataCellNormLo,handles.attributes.gnID]=...
                    NormalizationLOAuto(handles.analysisInfo(ind).exptab,...
                    handles.analysisInfo(ind).exprp,...
                    handles.analysisInfo(ind).numberOfConditions,...
                    handles.analysisInfo(ind).normalizationMethod,...
                    handles.analysisInfo(ind).channel,...
                    handles.analysisInfo(ind).span,...
                    usetimebar,handles.attributes.pbID,...
                    sumprobes,sumhow,sumwhen,...
                    handles.mainTextbox,rankopts);
                
                % Update the main message (again)
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';...
                                 char(handles.analysisInfo(ind).DataCellNormLo{14});' '];
                set(handles.mainTextbox,'String',handles.mainmsg)
                drawnow;
            end
            
            set(hh,'CloseRequestFcn','closereq')
            close(hh)
            
            % Allow actions again
            enableActive(hmenu,hbtn);
            
        end
        
        % Enable analysis report and delete
        set(handles.analysisContextReport,'Enable','on')
        set(handles.analysisContextDelete,'Enable','on')
        set(handles.analysisContextNormList,'Enable','on')
        set(handles.analysisContextExportNormList,'Enable','on')
        % Enable Statistics menu
        set(handles.stats,'Enable','on')
        % Enable some plots
        dec=get(handles.plotsArrayImage,'Enable');
        if strcmp(dec,'on')
            set(handles.plotsNormUnnorm,'Enable','on')
        else
            set(handles.plotsNormUnnorm,'Enable','off')
        end
        set(handles.plotsMA,'Enable','on')
        set(handles.plotsSlideDistrib,'Enable','on')
        set(handles.plotsExprProfile,'Enable','on')
        % View and export normalized data
        set(handles.viewNormData,'Enable','on')
        set(handles.viewNormImage,'Enable','on')
        set(handles.fileDataExport,'Enable','on')
        set(handles.fileDataExportNorm,'Enable','on')
        % Find what is happening with already selected array so as to enable
        % normalized image controls
        arrays=get(handles.arrayObjectList,'String');
        arrval=get(handles.arrayObjectList,'Value');
        if ~isempty(arrays)
            arrayname=arrays(arrval);
        end
        if length(arrval)==1
            index=1;
            for i=1:handles.analysisInfo(ind).numberOfConditions
                for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                    currentnames{index}=handles.analysisInfo(ind).exprp{i}{j};
                    index=index+1;
                end
            end
            z=strmatch(arrayname,currentnames,'exact');
            if isempty(z)
                set(handles.normImageButton,'Enable','off')
                set(handles.arrayContextNormImage,'Enable','off')
            else
                set(handles.normImageButton,'Enable','on')
                set(handles.arrayContextNormImage,'Enable','on')
            end
        end
        % Check the case of only one replicate
        if handles.analysisInfo(ind).numberOfConditions==1 && ...
           handles.Project.Analysis(ind).NumberOfSlides==1
            set(handles.stats,'Enable','off')
        end
        % Indicate changes
        handles.somethingChanged=true;
        guidata(hObject,handles);
        
    end
    
catch
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    % Allow actions again in the case of routine failure
    enableActive(hmenu,hbtn);
    errmsg={'An unexpected error occured while trying to normalize data.',...
            'Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AFFYMETRIX ONLY PREPROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------------------------%

function preprocessAffyBackNormSum_Callback(hObject, eventdata, handles)

% Firstly get selected analysis object
ind=handles.currentSelectionIndex;
% ...get and set some defaults about selected conditions
if ind==1 && ~handles.selectedConditions(ind).hasRun
    handles.analysisInfo(ind).exprp=handles.experimentInfo.exprp;
    handles.analysisInfo(ind).numberOfConditions=handles.experimentInfo.numberOfConditions;
    handles.analysisInfo(ind).numberOfSlides=handles.Project.NumberOfSlides;
    handles.analysisInfo(ind).conditionNames=handles.experimentInfo.conditionNames;
    handles.analysisInfo(ind).conditions=1:handles.experimentInfo.numberOfConditions;
    handles.Project.Analysis(ind).NumberOfConditions=handles.Project.NumberOfConditions;
    handles.Project.Analysis(ind).NumberOfSlides=handles.Project.NumberOfSlides;
    handles.Project.Analysis(ind).Slides=handles.Project.Slides;
% elseif ~handles.analysisIndexChanged && ~handles.selectedConditions(1).prepro
%     ind=ind-1;
end

% Get options
count=0;
arrays=cell(handles.Project.Analysis(ind).NumberOfSlides,1);
for i=1:length(handles.analysisInfo(ind).exprp)
    for j=1:length(handles.analysisInfo(ind).exprp{i})
        count=count+1;
        arrays{count}=handles.analysisInfo(ind).exprp{i}{j};
    end
end
[back,backName,backopts,norm,normName,normopts,summ,summName,summopts,zeros,cancel]=...
    NormalizationEditorAffy(arrays);

if ~cancel
    
    try
        
        if ind==1 && ~handles.selectedConditions(ind).hasRun && ~isfield(handles.analysisInfo,'BackAdj')
            % Update analysis objects listbox
            liststr=get(handles.analysisObjectList,'String');
            liststr=[liststr;['Analysis ',num2str(ind)]];
            set(handles.analysisObjectList,'String',liststr)
        end
        
        handles.analysisInfo(ind).BackAdj=back;
        handles.analysisInfo(ind).BackAdjOpts=backopts;
        handles.analysisInfo(ind).Norm=norm;
        handles.analysisInfo(ind).NormOpts=normopts;
        handles.analysisInfo(ind).Sum=summ;
        handles.analysisInfo(ind).SumOpts=summopts;

        % Update main message
        line0=['Information on Analysis Run ',num2str(ind)];
        % Background adjustment
        switch back
            case 'rma'
                line1=['Background Adjustment Method : ' backName];
                line2='Background Adjustment Options :';
                if backopts.trunc
                    line3='Truncate distribution : Yes';
                else
                    line3='Truncate distribution : No';
                end
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';line0;' ';line1;line2;line3];
                set(handles.mainTextbox,'String',handles.mainmsg)
                backopts2text=line3;
            case 'gcrma'
                line1=['Background Adjustment Method : ' backName];
                line2='Background Adjustment Options :';
                if backopts.optcorr
                    line3='Optical correction : Yes';
                else
                    line3='Optical correction : No';
                end
                if backopts.gsbcorr
                    line4='Gene specific binding correction : Yes';
                else
                    line4='Gene specific binding correction : No';
                end
                if backopts.addvar
                    line5='Add signal variance : Yes';
                else
                    line5='Add signal variance : No';
                end
                line6=['Correlation coefficient constant : ',num2str(backopts.corrconst)];
                line7=['Signal estimation method : ',backopts.method];
                line8=['Tuning parameter : ',num2str(backopts.tuningpar)];
                if backopts.eachaffin
                    line9='Calculate affinities for each chip : Yes';
                else
                    line9='Calculate affinities for each chip : No';
                end
                line10=backopts.seqfile;
                line11=backopts.affinfile;
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';line0;' ';line1;line2;line3;line4;...
                                 line5;line6;line7;line8;line9;line10;line11];
                set(handles.mainTextbox,'String',handles.mainmsg)
                backopts2text=[line3 ', ' line4 ', ' line5 ', ' line6 ', ' line7 ', ' line8];
            case 'plier'
                % When we implement...
            case 'none'
                line1=['Background Adjustment Method : ' backName];
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';line0;' ';line1];
                set(handles.mainTextbox,'String',handles.mainmsg)
                backopts2text=' ';
        end
        
        % Normalization
        switch norm
            case 'quantile'
                line1=['Normalization Method : ' normName];
                line2='Normalization Options :';
                if normopts.usemedian
                    line3='Use median : Yes';
                else
                    line3='Use median : No';
                end
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';line1;line2;line3];
                set(handles.mainTextbox,'String',handles.mainmsg)
                normopts2text=line3;
            case 'rankinvariant'
                line1=['Normalization Method : ' normName];
                line2='Normalization Options :';
                line3=['Rank thresholds : ',num2str(normopts.lowrank),' ',num2str(normopts.uprank)];
                line4=['Higher or lower average rank exclusion position : ',num2str(normopts.maxdata)];
                line5=['Maximum percentage of genes included in the rank invariant set : ',num2str(normopts.maxinvar)];
                if normopts.baseline==-1
                    line6='Baseline array : Median of medians';
                else
                    line6=['Baseline array : ',arrays{normopts.baseline}];
                end
                line7=['Data smoothing : ',normopts.method];
                line8=['Span for data smoothing : ',num2str(normopts.span)];
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';line1;line2;line3;line4;line5;...
                                 line6;line7;line8];
                set(handles.mainTextbox,'String',handles.mainmsg)
                normopts2text=[line3 ', ' line4 ', ' line5 ', ' line6 ', ' line7 ', ' line8];
            case 'none'
                line1=['Normalization Method : ' normName];
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';line1];
                set(handles.mainTextbox,'String',handles.mainmsg)
                normopts2text=' ';
        end
        
        % Summarization
        switch summ
            case 'medianpolish'
                line1=['Summarization Method : ' summName];
                line2='Summarization Options :';
                line3=['Output values : ',summopts.output];
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';line1;line2;line3];
                set(handles.mainTextbox,'String',handles.mainmsg)
                summopts2text=line3;
            case 'mas5'
                % When we implement...
                summopts2text=' ';
        end
        drawnow;
        
        % Update Project structure
        handles.Project.Analysis(ind).Preprocess.BackgroundAdjustment=backName;
        handles.Project.Analysis(ind).Preprocess.BackgroundOptions=backopts2text;
        handles.Project.Analysis(ind).Preprocess.Normalization=normName;
        handles.Project.Analysis(ind).Preprocess.NormalizationOptions=normopts2text;
        handles.Project.Analysis(ind).Preprocess.Summarization=summName;
        handles.Project.Analysis(ind).Preprocess.SummarizationOptions=summopts2text;
        guidata(hObject,handles);

        % Update tree
        handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                     handles.sessionNumber);
        
        % Enable analysis report and delete
        set(handles.analysisContextReport,'Enable','on')
        set(handles.analysisContextDelete,'Enable','on')
        
        % Find the appropriate part of datstruct
        lsel=length(handles.selectedConditions);
        linf=length(handles.analysisInfo);
        if ind==1 && lsel<linf
            datstr=handles.datstruct;
        elseif ind~=1 && lsel<linf
            datstr=cell(1,handles.selectedConditions(ind-1).NumberOfConditions);
            for i=1:handles.selectedConditions(ind-1).NumberOfConditions
                datstr{i}=handles.datstruct{handles.selectedConditions(ind-1).Conditions(i)}...
                                           (handles.selectedConditions(ind-1).Replicates{i});
            end
        else
            datstr=cell(1,handles.selectedConditions(ind).NumberOfConditions);
            for i=1:handles.selectedConditions(ind).NumberOfConditions
                datstr{i}=handles.datstruct{handles.selectedConditions(ind).Conditions(i)}...
                                           (handles.selectedConditions(ind).Replicates{i});
            end
        end

        % Run actual work...
        
        % Do not allow other actions while running
        [hmenu,hbtn]=disableActive;
        
        hh=showinfowindow('Background adjusting. Please wait...');
        
        % Background adjustment
        handles.analysisInfo(ind).exptab=AffyBackAdjust(datstr,handles.cdfstruct,back,backopts,handles.mainTextbox);
        
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
        
        hh=showinfowindow('Normalizing. Please wait...');
        
        % Normalization
        handles.analysisInfo(ind).exptab=AffyNorm(handles.analysisInfo(ind).exptab,norm,normopts,handles.mainTextbox);
        
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
        
        hh=showinfowindow('Summarizing. Please wait...');
        
        % Summarization
        [handles.analysisInfo(ind).DataCellNormLo,handles.attributes.gnID]=...
            AffySum(handles.analysisInfo(ind).exptab,handles.cdfstruct,summ,summopts,{back,norm},zeros,handles.mainTextbox);
        
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
        
        % Re-enable menus
        enableActive(hmenu,hbtn);
        
        % Enable analysis report and delete
        set(handles.analysisContextReport,'Enable','on')
        set(handles.analysisContextDelete,'Enable','on')
        set(handles.analysisContextNormList,'Enable','on')
        set(handles.analysisContextExportNormList,'Enable','on')
        % Enable Statistics menu
        set(handles.stats,'Enable','on')
        % Enable some plots
%         dec=get(handles.plotsArrayImage,'Enable');
%         if strcmp(dec,'on')
%             set(handles.plotsNormUnnorm,'Enable','on')
%         else
%             set(handles.plotsNormUnnorm,'Enable','off')
%         end
        set(handles.plotsMAAffy,'Enable','on')
        set(handles.plotsSlideDistribAffy,'Enable','on')
        set(handles.plotsExprProfile,'Enable','on')
        % View and export normalized data
        set(handles.viewNormData,'Enable','on')
        set(handles.viewNormImage,'Enable','on')
        set(handles.fileDataExportNorm,'Enable','on')
        % Find what is happening with already selected array so as to enable
        % normalized image controls
        arrays=get(handles.arrayObjectList,'String');
        arrval=get(handles.arrayObjectList,'Value');
        if ~isempty(arrays)
            arrayname=arrays(arrval);
        end
        if length(arrval)==1
            index=1;
            for i=1:handles.analysisInfo(ind).numberOfConditions
                for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                    currentnames{index}=handles.analysisInfo(ind).exprp{i}{j};
                    index=index+1;
                end
            end
            z=strmatch(arrayname,currentnames,'exact');
            if isempty(z)
                set(handles.normImageButton,'Enable','off')
                set(handles.arrayContextNormImage,'Enable','off')
            else
                set(handles.normImageButton,'Enable','on')
                set(handles.arrayContextNormImage,'Enable','on')
            end
        end
        % Check the case of only one replicate
        if handles.analysisInfo(ind).numberOfConditions==1 && ...
           handles.Project.Analysis(ind).NumberOfSlides==1
            set(handles.stats,'Enable','off')
        end
        % Indicate changes
        handles.somethingChanged=true;
        guidata(hObject,handles);
        
    catch
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
        % Allow actions again in the case of routine failure
        enableActive(hmenu,hbtn);
        errmsg={'An unexpected error occured during preprocessing.',...
                'Please review your settings and check your files.',...
                lasterr};
        uiwait(errordlg(errmsg,'Error'));
    end
    
end


function preprocessAffyFiltering_Callback(hObject, eventdata, handles)

% Firstly get selected analysis object
ind=handles.currentSelectionIndex;
% ...get and set some defaults about selected conditions
if ind==1 && ~handles.selectedConditions(ind).hasRun
    handles.analysisInfo(ind).exprp=handles.experimentInfo.exprp;
    handles.analysisInfo(ind).numberOfConditions=handles.experimentInfo.numberOfConditions;
    handles.analysisInfo(ind).numberOfSlides=handles.Project.NumberOfSlides;
    handles.analysisInfo(ind).conditionNames=handles.experimentInfo.conditionNames;
    handles.analysisInfo(ind).conditions=1:handles.experimentInfo.numberOfConditions;
    handles.Project.Analysis(ind).NumberOfConditions=handles.Project.NumberOfConditions;
    handles.Project.Analysis(ind).NumberOfSlides=handles.Project.NumberOfSlides;
    handles.Project.Analysis(ind).Slides=handles.Project.Slides;
% elseif ~handles.analysisIndexChanged && ~handles.selectedConditions(1).prepro
%     ind=ind-1;
end

% Get options
[alpha,tau,alphalims,margasabs,iqrv,varv,inten,custom,nofilt,export,usewaitbar,...
 outlierTest,pval,dishis,cancel]=FilteringEditorAffy;

% Work
if ~cancel
    
    try
        
        if ind==1 && ~handles.selectedConditions(ind).hasRun && ~isfield(handles.analysisInfo,'BackAdj')
            % Update analysis objects listbox
            liststr=get(handles.analysisObjectList,'String');
            liststr=[liststr;['Analysis ',num2str(ind)]];
            set(handles.analysisObjectList,'String',liststr)
        end
        
        % Handle the case where background adjustment, normalization and summarization has
        % not been performed (assuming the user does not want to do them). Preprocessing 
        % must be called anyway to create exptab.
        recre=true; % Switch to recreate part of datstruct if preprocessing performed
        if ~isfield(handles.analysisInfo(ind),'BackAdj') || isempty(handles.analysisInfo(ind).BackAdj)
            
            recre=false;
            
            backopts.optcorr=true;
            backopts.corrconst=0.7;
            backopts.method='MLE';
            backopts.addvar=true;
            backopts.tuningpar=5;
            backopts.gsbcorr=true;
            backopts.alpha=0.5;
            backopts.steps=128;
            backopts.showplot=false;
            backopts.eachaffin=false;
            backopts.seqfile='';
            backopts.affinfile='';
            backopts.usemedian=false;
            backopts.display=false;
            normopts.usemedian=false;
            normopts.display=false;
            summopts.output='log2';
            isdone={'gcrma','quantile'};
            
            handles.analysisInfo(ind).BackAdj='gcrma';
            handles.analysisInfo(ind).BackAdjOpts=backopts;
            handles.analysisInfo(ind).Norm='quantile';
            handles.analysisInfo(ind).NormOpts=normopts;
            handles.analysisInfo(ind).Sum='medianpolish';
            handles.analysisInfo(ind).SumOpts=summopts;

            % Update main message
            line_1=['You have not performed background adjustment, normalization and summarization ',...
                    'on Analysis Run ',num2str(ind),'. It will be performed using defaults...'];
            line0=['Information on Analysis Run ',num2str(ind)];
            % Background adjustment
            line1='Background Adjustment Method : GCRMA';
            line2='Background Adjustment Options :';
            line3=['Optical correction : ',log2lang(backopts.optcorr)];
            line4=['Gene specific binding correction : ',log2lang(backopts.gsbcorr)];
            line5=['Add signal variance : ',log2lang(backopts.addvar)];
            line6=['Correlation coefficient constant : ',num2str(backopts.corrconst)];
            line7=['Signal estimation method : ',backopts.method];
            line8=['Tuning parameter : ',num2str(backopts.tuningpar)];
            line9=['Calculate affinities for each chip : ',log2lang(backopts.eachaffin)];
            line10=backopts.seqfile;
            line11=backopts.affinfile;
            handles.mainmsg=get(handles.mainTextbox,'String');
            handles.mainmsg=[handles.mainmsg;' ';line_1;' ';line0;' ';line1;line2;line3;...
                             line4;line5;line6;line7;line8;line9;line10;line11];
            set(handles.mainTextbox,'String',handles.mainmsg)
            backopts2text=[line3 ', ' line4 ', ' line5 ', ' line6 ', ' line7 ', ' line8];

            % Normalization
            line1=['Normalization Method : ' normName];
            line2='Normalization Options :';
            line3=['Use median : ',log2lang(normopts.usemedian)];
            handles.mainmsg=get(handles.mainTextbox,'String');
            handles.mainmsg=[handles.mainmsg;' ';line1;line2;line3];
            set(handles.mainTextbox,'String',handles.mainmsg)
            normopts2text=line3;
            
            % Summarization
            line1='Summarization Method : Median Polish';
            line2='Summarization Options :';
            line3=['Output values : ',summopts.output];
            handles.mainmsg=get(handles.mainTextbox,'String');
            handles.mainmsg=[handles.mainmsg;' ';line1;line2;line3];
            set(handles.mainTextbox,'String',handles.mainmsg)
            summopts2text=line3;

            drawnow;

            % Update Project structure
            handles.Project.Analysis(ind).Preprocess.BackgroundAdjustment='GCRMA';
            handles.Project.Analysis(ind).Preprocess.BackgroundOptions=backopts2text;
            handles.Project.Analysis(ind).Preprocess.Normalization='Quantile';
            handles.Project.Analysis(ind).Preprocess.NormalizationOptions=normopts2text;
            handles.Project.Analysis(ind).Preprocess.Summarization='Median Polish';
            handles.Project.Analysis(ind).Preprocess.SummarizationOptions=summopts2text;
            guidata(hObject,handles);

            % Find the appropriate part of datstruct
            lsel=length(handles.selectedConditions);
            linf=length(handles.analysisInfo);
            if ind==1 && lsel<linf
                datstr=handles.datstruct;
            elseif ind~=1 && lsel<linf
                datstr=cell(1,handles.selectedConditions(ind-1).NumberOfConditions);
                for i=1:handles.selectedConditions(ind-1).NumberOfConditions
                    datstr{i}=handles.datstruct{handles.selectedConditions(ind-1).Conditions(i)}...
                        (handles.selectedConditions(ind-1).Replicates{i});
                end
            else
                datstr=cell(1,handles.selectedConditions(ind).NumberOfConditions);
                for i=1:handles.selectedConditions(ind).NumberOfConditions
                    datstr{i}=handles.datstruct{handles.selectedConditions(ind).Conditions(i)}...
                        (handles.selectedConditions(ind).Replicates{i});
                end
            end

            % Run actual work...

            % Do not allow other actions while running
            [hmenu,hbtn]=disableActive;

            hh=showinfowindow('Background adjusting. Please wait...');

            % Background adjustment
            handles.analysisInfo(ind).exptab=AffyBackAdjust(datstr,handles.cdfstruct,back,backopts,handles.mainTextbox);

            set(hh,'CloseRequestFcn','closereq')
            close(hh)

            hh=showinfowindow('Normalizing. Please wait...');

            % Normalization
            handles.analysisInfo(ind).exptab=AffyNorm(handles.analysisInfo(ind).exptab,norm,normopts,handles.mainTextbox);

            set(hh,'CloseRequestFcn','closereq')
            close(hh)

            hh=showinfowindow('Summarizing. Please wait...');

            % Summarization
            [handles.analysisInfo(ind).DataCellNormLo,handles.attributes.gnID]=...
                AffySum(handles.analysisInfo(ind).exptab,handles.cdfstruct,summ,summopts,isdone,handles.mainTextbox);

            set(hh,'CloseRequestFcn','closereq')
            close(hh)

            % Re-enable menus
            enableActive(hmenu,hbtn);
            
            % Enable analysis report and delete
            set(handles.analysisContextReport,'Enable','on')
            set(handles.analysisContextDelete,'Enable','on')
            set(handles.analysisContextNormList,'Enable','on')
            set(handles.analysisContextExportNormList,'Enable','on')
            % Enable Statistics menu
            set(handles.stats,'Enable','on')
            % Enable some plots
            set(handles.plotsMA,'Enable','on')
            set(handles.plotsSlideDistrib,'Enable','on')
            set(handles.plotsExprProfile,'Enable','on')
            % View and export normalized data
            set(handles.viewNormData,'Enable','on')
            set(handles.viewNormImage,'Enable','on')
            set(handles.fileDataExportNorm,'Enable','on')
            % Find what is happening with already selected array so as to enable
            % normalized image controls
            arrays=get(handles.arrayObjectList,'String');
            arrval=get(handles.arrayObjectList,'Value');
            if ~isempty(arrays)
                arrayname=arrays(arrval);
            end
            if length(arrval)==1
                index=1;
                for i=1:handles.analysisInfo(ind).numberOfConditions
                    for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                        currentnames{index}=handles.analysisInfo(ind).exprp{i}{j};
                        index=index+1;
                    end
                end
                z=strmatch(arrayname,currentnames,'exact');
                if isempty(z)
                    set(handles.normImageButton,'Enable','off')
                    set(handles.arrayContextNormImage,'Enable','off')
                else
                    set(handles.normImageButton,'Enable','on')
                    set(handles.arrayContextNormImage,'Enable','on')
                end
            end
            % Check the case of only one replicate
            if handles.analysisInfo(ind).numberOfConditions==1 && ...
                    handles.Project.Analysis(ind).NumberOfSlides==1
                set(handles.stats,'Enable','off')
            end
            
        end
        
        % After having checked about normalization etc. proceed with filtering
        line0=['Filtering Information on Analysis Run ',num2str(ind)];
        if ~nofilt
            if ~isempty(alpha)
                line1=['MAS5 Calls filter : Yes at alpha ',num2str(alpha),' tau ',num2str(tau),...
                       ' and marginal limits (',num2str(alphalims(1)),',',num2str(alphalims(2)),')'];
                forp=['alpha : ',num2str(alpha),', tau : ',num2str(tau),', limits : (',num2str(alphalims(1)),...
                      ',',num2str(alphalims(2)),')'];
            else
                line1='MAS5 Calls filter : No';
                forp='No';
            end
            line2=['IQR filter : ',log2lang(iqrv)];
            line3=['Variance filter : ',log2lang(varv)];
            line4=['Intensity filter : ',log2lang(inten)];
            line5=['Custom filter : ',log2lang(custom)];
            line6=['Outlier test : ',log2lang(outlierTest),' p-value : ',log2lang(pval)];
            handles.mainmsg=get(handles.mainTextbox,'String');
            handles.mainmsg=[handles.mainmsg;' ';line0;' ';line1;line2;line3;line4;line5;line6];
            set(handles.mainTextbox,'String',handles.mainmsg)
        else
            forp='No';
            line1='No gene filtering performed';
            handles.mainmsg=get(handles.mainTextbox,'String');
            handles.mainmsg=[handles.mainmsg;' ';line0;' ';line1];
            set(handles.mainTextbox,'String',handles.mainmsg)
        end
        
        % Update Project structure
        handles.Project.Analysis(ind).Preprocess.MAS5Filter=forp;
        handles.Project.Analysis(ind).Preprocess.IQRFilter=log2lang(iqrv);
        handles.Project.Analysis(ind).Preprocess.VarianceFilter=log2lang(iqrv);
        handles.Project.Analysis(ind).Preprocess.IntensityFilter=log2lang(inten);
        handles.Project.Analysis(ind).Preprocess.CustomFilter=log2lang(custom);
        handles.Project.Analysis(ind).Preprocess.OutlierTest=...
            ['Outlier test : ',log2lang(outlierTest),' p-value : ',log2lang(pval)];
        guidata(hObject,handles);
        
        % Do the filtering
        
        % Find the appropriate part of datstruct
        if recre
            lsel=length(handles.selectedConditions);
            linf=length(handles.analysisInfo);
            if ind==1 && lsel<linf
                datstr=handles.datstruct;
            elseif ind~=1 && lsel<linf
                datstr=cell(1,handles.selectedConditions(ind-1).NumberOfConditions);
                for i=1:handles.selectedConditions(ind-1).NumberOfConditions
                    datstr{i}=handles.datstruct{handles.selectedConditions(ind-1).Conditions(i)}...
                        (handles.selectedConditions(ind-1).Replicates{i});
                end
            else
                datstr=cell(1,handles.selectedConditions(ind).NumberOfConditions);
                for i=1:handles.selectedConditions(ind).NumberOfConditions
                    datstr{i}=handles.datstruct{handles.selectedConditions(ind).Conditions(i)}...
                        (handles.selectedConditions(ind).Replicates{i});
                end
            end
        end

        % Do not allow other actions while calculating bad points
        [hmenu,hbtn]=disableActive;
        
        if ~nofilt
            
            hh=showinfowindow('Filtering. Please wait...');
            
            [handles.analysisInfo(ind).DataCellNormLo,handles.analysisInfo(ind).TotalBadpoints]=...
                FilterGenesAffy(datstr,handles.analysisInfo(ind).DataCellNormLo,handles.cdfstruct,...
                                'MAS5Calls',{alpha,tau,alphalims},...
                                'MarginAsAbsent',margasabs,...
                                'IQR',iqrv,...
                                'Variance',varv,...
                                'Intensity',inten,...
                                'Custom',custom,...
                                'RepTest',outlierTest,...
                                'PVal',pval,...
                                'ShowHist',dishis,...
                                'Conditions',handles.analysisInfo(ind).conditionNames,...
                                'UseWaitbar',usewaitbar,...
                                'ExportFilt',false,...
                                'HText',handles.mainTextbox);
                            
            set(hh,'CloseRequestFcn','closereq')
            close(hh)
            
        else
            handles.analysisInfo(ind).TotalBadpoints={};
        end

        % Allow actions again
        enableActive(hmenu,hbtn);
       
        % No menus to handle since DataCellNormLo has been created
        % Update tree
        handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                     handles.sessionNumber);
                                 
        % Indicate changes
        handles.somethingChanged=true;
        guidata(hObject,handles);
        
    catch
        
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
        % Allow actions again in the case of routine failure
        enableActive(hmenu,hbtn);
        errmsg={'An unexpected error occured during filtering.',...
                'Please review your settings and check your files.',...
                lasterr};
        uiwait(errordlg(errmsg,'Error'));

    end
    
end

%----------------------------------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ILLUMINA ONLY PREPROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------------------------%

function preprocessNormalizationIllu_Callback(hObject, eventdata, handles)

% Firstly get selected analysis object
ind=handles.currentSelectionIndex;
% ...get and set some defaults about selected conditions
if ind==1 && ~handles.selectedConditions(ind).hasRun
    handles.analysisInfo(ind).exprp=handles.experimentInfo.exprp;
    handles.analysisInfo(ind).numberOfConditions=handles.experimentInfo.numberOfConditions;
    handles.analysisInfo(ind).numberOfSlides=handles.Project.NumberOfSlides;
    handles.analysisInfo(ind).conditionNames=handles.experimentInfo.conditionNames;
    handles.analysisInfo(ind).conditions=1:handles.experimentInfo.numberOfConditions;
    handles.Project.Analysis(ind).NumberOfConditions=handles.Project.NumberOfConditions;
    handles.Project.Analysis(ind).NumberOfSlides=handles.Project.NumberOfSlides;
    handles.Project.Analysis(ind).Slides=handles.Project.Slides;
% elseif ~handles.analysisIndexChanged && ~handles.selectedConditions(1).prepro
%     ind=ind-1;
end

% Get options
count=0;
arrays=cell(handles.Project.Analysis(ind).NumberOfSlides,1);
for i=1:length(handles.analysisInfo(ind).exprp)
    for j=1:length(handles.analysisInfo(ind).exprp{i})
        count=count+1;
        arrays{count}=handles.analysisInfo(ind).exprp{i}{j};
    end
end
[norm,normName,normopts,summ,summName,summopts,cancel]=...
    NormalizationEditorIllumina(arrays);

if ~cancel
    
    try
        
        if ind==1 && ~handles.selectedConditions(ind).hasRun && ~isfield(handles.analysisInfo,'Norm')
            % Update analysis objects listbox
            liststr=get(handles.analysisObjectList,'String');
            liststr=[liststr;['Analysis ',num2str(ind)]];
            set(handles.analysisObjectList,'String',liststr)
        end
        
        handles.analysisInfo(ind).Norm=norm;
        handles.analysisInfo(ind).NormOpts=normopts;
        handles.analysisInfo(ind).Sum=summ;
        handles.analysisInfo(ind).SumOpts=summopts;
        
        line0=['Information on Analysis Run ',num2str(ind)];
        % Normalization
        switch norm
            case 'quantile'
                line1=['Normalization Method : ' normName];
                line2='Normalization Options :';
                if normopts.usemedian
                    line3='Use median : Yes';
                else
                    line3='Use median : No';
                end
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';line1;line2;line3];
                set(handles.mainTextbox,'String',handles.mainmsg)
                normopts2text=line3;
            case 'rankinvariant'
                line1=['Normalization Method : ' normName];
                line2='Normalization Options :';
                line3=['Rank thresholds : ',num2str(normopts.lowrank),' ',num2str(normopts.uprank)];
                line4=['Higher or lower average rank exclusion position : ',num2str(normopts.exclude)];
                line5=['Maximum percentage of genes included in the rank invariant set : ',num2str(normopts.percentage)];
                if normopts.baseline==-1
                    line6='Baseline array : Median of medians';
                else
                    line6=['Baseline array : ',arrays{normopts.baseline}];
                end
                if normopts.iterate
                    str1='Yes';
                else
                    str1='No';
                end
                line7=['Iterate until specified rank invariant set size reached : ',str1];
                line8=['Data smoothing : ',normopts.method];
                line9=['Span for data smoothing : ',num2str(normopts.span)];
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';line0;' ';line1;line2;line3;line4;line5;...
                                 line6;line7;line8;line9];
                set(handles.mainTextbox,'String',handles.mainmsg)
                normopts2text=[line3 ', ' line4 ', ' line5 ', ' line6 ', ' line7 ', ' line8 ', ' line9];
            case 'none'
                line1=['Normalization Method : ' normName];
                handles.mainmsg=get(handles.mainTextbox,'String');
                handles.mainmsg=[handles.mainmsg;' ';line1];
                set(handles.mainTextbox,'String',handles.mainmsg)
                normopts2text=' ';
        end
        
        % Summarization
        line1=['Summarization Method : ' summName];
        line2='Summarization Options :';
        line3=['Output values : ',summopts.output];
        handles.mainmsg=get(handles.mainTextbox,'String');
        handles.mainmsg=[handles.mainmsg;' ';line1;line2;line3];
        set(handles.mainTextbox,'String',handles.mainmsg)
        summopts2text=line3;
        drawnow;
        
        % Update Project structure
        handles.Project.Analysis(ind).Preprocess.Normalization=normName;
        handles.Project.Analysis(ind).Preprocess.NormalizationOptions=normopts2text;
        handles.Project.Analysis(ind).Preprocess.Summarization=summName;
        handles.Project.Analysis(ind).Preprocess.SummarizationOptions=summopts2text;
        guidata(hObject,handles);

        % Update tree
        handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                     handles.sessionNumber);
        
        % Enable analysis report and delete
        set(handles.analysisContextReport,'Enable','on')
        set(handles.analysisContextDelete,'Enable','on')
        
        % Find the appropriate part of datstruct
        lsel=length(handles.selectedConditions);
        linf=length(handles.analysisInfo);
        if ind==1 && lsel<linf
            datstr=handles.datstruct;
        elseif ind~=1 && lsel<linf
            datstr=cell(1,handles.selectedConditions(ind-1).NumberOfConditions);
            for i=1:handles.selectedConditions(ind-1).NumberOfConditions
                datstr{i}=handles.datstruct{handles.selectedConditions(ind-1).Conditions(i)}...
                                           (handles.selectedConditions(ind-1).Replicates{i});
            end
        else
            datstr=cell(1,handles.selectedConditions(ind).NumberOfConditions);
            for i=1:handles.selectedConditions(ind).NumberOfConditions
                datstr{i}=handles.datstruct{handles.selectedConditions(ind).Conditions(i)}...
                                           (handles.selectedConditions(ind).Replicates{i});
            end
        end

        % Run actual work...
        
        % Do not allow other actions while running
        [hmenu,hbtn]=disableActive;
        
        hh=showinfowindow('Normalizing. Please wait...');
        
        % Normalization
        [handles.analysisInfo(ind).exptab,handles.analysisInfo(ind).DataCellNormLo]=...
            IlluminaNorm(datstr,norm,normopts,summ,handles.mainTextbox);
        
        set(hh,'CloseRequestFcn','closereq')
        close(hh)                                                                                                                                                                                                  
        
        % Re-enable menus
        enableActive(hmenu,hbtn);
        
        % Enable analysis report and delete
        set(handles.analysisContextReport,'Enable','on')
        set(handles.analysisContextDelete,'Enable','on')
        set(handles.analysisContextNormList,'Enable','on')
        set(handles.analysisContextExportNormList,'Enable','on')
        % Enable Statistics menu
        set(handles.stats,'Enable','on')
        % Enable some plots
%         dec=get(handles.plotsArrayImage,'Enable');
%         if strcmp(dec,'on')
%             set(handles.plotsNormUnnorm,'Enable','on')
%         else
%             set(handles.plotsNormUnnorm,'Enable','off')
%         end
        set(handles.plotsMAAffy,'Enable','on')
        set(handles.plotsSlideDistribAffy,'Enable','on')
        set(handles.plotsExprProfile,'Enable','on')
        % View and export normalized data
        set(handles.viewNormData,'Enable','on')
        set(handles.viewNormImage,'Enable','on')
        set(handles.fileDataExportNorm,'Enable','on')
        % Find what is happening with already selected array so as to enable
        % normalized image controls
        arrays=get(handles.arrayObjectList,'String');
        arrval=get(handles.arrayObjectList,'Value');
        if ~isempty(arrays)
            arrayname=arrays(arrval);
        end
        if length(arrval)==1
            index=1;
            for i=1:handles.analysisInfo(ind).numberOfConditions
                for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                    currentnames{index}=handles.analysisInfo(ind).exprp{i}{j};
                    index=index+1;
                end
            end
            z=strmatch(arrayname,currentnames,'exact');
            if isempty(z)
                set(handles.normImageButton,'Enable','off')
                set(handles.arrayContextNormImage,'Enable','off')
            else
                set(handles.normImageButton,'Enable','on')
                set(handles.arrayContextNormImage,'Enable','on')
            end
        end
        % Check the case of only one replicate
        if handles.analysisInfo(ind).numberOfConditions==1 && ...
           handles.Project.Analysis(ind).NumberOfSlides==1
            set(handles.stats,'Enable','off')
        end
        % Indicate changes
        handles.somethingChanged=true;
        guidata(hObject,handles);
        
    catch
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
        % Allow actions again in the case of routine failure
        enableActive(hmenu,hbtn);
        errmsg={'An unexpected error occured during preprocessing.',...
                'Please review your settings and check your files.',...
                lasterr};
        uiwait(errordlg(errmsg,'Error'));
    end
    
end


function preprocessFilteringIllu_Callback(hObject, eventdata, handles)

% Firstly get selected analysis object
ind=handles.currentSelectionIndex;
% ...get and set some defaults about selected conditions
if ind==1 && ~handles.selectedConditions(ind).hasRun
    handles.analysisInfo(ind).exprp=handles.experimentInfo.exprp;
    handles.analysisInfo(ind).numberOfConditions=handles.experimentInfo.numberOfConditions;
    handles.analysisInfo(ind).numberOfSlides=handles.Project.NumberOfSlides;
    handles.analysisInfo(ind).conditionNames=handles.experimentInfo.conditionNames;
    handles.analysisInfo(ind).conditions=1:handles.experimentInfo.numberOfConditions;
    handles.Project.Analysis(ind).NumberOfConditions=handles.Project.NumberOfConditions;
    handles.Project.Analysis(ind).NumberOfSlides=handles.Project.NumberOfSlides;
    handles.Project.Analysis(ind).Slides=handles.Project.Slides;
% elseif ~handles.analysisIndexChanged && ~handles.selectedConditions(1).prepro
%     ind=ind-1;
end

% Get options
[alphalims,margasabs,iqrv,varv,inten,custom,nofilt,invert,export,usewaitbar,...
 outlierTest,pval,dishis,cancel]=FilteringEditorIllumina(handles.attributes.invertFlag);

% Work
if ~cancel
    
    try
        
        if ind==1 && ~handles.selectedConditions(ind).hasRun && ~isfield(handles.analysisInfo,'Norm')
            % Update analysis objects listbox
            liststr=get(handles.analysisObjectList,'String');
            liststr=[liststr;['Analysis ',num2str(ind)]];
            set(handles.analysisObjectList,'String',liststr)
        end
        
        % Handle the case where normalization and summarization has not been performed
        % (assuming the user does not want to do them). Preprocessing must be called
        % anyway to create exptab.
        recre=true; % Switch to recreate part of datstruct if preprocessing performed
        if ~isfield(handles.analysisInfo(ind),'Norm') || isempty(handles.analysisInfo(ind).Norm)
            
            recre=false;
            normopts.usemedian=false;
            normopts.display=false;
            summopts.output='log2';
            isdone={'quantile'};
            
            handles.analysisInfo(ind).Norm='quantile';
            handles.analysisInfo(ind).NormOpts=normopts;
            handles.analysisInfo(ind).Sum='log2';
            handles.analysisInfo(ind).SumOpts=summopts;

            % Update main message
            line_1=['You have not performed normalization and summarization on Analysis Run ',...
                    num2str(ind),'. It will be performed using defaults...'];
            line0=['Information on Analysis Run ',num2str(ind)];
            
            % Normalization
            line1='Normalization Method : Quantile';
            line2='Normalization Options :';
            line3=['Use median : ',log2lang(normopts.usemedian)];
            handles.mainmsg=get(handles.mainTextbox,'String');
            handles.mainmsg=[handles.mainmsg;' ';line_1;' ';line0;' ';line1;line2;line3];
            set(handles.mainTextbox,'String',handles.mainmsg)
            normopts2text=line3;
            
            % Summarization
            line1='Summarization Method : log2';
            line2='Summarization Options :';
            line3=['Output values : ',summopts.output];
            handles.mainmsg=get(handles.mainTextbox,'String');
            handles.mainmsg=[handles.mainmsg;' ';line1;line2;line3];
            set(handles.mainTextbox,'String',handles.mainmsg)
            summopts2text=line3;
                
            drawnow;

            % Update Project structure
            handles.Project.Analysis(ind).Preprocess.Normalization='Quantile';
            handles.Project.Analysis(ind).Preprocess.NormalizationOptions=normopts2text;
            handles.Project.Analysis(ind).Preprocess.Summarization='log2';
            handles.Project.Analysis(ind).Preprocess.SummarizationOptions=summopts2text;
            guidata(hObject,handles);

            % Find the appropriate part of datstruct
            lsel=length(handles.selectedConditions);
            linf=length(handles.analysisInfo);
            if ind==1 && lsel<linf
                datstr=handles.datstruct;
            elseif ind~=1 && lsel<linf
                datstr=cell(1,handles.selectedConditions(ind-1).NumberOfConditions);
                for i=1:handles.selectedConditions(ind-1).NumberOfConditions
                    datstr{i}=handles.datstruct{handles.selectedConditions(ind-1).Conditions(i)}...
                        (handles.selectedConditions(ind-1).Replicates{i});
                end
            else
                datstr=cell(1,handles.selectedConditions(ind).NumberOfConditions);
                for i=1:handles.selectedConditions(ind).NumberOfConditions
                    datstr{i}=handles.datstruct{handles.selectedConditions(ind).Conditions(i)}...
                        (handles.selectedConditions(ind).Replicates{i});
                end
            end

            % Run actual work...

            % Do not allow other actions while running
            [hmenu,hbtn]=disableActive;

            hh=showinfowindow('Normalizing. Please wait...');

            % Normalization
            [handles.analysisInfo(ind).exptab,handles.analysisInfo(ind).DataCellNormLo]=...
                IlluminaNorm(datstr,'quantile',normopts,'log2',handles.mainTextbox);

            set(hh,'CloseRequestFcn','closereq')
            close(hh)
            
            % Re-enable menus
            enableActive(hmenu,hbtn);
            
            % Enable analysis report and delete
            set(handles.analysisContextReport,'Enable','on')
            set(handles.analysisContextDelete,'Enable','on')
            set(handles.analysisContextNormList,'Enable','on')
            set(handles.analysisContextExportNormList,'Enable','on')
            % Enable Statistics menu
            set(handles.stats,'Enable','on')
            % Enable some plots
            set(handles.plotsMA,'Enable','on')
            set(handles.plotsSlideDistrib,'Enable','on')
            set(handles.plotsExprProfile,'Enable','on')
            % View and export normalized data
            set(handles.viewNormData,'Enable','on')
            set(handles.viewNormImage,'Enable','on')
            set(handles.fileDataExportNorm,'Enable','on')
            % Find what is happening with already selected array so as to enable
            % normalized image controls
            arrays=get(handles.arrayObjectList,'String');
            arrval=get(handles.arrayObjectList,'Value');
            if ~isempty(arrays)
                arrayname=arrays(arrval);
            end
            if length(arrval)==1
                index=1;
                for i=1:handles.analysisInfo(ind).numberOfConditions
                    for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                        currentnames{index}=handles.analysisInfo(ind).exprp{i}{j};
                        index=index+1;
                    end
                end
                z=strmatch(arrayname,currentnames,'exact');
                if isempty(z)
                    set(handles.normImageButton,'Enable','off')
                    set(handles.arrayContextNormImage,'Enable','off')
                else
                    set(handles.normImageButton,'Enable','on')
                    set(handles.arrayContextNormImage,'Enable','on')
                end
            end
            % Check the case of only one replicate
            if handles.analysisInfo(ind).numberOfConditions==1 && ...
                    handles.Project.Analysis(ind).NumberOfSlides==1
                set(handles.stats,'Enable','off')
            end
            
        end
        
        % After having checked about normalization etc. proceed with filtering
        line0=['Filtering Information on Analysis Run ',num2str(ind)];
        if ~nofilt
            if ~isempty(alphalims)
                line1=['Detection filter : Yes at marginal limits (',num2str(alphalims(1)),',',num2str(alphalims(2)),')'];
                forp=['limits : (',num2str(alphalims(1)),',',num2str(alphalims(2)),')'];
            else
                line1='Detection filter : No';
                forp='No';
            end
            line2=['IQR filter : ',log2lang(iqrv)];
            line3=['Variance filter : ',log2lang(varv)];
            line4=['Intensity filter : ',log2lang(inten)];
            line5=['Custom filter : ',log2lang(custom)];
            line6=['Outlier test : ',log2lang(outlierTest),' p-value : ',log2lang(pval)];
            handles.mainmsg=get(handles.mainTextbox,'String');
            handles.mainmsg=[handles.mainmsg;' ';line0;' ';line1;line2;line3;line4;line5;line6];
            set(handles.mainTextbox,'String',handles.mainmsg)
        else
            forp='No';
            line1='No gene filtering performed';
            handles.mainmsg=get(handles.mainTextbox,'String');
            handles.mainmsg=[handles.mainmsg;' ';line0;' ';line1];
            set(handles.mainTextbox,'String',handles.mainmsg)
        end
        
        % Update Project structure
        handles.Project.Analysis(ind).Preprocess.DetFilter=forp;
        handles.Project.Analysis(ind).Preprocess.IQRFilter=log2lang(iqrv);
        handles.Project.Analysis(ind).Preprocess.VarianceFilter=log2lang(iqrv);
        handles.Project.Analysis(ind).Preprocess.IntensityFilter=log2lang(inten);
        handles.Project.Analysis(ind).Preprocess.CustomFilter=log2lang(custom);
        handles.Project.Analysis(ind).Preprocess.OutlierTest=...
            ['Outlier test : ',log2lang(outlierTest),' p-value : ',log2lang(pval)];
        guidata(hObject,handles);
        
        % Do the filtering
        
        % Find the appropriate part of datstruct
        if recre
            lsel=length(handles.selectedConditions);
            linf=length(handles.analysisInfo);
            if ind==1 && lsel<linf
                datstr=handles.datstruct;
            elseif ind~=1 && lsel<linf
                datstr=cell(1,handles.selectedConditions(ind-1).NumberOfConditions);
                for i=1:handles.selectedConditions(ind-1).NumberOfConditions
                    datstr{i}=handles.datstruct{handles.selectedConditions(ind-1).Conditions(i)}...
                        (handles.selectedConditions(ind-1).Replicates{i});
                end
            else
                datstr=cell(1,handles.selectedConditions(ind).NumberOfConditions);
                for i=1:handles.selectedConditions(ind).NumberOfConditions
                    datstr{i}=handles.datstruct{handles.selectedConditions(ind).Conditions(i)}...
                        (handles.selectedConditions(ind).Replicates{i});
                end
            end
        end

        % Do not allow other actions while calculating bad points
        [hmenu,hbtn]=disableActive;
        
        if ~nofilt
            
            hh=showinfowindow('Filtering. Please wait...');
            
            [handles.analysisInfo(ind).DataCellNormLo,handles.analysisInfo(ind).TotalBadpoints]=...
                FilterGenesIllu(datstr,handles.analysisInfo(ind).DataCellNormLo,...
                                'Detection',alphalims,...
                                'InvertDetection',invert,...
                                'MarginAsAbsent',margasabs,...
                                'IQR',iqrv,...
                                'Variance',varv,...
                                'Intensity',inten,...
                                'Custom',custom,...
                                'RepTest',outlierTest,...
                                'PVal',pval,...
                                'ShowHist',dishis,...
                                'Conditions',handles.analysisInfo(ind).conditionNames,...
                                'ExportFilt',false,...
                                'HText',handles.mainTextbox);
                            
            set(hh,'CloseRequestFcn','closereq')
            close(hh)
            
        else
            handles.analysisInfo(ind).TotalBadpoints={};
        end

        % Allow actions again
        enableActive(hmenu,hbtn);
       
        % No menus to handle since DataCellNormLo has been created
        % Update tree
        handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                                     handles.sessionNumber);
                                 
        % Indicate changes
        handles.somethingChanged=true;
        guidata(hObject,handles);
        
    catch
        
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
        % Allow actions again in the case of routine failure
        enableActive(hmenu,hbtn);
        errmsg={'An unexpected error occured during filtering.',...
                'Please review your settings and check your files.',...
                lasterr};
        uiwait(errordlg(errmsg,'Error'));

    end
    
end


%----------------------------------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --------------------------------------------------------------------
function statsSelectConditions_Callback(hObject, eventdata, handles)

% !!! UNUSED !!! It is a hidden control. Refer to Preprocessing -> Select Conditions
% instead


% --------------------------------------------------------------------
function stats_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function statsStatSelect_Callback(hObject, eventdata, handles)

% Prepare the input variable to StatisticalSelectionEditor
numberOfAnalyses=0;
fulfill=[];
if handles.experimentInfo.imgsw==99 || handles.experimentInfo.imgsw==98 % Affy, Illu
    for i=1:length(handles.analysisInfo)
        if isfield(handles.analysisInfo(i),'Norm') && ~isempty(handles.analysisInfo(i).Norm)
            numberOfAnalyses=numberOfAnalyses+1;
            fulfill=[fulfill,i];
        end
    end
else % Not Affy, Illu
    for i=1:length(handles.analysisInfo)
        if isfield(handles.analysisInfo(i),'normalizationMethod') && ~isempty(handles.analysisInfo(i).normalizationMethod)
            numberOfAnalyses=numberOfAnalyses+1;
            fulfill=[fulfill,i];
        end
    end
end
%numberOfAnalyses=length(handles.analysisInfo);
conditionIndices=zeros(1,numberOfAnalyses);
conditionNames=cell(1,numberOfAnalyses);
for i=1:numberOfAnalyses
    conditionIndices(i)=handles.analysisInfo(fulfill(i)).numberOfConditions;
    conditionNames{i}=handles.analysisInfo(fulfill(i)).conditionNames;
end
noArrays=zeros(1,numberOfAnalyses);
for i=1:numberOfAnalyses
    count=0;
    for j=1:handles.analysisInfo(fulfill(i)).numberOfConditions
        count=count+size(handles.analysisInfo(fulfill(i)).exprp{j},2);
    end
    noArrays(i)=count;
end

% Choose statistical selection properties
[whichones,scale,scaleOpts,scaleName,impute,imputeOpts,imputeName,...
 imputeBefOrAft,imputeBefOrAftName,statTest,statTestName,...
 multiCorr,multiCorrName,thecut,tf,stf,disbox,cind,tind,cancel]=...
    StatisticalSelectionEditor(numberOfAnalyses,conditionIndices,noArrays,conditionNames,...
                               handles.experimentInfo.imgsw,fulfill);

% Start the process...
if ~cancel
    
    try
        
        hh=showinfowindow('Running statistical selections. Please wait...');
        
        % Do not allow other actions during statistical selections
        [hmenu,hbtn]=disableActive;
        
        %%% HERE CREATE A MAPPING BETWEEN whichones and the actual returned values!
        mapObj=containers.Map;
        for i=1:length(fulfill)
            mapObj(num2str(fulfill(i)))=i;
        end
        
        for i=1:length(whichones)
            
            % Extra field has to be created in the case of time course ANOVA
            %handles.analysisInfo(whichones(i)).TCAinds={cind{whichones(i)},tind{whichones(i)}};
            handles.analysisInfo(whichones(i)).TCAinds={cind{mapObj(num2str(whichones(i)))},...
                tind{mapObj(num2str(whichones(i)))}};

            % Update main message
            handles.mainmsg=get(handles.mainTextbox,'String');
            line1=['Performing Statistical Selection for Analysis run : ',num2str(mapObj(num2str(whichones(i))))];
            line2=['Between slide normalization : ',scaleName{mapObj(num2str(whichones(i)))}];
            line3=['Missing value imputation : ',imputeName{mapObj(num2str(whichones(i)))}];
            if strcmp(impute{mapObj(num2str(whichones(i)))},'knn')
                topts=imputeOpts{mapObj(num2str(whichones(i)))};
                line3=[line3,' - Distance metric : ',topts.distancename];
                line3=[line3,' - Impute space : ',topts.imputespacename];
            end
            line4=['Missing value imputation relative to between slide normalization (if performed) : ',...
                   imputeBefOrAftName{mapObj(num2str(whichones(i)))}];
            line5=['Trust Factor threshold : ',num2str(tf(mapObj(num2str(whichones(i)))))];
            line6=['Chosen statistical test : ',statTestName{mapObj(num2str(whichones(i)))}];
            line7=['Multiple testing correction : ',multiCorrName{mapObj(num2str(whichones(i)))}];
            line8=['p-value or FDR threshold : ',thecut(mapObj(num2str(whichones(i))))];
            handles.mainmsg=[handles.mainmsg;' ';...
                             line1;line2;line3;line4;line5;line6;line7;line8;' '];
            set(handles.mainTextbox,'String',handles.mainmsg)
            drawnow;

            % Update Project analysis Info
            handles.Project.Analysis(whichones(i)).StatisticalSelection.BSN=...
                scaleName{mapObj(num2str(whichones(i)))};
            l=imputeName{mapObj(num2str(whichones(i)))};
            if strcmp(impute,'knn')
                l=[l,' - ',topts.distancename];
                l=[l,' - ',topts.imputespacename];
            end
            handles.Project.Analysis(whichones(i)).StatisticalSelection.Impute=l;
            handles.Project.Analysis(whichones(i)).StatisticalSelection.When=...
                imputeBefOrAftName{mapObj(num2str(whichones(i)))};
            handles.Project.Analysis(i).StatisticalSelection.TF=...
                num2str(tf(mapObj(num2str(whichones(i)))));
            handles.Project.Analysis(whichones(i)).StatisticalSelection.Test=...
                statTestName{mapObj(num2str(whichones(i)))};
            handles.Project.Analysis(whichones(i)).StatisticalSelection.Correction=...
                multiCorrName{mapObj(num2str(whichones(i)))};
            handles.Project.Analysis(whichones(i)).StatisticalSelection.Cut=...
                thecut(mapObj(num2str(whichones(i))));

            % Update tree
            handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,...
                                         handles.Project.Name,handles.sessionNumber);
            
            % Correct topts options structure defined before
            if strcmp(impute{mapObj(num2str(whichones(i)))},'knn')
                optsknn=imputeOpts{mapObj(num2str(whichones(i)))};
                optsknn=rmfield(optsknn,'distancename');
                imputeOpts{mapObj(num2str(whichones(i)))}=optsknn;
            end
                                     
            % Perform statistical selection
            % Filter replicates
            handles.analysisInfo(whichones(i)).DataCellFiltered=...
                FilterReplicates(handles.analysisInfo(whichones(i)).DataCellNormLo,...
                                 handles.analysisInfo(whichones(i)).numberOfConditions,...
                                 handles.attributes.gnID,...
                                 'BetweenNorm',scale{mapObj(num2str(whichones(i)))},...
                                 'BetweenNormOpts',scaleOpts{mapObj(num2str(whichones(i)))},...
                                 'Impute',impute{mapObj(num2str(whichones(i)))},...
                                 'ImputeOpts',imputeOpts{mapObj(num2str(whichones(i)))},...
                                 'ImputeWhen',imputeBefOrAft(mapObj(num2str(whichones(i)))),...
                                 'TrustFactor',tf(mapObj(num2str(whichones(i)))),...
                                 'StrictTF',stf(mapObj(num2str(whichones(i)))),...
                                 'ViewBoxplot',disbox(mapObj(num2str(whichones(i)))),...
                                 'HText',handles.mainTextbox);
            
            if ~isempty(handles.analysisInfo(whichones(i)).DataCellFiltered)
                % Statistical selection
                DataCellStat=...
                    StatisticalTest(handles.analysisInfo(whichones(i)).DataCellFiltered,...
                                    handles.analysisInfo(whichones(i)).numberOfConditions,...
                                    handles.analysisInfo(whichones(i)).conditionNames,...
                                    statTest(mapObj(num2str(whichones(i)))),...
                                    multiCorr(mapObj(num2str(whichones(i)))),...
                                    thecut(mapObj(num2str(whichones(i)))),...
                                    {cind{mapObj(num2str(whichones(i)))},tind{mapObj(num2str(whichones(i)))}},...
                                    handles.mainTextbox);
                                
                if ~isempty(DataCellStat)
                    handles.analysisInfo(whichones(i)).DataCellStat=DataCellStat;
                else
                    handles.analysisInfo(whichones(i)).DataCellStat=[];
                end                
                                
                % Update again Project analysis info (again)
                if isfield(handles.analysisInfo(whichones(i)),'DataCellStat')
                    if ~isempty(handles.analysisInfo(whichones(i)).DataCellStat)
                        handles.Project.Analysis(whichones(i)).StatisticalSelection.DEGenes=...
                            length(handles.analysisInfo(whichones(i)).DataCellStat{2});
                    else
                        handles.Project.Analysis(whichones(i)).StatisticalSelection.DEGenes=0;
                        % Update tree (again)
                    end
                        handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,...
                            handles.Project.Name,handles.sessionNumber);
                end
            end
            
        end
        
        % Allow actions again
        enableActive(hmenu,hbtn);
        
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
        
        % Enable clustering and fold change calculation
        %ind=handles.currentSelectionIndex;
        %if handles.analysisInfo(ind).numberOfConditions>1
        %    set(handles.statsFoldChangeCalc,'Enable','on')
        %else
        %    set(handles.statsFoldChangeCalc,'Enable','off')
        %end
        set(handles.statsClustering,'Enable','on')
        set(handles.toolsGap,'Enable','on')
        set(handles.statsClassification,'Enable','on')
        % Enable list exporting
        if ~isempty(DataCellStat)
            set(handles.exportListButton,'Enable','on')
            set(handles.DEListButton,'Enable','on')
            set(handles.viewDEList,'Enable','on')
            set(handles.analysisContextDEList,'Enable','on')
            set(handles.analysisContextExportDEList,'Enable','on')
            set(handles.fileDataExportDE,'Enable','on')
        else
            set(handles.exportListButton,'Enable','off')
            set(handles.DEListButton,'Enable','off')
            set(handles.viewDEList,'Enable','off')
            set(handles.analysisContextDEList,'Enable','off')
            set(handles.analysisContextExportDEList,'Enable','off')
            set(handles.fileDataExportDE,'Enable','off')
        end
        % Enable also PCA
        set(handles.toolsPCA,'Enable','on')
        % Disable Fold Change Calculation in case of time course ANOVA
        currind=handles.currentSelectionIndex;
        if ~isempty(handles.Project.Analysis(currind).StatisticalSelection)
            if strcmpi(handles.Project.Analysis(currind).StatisticalSelection.Test,...
                    'Time Course ANOVA')
                set(handles.statsFoldChangeCalc,'Enable','off')
            else
                set(handles.statsFoldChangeCalc,'Enable','on')
            end
        else
            set(handles.statsFoldChangeCalc,'Enable','off')
        end
        % If all OK, indicate changes
        handles.somethingChanged=true;
        guidata(hObject,handles);
        
        % Do something about volcano plots and expression profiles
        index=get(handles.analysisObjectList,'Value');
        if isfield(handles.analysisInfo,'DataCellStat')
            if ~isempty(handles.analysisInfo(index).DataCellStat)
                if handles.analysisInfo(index).numberOfConditions==1 || ...
                   handles.analysisInfo(index).numberOfConditions==2
                        set(handles.plotsVolcano,'Enable','on')
                else
                    set(handles.plotsVolcano,'Enable','off')
                end
            end
        end
        set(handles.plotsExprProfile,'Enable','on')
        
    catch
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
        % Allow actions again in the case of routine failure
        enableActive(hmenu,hbtn);
        errmsg={'An unexpected error occured during the statistical selection',...
               'process. Please review your settings and check your files.',...
               lasterr};
        uiwait(errordlg(errmsg,'Error'));   
    end
    
end


% --------------------------------------------------------------------
function statsClassification_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function statsClasskNN_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function statsClasskNNTune_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;

% Find the number of slides for this analysis (in order to place a limit for k in case
% user wants to cluster conditions
maxrep=0;
for i=1:handles.analysisInfo(ind).numberOfConditions
    maxrep=maxrep+max(size(handles.analysisInfo(ind).exprp{i}));
end
% ...and get the proper DataCellStat
DataCellStat=handles.analysisInfo(ind).DataCellStat;

% Get parameters
try
    
    [krange,distance,rule,validmethod,validparam,validname,...
        showplot,showresult,verbose,cancel]=kNNTuneEditor(maxrep);
 
    if ~cancel
 
        % Update main message
        handles.mainmsg=get(handles.mainTextbox,'String');
        line1=['Performing kNN Classifier Tuning for Analysis run : ',num2str(ind)];
        line2=['Number of nearest neighbors range : ',num2str(krange)];
        line3='Chosen classifier evaluation methods : ';
        line4=validname(:);
        line5='Chosen distances :';
        line6=distance(:);
        line7='Chosen classification rules :';
        line8=rule(:);
        handles.mainmsg=[handles.mainmsg;' ';...
                         line1;line2;line3;line4;line5;line6;line7;line8;' '];
        set(handles.mainTextbox,'String',handles.mainmsg)
        drawnow;
        
        % Convert DataCellStat to proper input for classifier. As classifiers work better
        % with more samples, classification is always performed using all current Analysis
        % arrays. Meaningless otherwise
        data=cell2mat(DataCellStat{5});
        group=handles.analysisInfo(ind).conditionNames;
        clg=cell(size(data,2),1);
        index=0;
        for i=1:length(group)
            for j=1:size(DataCellStat{5}{i},2)
                index=index+1;
                clg{index}=group{i};
            end
        end
        data=data';

        % Do not allow other actions during classfier tuning
        [hmenu,hbtn]=disableActive;

        % Perform classifier tuning
        tuneknn(data,clg,'NNRange',krange,...
                         'Distances',distance,...
                         'Rules',rule,...
                         'ValidMethods',validmethod,...
                         'ValidParams',validparam,...
                         'ShowPlots',showplot,...
                         'ShowResults',showresult,...
                         'UseWaitbar',true,...
                         'Verbose',verbose);

        % Allow actions again
        enableActive(hmenu,hbtn);
        
    end

catch
    % Allow actions again in the case of routine failure
    enableActive(hmenu,hbtn);
    errmsg={'An unexpected error occured during classifier tuning.',...
            'Please review your settings.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function statsClasskNNClassify_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;

% Find the number of slides for this analysis (in order to place a limit for k in case
% user wants to cluster conditions
maxrep=0;
for i=1:handles.analysisInfo(ind).numberOfConditions
    maxrep=maxrep+max(size(handles.analysisInfo(ind).exprp{i}));
end
% ...and get the proper DataCellStat
DataCellStat=handles.analysisInfo(ind).DataCellStat;

% Get parameters
try
    
    [k,distance,rule,samplenames,newdata,cancel]=kNNClassifyEditor(maxrep);
    
    if ~cancel
        
        % Check if we have the same number of features in new data
        if size(newdata,1)~=length(DataCellStat{2})
            uiwait(errordlg({'The new data must have the same number of features (genes)',...
                ['as the data used to train the classifier (',num2str(length(DataCellStat{2})),')']}));
            return
        end
 
        % Update main message
        handles.mainmsg=get(handles.mainTextbox,'String');
        line1=['Performing kNN Classification using data of Analysis run : ',num2str(ind)];
        line2=['Number of nearest neighbors : ',num2str(k)];
        line3=['Chosen distance : ',distance];
        line4=['Chosen classification rule : ',rule];
        handles.mainmsg=[handles.mainmsg;' ';...
                         line1;line2;line3;line4;' '];
        set(handles.mainTextbox,'String',handles.mainmsg)
        drawnow;
        
        % Convert DataCellStat to proper input for classifier. As classifiers work better
        % with more samples, classification is always performed using all current Analysis
        % arrays. Meaningless otherwise
        data=cell2mat(DataCellStat{5});
        group=handles.analysisInfo(ind).conditionNames;
        clg=cell(size(data,2),1);
        index=0;
        for i=1:length(group)
            for j=1:size(DataCellStat{5}{i},2)
                index=index+1;
                clg{index}=group{i};
            end
        end

        % Do not allow other actions during classfier tuning
        [hmenu,hbtn]=disableActive;
        
        hh=showinfowindow('Classifying. Please wait...');

        % Perform classification
        newclass=knnclassify(newdata',data',clg,k,distance,rule);
        if ~iscell(newclass)
            newclass=mat2cell(newclass,ones(size(newclass,1)),ones(size(newclass,2)));
        end
        
        set(hh,'CloseRequestFcn','closereq')
        close(hh)

        % Allow actions again
        enableActive(hmenu,hbtn);
        
        % Display results with the help of GenericReport
        repcell=cell(length(newclass)+11,1);
        repcell{1}='k-Nearest Neighbors classification results';
        repcell{2}='--------------------------------------------------';
        repcell{3}=' ';
        repcell{4}=['Number of nearest neighbors : ',num2str(k)];
        repcell{5}=['Distance metric : ',distance];
        repcell{6}=['Classification rule : ',rule];
        repcell{7}=' ';
        repcell{8}=['Number of new samples : ',num2str(size(newdata,2))];
        repcell{9}=' ';
        repcell{10}='The class(es) assigned to new data samples is(are) : ';
        repcell{11}=' ';
        for i=1:length(newclass)
            repcell{i+11}=['Sample ',samplenames{i},' belongs to class ',newclass{i},'.'];
        end
        GenericReport(repcell,'kNN Classification results')
        
    end

catch
    % Allow actions again in the case of routine failure
    enableActive(hmenu,hbtn);
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    errmsg={'An unexpected error occured during classifier tuning.',...
            'Please review your settings.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function statsClassSVM_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function statsClassSVMTune_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;

% Find the number of slides for this analysis (in order to place a limit for k in case
% user wants to cluster conditions
maxrep=0;
for i=1:handles.analysisInfo(ind).numberOfConditions
    maxrep=maxrep+max(size(handles.analysisInfo(ind).exprp{i}));
end
% ...and get the proper DataCellStat
DataCellStat=handles.analysisInfo(ind).DataCellStat;

% Get parameters
try
    
    [kernel,kernelName,nrmlz,scl,scalevals,tol,polyParams,mlpParams,rbfParams,validmethod,...
     validparam,validname,showplot,showresult,verbose,cancel]=SVMTuneEditor(maxrep);
 
    if ~cancel
 
        % Update main message
        handles.mainmsg=get(handles.mainTextbox,'String');
        line1=['Performing Support Vector Machines Classifier Tuning for Analysis run : ',num2str(ind)];
        line2='Chosen classifier evaluation methods : ';
        line3=validname(:);
        line4='Chosen kernel function types :';
        line5=kernelName(:);
        handles.mainmsg=[handles.mainmsg;' ';...
                         line1;line2;line3;line4;line5;' '];
        set(handles.mainTextbox,'String',handles.mainmsg)
        drawnow;
        
        % Convert DataCellStat to proper input for classifier. As classifiers work better
        % with more samples, classification is always performed using all current Analysis
        % arrays. Meaningless otherwise
        data=cell2mat(DataCellStat{5});
        group=handles.analysisInfo(ind).conditionNames;
        clg=cell(size(data,2),1);
        index=0;
        for i=1:length(group)
            for j=1:size(DataCellStat{5}{i},2)
                index=index+1;
                clg{index}=group{i};
            end
        end
        data=data';
        
        % Construct parameters cell
        params=cell(1,length(kernel));
        for i=1:length(kernel)
            switch kernel{i}
                case 'linear'
                    params{i}={[]};
                case 'polynomial'
                    params{i}=polyParams;
                case 'mlp'
                    params{i}=mlpParams;
                case 'rbf'
                    params{i}=rbfParams;
            end
        end

        % Do not allow other actions during classfier tuning
        [hmenu,hbtn]=disableActive;

        % Perform classifier tuning
        tunesvm(data,clg,'Kernel',kernel,...
                         'Parameters',params,...
                         'Normalize',nrmlz,...
                         'Scale',scl,...
                         'ValidMethods',validmethod,...
                         'ValidParams',validparam,...
                         'ShowPlots',showplot,...
                         'ShowResults',showresult,...
                         'UseWaitbar',true,...
                         'Verbose',verbose);

        % Allow actions again
        enableActive(hmenu,hbtn);
        
    end

catch
    % Allow actions again in the case of routine failure
    enableActive(hmenu,hbtn);
    errmsg={'An unexpected error occured during classifier tuning.',...
            'Please review your settings.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function statsClassSVMTrain_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;

% Find the number of slides for this analysis (in order to place a limit for k in case
% user wants to cluster conditions
maxrep=0;
for i=1:handles.analysisInfo(ind).numberOfConditions
    maxrep=maxrep+max(size(handles.analysisInfo(ind).exprp{i}));
end
% ...and get the proper DataCellStat
DataCellStat=handles.analysisInfo(ind).DataCellStat;

% Get parameters
try
    
    [kernel,kernelName,normalize,scale,scalevals,tol,params,cancel]=SVMTrainEditor(maxrep);
 
    if ~cancel
 
        % Update main message
        handles.mainmsg=get(handles.mainTextbox,'String');
        line1=['Performing SVM Classification using data of Analysis run : ',num2str(ind)];
        line2=['Chosen kernel function type : ',kernelName];
        line3_1='Chosen parameters : ';
        switch kernel
            case 'linear'
                line3_2='none (linear kernel)';
            case 'polynomial'
                line3_2=['Gamma: ',num2str(params(1)),' Coefficient: ',num2str(params(2)),...
                         ' Degree: ',num2str(params(3))];
            case 'mlp'
                line3_2=['Gamma: ',num2str(params(1)),' Coefficient: ',num2str(params(2))];
            case 'rbf'
                line3_2=['Gamma: ',num2str(params(1))];
        end
        line3=[line3_1 line3_2];
        handles.mainmsg=[handles.mainmsg;' ';...
                         line1;line2;line3;' '];
        set(handles.mainTextbox,'String',handles.mainmsg)
        drawnow;
        
        % Convert DataCellStat to proper input for classifier. As classifiers work better
        % with more samples, classification is always performed using all current Analysis
        % arrays. Meaningless otherwise
        data=cell2mat(DataCellStat{5});
        group=handles.analysisInfo(ind).conditionNames;
        clg=cell(size(data,2),1);
        index=0;
        for i=1:length(group)
            for j=1:size(DataCellStat{5}{i},2)
                index=index+1;
                clg{index}=group{i};
            end
        end
        % Convert class array to row vector and convert to class numeric ids if cell
        [cl,cln]=grp2idx(clg);
        cl=cl(:);
        cl=cl';

        % Do not allow other actions during classfier training
        [hmenu,hbtn]=disableActive;
        
        hh=showinfowindow('Training SVM. Please wait...');
        
        switch kernel
            case 'linear'
                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=LinearSVC(data,cl);
            case 'polynomial'
                g=params(1);
                c=params(2);
                d=params(3);
                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=PolySVC(data,cl,d,1,g,c);
            case 'rbf'
                g=params(1);
                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=RbfSVC(data,cl,g);
            case 'mlp'
                g=params(1);
                c=params(2);
                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=MlpSVC(data,cl,g,c);
        end

        SVMStruct.AlphaY=AlphaY;
        SVMStruct.SVs=SVs;
        SVMStruct.Bias=Bias;
        SVMStruct.Parameters=Parameters;
        SVMStruct.nSV=nSV;
        SVMStruct.nLabel=nLabel;
        SVMStruct.cNames=cln;
        SVMStruct.kernel=kernelName;
        SVMStruct.params=line3;
        
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
        
        % Allow actions again
        enableActive(hmenu,hbtn);
        
        % Update analysis info
        handles.analysisInfo(ind).SVMStruct=SVMStruct;
        
        % Update Project analysis Info
        handles.Project.Analysis(ind).SVM.Kernel=kernelName;
        handles.Project.Analysis(ind).SVM.Parameters=line3_2;
        
        % Update tree
        handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,...
                                     handles.Project.Name,handles.sessionNumber);
                                 
        % Show a message
        uiwait(msgbox('SVM classifier trained!','Info'));
                                 
        guidata(hObject,handles);
    
    end

catch
    % Allow actions again in the case of routine failure
    enableActive(hmenu,hbtn);
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    errmsg={'An unexpected error occured during classifier tuning.',...
            'Please review your settings.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function statsClassSVMClassify_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;

if ~isfield(handles.analysisInfo(ind),'SVMStruct') || isempty(handles.analysisInfo(ind).SVMStruct)
    uiwait(warndlg({'SVM training has not been performed yet',...
                    ['for the current analysis (',num2str(ind),')']}));
    return
end

% Open sample file
[sfile,pname,findex]=uigetfile({'*.txt','Text tab delimited files (*.txt)';...
                                '*.xls','Excel files (*.xls)'},...
                                'Select New Samples file');
if sfile==0
    return
end

sfile=strcat(pname,sfile);
n=length(handles.analysisInfo(ind).DataCellStat{2}); % Features length

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
        newdata=cell2mat(data);
        samplenames=colnames(2:end);
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
    newdata=num;
    samplenames=colnames;
end

% Check if we have the same number of features in new data
if size(newdata,1)~=n
    uiwait(errordlg({'The new data must have the same number of features (genes)',...
                    ['as the data used to train the classifier (',num2str(n),')']}));
    return
end

% Classify
AlphaY=handles.analysisInfo(ind).SVMStruct.AlphaY;
SVs=handles.analysisInfo(ind).SVMStruct.SVs;
Bias=handles.analysisInfo(ind).SVMStruct.Bias;
Parameters=handles.analysisInfo(ind).SVMStruct.Parameters;
nSV=handles.analysisInfo(ind).SVMStruct.nSV;
nLabel=handles.analysisInfo(ind).SVMStruct.nLabel;
cNames=handles.analysisInfo(ind).SVMStruct.cNames;
kernel=handles.analysisInfo(ind).SVMStruct.kernel;
params=handles.analysisInfo(ind).SVMStruct.params;

hh=showinfowindow('Classifying. Please wait...');

[nc,dv]=SVMClass(newdata,AlphaY,SVs,Bias,Parameters,nSV,nLabel);

set(hh,'CloseRequestFcn','closereq')
close(hh)

newclass=cNames(nc);

% Display results with the help of GenericReport
repcell=cell(length(newclass)+10,1);
repcell{1}='Support Vector Machines classification results';
repcell{2}='--------------------------------------------------';
repcell{3}=' ';
repcell{4}=['Kernel function type : ',kernel];
repcell{5}=['Kernel parameters : ',params];
repcell{6}=' ';
repcell{7}=['Number of new samples : ',num2str(size(newdata,2))];
repcell{8}=' ';
repcell{9}='The class(es) assigned to new data samples is(are) : ';
repcell{10}=' ';
for i=1:length(newclass)
    repcell{i+10}=['Sample ',samplenames{i},' belongs to class ',newclass{i},' with decision value ',num2str(dv(i)),'.'];
end
GenericReport(repcell,'SVM Classification results')

guidata(hObject,handles);


% --------------------------------------------------------------------
function statsClassLDA_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function statsClassLDATune_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;

% Find the number of slides for this analysis (in order to place a limit for k in case
% user wants to cluster conditions
maxrep=0;
for i=1:handles.analysisInfo(ind).numberOfConditions
    maxrep=maxrep+max(size(handles.analysisInfo(ind).exprp{i}));
end
% ...and get the proper DataCellStat
DataCellStat=handles.analysisInfo(ind).DataCellStat;

% Get parameters
try
    
    [type,typeName,priors,priorName,validmethod,validparam,validname,...
        showplot,showresult,verbose,cancel]=LDATuneEditor(maxrep);
 
    if ~cancel
 
        % Update main message
        handles.mainmsg=get(handles.mainTextbox,'String');
        line1=['Performing Discriminant Analysis Classifier Tuning for Analysis run : ',num2str(ind)];
        line2='Chosen classifier evaluation methods : ';
        line3=validname(:);
        line4='Chosen discriminant function types :';
        line5=typeName(:);
        line6='Chosen class prior probabilities :';
        line7=priorName(:);
        handles.mainmsg=[handles.mainmsg;' ';...
                         line1;line2;line3;line4;line5;line6;line7;' '];
        set(handles.mainTextbox,'String',handles.mainmsg)
        drawnow;
        
        % Convert DataCellStat to proper input for classifier. As classifiers work better
        % with more samples, classification is always performed using all current Analysis
        % arrays. Meaningless otherwise
        data=cell2mat(DataCellStat{5});
        group=handles.analysisInfo(ind).conditionNames;
        clg=cell(size(data,2),1);
        index=0;
        for i=1:length(group)
            for j=1:size(DataCellStat{5}{i},2)
                index=index+1;
                clg{index}=group{i};
            end
        end
        data=data';

        % Do not allow other actions during classfier tuning
        [hmenu,hbtn]=disableActive;

        % Perform optimal number of clusters calculation
        tunelda(data,clg,'Type',type,...
                         'Prior',priors,...
                         'ValidMethods',validmethod,...
                         'ValidParams',validparam,...
                         'ShowPlots',showplot,...
                         'ShowResults',showresult,...
                         'UseWaitbar',true,...
                         'Verbose',verbose);

        % Allow actions again
        enableActive(hmenu,hbtn);
        
    end

catch
    % Allow actions again in the case of routine failure
    enableActive(hmenu,hbtn);
    errmsg={'An unexpected error occured during classifier tuning.',...
            'Please review your settings.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function statsClassLDAClassify_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;

% Find the number of slides for this analysis (in order to place a limit for k in case
% user wants to cluster conditions
maxrep=0;
for i=1:handles.analysisInfo(ind).numberOfConditions
    maxrep=maxrep+max(size(handles.analysisInfo(ind).exprp{i}));
end
% ...and get the proper DataCellStat
DataCellStat=handles.analysisInfo(ind).DataCellStat;

% Get parameters
try
    
    [type,typeName,prior,priorName,samplenames,newdata,cancel]=LDAClassifyEditor(maxrep);
 
    if ~cancel
        
        % Check if we have the same number of features in new data
        if size(newdata,1)~=length(DataCellStat{2})
            uiwait(errordlg({'The new data must have the same number of features (genes)',...
                             ['as the data used to train the classifier (',num2str(length(DataCellStat{2})),')']}));
            return
        end
 
        % Update main message
        handles.mainmsg=get(handles.mainTextbox,'String');
        line1=['Performing DA Classification using data of Analysis run : ',num2str(ind)];
        line2=['Chosen discriminant function type : ',typeName];
        line3=['Chosen prior class probabilities : ',priorName];
        handles.mainmsg=[handles.mainmsg;' ';...
                         line1;line2;line3;' '];
        set(handles.mainTextbox,'String',handles.mainmsg)
        drawnow;
        
        % Convert DataCellStat to proper input for classifier. As classifiers work better
        % with more samples, classification is always performed using all current Analysis
        % arrays. Meaningless otherwise
        data=cell2mat(DataCellStat{5});
        group=handles.analysisInfo(ind).conditionNames;
        clg=cell(size(data,2),1);
        index=0;
        for i=1:length(group)
            for j=1:size(DataCellStat{5}{i},2)
                index=index+1;
                clg{index}=group{i};
            end
        end

        % Do not allow other actions during classfier tuning
        [hmenu,hbtn]=disableActive;
        
        hh=showinfowindow('Classifying. Please wait...');

        % Perform classification
        newclass=classify(newdata',data',clg,type,prior);
        if ~iscell(newclass)
            newclass=mat2cell(newclass,ones(size(newclass,1)),ones(size(newclass,2)));
        end
        
        set(hh,'CloseRequestFcn','closereq')
        close(hh)

        % Allow actions again
        enableActive(hmenu,hbtn);
        
        % Display results with the help of GenericReport
        repcell=cell(length(newclass)+10,1);
        repcell{1}='Discriminant Analysis classification results';
        repcell{2}='--------------------------------------------------';
        repcell{3}=' ';
        repcell{4}=['Discriminant function type : ',typeName];
        repcell{5}=['Class prior probabilities : ',priorName];
        repcell{6}=' ';
        repcell{7}=['Number of new samples : ',num2str(size(newdata,2))];
        repcell{8}=' ';
        repcell{9}='The class(es) assigned to new data samples is(are) : ';
        repcell{10}=' ';
        for i=1:length(newclass)
            repcell{i+10}=['Sample ',samplenames{i},' belongs to class ',newclass{i},'.'];
        end
        GenericReport(repcell,'DA Classification results')
        
    end

catch
    % Allow actions again in the case of routine failure
    enableActive(hmenu,hbtn);
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    errmsg={'An unexpected error occured during classifier tuning.',...
            'Please review your settings.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function statsFoldChangeCalc_Callback(hObject, eventdata, handles)

% Get currently selected analysis
ind=handles.currentSelectionIndex;

try
   
    % Get calculation parameters
    [cind,tind,cancel]=FoldChangeEditor(handles.analysisInfo(ind).conditionNames);
    
    % Processes such as control if DataCellStat exists or if we have only one condition
    % have been checked. If something of these is true then the menu about fold change is
    % not activated.
    
    if ~cancel
        
        % Store somewhere the indices for further use with names in exporting
        handles.analysisInfo(ind).fcinds={cind,tind};
        % Work for normalized data only first
        % Preallocate a matrix of fold changes (set to zero to fix problem with controls 
        % and since we work on the log scale)
        n=handles.analysisInfo(ind).numberOfConditions;
        logratnorm=handles.analysisInfo(ind).DataCellNormLo{2};
        for i=1:n
            logratnorm{i}=nanmean(cell2mat(logratnorm{i}),2);
        end
        mn=length(handles.attributes.gnID);
        %fcmatn=zeros(mn,n);
        fcmatn=zeros(mn,length(tind));
        % Values to calculate FC from
        valuematn=cell2mat(logratnorm);
        % Calculate fold changes
        for i=1:length(tind)
            % Minus (-) ! We work on the log scale
            fcmatn(:,i)=valuematn(:,tind(i))-valuematn(:,cind(i));
        end
        handles.analysisInfo(ind).DataCellNormLo{7}=fcmatn;
        
        % Repeat for statistically selected data
        if isfield(handles.analysisInfo(ind),'DataCellStat') && ... 
           ~isempty(handles.analysisInfo(ind).DataCellStat)
            ms=length(handles.analysisInfo(ind).DataCellStat{2});
            %fcmats=zeros(ms,n);
            fcmats=zeros(ms,length(tind));
            valuemats=handles.analysisInfo(ind).DataCellStat{1}(:,3:end);
            for i=1:length(tind)
                % Minus (-) ! We work on the log scale
                fcmats(:,i)=valuemats(:,tind(i))-valuemats(:,cind(i));
            end
            handles.analysisInfo(ind).DataCellStat{9}=fcmats;
        end
        
        % Indicate changes
        handles.somethingChanged=true;
        
        % Put a message in the main window
        handles.mainmsg=get(handles.mainTextbox,'String');
        line1='Calculating fold changes...';
        line2='Fold changes calculated!';
        handles.mainmsg=[handles.mainmsg;line1;line2;' '];
        set(handles.mainTextbox,'String',handles.mainmsg)
        drawnow;
        
        guidata(hObject,handles);
        
    end
    
catch
    errmsg={'An unexpected error occured during the fold change calculation',...
            'process. Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function statsClustering_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function statsClusteringHierarchical_Callback(hObject, eventdata, handles)

% Get currently selected analysis
ind=handles.currentSelectionIndex;

% Get clustering parameters
if ~isfield(handles.analysisInfo(ind),'DataCellStat') || isempty(handles.analysisInfo(ind).DataCellStat)
    msg={'Cannot perform clustering on an analysis object without performing',...
         'statistical selection first. Please perform statistical selection of',...
         ['DE genes on analysis ',num2str(ind),' and try again.']};
    uiwait(errordlg(msg,'Error','modal'));
    return
else
    
    [repchoice,dim,linkage,distance,distanceName,incutoff,maxclust,pval,optleaf,...
     disheat,cmap,cmapden,titre,cancel]=HierarchicalClusteringEditor;
    
    if ~cancel
        
        try
       
            % Update main message
            handles.mainmsg=get(handles.mainTextbox,'String');
            line1=['Performing Cluster Analysis for Analysis run : ',num2str(ind)];
            line2='Chosen clustering algorithm : Hierarchical Clustering';
            line3=['Linkage algorithm : ',linkage,' linkage'];
            line4=['Distance metric : ',distanceName,' distance'];
            if isnan(maxclust)
                l1='Inconsistency coefficient cutoff';
                l2=num2str(incutoff);
                l3=['Inconsistency : ',l2];
            elseif isnan(incutoff)
                l1='Maximum number of clusters';
                l2=num2str(maxclust);
                l3=['Maximum clusters : ',l2];
            end
            line5=['Chosen cluster formation limit : ',l1,' set to ',l2];
            line6=['DE genes p-value cutoff : ',num2str(pval)];
            handles.mainmsg=[handles.mainmsg;' ';...
                             line1;line2;line3;line4;line5;line6;' '];
            set(handles.mainTextbox,'String',handles.mainmsg)
            drawnow;

            % Update Project analysis Info
            handles.Project.Analysis(ind).Clustering.Algorithm='Hierarchical';
            handles.Project.Analysis(ind).Clustering.Linkage=linkage;
            handles.Project.Analysis(ind).Clustering.Distance=distanceName;
            handles.Project.Analysis(ind).Clustering.Seed='None : using hierarchical clustering';
            handles.Project.Analysis(ind).Clustering.Limit=l3;
            handles.Project.Analysis(ind).Clustering.PValue=num2str(pval);

            % Update tree
            handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,...
                                         handles.Project.Name,handles.sessionNumber);
            
            hh=showinfowindow('Clustering. Please wait...');
            
            % Do not allow other actions during clustering
            [hmenu,hbtn]=disableActive;
                                     
            % Perform hierarchical clustering
            [handles.analysisInfo(ind).FinalTable,handles.analysisInfo(ind).Clusters,...
             handles.analysisInfo(ind).PIndex,fig]=...
                ExpHClustering(handles.analysisInfo(ind).DataCellStat,...
                               'ClusterWhat',repchoice,'ClusterDim',dim,...
                               'Distance',distance,'Linkage',linkage,...
                               'OptimalLeafOrder',optleaf,...
                               'PValue',pval,'Inconsistency',incutoff,...
                               'MaxClust',maxclust,'DisplayHeatmap',disheat,...
                               'Title',titre,'HText',handles.mainTextbox);
                          
            % Allow actions again
            enableActive(hmenu,hbtn);
                         
            set(hh,'CloseRequestFcn','closereq')
            close(hh)

            % Set the proper colormap
            if strcmpi(cmap,'redgreen')
                strcmap=['redgreencmap','(',num2str(cmapden),')'];
                colormap(strcmap)
            elseif strcmpi(cmap,'redgreenfixed')
                % Load my adjusted fixed 64-colormap
                S=load('MyColormaps','mycmap');
                mycmap=S.mycmap;
                set(fig,'Colormap',mycmap)
            else
                strcmap=[lower(cmap),'(',num2str(cmapden),')'];
                colormap(strcmap)
            end
            colorbar('OuterPosition',[0.9 -0.025 0.05 0.85],'FontSize',10);
                           
            % Update Project analysis Info
            handles.Project.Analysis(ind).Clustering.Clusters=...
                length(unique(handles.analysisInfo(ind).Clusters));
            % Update tree
            handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,...
                                         handles.Project.Name,handles.sessionNumber);
            
            % Enable view and export clusters buttons
            set(handles.clusterListButton,'Enable','on')
            set(handles.analysisContextClusterList,'Enable','on')
            set(handles.viewClusterList,'Enable','on')
            set(handles.analysisContextExportClusterList,'Enable','on')
            set(handles.exportClusterList,'Enable','on')
            set(handles.fileDataExportClusters,'Enable','on')
            % Indicate changes
            handles.somethingChanged=true;
            guidata(hObject,handles);
            
        catch
            % Allow actions again in the case of routine failure
            enableActive(hmenu,hbtn);
            set(hh,'CloseRequestFcn','closereq')
            close(hh)
            errmsg={'An unexpected error occured during the clustering process',...
                    'process. Please review your settings and check your files.',...
                    lasterr};
            uiwait(errordlg(errmsg,'Error'));
        end
    end
end


% --------------------------------------------------------------------
function statsClusteringkmeans_Callback(hObject, eventdata, handles)

% Get currently selected analysis
ind=handles.currentSelectionIndex;

% Get clustering parameters
if ~isfield(handles.analysisInfo(ind),'DataCellStat') || isempty(handles.analysisInfo(ind).DataCellStat)
    msg={'Cannot perform clustering on an analysis object without performing',...
         'statistical selection first. Please perform statistical selection of',...
         ['DE genes on analysis ',num2str(ind),' and try again.']};
    uiwait(errordlg(msg,'Error','modal'));
    return
else
    
    % Find the number of slides for this analysis (in order to place a limit for k in case
    % user wants to cluster conditions
    maxrep=0;
    for i=1:handles.analysisInfo(ind).numberOfConditions
        maxrep=maxrep+max(size(handles.analysisInfo(ind).exprp{i}));
    end
    % Also calculate a k limit for the number of genes
    maxgenes=size(handles.analysisInfo(ind).DataCellStat{1},1);
    
    [repchoice,dim,k,distance,distanceName,seed,seedName,repeat,maxiter,pval,cancel]=...
        kmeansClusteringEditor(maxgenes,maxrep);
    
    if ~cancel
        
        try
       
            % Update main message
            handles.mainmsg=get(handles.mainTextbox,'String');
            line1=['Performing Cluster Analysis for Analysis run : ',num2str(ind)];
            line2='Chosen clustering algorithm : k-means Clustering';
            line3=['Distance metric : ',distanceName,' distance'];
            line4=['Initial clusters chosen using : ',seedName];
            line5=['Number of algorithm repetitions : ',num2str(repeat)];
            line6=['Maximum number of convergence iterations : ',num2str(maxiter)];
            line7=['DE genes p-value cutoff : ',num2str(pval)];
            handles.mainmsg=[handles.mainmsg;' ';...
                             line1;line2;line3;line4;line5;line6;line7;' '];
            set(handles.mainTextbox,'String',handles.mainmsg)
            drawnow;

            % Update Project analysis Info
            handles.Project.Analysis(ind).Clustering.Algorithm='k-means';
            handles.Project.Analysis(ind).Clustering.Linkage='None : using k-means clustering';
            handles.Project.Analysis(ind).Clustering.Distance=distanceName;
            handles.Project.Analysis(ind).Clustering.Seed=seedName;
            handles.Project.Analysis(ind).Clustering.Limit=k;
            handles.Project.Analysis(ind).Clustering.PValue=num2str(pval);

            % Update tree
            handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,...
                                         handles.Project.Name,handles.sessionNumber);

            hh=showinfowindow('Clustering. Please wait...');
            
            % Do not allow other actions during clustering
            [hmenu,hbtn]=disableActive;
                                     
            % Perform k-means clustering
            [handles.analysisInfo(ind).FinalTable,handles.analysisInfo(ind).Clusters,...
             handles.analysisInfo(ind).PIndex,handles.analysisInfo(ind).Centroids,...
             sumofdists,singledists,handles.analysisInfo(ind).group]=...
                kmeansClustering(handles.analysisInfo(ind).DataCellStat,k,...
                                 'ClusterWhat',repchoice,'ClusterDim',dim,...
                                 'PValue',pval,'Distance',distance,...
                                 'Start',seed,'Replications',repeat,...
                                 'MaxIter',maxiter,'EmptyAction','drop',...
                                 'Display','off','HText',handles.mainTextbox);

            % Allow actions again
            enableActive(hmenu,hbtn);
                         
            set(hh,'CloseRequestFcn','closereq')
            close(hh)
                             
            % Update Project analysis Info
            handles.Project.Analysis(ind).Clustering.Clusters=...
                length(unique(handles.analysisInfo(ind).Clusters));            
            % Update tree
            handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,...
                                         handles.Project.Name,handles.sessionNumber);
            
            % Enable view and export clusters buttons
            set(handles.clusterListButton,'Enable','on')
            set(handles.analysisContextClusterList,'Enable','on')
            set(handles.viewClusterList,'Enable','on')
            set(handles.analysisContextExportClusterList,'Enable','on')
            set(handles.exportClusterList,'Enable','on')
            set(handles.fileDataExportClusters,'Enable','on')
            % Indicate changes
            handles.somethingChanged=true;
            guidata(hObject,handles);
            
        catch
            % Allow actions again in the case of routine failure
            enableActive(hmenu,hbtn);
            set(hh,'CloseRequestFcn','closereq')
            close(hh)
            errmsg={'An unexpected error occured during the clustering process',...
                    'process. Please review your settings and check your files.',...
                    lasterr};
            uiwait(errordlg(errmsg,'Error'));
        end
    end
end


% --------------------------------------------------------------------
function statsClusteringFCM_Callback(hObject, eventdata, handles)

% Get currently selected analysis
ind=handles.currentSelectionIndex;

% Get clustering parameters
if ~isfield(handles.analysisInfo(ind),'DataCellStat') || isempty(handles.analysisInfo(ind).DataCellStat)
    msg={'Cannot perform clustering on an analysis object without performing',...
         'statistical selection first. Please perform statistical selection of',...
         ['DE genes on analysis ',num2str(ind),' and try again.']};
    uiwait(errordlg(msg,'Error','modal'));
    return
else
    
    % Find the number of slides for this analysis (in order to place a limit for k in case
    % user wants to cluster conditions
    maxrep=0;
    for i=1:handles.analysisInfo(ind).numberOfConditions
        maxrep=maxrep+max(size(handles.analysisInfo(ind).exprp{i}));
    end
    % Also calculate a number of clusters limit by the number of genes
    maxgenes=size(handles.analysisInfo(ind).DataCellStat{1},1);
    
    [repchoice,dim,k,m,tol,maxiter,pval,doopt,cvcon,mtol,miter,cancel]=...
        FCMClusteringEditor(maxgenes,maxrep);
    
    if ~cancel
        
        try
       
            % Update main message
            handles.mainmsg=get(handles.mainTextbox,'String');
            line1=['Performing Cluster Analysis for Analysis run : ',num2str(ind)];
            line2='Chosen clustering algorithm : Fuzzy C-Means Clustering';
            line3=['Maximum number of convergence iterations : ',num2str(maxiter)];
            line4=['DE genes p-value cutoff : ',num2str(pval)];
            handles.mainmsg=[handles.mainmsg;' ';...
                             line1;line2;line3;line4;' '];
            set(handles.mainTextbox,'String',handles.mainmsg)
            drawnow;

            % Update Project analysis Info
            handles.Project.Analysis(ind).Clustering.Algorithm='FCM';
            handles.Project.Analysis(ind).Clustering.Linkage='None : using FCM clustering';
            handles.Project.Analysis(ind).Clustering.Distance='Euclidean - FCM';
            handles.Project.Analysis(ind).Clustering.Seed='None - using FCM';
            handles.Project.Analysis(ind).Clustering.Limit=k;
            handles.Project.Analysis(ind).Clustering.PValue=num2str(pval);

            % Update tree
            handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,...
                                         handles.Project.Name,handles.sessionNumber);
                                    
            hh=showinfowindow('Clustering. Please wait...');
            
            % Do not allow other actions during clustering
            [hmenu,hbtn]=disableActive;
                                     
            % Perform FCM clustering
            [handles.analysisInfo(ind).FinalTable,handles.analysisInfo(ind).Clusters,...
             handles.analysisInfo(ind).PIndex,handles.analysisInfo(ind).Centroids,...
             u,handles.analysisInfo(ind).group]=...
                FCMClustering(handles.analysisInfo(ind).DataCellStat,k,...
                             'ClusterWhat',repchoice,'ClusterDim',dim,...
                             'PValue',pval,'FuzzyParam',m,...
                             'Tolerance',tol,'MaxIter',maxiter,...
                             'Optimize',doopt,'CVThreshold',cvcon,...
                             'MTol',mtol,'OptMaxIter',miter,...
                             'HText',handles.mainTextbox);

            % Allow actions again
            enableActive(hmenu,hbtn);
                         
            set(hh,'CloseRequestFcn','closereq')
            close(hh)
                         
            % Update Project analysis Info
            handles.Project.Analysis(ind).Clustering.Clusters=...
                length(unique(handles.analysisInfo(ind).Clusters));            
            % Update tree
            handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,...
                                         handles.Project.Name,handles.sessionNumber);
            
            % Enable view and export clusters buttons
            set(handles.clusterListButton,'Enable','on')
            set(handles.analysisContextClusterList,'Enable','on')
            set(handles.viewClusterList,'Enable','on')
            set(handles.analysisContextExportClusterList,'Enable','on')
            set(handles.exportClusterList,'Enable','on')
            set(handles.fileDataExportClusters,'Enable','on')
            % Indicate changes
            handles.somethingChanged=true;
            guidata(hObject,handles);
            
        catch
            Allow actions again in the case of routine failure
            enableActive(hmenu,hbtn);
            set(hh,'CloseRequestFcn','closereq')
            close(hh)
            errmsg={'An unexpected error occured during the clustering process',...
                    'process. Please review your settings and check your files.',...
                    lasterr};
            uiwait(errordlg(errmsg,'Error'));
        end
    end
end


% --------------------------------------------------------------------
function plots_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function plotsArrayImage_Callback(hObject, eventdata, handles)

contents=get(handles.arrayObjectList,'String');
val=get(handles.arrayObjectList,'Value');
selcont=contents(val);
t=handles.experimentInfo.numberOfConditions;
exprp=handles.experimentInfo.exprp;
paths=handles.experimentInfo.pathnames;
filenames=cell(length(val),1);
clearfilenames=cell(length(val),1);
stru=cell(length(val),1);

% Find the arrays from the list
for k=1:length(selcont)
    for i=1:t
        for j=1:max(size(exprp{i}))
            if strcmp(selcont{k},exprp{i}{j})
                stru{k}=handles.datstruct{i}{j};
                filenames{k}=strcat(paths{i}{j},exprp{i}{j});
                clearfilenames{k}=exprp{i}{j};
            end
        end
    end
end

% Do not create if indices matrix not assigned
if isempty(handles.attributes.Indices)
    uiwait(warndlg('Insufficient array grid information to create an image!',...
                   'Insufficient data'));
    return
end

% Get input parameters
[imgdata,imgdataname,cmap,cmapdensity,discolbar,dim,titles,cancel]=...
    MAImageEditor(length(filenames),handles.experimentInfo.imgsw);

if ~cancel
    
    try
        
        if dim==1
            
            for i=1:length(filenames)
                h=figure;
                if isempty(titles)
                    mymaimage(stru{i},handles.attributes,{imgdata,imgdataname},'ColorBar',discolbar);
                else
                    mymaimage(stru{i},handles.attributes,{imgdata,imgdataname},'ColorBar',discolbar,'Title',titles{i});
                end
                if strcmpi(cmap,'red') || strcmpi(cmap,'green')
                    load('redgreenmaps.mat');
                    if strcmpi(cmap,'red')
                        colormap(aredmap)
                    elseif strcmpi(cmap,'green')
                        colormap(agreenmap)
                    end
                elseif ~strcmpi(cmap,'default')
                    strcmap=[lower(cmap),'(',num2str(cmapdensity),')'];
                    colormap(strcmap)
                end
                set(h,'Name',['Image of ',imgdataname,' for array ',clearfilenames{i}])
            end
            
        elseif dim==2
            
            for i=1:length(filenames)
                h=figure;
                if isempty(titles)
                    mymaimage3D(stru{i},handles.attributes,{imgdata,imgdataname},'ColorBar',discolbar);
                else
                    mymaimage3D(stru{i},handles.attributes,{imgdata,imgdataname},'ColorBar',discolbar,'Title',titles{i});
                end
                if strcmpi(cmap,'red') || strcmpi(cmap,'green')
                    load('redgreenmaps.mat');
                    if strcmpi(cmap,'red')
                        colormap(aredmap)
                    elseif strcmpi(cmap,'green')
                        colormap(agreenmap)
                    end
                elseif ~strcmpi(cmap,'default')
                    strcmap=[lower(cmap),'(',num2str(cmapdensity),')'];
                    colormap(strcmap)
                end
                set(h,'Name',['Image of ',imgdataname,' for array ',clearfilenames{i}])
            end
            
        end
        
    catch
        errmsg={'An unexpected error occured while trying to create array',...
                'images. Please review your settings and check your files.',...
                lasterr};
        uiwait(errordlg(errmsg,'Error'));
    end
    
end



% --------------------------------------------------------------------
function plotsNormUnnorm_Callback(hObject, eventdata, handles)

% Get current analysis selection index
ind=handles.currentSelectionIndex;

% Create contents of the Editor array listbox
if isfield(handles,'analysisInfo')
    if isfield(handles.analysisInfo,'DataCellNormLo') && ~isempty(handles.analysisInfo(ind).DataCellNormLo)
        index=1;
        for i=1:handles.analysisInfo(ind).numberOfConditions
            for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                contents{index}=handles.analysisInfo(ind).exprp{i}{j};
                index=index+1;
            end
        end
    end
end

try
    
    % Get NU plot parameters
    [whichones,plotwhat,plotwhatname,cmap,cmapdensity,discolbar,dim,titles,cancel]=...
        NUImageEditor(contents);
    
    if ~cancel
        
        % Locate the arrays
        t=handles.analysisInfo(ind).numberOfConditions;
        exprp=handles.analysisInfo(ind).exprp;
        DataCellNormLo=handles.analysisInfo(ind).DataCellNormLo;
        arrays=cell(length(whichones),1);

        % Find the arrays from the main or the MAEditor list
        m=[]; n=[];
        for k=1:length(whichones)
            for i=1:t
                for j=1:max(size(exprp{i}))
                    if strcmp(whichones{k},exprp{i}{j})
                        arrays{k}=exprp{i}{j};
                        m=[m,i];
                        n=[n,j];
                    end
                end
            end
        end
        
        % We don't really need datstruct for this case... just the indices, the shape and
        % the gene names (obtained from handles.attributes.gnID)
        stru.Indices=handles.attributes.Indices;
        stru.Shape=handles.attributes.Shape;
        stru.GeneNames=handles.attributes.gnID;
        
        % Plot for normalized or unnormalized ratio, 2D or 3D
        if plotwhat==1

            if isempty(titles)
                titres=cell(length(whichones),1);
                for i=1:length(m)
                    titres{i}=[plotwhatname,' image for array ',exprp{m(i)}{n(i)}];
                end
            else
                titres=titles;
            end

            for i=1:length(m)
                logratnorm=DataCellNormLo{2}{m(i)}{n(i)};
                createRawNormImage(stru,handles.attributes,logratnorm,dim);
                if strcmpi(cmap,'red-green')
                    S=load('redgreenmaps.mat','aredgreenmap');
                    colormap(S.aredgreenmap)
                elseif ~strcmpi(cmap,'default')
                    strcmap=[lower(cmap),'(',num2str(cmapdensity),')'];
                    colormap(strcmap)
                end
                climprop=[-max(abs(logratnorm)) max(abs(logratnorm))];
                set(gca,'CLim',climprop)
                if discolbar
                    colorbar;
                end
                set(gcf,'Name',titres{i})
            end
            
        elseif plotwhat==2
            
            if isempty(titles)
                titres=cell(length(whichones),1);
                for i=1:length(m)
                    titres{i}=[plotwhatname,' image for array ',exprp{m(i)}{n(i)}];
                end
            else
                titres=titles;
            end

            for i=1:length(m)
                lograt=DataCellNormLo{1}{m(i)}{n(i)};
                createRawNormImage(stru,handles.attributes,lograt,dim);
                if strcmpi(cmap,'red-green')
                    S=load('redgreenmaps.mat','aredgreenmap');
                    colormap(S.aredgreenmap)
                elseif ~strcmpi(cmap,'default')
                    strcmap=[lower(cmap),'(',num2str(cmapdensity),')'];
                    colormap(strcmap)
                end
                climprop=[-max(abs(lograt)) max(abs(lograt))];
                set(gca,'CLim',climprop)
                if discolbar
                    colorbar;
                end
                set(gcf,'Name',titres{i})
            end

        end
        
    end
    
catch
    errmsg={'An unexpected error occured while trying to create array',...
            'images. Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function plotsArrayPlot_Callback(hObject, eventdata, handles)

% Get current analysis selection index
ind=handles.currentSelectionIndex;

% Create a list of all the arrays
index=0;
allarrays=cell(handles.Project.NumberOfSlides,1);
for i=1:length(handles.experimentInfo.exprp)
    for j=1:length(handles.experimentInfo.exprp{i})
        index=index+1;
        allarrays{index}=handles.experimentInfo.exprp{i}{j};
    end
end
% Create a list of the normalized arrays for the current analysis
if isfield(handles,'analysisInfo')
    if isfield(handles.analysisInfo(ind),'DataCellNormLo') && ~isempty(handles.analysisInfo(ind).DataCellNormLo)
        index=0;
        normarrays=cell(handles.Project.Analysis(ind).NumberOfSlides,1);
        for i=1:length(handles.analysisInfo(ind).exprp)
            for j=1:length(handles.analysisInfo(ind).exprp{i})
                index=index+1;
                normarrays{index}=handles.analysisInfo(ind).exprp{i}{j};
            end
        end
        normpfmd=true;
    else
        normarrays={' '};
        normpfmd=false;
    end
else
    normarrays={' '};
    normpfmd=false;
end

% Get plotting parameters and do job
% try 
    
    [farrays,fnarrays,plotwhat,plotwhatName,vswhat,vswhatName,titles,...
     ntitle,dispcorr,logscale,displine,linecut,issingle,cancel]=...
        ArrayPlotEditor(allarrays,normarrays,handles.experimentInfo.imgsw,normpfmd);
    
    if ~cancel
        
        if issingle % Multiple arrays allowed, we don't use DataCellNormLo in this case
            
            % Find the arrays from the list of all arrays
            m=[]; n=[];
            for k=1:length(farrays)
                for i=1:handles.experimentInfo.numberOfConditions
                    for j=1:max(size(handles.experimentInfo.exprp{i}))
                        if strcmp(farrays{k},handles.experimentInfo.exprp{i}{j})
                            m=[m,i];
                            n=[n,j];
                        end
                    end
                end
            end
            % Create the titles if not given
            if isempty(titles)
                titles=cell(1,length(m));
                for i=1:length(m)
                    titles{i}{1}=[plotwhatName,' vs ',vswhatName];
                    titles{i}{2}=['Array: ',farrays{i}];
                end
            end
            % Create axis labels
            xlabels=cell(1,length(m));
            ylabels=cell(1,length(m));
            for i=1:length(m)
                xlabels{i}=plotwhatName;
                ylabels{i}=vswhatName;
            end
            % Retrieve and plot data
            for i=1:length(m)
                xdata=retrieveArrayData(plotwhat,[],[],handles.datstruct,m(i),n(i));
                ydata=retrieveArrayData(vswhat,[],[],handles.datstruct,m(i),n(i));
                plotGeneric(xdata,ydata,'Title',titles{i},...
                                        'XTitle',xlabels{i},...
                                        'YTitle',ylabels{i},...
                                        'DisplayCutLine',displine,...
                                        'CutLine',linecut,...
                                        'LogScale',logscale,...
                                        'ShowCorrelation',dispcorr,...
                                        'Labels',handles.attributes.pbID,...
                                        'Count',randomint(1,1,[1 10000]))
            end
            
            % Only for Affymetrix and Illumina
            if (handles.experimentInfo.imgsw==99 || handles.experimentInfo.imgsw==98) && ~isempty(fnarrays)
                % Fetch some data
                t=handles.analysisInfo(ind).numberOfConditions;
                exprp=handles.analysisInfo(ind).exprp;
                exptab=handles.analysisInfo(ind).exptab;
                DataCellNormLo=handles.analysisInfo(ind).DataCellNormLo;
                % Locate the arrays for normalized ones
                m=[]; n=[];
                for k=1:length(fnarrays)
                    for i=1:t
                        for j=1:max(size(exprp{i}))
                            if strcmp(fnarrays{k},exprp{i}{j})
                                m=[m,i];
                                n=[n,j];
                            end
                        end
                    end
                end
                % Create the title if not given
                if ~isempty(fnarrays) && isempty(ntitle)
                    ntitles=cell(1,length(m));
                    for i=1:length(m)
                        ntitles{i}{1}=[plotwhatName,' vs ',vswhatName];
                        ntitles{i}{2}=['Array: ',fnarrays{i}];
                    end
                end
                % Create axis labels and plot
                xlabels=cell(1,length(m));
                ylabels=cell(1,length(m));
                for i=1:length(m)
                    xlabels{i}=plotwhatName;
                    ylabels{i}=vswhatName;
                end
                for i=1:length(m)
                    xdata=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m(i),n(i));
                    ydata=retrieveArrayData(vswhat,DataCellNormLo,exptab,handles.datstruct,m(i),n(i));
                    plotGeneric(xdata,ydata,'Title',ntitles{i},...
                                            'XTitle',xlabels{i},...
                                            'YTitle',ylabels{i},...
                                            'DisplayCutLine',displine,...
                                            'CutLine',linecut,...
                                            'LogScale',logscale,...
                                            'ShowCorrelation',dispcorr,...
                                            'Labels',handles.attributes.gnID,...
                                            'Count',randomint(1,1,[1 10000]))
                end
            end
            
        else
            
            % Find the arrays from the list of all arrays
            m=[]; n=[];
            for k=1:length(farrays)
                for i=1:handles.experimentInfo.numberOfConditions
                    for j=1:max(size(handles.experimentInfo.exprp{i}))
                        if strcmp(farrays{k},handles.experimentInfo.exprp{i}{j})
                            m=[m,i];
                            n=[n,j];
                        end
                    end
                end
            end
            % Create the titles for all arrays if not given
            if ~isempty(farrays)
                if isempty(titles)
                    titles{1}=['Array: ',farrays{1},' vs ',farrays{2}];
                    titles{2}=plotwhatName;
                end
                % Create axis labels
                xlabels=[plotwhatName,' ',farrays{1}];
                ylabels=[plotwhatName,' ',farrays{2}];
                % Retrieve and plot data for un-normalized arrays
                xdata=retrieveArrayData(plotwhat,[],[],handles.datstruct,m(1),n(1));
                ydata=retrieveArrayData(plotwhat,[],[],handles.datstruct,m(2),n(2));
                plotGeneric(xdata,ydata,'Title',titles,...
                                        'XTitle',xlabels,...
                                        'YTitle',ylabels,...
                                        'DisplayCutLine',displine,...
                                        'CutLine',linecut,...
                                        'LogScale',logscale,...
                                        'ShowCorrelation',dispcorr,...
                                        'Labels',handles.attributes.pbID,...
                                        'Count',randomint(1,1,[1 10000]))
            end

            % Fetch some data
            t=handles.analysisInfo(ind).numberOfConditions;
            exprp=handles.analysisInfo(ind).exprp;
            exptab=handles.analysisInfo(ind).exptab;
            DataCellNormLo=handles.analysisInfo(ind).DataCellNormLo;
            % Locate the arrays for normalized ones
            m=[]; n=[];
            for k=1:length(fnarrays)
                for i=1:t
                    for j=1:max(size(exprp{i}))
                        if strcmp(fnarrays{k},exprp{i}{j})
                            m=[m,i];
                            n=[n,j];
                        end
                    end
                end
            end
            % Create the title if not given
            if ~isempty(fnarrays) && isempty(ntitle)
                ntitle{1}=['Arrays: ',fnarrays{1},' vs ',fnarrays{2}];
                ntitle{2}=plotwhatName;
            end
            % Create axis labels and plot
            if ~isempty(fnarrays)
                xlabels=[plotwhatName,' ',fnarrays{1}];
                ylabels=[plotwhatName,' ',fnarrays{2}];
                xdata=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m(1),n(1));
                ydata=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m(2),n(2));
                plotGeneric(xdata,ydata,'Title',ntitle,...
                                        'XTitle',xlabels,...
                                        'YTitle',ylabels,...
                                        'DisplayCutLine',displine,...
                                        'CutLine',linecut,...
                                        'LogScale',logscale,...
                                        'ShowCorrelation',dispcorr,...
                                        'Labels',handles.attributes.gnID,...
                                        'Count',randomint(1,1,[1 10000]))
            end   

        end
        
    end
            
% catch
%     errmsg={'An unexpected error occured while trying to create array',...
%             'plots. Please review your settings and check your files.',...
%             lasterr};
%     uiwait(errordlg(errmsg,'Error'));
% end


% --------------------------------------------------------------------
function plotsMA_Callback(hObject, eventdata, handles)

% Get current analysis selection index
ind=handles.currentSelectionIndex;

% Create contents of the MA Plots Editor array listbox
if isfield(handles,'analysisInfo')
    if isfield(handles.analysisInfo,'DataCellNormLo') && ~isempty(handles.analysisInfo(ind).DataCellNormLo)
        index=1;
        for i=1:handles.analysisInfo(ind).numberOfConditions
            for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                contents{index}=handles.analysisInfo(ind).exprp{i}{j};
                index=index+1;
            end
        end
        % Indicate whether subgrid normalization has been performed or not
        if isfield(handles.analysisInfo,'subgrid') && ~isempty(handles.analysisInfo(ind).subgrid)
            if handles.analysisInfo(ind).subgrid==1
                subpfmd=true;
            elseif handles.analysisInfo(ind).subgrid==2
                subpfmd=false;
            end
        else
            subpfmd=false;
        end
        % Re-assign ability to display subgrid plots in the case of no normalization
        if handles.analysisInfo(ind).DataCellNormLo{5}==8
            subpfmd=false;
        end
    else
        uiwait(warndlg({'Normalization has not yet been performed for',...
            ['Analysis ',num2str(ind),'. Normalize data and try again']},...
            'Warning'));
        return
    end
else
    uiwait(warndlg({'No data preprocessing has been performed yet for ',...
        ['Analysis ',num2str(ind),'. Start preprocessing and try again']},...
        'Warning'));
    return
end

% Proceed
try
    
    % Get MA plot parameters
    [whichones,before,after,beforeafter,beforeTitles,afterTitles,beforeAfterTitles,...
     disCurve,disFCLine,FCLine,disSub,cancel]=...
        MAPlotEditor(contents,subpfmd);
    
    if ~cancel
        
        % Locate the arrays
        t=handles.analysisInfo(ind).numberOfConditions;
        exprp=handles.analysisInfo(ind).exprp;
        DataCellNormLo=handles.analysisInfo(ind).DataCellNormLo;
        arrays=cell(length(whichones),1);

        % Find the arrays from the main or the MAEditor list
        m=[]; n=[];
        for k=1:length(whichones)
            for i=1:t
                for j=1:max(size(exprp{i}))
                    if strcmp(whichones{k},exprp{i}{j})
                        arrays{k}=exprp{i}{j};
                        m=[m,i];
                        n=[n,j];
                    end
                end
            end
        end

        % Plot befores
        if before && ~disSub

            if isempty(beforeTitles)
                titres=cell(length(whichones),1);
                for i=1:length(m)
                    titres{i}=['Un-normalized MA plot for array ',...
                               exprp{m(i)}{n(i)}];
                end
            else
                titres=beforeTitles;
            end

            labels=handles.attributes.gnID;
            for i=1:length(m)
                inten=DataCellNormLo{3}{m(i)}{n(i)};
                lograt=DataCellNormLo{1}{m(i)}{n(i)};
                logratsmth=DataCellNormLo{6}{m(i)}{n(i)};
                plotMA(inten,lograt,logratsmth,...
                       'Title',titres{i},...
                       'DisplayNormCurve',disCurve,...
                       'DisplayFCLine',disFCLine,...
                       'FoldChange',FCLine,...
                       'Labels',labels,...
                       'Count',randomint(1,1,[1 10000]))
            end

        end
        
        % Plot afters
        if after && ~disSub

            if isempty(afterTitles)
                titres=cell(length(whichones),1);
                normtype=DataCellNormLo{5};
                span=DataCellNormLo{4};
                switch normtype
                    case 1
                        part1=strcat('Lowess with span : ',num2str(span));
                    case 2
                        part1=strcat('Robust Lowess with span : ',num2str(span));
                    case 3
                        part1=strcat('Loess with Span : ',num2str(span));
                    case 4
                        part1=strcat('Robust Loess span : ',num2str(span));
                    case 5
                        part1='Global Mean';
                    case 6
                        part1='Global Median';
                    case 7
                        part1='Rank Invariant';
                    case 8
                        part1='No Normalization';
                    otherwise
                        part1='Externally Normalized';
                end
                for i=1:length(m)
                    titres{i}={['Normalized MA plot for array ',...
                                exprp{m(i)}{n(i)}];...
                               ['Normalization : ',part1]};
                end
            else
                titres=afterTitles;
            end
            
            labels=handles.attributes.gnID;
            for i=1:length(m)
                inten=DataCellNormLo{3}{m(i)}{n(i)};
                logratnorm=DataCellNormLo{2}{m(i)}{n(i)};
                plotMANorm(inten,logratnorm,...
                           'Title',titres{i},...
                           'DisplayFCLine',disFCLine,...
                           'FoldChange',FCLine,...
                           'Labels',labels,...
                           'ForAffy',[],...
                           'Count',randomint(1,1,[1 10000]))
            end

        end
        
        % Plot befores and afters
        if beforeafter

            if isempty(beforeAfterTitles)
                suptitres=cell(length(whichones),1);
                for i=1:length(whichones)
                    suptitres{i}=['MA Plots before and after normalization for array ',...
                                  whichones{i}];
                end
            else
                suptitres=beforeAfterTitles;
            end
            
            % Subplot titles
            titres=cell(length(whichones),2);
            normtype=DataCellNormLo{5};
            span=DataCellNormLo{4};
            switch normtype
                case 1
                    part1=strcat('Lowess with span : ',num2str(span));
                case 2
                    part1=strcat('Robust Lowess with span : ',num2str(span));
                case 3
                    part1=strcat('Loess with Span : ',num2str(span));
                case 4
                    part1=strcat('Robust Loess span : ',num2str(span));
                case 5
                    part1='Global Mean';
                case 6
                    part1='Global Median';
                case 7
                    part1='Rank Invariant';
                case 8
                    part1='No Normalization';
                otherwise
                    part1='Externally Normalized';
            end
            for i=1:length(m)
                titres{i,1}=['Un-normalized MA plot for array ',exprp{m(i)}{n(i)}];
                titres{i,2}={['Normalized MA plot for array ',exprp{m(i)}{n(i)}];...
                             ['Normalization : ',part1]};
            end
            labels=handles.attributes.gnID;
            for i=1:length(m)
                inten=DataCellNormLo{3}{m(i)}{n(i)};
                lograt=DataCellNormLo{1}{m(i)}{n(i)};
                logratnorm=DataCellNormLo{2}{m(i)}{n(i)};
                logratsmth=DataCellNormLo{6}{m(i)}{n(i)};
                plotMABeforeAfter(inten,lograt,logratnorm,logratsmth,...
                                  'Title',titres(i,:),...
                                  'SuperTitle',suptitres{i},...
                                  'DisplayNormCurve',disCurve,...
                                  'DisplayFCLine',disFCLine,...
                                  'FoldChange',FCLine,...
                                  'Labels',labels,...
                                  'Count',randomint(1,1,[1 10000]))
            end

        end
        
        % Plot befores and subgrid
        if before && disSub

            if isempty(beforeTitles)
                titres=cell(length(whichones),1);
                for i=1:length(m)
                    titres{i}=['Un-normalized MA subgrid plot for array ',...
                               exprp{m(i)}{n(i)}];
                end
            else
                titres=beforeTitles;
            end

            labels=handles.attributes.gnID;
            areas=DataCellNormLo{7};
            for i=1:length(m)
                inten=DataCellNormLo{3}{m(i)}{n(i)};
                lograt=DataCellNormLo{1}{m(i)}{n(i)};
                logratsmth=DataCellNormLo{6}{m(i)}{n(i)};
                plotMASub(areas,inten,lograt,logratsmth,titres{i},disCurve,...
                          disFCLine,FCLine,labels)
            end

        end
        
        % Plot afters and subgrid
        if after && disSub

            if isempty(afterTitles)
                titres=cell(length(whichones),1);
                normtype=DataCellNormLo{5};
                span=DataCellNormLo{4};
                switch normtype
                    case 1
                        part1=strcat('Lowess with span : ',num2str(span));
                    case 2
                        part1=strcat('Robust Lowess with span : ',num2str(span));
                    case 3
                        part1=strcat('Loess with Span : ',num2str(span));
                    case 4
                        part1=strcat('Robust Loess span : ',num2str(span));
                    case 5
                        part1='Global Mean';
                    case 6
                        part1='Global Median';
                    case 7
                        part1='Rank Invariant';
                    case 8
                        part1='No Normalization';
                    otherwise
                        part1='Externally Normalized';
                end
                for i=1:length(m)
                    titres{i}=['Normalized MA plot for array ',exprp{m(i)}{n(i)},...
                               ' Normalization : ',part1];
                end
            else
                titres=afterTitles;
            end
            
            labels=handles.attributes.gnID;
            areas=DataCellNormLo{7};
            for i=1:length(m)
                inten=DataCellNormLo{3}{m(i)}{n(i)};
                logratnorm=DataCellNormLo{2}{m(i)}{n(i)};
                plotMANormSub(areas,inten,logratnorm,titres{i},disFCLine,FCLine,labels)
            end

        end
        
    end
    
catch
    errmsg={'An unexpected error occured during the plotting process.',...
            'Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function plotsSlideDistrib_Callback(hObject, eventdata, handles)

% Get current analysis selection index
ind=handles.currentSelectionIndex;

% Create contents of the Slide Distribution Editor array listbox
if isfield(handles,'analysisInfo')
    if isfield(handles.analysisInfo,'DataCellNormLo') && ~isempty(handles.analysisInfo(ind).DataCellNormLo)
        index=0;
        conditioncontents=handles.analysisInfo(ind).conditionNames;
        for i=1:handles.analysisInfo(ind).numberOfConditions
            for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                index=index+1;
                arraycontents{index}=handles.analysisInfo(ind).exprp{i}{j};
            end
        end
    else
        uiwait(warndlg({'Normalization has not yet been performed for',...
                        ['Analysis ',num2str(ind),'. Normalize data and try again']},...
                        'Warning'));
        return
    end
end

% Proceed
try
    
    % Get ratio distribution plot parameters
    [whicharrays,whichconditions,sliorcon,before,after,beforeafter,beforeTitles,afterTitles,...
     beforeAfterTitles,cancel]=SlideDistributionEditor(arraycontents,conditioncontents);
    
    if ~cancel
        
        % Locate the arrays
        t=handles.analysisInfo(ind).numberOfConditions;
        exprp=handles.analysisInfo(ind).exprp;
        condnams=handles.analysisInfo(ind).conditionNames;
        DataCellNormLo=handles.analysisInfo(ind).DataCellNormLo;

        if sliorcon==1 % Plot for each slide separetely
            
            % Find the arrays from the main list
            m=[]; n=[];
            for k=1:length(whicharrays)
                for i=1:t
                    for j=1:max(size(exprp{i}))
                        if strcmp(whicharrays{k},exprp{i}{j})
                            m=[m,i];
                            n=[n,j];
                        end
                    end
                end
            end
            
            % Plot befores
            if before
                if isempty(beforeTitles)
                    titres=cell(length(whicharrays),1);
                    for i=1:length(m)
                        titres{i}=['Non-normalized ratio distribution for array ',...
                                   exprp{m(i)}{n(i)}];
                    end
                else
                    titres=beforeTitles;
                end
                for i=1:length(m)
                    lograt=DataCellNormLo{1}{m(i)}{n(i)};
                    plotDistribArray(lograt,titres{i})
                end
            end
            
            % Plot afters
            if after
                if isempty(afterTitles)
                    titres=cell(length(whicharrays),1);
                    normtype=DataCellNormLo{5};
                    span=DataCellNormLo{4};
                    switch normtype
                        case 1
                            part1=strcat('Lowess with span : ',num2str(span));
                        case 2
                            part1=strcat('Robust Lowess with span : ',num2str(span));
                        case 3
                            part1=strcat('Loess with Span : ',num2str(span));
                        case 4
                            part1=strcat('Robust Loess span : ',num2str(span));
                        case 5
                            part1='Global Mean';
                        case 6
                            part1='Global Median';
                        case 7
                            part1='Rank Invariant';
                        case 8
                            part1='No Normalization';
                        otherwise
                            part1='Externally Normalized';
                    end
                    for i=1:length(m)
                        titres{i}={['Normalized ratio distribution for array ',...
                                    exprp{m(i)}{n(i)}];...
                                    ['Normalization : ',part1]};
                    end
                else
                    titres=afterTitles;
                end
                for i=1:length(m)
                    logratnorm=DataCellNormLo{2}{m(i)}{n(i)};
                    plotDistribArrayNorm(logratnorm,titres{i})
                end
            end
            
            % Plot befores and afters
            if beforeafter

                if isempty(beforeAfterTitles)
                    suptitres=cell(length(whicharrays),1);
                    for i=1:length(whicharrays)
                        suptitres{i}=['Ratio distributions before and after normalization for array ',...
                                      whicharrays{i}];
                    end
                else
                    suptitres=beforeAfterTitles;
                end
                % Subplot titles
                titres=cell(length(whicharrays),3);
                normtype=DataCellNormLo{5};
                span=DataCellNormLo{4};
                switch normtype
                    case 1
                        part1=strcat('Lowess with span : ',num2str(span));
                    case 2
                        part1=strcat('Robust Lowess with span : ',num2str(span));
                    case 3
                        part1=strcat('Loess with Span : ',num2str(span));
                    case 4
                        part1=strcat('Robust Loess span : ',num2str(span));
                    case 5
                        part1='Global Mean';
                    case 6
                        part1='Global Median';
                    case 7
                        part1='Rank Invariant';
                    case 8
                        part1='No Normalization';
                    otherwise
                        part1='Externally Normalized';
                end
                for i=1:length(m)
                    titres{i,1}=['Non-normalized ratio distribution for array ',...
                                 strrep(exprp{m(i)}{n(i)},'_','-')];
                    titres{i,2}={['Normalized ratio distribution for array ',...
                                  strrep(exprp{m(i)}{n(i)},'_','-')];...
                                 ['Normalization : ',part1]};
                    titres{i,3}={['Ratio distribution before and after normalization for array ',...
                                  strrep(exprp{m(i)}{n(i)},'_','-')];...
                                 ['Normalization : ',part1]};
                end
                for i=1:length(m)
                    lograt=DataCellNormLo{1}{m(i)}{n(i)};
                    logratnorm=DataCellNormLo{2}{m(i)}{n(i)};
                    plotDistribArrayBeforeAfter(lograt,logratnorm,suptitres{i},titres(i,:))
                end
            end
            
        end
        
        if sliorcon==2 % Plot for each condition
            
            % Find the conditions from the main list
            if ~iscell(whichconditions)
                whichconditions={whichconditions};
            end
            m=zeros(length(whichconditions),1);
            for k=1:length(whichconditions)
                for i=1:t
                    if strcmp(whichconditions{k},condnams{i})
                        m(k)=i;
                    end
                end
            end
            
            % Plot befores
            if before
                if isempty(beforeTitles)
                    titres=cell(length(whichconditions),1);
                    for i=1:length(m)
                        titres{i}=['Non-normalized ratio distribution for arrays of condition ',...
                                   whichconditions{i}];
                    end
                else
                    titres=beforeTitles;
                end
                for i=1:length(m)
                    lograt=cell2mat(DataCellNormLo{1}{m(i)});
                    leg=exprp{i};
                    plotDistribCondition(lograt,titres{i},leg)
                end
            end
            
            % Plot afters
            if after
                if isempty(afterTitles)
                    titres=cell(length(whichconditions),1);
                    normtype=DataCellNormLo{5};
                    span=DataCellNormLo{4};
                    switch normtype
                        case 1
                            part1=strcat('Lowess with span : ',num2str(span));
                        case 2
                            part1=strcat('Robust Lowess with span : ',num2str(span));
                        case 3
                            part1=strcat('Loess with Span : ',num2str(span));
                        case 4
                            part1=strcat('Robust Loess span : ',num2str(span));
                        case 5
                            part1='Global Mean';
                        case 6
                            part1='Global Median';
                        case 7
                            part1='Rank Invariant';
                        case 8
                            part1='No Normalization';
                        otherwise
                            part1='Externally Normalized';
                    end
                    for i=1:length(m)
                        titres{i}={['Normalized ratio distribution for arrays of condition ',...
                                    whichconditions{i}];...
                                    ['Normalization : ',part1]};
                    end
                else
                    titres=afterTitles;
                end
                for i=1:length(m)
                    logratnorm=cell2mat(DataCellNormLo{2}{m(i)});
                    leg=exprp{i};
                    plotDistribConditionNorm(logratnorm,titres{i},leg)
                end
            end
            
            % Plot befores and afters
            if beforeafter

                if isempty(beforeAfterTitles)
                    suptitres=cell(length(whichconditions),1);
                    for i=1:length(whichconditions)
                        suptitres{i}=['Ratio distributions before and after normalization for arrays of condition ',...
                                      whichconditions{i}];
                    end
                else
                    suptitres=beforeAfterTitles;
                end
                % Subplot titles
                titres=cell(length(whicharrays),2);
                normtype=DataCellNormLo{5};
                span=DataCellNormLo{4};
                switch normtype
                    case 1
                        part1=strcat('Lowess with span : ',num2str(span));
                    case 2
                        part1=strcat('Robust Lowess with span : ',num2str(span));
                    case 3
                        part1=strcat('Loess with Span : ',num2str(span));
                    case 4
                        part1=strcat('Robust Loess span : ',num2str(span));
                    case 5
                        part1='Global Mean';
                    case 6
                        part1='Global Median';
                    case 7
                        part1='Rank Invariant';
                    case 8
                        part1='No Normalization';
                    otherwise
                        part1='Externally Normalized';
                end
                for i=1:length(m)
                    titres{i,1}=['Non-normalized ratio distribution for arrays of condition ',...
                                 strrep(whichconditions{i},'_','-')];
                    titres{i,2}={['Normalized ratio distribution for arrays of condition ',...
                                  strrep(whichconditions{i},'_','-')];...
                                 ['Normalization : ',part1]};
                end
                for i=1:length(m)
                    lograt=cell2mat(DataCellNormLo{1}{m(i)});
                    logratnorm=cell2mat(DataCellNormLo{2}{m(i)});
                    leg=exprp{i};
                    plotDistribConditionBeforeAfter(lograt,logratnorm,suptitres{i},leg,titres(i,:))
                end
            end
            
        end
        
    end
    
catch
    errmsg={'An unexpected error occured during the plotting process.',...
            'Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function plotsBoxplot_Callback(hObject, eventdata, handles)

% Get current analysis selection index
ind=handles.currentSelectionIndex;
% Has normalization been performed
normpfmd=false;
% Has any form of ratio been already calculated?
ratioexists=false;

% Check if normalization has been performed
if isfield(handles,'analysisInfo')
    if isfield(handles.analysisInfo,'DataCellNormLo')
        if ~isempty(handles.analysisInfo(ind).DataCellNormLo)
            % Indicate normalization performed
            normpfmd=true;
        else
            % Indicate normalization not performed
            normpfmd=false;
        end
    end
    if isfield(handles.analysisInfo,'exptab')
        if ~isempty(handles.analysisInfo(ind).exptab)
            % Indicate ratio calculated
            ratioexists=true;
        else
            % Indicate ratio not calculated
            ratioexists=false;
        end
    end
end

% Create contents for the Boxplot Editor array listbox
if isfield(handles,'analysisInfo')
    if isfield(handles.analysisInfo,'exprp')
        if ~isempty(handles.analysisInfo(ind).exprp)
            index=0;
            conditioncontents=handles.analysisInfo(ind).conditionNames;
            for i=1:handles.analysisInfo(ind).numberOfConditions
                for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                    index=index+1;
                    arraycontents{index}=handles.analysisInfo(ind).exprp{i}{j};
                end
            end
        end
    end
else
    index=0;
    conditioncontents=handles.experimentInfo.conditionNames;
    for i=1:handles.experimentInfo.numberOfConditions
        for j=1:max(size(handles.experimentInfo.exprp{i}))
            index=index+1;
            arraycontents{index}=handles.experimentInfo.exprp{i}{j};
        end
    end
end

% Proceed
% try
    
    % Get ratio distribution plot parameters
    [whicharrays,whichconditions,sliorcon,plotwhat,plotwhatName,before,after,beforeafter,...
     beforeTitles,afterTitles,beforeafterTitles,cancel]=...
        BoxplotEditor(arraycontents,conditioncontents,normpfmd,...
                      handles.experimentInfo.imgsw,ratioexists);
    
    if ~cancel
        
        % Locate the arrays
        if normpfmd
            t=handles.analysisInfo(ind).numberOfConditions;
            exprp=handles.analysisInfo(ind).exprp;
            condnams=handles.analysisInfo(ind).conditionNames;
            DataCellNormLo=handles.analysisInfo(ind).DataCellNormLo;
            if before
                datagiven=DataCellNormLo{1}; % Log ratio
            end 
        else
            t=handles.experimentInfo.numberOfConditions;
            exprp=handles.experimentInfo.exprp;
            condnams=handles.experimentInfo.conditionNames;
            if isfield(handles,'analysisInfo')
                if isfield(handles.analysisInfo,'exptab') && ~isempty(handles.analysisInfo(ind).exptab)
                    % We can safely declare datagiven using exptab since BoxplotEditor will not
                    % allow ploting ratio choice if any ratio has not been calculated, thus
                    % datagiven variable will always exist (in this case)
                    for i=1:t
                        for j=1:max(size(exprp{i}))
                            datagiven{i}{j}=handles.analysisInfo(ind).exptab{i}{j}(:,3);
                        end
                    end
                end
            else
                for i=1:t
                    for j=1:max(size(exprp{i}))
                        datagiven{i}{j}=[];
                    end
                end
            end
        end

        if sliorcon==1 % Plot for each slide separetely
            
            % Find the arrays from the main list
            m=[]; n=[];
            for k=1:length(whicharrays)
                for i=1:t
                    for j=1:max(size(exprp{i}))
                        if strcmp(whicharrays{k},exprp{i}{j})
                            m=[m,i];
                            n=[n,j];
                        end
                    end
                end
            end
            
            % Plot before
            if before
                % Create titles
                if isempty(beforeTitles)
                    if strcmpi(plotwhatName,'ratio')
                        titre=['Un-normalized boxplot for ',plotwhatName];
                    else
                        titre=['Boxplot for ',plotwhatName];
                    end
                else
                    titre=beforeTitles;
                end
                % Create data
                data=createBoxplotData(plotwhat,datagiven,handles.datstruct,m,n);
                figure;
                maboxplot(data,whicharrays)
                title(titre,'Fontsize',11,'FontWeight','bold')
                set(gca,'FontSize',9,'FontWeight','bold')
                ylabel(plotwhatName)
                % Rotate the x-axis labels if everything very long. Subfunction decides.
                rotateIfLong(whicharrays);
            end
            
            % Plot after
            if after
                % Create titles
                if isempty(afterTitles)
                    titre=['Normalized ratio boxplot for ',plotwhatName];
                else
                    titre=afterTitles;
                end
                % Create data
                data=cell(1,length(m));
                for i=1:length(m)
                    data{i}=DataCellNormLo{2}{m(i)}{n(i)};
                end
                data=cell2mat(data);
                figure;
                maboxplot(data,whicharrays)
                title(titre,'Fontsize',11,'FontWeight','bold')
                set(gca,'FontSize',9,'FontWeight','bold')
                ylabel('Ratio')
                % Rotate the x-axis labels if everything very long. Subfunction decides.
                rotateIfLong(whicharrays);
            end
            
            % Plot before and after
            if beforeafter
                % Create titles
                if isempty(beforeafterTitles)
                    titre=['Non-normalized and normalized ratio boxplot for ',plotwhatName];
                else
                    titre=beforeafterTitles;
                end
                % Create data
                titres{1}=['Non-normalized ratio boxplot for ',plotwhatName];
                titres{2}=['Normalized ratio boxplot for ',plotwhatName];
                datanonorm=cell(1,length(m));
                datanorm=cell(1,length(m));
                for i=1:length(m)
                    datanonorm{i}=DataCellNormLo{1}{m(i)}{n(i)};
                    datanorm{i}=DataCellNormLo{2}{m(i)}{n(i)};
                end
                datanonorm=cell2mat(datanonorm);
                datanorm=cell2mat(datanorm);
                figure;
                % Before
                subplot(2,1,1)
                maboxplot(datanonorm,whicharrays)
                title(titres{1},'Fontsize',11,'FontWeight','bold')
                set(gca,'FontSize',9,'FontWeight','bold')
                ylabel('Ratio')
                % Rotate the x-axis labels if everything very long. Subfunction decides.
                rotateIfLong(whicharrays);
                % After
                subplot(2,1,2)
                maboxplot(datanorm,whicharrays)
                title(titres{2},'Fontsize',11,'FontWeight','bold')
                set(gca,'FontSize',9,'FontWeight','bold')
                ylabel('Ratio')
                % Rotate the x-axis labels if everything very long. Subfunction decides.
                rotateIfLong(whicharrays);
                set(gcf,'Name',char(titre))
            end
            
        end
        
        if sliorcon==2 % Plot for each condition
            
            % Find the conditions from the main list
            if ~iscell(whichconditions)
                whichconditions={whichconditions};
            end
            m=zeros(length(whichconditions),1);
            for k=1:length(whichconditions)
                for i=1:t
                    if strcmp(whichconditions{k},condnams{i})
                        m(k)=i;
                    end
                end
            end
            % Find the corresponding arrays in order to give column names
            colnames=[];
            for i=1:length(m)
                colnames=[colnames,exprp{m(i)}];
            end
            
            % Plot before
            if before
                if isempty(beforeTitles)
                    if strcmpi(plotwhatName,'ratio')
                        titre=['Un-normalized ',plotwhatName,' boxplot'];
                    else
                        titre=['Boxplot for ',plotwhatName];
                    end
                else
                    titre=beforeTitles;
                end
                % Create data
                data=createBoxplotData(plotwhat,datagiven,handles.datstruct,m);
                figure;
                maboxplot(data,colnames)
                title(titre,'Fontsize',11,'FontWeight','bold')
                set(gca,'FontSize',9,'FontWeight','bold')
                ylabel(plotwhatName) 
                % Rotate the x-axis labels if everything very long. Subfunction decides.
                rotateIfLong(colnames);
            end
            
            % Plot after
            if after
                if isempty(afterTitles)
                    titre='Normalized ratio boxplot';
                else
                    titre=afterTitles;
                end
                % Create data
                data=cell(1,length(m));
                for i=1:length(m)
                    data{i}=cell2mat(DataCellNormLo{2}{m(i)});
                end
                data=cell2mat(data);
                figure;
                maboxplot(data,colnames)
                title(titre,'Fontsize',11,'FontWeight','bold')
                set(gca,'FontSize',9,'FontWeight','bold')
                ylabel('Ratio')
                % Rotate the x-axis labels if everything very long. Subfunction decides.
                rotateIfLong(colnames);
            end
            
            % Plot before and after
            if beforeafter
                % Create titles
                if isempty(beforeafterTitles)
                    titre=['Non-normalized and normalized ratio boxplot for ',plotwhatName];
                else
                    titre=beforeafterTitles;
                end
                % Create data
                titres{1}=['Non-normalized ratio boxplot for ',plotwhatName];
                titres{2}=['Normalized ratio boxplot for ',plotwhatName];
                datanonorm=cell(1,length(m));
                datanorm=cell(1,length(m));
                for i=1:length(m)
                    datanonorm{i}=cell2mat(DataCellNormLo{1}{m(i)});
                    datanorm{i}=cell2mat(DataCellNormLo{2}{m(i)});
                end
                datanonorm=cell2mat(datanonorm);
                datanorm=cell2mat(datanorm);
                figure;
                % Before
                subplot(2,1,1)
                maboxplot(datanonorm,colnames)
                title(titres{1},'Fontsize',11,'FontWeight','bold')
                set(gca,'FontSize',9,'FontWeight','bold')
                ylabel('Ratio')
                % Rotate the x-axis labels if everything very long. Subfunction decides.
                rotateIfLong(colnames);
                % After
                subplot(2,1,2)
                maboxplot(datanorm,colnames)
                title(titres{2},'Fontsize',11,'FontWeight','bold')
                set(gca,'FontSize',9,'FontWeight','bold')
                ylabel('Ratio')
                % Rotate the x-axis labels if everything very long. Subfunction decides.
                rotateIfLong(colnames);
                set(gcf,'Name',char(titre))
            end
            
        end
        
    end
        
% catch
%     errmsg={'An unexpected error occured during the plotting process.',...
%             'Please review your settings and check your files.',...
%             lasterr};
%     uiwait(errordlg(errmsg,'Error'));
% end
                        

% --------------------------------------------------------------------
function plotsVolcano_Callback(hObject, eventdata, handles)

% Get current analysis selection index
ind=handles.currentSelectionIndex;
noconds=handles.analysisInfo(ind).numberOfConditions;
conds=handles.analysisInfo(ind).conditionNames;
DataCellFiltered=handles.analysisInfo(ind).DataCellFiltered;

% Plot
try
    
    [effect,dispvalLine,disFCLine,pvalCut,FCCut,titre,...
     control,controlName,treated,treatedName,cancel]=...
        VolcanoPlotEditor(noconds,conds);
    
    if ~cancel
        pval=handles.analysisInfo(ind).DataCellStat{4}(:,2);
        if noconds==1
            logcontrol=[];
            logtreated=nanmean(DataCellFiltered{8}{1},2);
            conds=char(conds);
        else
            logcontrol=nanmean(DataCellFiltered{8}{1+control},2);
            logtreated=nanmean(DataCellFiltered{8}{1+treated},2);
            conds={treatedName,controlName};
        end
        labels=handles.attributes.gnID;
    
        if isempty(titre)
            if noconds==1
                titre=['Volcano Plot for ',treatedName];
            elseif noconds==2
                titre=['Volcano Plot for ',controlName,' vs ',treatedName];
            end
        end

        plotVolcano(logtreated,logcontrol,pval,...
                    'DisplayPLine',dispvalLine,...
                    'DisplayFCLine',disFCLine,...
                    'PValue',pvalCut,...
                    'FoldChange',FCCut,...
                    'Title',titre,...
                    'Labels',labels,...
                    'Effect',effect,...
                    'Names',conds,...
                    'Count',randomint(1,1,[1 10000]))
    end
        
catch
    errmsg={'An unexpected error occured during the plotting process.',...
            'Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end
        

% --------------------------------------------------------------------
function plotsExprProfile_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;

% Create arguments for the Expression Profile Editor. We assume that DataCellFiltered
% and DataCellStat exist or else the corresponding menu is disabled
allinds=1:length(handles.attributes.gnID);
allinds=allinds';
%sps=allinds(handles.analysisInfo(ind).DataCellFiltered{3});
sps=allinds;
if isfield(handles.analysisInfo(ind),'DataCellStat') && ~isempty(handles.analysisInfo(ind).DataCellStat)
    statsps=allinds(handles.analysisInfo(ind).DataCellStat{3});
else
    statsps=[];
end
if isfield(handles.analysisInfo(ind),'FinalTable') && ~isempty(handles.analysisInfo(ind).FinalTable)
    clusters=handles.analysisInfo(ind).Clusters;
    clustersview=unique(sort(handles.analysisInfo(ind).Clusters));
    clustersview=mat2cell(clustersview,ones(1,length(clustersview)));
    % Determine the type of clustering
    if strcmpi(handles.Project.Analysis(ind).Clustering.Algorithm,'Hierarchical')
        ishier=true;
    else
        ishier=false;
    end
else
    clusters=[];
    clustersview='';
    ishier=false;
end

try

    % Get parameters
    [outelem,outelemind,plotwhat,centro,centrotoo,multi,diffcol,showleg,plotmr,titre,cancel]=...
        ExpressionProfileEditor(handles.attributes.gnID,sps,statsps,clustersview,ishier);

    if ~cancel

        % Create title in case of empty
        if isempty(titre)
            titisempty=true;
            switch plotwhat
                case 1
                    part1='All Genes';
                case 2
                    part1='DE Genes';
                case 3
                    part1='Gene Clusters';
            end
            titre=['Expression Profile - ',part1];
        else
            titisempty=false;
        end

        % Prepare to plot
        switch plotwhat
            
            case 1 % All genes
                % Take the normalized log2 ratios
                temp=handles.analysisInfo(ind).DataCellNormLo{2};
                tempcell=cell(1,length(temp));
                if plotmr==1 % Means
                    for i=1:length(temp)
                        tempcell{i}=nanmean(cell2mat(temp{i}),2);
                    end
                    tempmat=cell2mat(tempcell);
                    plotmat=tempmat(outelemind,:);
                    group=handles.analysisInfo(ind).conditionNames;
                    xax=1:length(group);
                elseif plotmr==2 % Replicates
                    for i=1:length(temp)
                        tempcell{i}=cell2mat(temp{i});
                    end
                    tempmat=cell2mat(tempcell);
                    plotmat=tempmat(outelemind,:);
                    cellSize=size(tempcell);
                    groupInit=handles.analysisInfo(ind).conditionNames;
                    repCol=[];
                    for index=1:cellSize(2)
                        repSize=size(tempcell{index});
                        repCol=[repCol,repSize(2)];
                    end
                    group=cell(0);
                    for i=1:cellSize(2)
                        for j=1:repCol(i)
                            group=[group,strcat(groupInit{i},'_',num2str(j))];
                        end
                    end
                    xax=1:length(group);
                end
                titre=[titre,' (',num2str(size(plotmat,1)),' genes)'];
                plotExprProfile(xax,plotmat,'Labels',outelem,...
                                            'Names',group,...
                                            'Legend',showleg,...
                                            'Title',titre,...
                                            'MultiColor',diffcol,...
                                            'Centroid',centrotoo)
                % Rotate the x-axis labels if everything very long. Subfunction decides.
                rotateIfLong(group);
                
                case 2 % DE genes                   
                    if plotmr==1 % Means
                        plotmat=handles.analysisInfo(ind).DataCellStat{1}(outelemind,3:end);
                        group=handles.analysisInfo(ind).DataCellStat{6};
                        xax=1:length(group);
                    elseif plotmr==2 % Replicates
                        plotmat=cell2mat(handles.analysisInfo(ind).DataCellStat{5});
                        plotmat=plotmat(outelemind,:);
                        cellSize=size(handles.analysisInfo(ind).DataCellStat{5});
                        groupInit=handles.analysisInfo(ind).conditionNames;
                        repCol=[];
                        for index=1:cellSize(2)
                            repSize=size(handles.analysisInfo(ind).DataCellStat{5}{index});
                            repCol=[repCol,repSize(2)];
                        end
                        group=cell(0);
                        for i=1:cellSize(2)
                            for j=1:repCol(i)
                                group=[group,strcat(groupInit{i},'_',num2str(j))];
                            end
                        end
                        xax=1:length(group);
                    end
                    titre=[titre,' (',num2str(size(plotmat,1)),' genes)'];
                    plotExprProfile(xax,plotmat,'Labels',outelem,...
                                                'Names',group,...
                                                'Legend',showleg,...
                                                'Title',titre,...
                                                'MultiColor',diffcol,...
                                                'Centroid',centrotoo)
                    % Rotate the x-axis labels if everything very long. Subfunction decides.
                    rotateIfLong(group);
                    
            case 3 % Clusters
                clusplot=outelemind;
                pind=handles.analysisInfo(ind).PIndex;
                gnam=handles.analysisInfo(ind).DataCellStat{2}(pind);
                if plotmr==1 % Means
                    statmat=handles.analysisInfo(ind).DataCellStat{1}(pind,3:end);
                    group=handles.analysisInfo(ind).DataCellStat{6};
                    xax=1:length(group);
                elseif plotmr==2 % Replicates
                    statmat=cell2mat(handles.analysisInfo(ind).DataCellStat{5});
                    statmat=statmat(pind,:);
                    cellSize=size(handles.analysisInfo(ind).DataCellStat{5});
                    groupInit=handles.analysisInfo(ind).DataCellStat{6};
                    repCol=[];
                    for index=1:cellSize(2)
                        repSize=size(handles.analysisInfo(ind).DataCellStat{5}{index});
                        repCol=[repCol,repSize(2)];
                    end
                    group=cell(0);
                    for i=1:cellSize(2)
                        for j=1:repCol(i)
                            group=[group,strcat(groupInit{i},'_',num2str(j))];
                        end
                    end
                    xax=1:length(group);
                end
                if centro && isfield(handles.analysisInfo(ind),'Centroids') && ...
                    ~isempty(handles.analysisInfo(ind).Centroids)
                    % Reconstruct statmat in case of plotting mean centroids
                    % Wrong to check for means or replicates, centroids already calculated
                    %if plotmr==1
                    %    cellSize=size(handles.analysisInfo(ind).DataCellStat{5});
                    %    repCol=[];
                    %    for index=1:cellSize(2)
                    %        repSize=size(handles.analysisInfo(ind).DataCellStat{5}{index});
                    %        repCol=[repCol,repSize(2)];
                    %    end
                    %    meancents=mat2cell(handles.analysisInfo(ind).Centroids,...
                    %                       size(handles.analysisInfo(ind).Centroids,1),...
                    %                       repCol);
                    %    for i=1:length(meancents)
                    %        meancents{i}=mean(meancents{i},2);
                    %    end
                    %    statmat=cell2mat(meancents);
                    %else
                    statmat=handles.analysisInfo(ind).Centroids;
                    xax=1:size(statmat,2);
                    if length(xax)<length(group)
                        group=groupInit;
                    end
                    %end
                    if multi
                        % Find optimal grid
                        n=length(clusplot);
                        [m,k]=findOptGrid(n);
                        [l,b,w,h]=createGrid(m,k);
                        
                        figure
                        for c=1:length(clusplot)
                            subplot('Position',[l(c),b(c),w(c),h(c)])
                            plotmat=statmat(clusplot(c),:);
                            if length(clusplot)<=9
                                if titisempty
                                    temptitre=[titre,' - Centroid ',num2str(clusplot(c))];
                                else
                                    temptitre=titre{c};
                                end
                            else
                                temptitre='';
                            end
                            plotExprProfileMulti(xax,plotmat,'Labels',{['Centroid ',num2str(clusplot(c))]},...
                                                             'Names',group,...
                                                             'Legend',showleg,...
                                                             'Title',temptitre,...
                                                             'MultiColor',diffcol)
                            % Rotate the x-axis labels if everything very long. Subfunction decides.
                            rotateIfLong(group);
                        end
                        
                    else
                        for c=1:length(clusplot)
                            plotmat=statmat(clusplot(c),:);
                            if titisempty
                                temptitre=[titre,' - Centroid ',num2str(clusplot(c))];
                            else
                                temptitre=titre{c};
                            end
                            plotExprProfile(xax,plotmat,'Labels',{['Centroid ',num2str(clusplot(c))]},...
                                                        'Names',group,...
                                                        'Legend',showleg,...
                                                        'Title',temptitre,...
                                                        'MultiColor',diffcol)
                            % Rotate the x-axis labels if everything very long. Subfunction decides.
                            rotateIfLong(group);
                        end
                    end
                else
                    if multi
                        n=length(clusplot);
                        [m,k]=findOptGrid(n);
                        [l,b,w,h]=createGrid(m,k);
                        
                        figure
                        for c=1:length(clusplot)
                            subplot('Position',[l(c),b(c),w(c),h(c)])
                            plotmat=statmat((clusters==clusplot(c)),:);
                            if length(clusplot)<=9
                                if titisempty
                                    temptitre=[titre,' - Cluster ',num2str(clusplot(c)),...
                                               ' (',num2str(size(plotmat,1)),' genes)'];
                                else
                                    temptitre=titre{c};
                                end
                            else
                                temptitre='';
                            end
                            plotExprProfileMulti(xax,plotmat,'Labels',gnam(clusters==clusplot(c)),...
                                                             'Names',group,...
                                                             'Legend',showleg,...
                                                             'Title',temptitre,...
                                                             'MultiColor',diffcol,...
                                                             'Centroid',centrotoo)
                            % Rotate the x-axis labels if everything very long. Subfunction decides.
                            rotateIfLong(group);
                        end
                    else                           
                        for c=1:length(clusplot)
                            plotmat=statmat((clusters==clusplot(c)),:);
                            if titisempty
                                temptitre=[titre,' - Cluster ',num2str(clusplot(c)),...
                                           ' (',num2str(size(plotmat,1)),' genes)'];
                            else
                                temptitre=titre{c};
                            end
                            plotExprProfile(xax,plotmat,'Labels',gnam(clusters==clusplot(c)),...
                                                        'Names',group,...
                                                        'Legend',showleg,...
                                                        'Title',temptitre,...
                                                        'MultiColor',diffcol,...
                                                        'Centroid',centrotoo)
                            % Rotate the x-axis labels if everything very long. Subfunction decides.
                            rotateIfLong(group);
                        end
                    end
                end
                
        end
        
    end
    
catch
    errmsg={'An unexpected error occured during the plotting process.',...
            'Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end
        

%%%%%%%%%%%%%%%%%%% AFFYMETRIX PLOTS %%%%%%%%%%%%%%%%%%%

function plotsMAAffy_Callback(hObject, eventdata, handles)

% Get current analysis selection index
ind=handles.currentSelectionIndex;

% Create contents of the MA Plots Editor array listbox
if isfield(handles,'analysisInfo')
    if isfield(handles.analysisInfo,'DataCellNormLo') && ~isempty(handles.analysisInfo(ind).DataCellNormLo)
        index=1;
        for i=1:handles.analysisInfo(ind).numberOfConditions
            for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                contents{index}=handles.analysisInfo(ind).exprp{i}{j};
                index=index+1;
            end
        end
    else
        uiwait(warndlg({'Normalization has not yet been performed for',...
                       ['Analysis ',num2str(ind),'. Normalize data and try again']},...
                       'Warning'));
        return
    end
end

% Proceed
try
    
    % Get Affy MA plot parameters
    [wharrays,vsarrays,type,plotwhat,plotwhatName,titles,displine,linecut,cancel]=...
        MAPlotEditorAffy(contents,handles.experimentInfo.imgsw);
    
    if ~cancel
        
        % Locate the arrays
        t=handles.analysisInfo(ind).numberOfConditions;
        exprp=handles.analysisInfo(ind).exprp;
        exptab=handles.analysisInfo(ind).exptab;
        DataCellNormLo=handles.analysisInfo(ind).DataCellNormLo;
        norminfo=DataCellNormLo{5};

        % Find the arrays from the main or the MAEditor list
        m1=[]; n1=[];
        m2=[]; n2=[];
        for k=1:length(wharrays)
            for i=1:t
                for j=1:max(size(exprp{i}))
                    if strcmp(wharrays{k},exprp{i}{j})
                        m1=[m1,i];
                        n1=[n1,j];
                    end
                end
            end
        end
        if ~isempty(vsarrays)
            for k=1:length(vsarrays)
                for i=1:t
                    for j=1:max(size(exprp{i}))
                        if strcmp(vsarrays{k},exprp{i}{j})
                            m2=[m2,i];
                            n2=[n2,j];
                        end
                    end
                end
            end
        end

        switch type
            
            case 'ava'

                if isempty(titles)
                    titres=cell(length(wharrays),1);
                    switch plotwhat
                        case 105
                            part1=['Background adjustment: ',norminfo{1}];
                        case 106
                            part1=['Background adjustment: ',norminfo{1},', ',...
                                   'Normalization: ',norminfo{2}];
                        case 107
                            part1=['Summarization: ',norminfo{3}];
                        case 108
                            part1=['Background adjustment: ',norminfo{1},', ',...
                                   'Summarization: ',norminfo{3}];
                        case 109
                            part1=['Background adjustment: ',norminfo{1},', ',...
                                   'Normalization: ',norminfo{2},', ',...
                                   'Summarization: ',norminfo{3}];
                        case 202
                            part1=['Normalization: ',norminfo{1}];
                        otherwise
                            part1='';
                    end
                    for i=1:length(m1)
                        titres{i}={[plotwhatName,' MA plot for arrays ',...
                                   exprp{m1(i)}{n1(i)},' vs ',exprp{m2(i)}{n2(i)}];part1};
                    end
                else
                    titres=titles;
                end
                
                if ismember(plotwhat,101:106)
                    labels='';
                else
                    labels=handles.attributes.gnID;
                end
                % For proper plotting inside plotMANorm
                opts.type=plotwhat;
                opts.scale=norminfo{4};
                for i=1:length(m1)
                    xdata=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m1(i),n1(i));
                    ydata=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m2(i),n2(i));
                    plotMANorm(xdata,ydata,...
                               'Title',titres{i},...
                               'DisplayFCLine',displine,...
                               'FoldChange',linecut,...
                               'Labels',labels,...
                               'ForAffy',opts,...
                               'Count',randomint(1,1,[1 10000]))
                end
                
            case 'avm'
                
                if isempty(titles)
                    titres=cell(length(wharrays),1);
                    switch plotwhat
                        case 105
                            part1=['Background adjustment: ',norminfo{1}];
                        case 106
                            part1=['Background adjustment: ',norminfo{1},', ',...
                                   'Normalization: ',norminfo{2}];
                        case 107
                            part1=['Summarization: ',norminfo{3}];
                        case 108
                            part1=['Background adjustment: ',norminfo{1},', ',...
                                   'Summarization: ',norminfo{3}];
                        case 109
                            part1=['Background adjustment: ',norminfo{1},', ',...
                                   'Normalization: ',norminfo{2},', ',...
                                   'Summarization: ',norminfo{3}];
                        case 203
                            part1=['Normalization: ',norminfo{1}];
                        otherwise
                            part1='';
                    end
                    for i=1:length(m1)
                        titres{i}={[plotwhatName,' MA plot for array ',...
                                   exprp{m1(i)}{n1(i)},' vs median of all'];part1};
                    end
                else
                    titres=titles;
                end
                
                if ismember(plotwhat,101:106)
                    labels='';
                else
                    labels=handles.attributes.gnID;
                end
                % For proper plotting inside plotMANorm
                opts.type=plotwhat;
                opts.scale=norminfo{4};
                % Pre-allocate... if it is to run out of memory, at least to know
                if ismember(plotwhat,103:106)
                    datamatrix=zeros(length(exptab{1}{1}(:,1)),length(vsarrays));
                else
                    datamatrix=zeros(length(DataCellNormLo{1}{1}{1}),length(vsarrays));
                end
                for i=1:length(m2)
                    datamatrix(:,i)=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m2(i),n2(i));
                end
                med=nanmedian(datamatrix,2);
                for i=1:length(m1)
                    xdata=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m1(i),n1(i));
                    plotMANorm(xdata,med,...
                               'Title',titres{i},...
                               'DisplayFCLine',displine,...
                               'FoldChange',linecut,...
                               'Labels',labels,...
                               'ForAffy',opts,...
                               'Count',randomint(1,1,[1 10000]))
                end
                
                case 'maxy'
                    switch plotwhat
                        case 105
                            moreinfo={['Background adjustment: ',norminfo{1}]};
                        case 106
                            moreinfo={['Background adjustment: ',norminfo{1}];...
                                      ['Normalization: ',norminfo{2}]};
                        case 107
                            moreinfo={['Summarization: ',norminfo{3}]};
                        case 108
                            moreinfo={['Background adjustment: ',norminfo{1}];...
                                      ['Summarization: ',norminfo{3}]};
                        case 109
                            moreinfo={['Background adjustment: ',norminfo{1}];...
                                      ['Normalization: ',norminfo{2}];...
                                      ['Summarization: ',norminfo{3}]};
                        case 203
                            part1=['Normalization: ',norminfo{1}];
                        otherwise
                            moreinfo='';
                    end
                    moreinfo=char(moreinfo);

                    % For proper plotting inside plotMAXY
                    opts.type=plotwhat;
                    opts.scale=norminfo{4};
                    % Pre-allocate... if it is to run out of memory, at least to know
                    if ismember(plotwhat,103:106)
                        datamatrix=zeros(length(exptab{1}{1}(:,1)),length(vsarrays));
                    else
                        datamatrix=zeros(length(DataCellNormLo{1}{1}{1}),length(vsarrays));
                    end
                    for i=1:length(m1)
                        datamatrix(:,i)=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m1(i),n1(i));
                    end
                    plotMAXY(datamatrix,opts,wharrays,moreinfo);
        end


    end
     
catch
    errmsg={'An unexpected error occured during the plotting process.',...
        'Please review your settings and check your files.',...
        lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


function plotsSlideDistribAffy_Callback(hObject, eventdata, handles)

% Get current analysis selection index
ind=handles.currentSelectionIndex;

% Create contents of the MA Plots Editor array listbox
if isfield(handles,'analysisInfo')
    if isfield(handles.analysisInfo,'DataCellNormLo') && ~isempty(handles.analysisInfo(ind).DataCellNormLo)
        index=1;
        for i=1:handles.analysisInfo(ind).numberOfConditions
            for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                contents{index}=handles.analysisInfo(ind).exprp{i}{j};
                index=index+1;
            end
        end
    else
        uiwait(warndlg({'Normalization has not yet been performed for',...
                       ['Analysis ',num2str(ind),'. Normalize data and try again']},...
                       'Warning'));
        return
    end
end

% Proceed
try
    
    % Get plot parameters
    [whicharrays,single,plotwhat,plotwhatName,titles,logscale,cancel]=...
        SlideDistributionEditorAffy(contents,handles.experimentInfo.imgsw);
    
    if ~cancel
        
        % Locate the arrays
        t=handles.analysisInfo(ind).numberOfConditions;
        exprp=handles.analysisInfo(ind).exprp;
        exptab=handles.analysisInfo(ind).exptab;
        DataCellNormLo=handles.analysisInfo(ind).DataCellNormLo;
        norminfo=DataCellNormLo{5};

        % Find the arrays from the main or the MAEditor list
        m=[]; n=[];
        for k=1:length(whicharrays)
            for i=1:t
                for j=1:max(size(exprp{i}))
                    if strcmp(whicharrays{k},exprp{i}{j})
                        m=[m,i];
                        n=[n,j];
                    end
                end
            end
        end
        
        if single
            
            if isempty(titles)
                switch plotwhat
                    case 105
                        part1=['Background adjustment: ',norminfo{1}];
                    case 106
                        part1=['Background adjustment: ',norminfo{1},', ',...
                               'Normalization: ',norminfo{2}];
                    case 107
                        part1=['Summarization: ',norminfo{3}];
                    case 108
                        part1=['Background adjustment: ',norminfo{1},', ',...
                               'Summarization: ',norminfo{3}];
                    case 109
                        part1=['Background adjustment: ',norminfo{1},', ',...
                               'Normalization: ',norminfo{2},', ',...
                               'Summarization: ',norminfo{3}];
                    case 203
                            part1=['Normalization: ',norminfo{1}];
                    otherwise
                        part1='';
                end
                titres={[plotwhatName,' distribution'];part1};
            else
                titres=titles;
            end

            % Pre-allocate... if it is to run out of memory, at least to know
            if ismember(plotwhat,103:106)
                datamatrix=zeros(length(exptab{1}{1}(:,1)),length(whicharrays));
            else
                datamatrix=zeros(length(DataCellNormLo{1}{1}{1}),length(whicharrays));
            end
            for i=1:length(m)
                datamatrix(:,i)=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m(i),n(i));
            end
            if logscale
                datamatrix=log2(datamatrix);
            end
            plotDistribArrayAffy(datamatrix,plotwhatName,titres,whicharrays,single)
            
        else
        
            if isempty(titles)
                titres=cell(length(whicharrays),1);
                switch plotwhat
                    case 105
                        part1=['Background adjustment: ',norminfo{1}];
                    case 106
                        part1=['Background adjustment: ',norminfo{1},', ',...
                               'Normalization: ',norminfo{2}];
                    case 107
                        part1=['Summarization: ',norminfo{3}];
                    case 108
                        part1=['Background adjustment: ',norminfo{1},', ',...
                               'Summarization: ',norminfo{3}];
                    case 109
                        part1=['Background adjustment: ',norminfo{1},', ',...
                               'Normalization: ',norminfo{2},', ',...
                               'Summarization: ',norminfo{3}];
                    case 203
                            part1=['Normalization: ',norminfo{1}];
                    otherwise
                        part1='';
                end
                for i=1:length(m)
                    titres{i}={[plotwhatName,' distribution'];part1};
                end
            else
                titres=titles;
            end
            
            % Pre-allocate... if it is to run out of memory, at least to know
            if ismember(plotwhat,103:106)
                datamatrix=zeros(length(exptab{1}{1}(:,1)),length(whicharrays));
            else
                datamatrix=zeros(length(DataCellNormLo{1}{1}{1}),length(whicharrays));
            end
            for i=1:length(m)
                datamatrix(:,i)=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m(i),n(i));
            end
            if logscale
                datamatrix=log2(datamatrix);
            end
            plotDistribArrayAffy(datamatrix,plotwhatName,titres,'',single)
        end
            
    end
     
catch
    errmsg={'An unexpected error occured during the plotting process.',...
        'Please review your settings and check your files.',...
        lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


function plotsBoxplotAffy_Callback(hObject, eventdata, handles)

% Get current analysis selection index
ind=handles.currentSelectionIndex;

% Create contents of the MA Plots Editor array listbox
if isfield(handles,'analysisInfo')
    if isfield(handles.analysisInfo,'DataCellNormLo') && ~isempty(handles.analysisInfo(ind).DataCellNormLo)
        index=1;
        for i=1:handles.analysisInfo(ind).numberOfConditions
            for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                contents{index}=handles.analysisInfo(ind).exprp{i}{j};
                index=index+1;
            end
        end
    else
        uiwait(warndlg({'Normalization has not yet been performed for',...
                       ['Analysis ',num2str(ind),'. Normalize data and try again']},...
                       'Warning'));
        return
    end
end

% Proceed
try
    
    % Get plot parameters
    [whicharrays,plotwhat,plotwhatName,titles,logscale,cancel]=...
        BoxplotEditorAffy(contents,handles.experimentInfo.imgsw);
    
    if ~cancel
        
        % Locate the arrays
        t=handles.analysisInfo(ind).numberOfConditions;
        exprp=handles.analysisInfo(ind).exprp;
        exptab=handles.analysisInfo(ind).exptab;
        DataCellNormLo=handles.analysisInfo(ind).DataCellNormLo;
        norminfo=DataCellNormLo{5};

        % Find the arrays from the main or the MAEditor list
        m=[]; n=[];
        for k=1:length(whicharrays)
            for i=1:t
                for j=1:max(size(exprp{i}))
                    if strcmp(whicharrays{k},exprp{i}{j})
                        m=[m,i];
                        n=[n,j];
                    end
                end
            end
        end
            
        if isempty(titles)
            switch plotwhat
                case 105
                    part1=['Background adjustment: ',norminfo{1}];
                case 106
                    part1=['Background adjustment: ',norminfo{1},', ',...
                           'Normalization: ',norminfo{2}];
                case 107
                    part1=['Summarization: ',norminfo{3}];
                case 108
                    part1=['Background adjustment: ',norminfo{1},', ',...
                           'Summarization: ',norminfo{3}];
                case 109
                    part1=['Background adjustment: ',norminfo{1},', ',...
                           'Normalization: ',norminfo{2},', ',...
                           'Summarization: ',norminfo{3}];
                case 203
                            part1=['Normalization: ',norminfo{1}];
                otherwise
                    part1='';
            end
            titres={[plotwhatName,' boxplot'];part1};
        else
            titres=titles;
        end

        % Pre-allocate... if it is to run out of memory, at least to know
        if ismember(plotwhat,103:106)
            datamatrix=zeros(length(exptab{1}{1}(:,1)),length(whicharrays));
        else
            datamatrix=zeros(length(DataCellNormLo{1}{1}{1}),length(whicharrays));
        end
        for i=1:length(m)
            datamatrix(:,i)=retrieveArrayData(plotwhat,DataCellNormLo,exptab,handles.datstruct,m(i),n(i));
        end
        if logscale
            datamatrix=log2(datamatrix);
        end
        figure;
        maboxplot(datamatrix,whicharrays)
        title(titres,'Fontsize',11,'FontWeight','bold')
        set(gca,'FontSize',9,'FontWeight','bold')
        ylabel(plotwhatName)
        % Rotate the x-axis labels if everything very long. Subfunction decides.
        rotateIfLong(whicharrays);
            
    end
    
catch
    errmsg={'An unexpected error occured during the plotting process.',...
        'Please review your settings and check your files.',...
        lasterr};
    uiwait(errordlg(errmsg,'Error'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --------------------------------------------------------------------
function tools_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function toolsPCA_Callback(hObject, eventdata, handles)

ind=handles.currentSelectionIndex;

% We suppose that DataCellFiltered and DataCellStat exist else toolsPCA wouldn't
% have been enabled so we skip this check and invoke the PCA options editor
genenames=handles.analysisInfo(ind).DataCellFiltered{4};
geneindices=handles.analysisInfo(ind).DataCellFiltered{3};
alldata=cell2mat(handles.analysisInfo(ind).DataCellFiltered{1});
dedata=cell2mat(handles.analysisInfo(ind).DataCellStat{5});
exprp=handles.analysisInfo(ind).exprp;
count=0;
for i=1:length(exprp)
    count=count+size(exprp{i},2);
end
colnames=cell(1,count);
incr=0;
for i=1:length(exprp)
    for j=1:size(exprp{i},2)
        incr=incr+1;
        colnames{incr}=exprp{i}{j};
    end
end

try
    
    [selgenes,selinds,dowhat,cancel]=PCAEditor(genenames,geneindices);
    
    if ~cancel
        switch dowhat
            case 'select'
                seldata=alldata(selinds,:);
                mapcaplot(seldata,genenames,colnames);
            case 'all'
                mapcaplot(alldata,genenames,colnames);
            case 'de'
                mapcaplot(dedata,handles.analysisInfo(ind).DataCellStat{2},colnames)
        end
    end
    
catch
    errmsg={'An unexpected error occured during PCA calculation.',...
            'Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --------------------------------------------------------------------
function toolsGap_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;

% Find the number of slides for this analysis (in order to place a limit for k in case
% user wants to cluster conditions
maxrep=0;
for i=1:handles.analysisInfo(ind).numberOfConditions
    maxrep=maxrep+max(size(handles.analysisInfo(ind).exprp{i}));
end
% Also calculate a k limit for the number of genes
maxgenes=size(handles.analysisInfo(ind).DataCellStat{1},1);
% ...and get the proper DataCellStat
DataCellStat=handles.analysisInfo(ind).DataCellStat;

% Get parameters
try
    
    [ks,refsize,repeat,algo,algoName,algoargs,refmethod,refmethodName,usesquared,...
     verbose,usewaitbar,showplot,cancel]=GapStatEditor(maxgenes,maxrep);
 
    if ~cancel
 
        % Update main message
        handles.mainmsg=get(handles.mainTextbox,'String');
        line1=['Performing Optimal Cluster Size calculation for Analysis run : ',num2str(ind)];
        line2=['Chosen clustering algorithm : ',algoName,' Clustering'];
        line3=['Number of clusters range : ',num2str(ks)];
        line4=['Reference dataset type : ',refmethod];
        line5=['Size of reference dataset : ',num2str(refsize)];
        line6=['Method repetitions : ',num2str(repeat)];
        handles.mainmsg=[handles.mainmsg;' ';...
            line1;line2;line3;line4;line5;line6;' '];
        set(handles.mainTextbox,'String',handles.mainmsg)
        drawnow;

        if ~usewaitbar
            hh=showinfowindow('Calculating optimal number of clusters. Please wait...');
        end

        % Do not allow other actions during clustering
        [hmenu,hbtn]=disableActive;

        % Perform optimal number of clusters calculation
        bestk=GapStatistic(DataCellStat,ks,'Algorithm',algo,...
                                           'AlgoArgs',algoargs,...
                                           'Reference',refmethod,...
                                           'Refsize',refsize,...
                                           'Repetitions',repeat,...
                                           'ShowPlots',showplot,...
                                           'Verbose',verbose,...
                                           'UseWaitbar',usewaitbar,...
                                           'UseSquared',usesquared);

        % Allow actions again
        enableActive(hmenu,hbtn);
       
        if ~usewaitbar
            set(hh,'CloseRequestFcn','closereq')
            close(hh)
        end
        
        msg={['The optimal number of clusters was found to be ',num2str(bestk),'.'],...
             'You may also perform Gap curve inspections.'};
        uiwait(msgbox(msg,'Result'));
        
    end

catch
    % Allow actions again in the case of routine failure
    enableActive(hmenu,hbtn);
    if ~usewaitbar
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
    end
    errmsg={'An unexpected error occured during optimal number of clusters',...
            'calculation process. Please review your settings.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end



% --------------------------------------------------------------------
function toolsBatch_Callback(hObject, eventdata, handles)

% Menu has been enabled after importing data
if handles.experimentInfo.imgsw==98
    uiwait(helpdlg('The Batch Programmer for Illumina arrays will be soon available!','Info'));
    return;
end
if handles.experimentInfo.imgsw==99
    BatchProgrammerAffy(handles.datstruct,handles.cdfstruct,handles.experimentInfo,handles.Project);
else
    BatchProgrammer(handles.datstruct,handles.experimentInfo,handles.attributes,handles.Project);
end


% --------------------------------------------------------------------
function toolsAnnotator_Callback(hObject, eventdata, handles)

try
    [flist,fann,unidg,unida,anncols,cancel]=AnnotationEditor;
    if ~cancel
        hh=showinfowindow('Annotating gene list(s). Please wait...','Annotating');
        annotateGeneLists(flist,fann,unidg,unida,anncols)
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
    end
catch
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    errmsg={'An error occured during the annotation process. Please check',...
            'the format of the files you provided to the annotation tool.',...
            'If the problem persists please report the following error and ',...
            'if possible a sample of the files you used.',...
            lasterr};
    uiwait(errordlg(errmsg,'Unexpected Error'));
end


function toolsNotes_Callback(hObject, eventdata, handles)

% Get somewhere the previous notes as character vector
oldnotes=char(handles.notes);
oldnotes=oldnotes(:);

% Launch notes editor
handles.notes=NotesEditor(handles.notes);

% Compare new notes with old notes so as to indicate changes
newnotes=char(handles.notes);
newnotes=newnotes(:);
if length(newnotes)~=length(oldnotes)
    handles.somethingChanged=true;
end
guidata(hObject,handles);


% --------------------------------------------------------------------
function toolsOverlap_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function view_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function viewRawImage_Callback(hObject, eventdata, handles)

rawImageButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function viewNormImage_Callback(hObject, eventdata, handles)

normImageButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function viewRawData_Callback(hObject, eventdata, handles)

arrayRawButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function viewNormData_Callback(hObject, eventdata, handles)

% Delete previous image... this GUI must not be full of trash
if isfield(handles,'Image')
    if ishandle(handles.Image.ax)
        delete(handles.Image.ax);
    end
    if ishandle(handles.Image.him)
        delete(handles.Image.him);
    end
    if ishandle(handles.Image.hscroll)
        delete(handles.Image.hscroll);
    end
    if ishandle(handles.Image.hmove)
        delete(handles.Image.hmove);
    end
    if ishandle(handles.Image.hmag)
        delete(handles.Image.hmag);
    end
end

% Delete previous table... this GUI must not be full of trash
if isfield(handles,'Table')
    if ishandle(handles.Table)
        delete(handles.Table);
    end
end

try

    hh=showinfowindow('Loading data table - Please wait...');

    ind=handles.currentSelectionIndex;
    
    if isfield(handles.analysisInfo(ind),'fcinds')
        fcinds=handles.analysisInfo(ind).fcinds;
    else
        fcinds=[];
    end

    % Create data
    if isfield(handles,'analysisInfo')
        if isfield(handles.analysisInfo,'DataCellNormLo')
            if ~isempty(handles.analysisInfo(ind).DataCellNormLo)
                if handles.experimentInfo.imgsw~=99 && handles.experimentInfo.imgsw~=98
                    [headers,data]=createNormListTable(handles.analysisInfo(ind).exprp,...
                                                       handles.analysisInfo(ind).exptab,...
                                                       handles.analysisInfo(ind).DataCellNormLo,...
                                                       handles.attributes.gnID,...
                                                       handles.analysisInfo(ind).conditionNames,...
                                                       fcinds,handles.exportSettings);
                else
                    opts=handles.exportSettings;
                    opts.outtype='excel';
                    [headers,data]=exportNormAffy(handles.analysisInfo(ind).exprp,...
                                                  handles.analysisInfo(ind).DataCellNormLo,...
                                                  handles.attributes.gnID,...
                                                  handles.analysisInfo(ind).conditionNames,...
                                                  fcinds,opts,'foo-bar',false);
                end
            else
                uiwait(errordlg({'Unexpected Error'},'Error'));
                set(hh,'CloseRequestFcn','closereq')
                close(hh)
                return
            end
        end
    end

    % Create table
    handles.Table=uitable('Data',data,...
                          'ColumnNames',headers,...
                          'Parent',handles.ARMADA_main,...
                          'NumRows',size(data,1),...
                          'NumColumns',length(headers));
    set(handles.Table,'Units','normalized',...
                      'Position',[0.293 0.333 0.697 0.655],...
                      'Editable',false);

    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    
    guidata(hObject,handles);
    
catch
    uiwait(errordlg({'Unexpected Error!',lasterr},'Error'));
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
end


% --------------------------------------------------------------------
function viewDEList_Callback(hObject, eventdata, handles)

DEListButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function viewClusterList_Callback(hObject, eventdata, handles)

clusterListButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function viewArrayReport_Callback(hObject, eventdata, handles)

if isempty(handles.datstruct)
    msg={'Insufficient data to create array report. This is probably',...
         'happening because your project includes externally processed',...
         'and imported to ARMADA data.'};
    uiwait(warndlg(msg,'Insufficient data'));
    return
end

contents=get(handles.arrayObjectList,'String');
val=get(handles.arrayObjectList,'Value');
selcont=contents(val);
t=handles.experimentInfo.numberOfConditions;
exprp=handles.experimentInfo.exprp;

% Find the arrays from the list
for i=1:t
    for j=1:max(size(exprp{i}))
        if strcmp(selcont,exprp{i}{j})
            stru=handles.datstruct{i}{j};
        end
    end
end

% Display report
ArrayReport(selcont,stru.Header)


% --------------------------------------------------------------------
function viewAnalysisReport_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;
% Call report creator
AnalysisReport(ind,handles.analysisInfo(ind),handles.Project.Analysis(ind),...
               handles.experimentInfo.imgsw)


% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function helpHelp_Callback(hObject, eventdata, handles)

try
    hlpath=char(textread('andropath.txt','%s','delimiter',''));
    system(hlpath);
    %if s~=0
    %    hlperr={'An error occured while trying to open the help file',...
    %            'Make sure that you have not renamed or moved the',...
    %            'ARMADA help file by mistake, moved the ARMADA',...
    %            'folder to another location, or moved the file named',...
    %            'andropath.txt located in the ARMADA folder',...
    %            lasterr};
    %    uiwait(errordlg(hlperr,'Error Reading Help file','modal'));
    %    return
    %end
catch
    mess={'ARMADA detected that you are using the Help for the',...
          'first time. You will be prompted to select the folder where',...
          'ARMADA is installed. This procedure will take place',...
          'only once.'};
    uiwait(helpdlg(mess,'First time using Help?'));
    hpath=uigetdir('C:\','Please select the folder where ARMADA is installed');
    if hpath==0
        messs={'You can perform this procedure another time. However it',...
               'us recommended to complete it as soon as possible in order',...
               'to be able to use ARMADA''s Help'};
        uiwait(msgbox(messs,'Help','modal'));
        return
    end
    hlpath=fullfile(hpath,'ARMADA user guide.pdf');
    fid=fopen(fullfile(hpath,'andropath.txt'),'w');
    fprintf(fid,'%s',hlpath);
    fclose(fid);
    system(hlpath);
end


% --------------------------------------------------------------------
function helpAbout_Callback(hObject, eventdata, handles)

msg={'ARMADA version 2.3.6',...
     ' ',...
     'Metabolic Engineering and Bioinformatics Group',...
     'Institute of Biological Research and Biotechnology',...
     'National Hellenic Research Foundation',...
     ' ',...
     ' ',...
     'For information about this tool contact with:',...
     'Panagiotis Moulos (pmoulos@eie.gr)'};
uiwait(msgbox(msg,'About...','help'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     END MENU ITEMS                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%               BEGIN CONTEXT MENU ITEMS              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function arrayContext_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function arrayContextImage_Callback(hObject, eventdata, handles)

rawImageButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function arrayContextData_Callback(hObject, eventdata, handles)

arrayRawButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function arrayContextNormImage_Callback(hObject, eventdata, handles)

normImageButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function arrayContextReport_Callback(hObject, eventdata, handles)

if isempty(handles.datstruct)
    msg={'Insufficient data to create array report. This is probably',...
         'happening because your project includes externally processed',...
         'and imported to ARMADA data.'};
    uiwait(warndlg(msg,'Insufficient data'));
    return
end

contents=get(handles.arrayObjectList,'String');
val=get(handles.arrayObjectList,'Value');
selcont=contents(val);
t=handles.experimentInfo.numberOfConditions;
exprp=handles.experimentInfo.exprp;

% Find the arrays from the list
for i=1:t
    for j=1:max(size(exprp{i}))
        if strcmp(selcont,exprp{i}{j})
            stru=handles.datstruct{i}{j};
        end
    end
end

% Display report
ArrayReport(selcont,stru.Header)


% --------------------------------------------------------------------
function analysisContext_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function analysisContextNormList_Callback(hObject, eventdata, handles)

viewNormData_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function analysisContextDEList_Callback(hObject, eventdata, handles)

DEListButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function analysisContextClusterList_Callback(hObject, eventdata, handles)

clusterListButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function analysisContextExportNormList_Callback(hObject, eventdata, handles)

fileDataExportNorm_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function analysisContextExportDEList_Callback(hObject, eventdata, handles)

exportListButton_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function analysisContextExportClusterList_Callback(hObject, eventdata, handles)

exportClusterList_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function analysisContextDelete_Callback(hObject, eventdata, handles)

% Get the index of the analysis to be deleted
ind=handles.currentSelectionIndex;

lsel=length(handles.selectedConditions);
linf=length(handles.analysisInfo);

% Do the job...
handles.analysisInfo(ind)=[];
handles.Project.Analysis(ind)=[];
if ind==1 && lsel<linf
    % Silently do nothing on handles.selectedConditions.
elseif ind~=1 && lsel<linf
        handles.selectedConditions(ind-1)=[];
        handles.selectConditionsIndex=handles.selectConditionsIndex-1;
else
    handles.selectedConditions(ind)=[];
    handles.selectConditionsIndex=handles.selectConditionsIndex-1;
end

% Adjust the listbox value in case we delete the last analysis
if ind==get(handles.analysisObjectList,'Value')
    set(handles.analysisObjectList,'Value',ind-1)
end

% Check if we have deleted everything so as to reinit analyses.
if isempty(handles.analysisInfo)
    handles=rmfield(handles,'analysisInfo');
    handles.Project=rmfield(handles.Project,'Analysis');
    handles.selectedConditions(1).NumberOfConditions=handles.experimentInfo.numberOfConditions;
    handles.selectedConditions(1).Conditions=1:handles.experimentInfo.numberOfConditions;
    handles.selectedConditions(1).ConditionNames=handles.experimentInfo.conditionNames;
    totalReplicates=cell(1,handles.experimentInfo.numberOfConditions);
    for i=1:handles.experimentInfo.numberOfConditions
        totalReplicates{i}=1:max(size(handles.experimentInfo.exprp{i}));
    end
    handles.selectedConditions(1).Replicates=totalReplicates;
    handles.selectedConditions(1).Exprp=handles.experimentInfo.exprp;
    handles.selectedConditions(1).hasRun=false;
    handles.selectedConditions(1).prepro=true;
    %handles.selectedConditions(1).prepro=false;
    handles.selectConditionsIndex=1;
    set(handles.fileExportSettingsMAT,'Enable','off')
end

% Check the case of deleting the 1st analysis in the case of containing all array
% normalization
if ind==1 && lsel<linf
    handles.selectedConditions(ind).prepro=false;
end

% Update the tree
handles.tree=myexplorestruct(handles.ARMADA_main,handles.Project,handles.Project.Name,...
                             handles.sessionNumber);

% Update the analysis object list
if isfield(handles,'analysisInfo')
    anal=cell(length(handles.analysisInfo),1);
    for i=1:length(handles.analysisInfo)
        anal{i}=['Analysis ',num2str(i)];
    end
    set(handles.analysisObjectList,'String',anal)
    set(handles.analysisContextDelete,'Enable','on')
    set(handles.analysisContextReport,'Enable','on')
else
    set(handles.analysisObjectList,'String','')
    set(handles.analysisContextDelete,'Enable','off')
    set(handles.analysisContextReport,'Enable','off')
end

% Adjust the listbox value in case we delete the first analysis
if ind==1
    set(handles.analysisObjectList,'Value',1)
end

% Refresh current selection index
handles.currentSelectionIndex=get(handles.analysisObjectList,'Value');

% Manage other button options directly through the analysis object list
analysisObjectList_Callback(handles.analysisObjectList, eventdata, handles)

% Indicate that something changed
handles.somethingChanged=true;

guidata(hObject,handles);


% --------------------------------------------------------------------
function analysisContextReport_Callback(hObject, eventdata, handles)

% Get current selection index
ind=handles.currentSelectionIndex;
% Call report creator
AnalysisReport(ind,handles.analysisInfo(ind),handles.Project.Analysis(ind),...
               handles.experimentInfo.imgsw)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                END CONTEXT MENU ITEMS               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% --------------------------------------------------------------------
function mainTextbox_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function mainTextbox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function itemInfoEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function itemInfoEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in analysisObjectList.
function analysisObjectList_Callback(hObject, eventdata, handles)

ind=get(hObject,'Value');
handles.currentSelectionIndex=get(hObject,'Value');
handles.analysisIndexChanged=true;

% Maybe fixes a bug
zzz=get(handles.arrayObjectList,'Value');
if length(zzz)>1
    set(handles.arrayObjectList,'Value',zzz(1))
end

% More enabling/disabling possibly to come because of plots
if isfield(handles,'analysisInfo')
    if ~isempty(handles.analysisInfo(ind))
        set(handles.analysisContextReport,'Enable','on')
        set(handles.analysisContextDelete,'Enable','on')
    else
        set(handles.analysisContextReport,'Enable','off')
        set(handles.analysisContextDelete,'Enable','off')
    end
    if isfield(handles.analysisInfo(ind),'DataCellNormLo')
        if ~isempty(handles.analysisInfo(ind).DataCellNormLo)
            set(handles.normImageButton,'Enable','on')
            if handles.analysisInfo(ind).numberOfConditions==1 && ...
               handles.Project.Analysis(ind).NumberOfSlides==1     
                set(handles.stats,'Enable','off')
            else
                set(handles.stats,'Enable','on')
            end
            if handles.analysisInfo(ind).numberOfConditions>1
                set(handles.statsFoldChangeCalc,'Enable','on')
            else
                set(handles.statsFoldChangeCalc,'Enable','off')
            end
            dec=get(handles.plotsArrayImage,'Enable');
            if strcmp(dec,'on')
                set(handles.plotsNormUnnorm,'Enable','on')
            else
                set(handles.plotsNormUnnorm,'Enable','off')
            end
            set(handles.plotsMA,'Enable','on')
            set(handles.plotsSlideDistrib,'Enable','on')
            set(handles.plotsExprProfile,'Enable','on')
            set(handles.viewNormData,'Enable','on')
            set(handles.fileDataExportNorm,'Enable','on')
            set(handles.analysisContextNormList,'Enable','on')
            set(handles.analysisContextExportNormList,'Enable','on')
            
            % Find what is happening with already selected array
            arrays=get(handles.arrayObjectList,'String');
            arrval=get(handles.arrayObjectList,'Value');
            if ~isempty(arrays)
                arrayname=arrays(arrval);
            end
            if length(arrval)==1
                index=1;
                for i=1:handles.analysisInfo(ind).numberOfConditions
                    for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                        currentnames{index}=handles.analysisInfo(ind).exprp{i}{j};
                        index=index+1;
                    end
                end
                z=strmatch(arrayname,currentnames,'exact');
                if isempty(z)
                    set(handles.normImageButton,'Enable','off')
                    set(handles.arrayContextNormImage,'Enable','off')
                    set(handles.viewNormImage,'Enable','off')
                else
                    set(handles.normImageButton,'Enable','on')
                    set(handles.arrayContextNormImage,'Enable','on')
                    set(handles.viewNormImage,'Enable','on')
                end
            end
        else
            set(handles.normImageButton,'Enable','off')
            set(handles.stats,'Enable','off')
            set(handles.statsFoldChangeCalc,'Enable','off')
            set(handles.plotsNormUnnorm,'Enable','off')
            set(handles.plotsMA,'Enable','off')
            set(handles.plotsSlideDistrib,'Enable','off')
            set(handles.plotsExprProfile,'Enable','off')
            set(handles.viewNormData,'Enable','off')
            set(handles.fileDataExportNorm,'Enable','off')
            set(handles.analysisContextNormList,'Enable','off')
            set(handles.analysisContextExportNormList,'Enable','off')
        end
    else
        set(handles.normImageButton,'Enable','off')
        set(handles.stats,'Enable','off')
        set(handles.statsFoldChangeCalc,'Enable','off')
        set(handles.plotsNormUnnorm,'Enable','off')
        set(handles.plotsMA,'Enable','off')
        set(handles.plotsSlideDistrib,'Enable','off')
        set(handles.plotsExprProfile,'Enable','off')
        set(handles.viewNormData,'Enable','off')
        set(handles.fileDataExportNorm,'Enable','off')
        set(handles.analysisContextNormList,'Enable','off')
        set(handles.analysisContextExportNormList,'Enable','off')
    end
    if isfield(handles.analysisInfo(ind),'DataCellFiltered')
       if ~isempty(handles.analysisInfo(ind).DataCellFiltered)
           set(handles.plotsExprProfile,'Enable','on')
           set(handles.toolsPCA,'Enable','on')
       else
           %set(handles.plotsExprProfile,'Enable','off')
           set(handles.toolsPCA,'Enable','off')
       end
    else
       %set(handles.plotsExprProfile,'Enable','off')
       set(handles.toolsPCA,'Enable','off')
    end
    if isfield(handles.analysisInfo(ind),'DataCellStat')
        if ~isempty(handles.analysisInfo(ind).DataCellStat)
            set(handles.DEListButton,'Enable','on')
            set(handles.exportListButton,'Enable','on')
            set(handles.fileDataExportDE,'Enable','on')
            set(handles.analysisContextDEList,'Enable','on')
            set(handles.analysisContextExportDEList,'Enable','on')
            set(handles.viewDEList,'Enable','on')
            if handles.analysisInfo(ind).numberOfConditions==1 || ...
               handles.analysisInfo(ind).numberOfConditions==2
                    set(handles.plotsVolcano,'Enable','on')
            else
                set(handles.plotsVolcano,'Enable','off')
            end
            set(handles.statsClustering,'Enable','on')
            set(handles.toolsGap,'Enable','on')
            set(handles.statsClassification,'Enable','on')
        else
            set(handles.DEListButton,'Enable','off')
            set(handles.viewDEList,'Enable','off')
            set(handles.analysisContextDEList,'Enable','off')
            set(handles.exportListButton,'Enable','off')
            set(handles.analysisContextExportDEList,'Enable','off')
            set(handles.fileDataExportDE,'Enable','off')
            set(handles.plotsVolcano,'Enable','off')
            set(handles.statsClustering,'Enable','off')
            set(handles.toolsGap,'Enable','off')
            set(handles.statsClassification,'Enable','off')
        end
    else
        set(handles.DEListButton,'Enable','off')
        set(handles.viewDEList,'Enable','off')
        set(handles.analysisContextDEList,'Enable','off')
        set(handles.exportListButton,'Enable','off')
        set(handles.analysisContextExportDEList,'Enable','off')
        set(handles.fileDataExportDE,'Enable','off')
        set(handles.plotsVolcano,'Enable','off')
        set(handles.statsClustering,'Enable','off')
        set(handles.toolsGap,'Enable','off')
        set(handles.statsClassification,'Enable','off')
    end
    if isfield(handles.analysisInfo(ind),'FinalTable')
        if ~isempty(handles.analysisInfo(ind).FinalTable)
            set(handles.clusterListButton,'Enable','on')
            set(handles.exportClusterList,'Enable','on')
            set(handles.analysisContextClusterList,'Enable','on')
            set(handles.analysisContextExportClusterList,'Enable','on')
            set(handles.viewClusterList,'Enable','on')
            set(handles.fileDataExportClusters,'Enable','on')
        else
            set(handles.clusterListButton,'Enable','off')
            set(handles.exportClusterList,'Enable','off')
            set(handles.analysisContextClusterList,'Enable','off')
            set(handles.analysisContextExportClusterList,'Enable','off')
            set(handles.viewClusterList,'Enable','off')
            set(handles.fileDataExportClusters,'Enable','off')
        end
    else
        set(handles.clusterListButton,'Enable','off')
        set(handles.exportClusterList,'Enable','off')
        set(handles.analysisContextClusterList,'Enable','off')
        set(handles.analysisContextExportClusterList,'Enable','off')
        set(handles.viewClusterList,'Enable','off')
        set(handles.fileDataExportClusters,'Enable','off')
    end
    if isfield(handles.Project.Analysis(ind),'StatisticalSelection')
        if isfield(handles.Project.Analysis(ind).StatisticalSelection,'Test')
            if strcmpi(handles.Project.Analysis(ind).StatisticalSelection.Test,...
                      'Time Course ANOVA')
                set(handles.statsFoldChangeCalc,'Enable','off')
            else
                set(handles.statsFoldChangeCalc,'Enable','on')
            end
        end
    end
else
    set(handles.analysisContextReport,'Enable','off')
    set(handles.analysisContextDelete,'Enable','off')
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function analysisObjectList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in arrayObjectList.
function arrayObjectList_Callback(hObject, eventdata, handles)

ind=handles.currentSelectionIndex;
contents=get(hObject,'String');
val=get(hObject,'Value');

% Disable array report if more than one selected
if length(val)>1
    set(handles.arrayContextReport,'Enable','off')
else
    set(handles.arrayContextReport,'Enable','on')
end

if ~isempty(contents)
    arrayname=contents(val);
end

% Find the array
if length(val)==1 && isfield(handles,'analysisInfo')
    index=1;
    if isfield(handles.analysisInfo(ind),'DataCellNormLo')
        if ~isempty(handles.analysisInfo(ind).DataCellNormLo)
            for i=1:handles.analysisInfo(ind).numberOfConditions
                for j=1:max(size(handles.analysisInfo(ind).exprp{i}))
                    currentnames{index}=handles.analysisInfo(ind).exprp{i}{j};
                    index=index+1;
                end
            end
            z=strmatch(arrayname,currentnames,'exact');
            if isempty(z)
                set(handles.normImageButton,'Enable','off')
                set(handles.arrayContextNormImage,'Enable','off')
                set(handles.viewNormImage,'Enable','off')
            else
                set(handles.normImageButton,'Enable','on')
                set(handles.arrayContextNormImage,'Enable','on')
                set(handles.viewNormImage,'Enable','on')
            end
        end
    end
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function arrayObjectList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%% BEGIN MAIN WINDOW BUTTONS %%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in rawImageButton.
function rawImageButton_Callback(hObject, eventdata, handles)

% Check if we have external data to visualize without indice support
if isempty(handles.datstruct)
    extflag=true;
else   
    extflag=false;
    if ~isempty(handles.attributes.Indices)
        indexist=true;
    else
        indexist=false;
    end
end

contents=get(handles.arrayObjectList,'String');
val=get(handles.arrayObjectList,'Value');
if length(val)>1 && indexist
    uiwait(warndlg('Cannot display more than one image at a time.',...
                   'Please select only one array','Warning'));
    set(handles.arrayObjectList,'Value',val(1))
    return
end

% Delete previous image... this GUI must not be full of trash
if isfield(handles,'Image')
    if ishandle(handles.Image.ax)
        delete(handles.Image.ax);
    end
    if ishandle(handles.Image.him)
        delete(handles.Image.him);
    end
    if ishandle(handles.Image.hscroll)
        delete(handles.Image.hscroll);
    end
    if ishandle(handles.Image.hmove)
        delete(handles.Image.hmove);
    end
    if ishandle(handles.Image.hmag)
        delete(handles.Image.hmag);
    end
end

% Delete previous table... this GUI must not be full of trash
if isfield(handles,'Table')
    if ishandle(handles.Table)
        delete(handles.Table);
    end
end

selcont=contents(val);
t=handles.experimentInfo.numberOfConditions;
exprp=handles.experimentInfo.exprp;

if ~extflag
    
    % Find the array from the list
    for i=1:t
        for j=1:max(size(exprp{i}))
            if strcmp(selcont,exprp{i}{j})
                stru=handles.datstruct{i}{j};
                break
            end
        end
    end

    % Do not create if indices matrix not assigned, pseudoimage instead
    if ~indexist
        count=0;
        if isfield(handles.datstruct{1}{1},'ch1Intensity') % No spatial data
            greenmat=zeros(length(handles.datstruct{1}{1}.ch1Intensity),1);
            redmat=zeros(length(handles.datstruct{1}{1}.ch2Intensity),1);
            for i=1:length(handles.datstruct)
                for j=1:length(handles.datstruct{i})
                    count=count+1;
                    greenmat(:,count)=handles.datstruct{i}{j}.ch1Intensity;
                    redmat(:,count)=handles.datstruct{i}{j}.ch2Intensity;
                end
            end
            labels=handles.attributes.pbID;
        else % Illumina
            greenmat=zeros(length(handles.datstruct{1}{1}.Intensity),1);
            for i=1:length(handles.datstruct)
                for j=1:length(handles.datstruct{i})
                    count=count+1;
                    greenmat(:,count)=handles.datstruct{i}{j}.Intensity;
                end
            end
            redmat=zeros(length(handles.datstruct{1}{1}.Intensity),count);
            labels=handles.attributes.gnID;
        end
        colnames=get(handles.arrayObjectList,'String');
    end
    
else
    
    exptab=handles.analysisInfo(1).exptab;
    tempmat=cell(1,length(exptab));
    for i=1:length(exptab)
        vec=zeros(size(exptab{i}{1},1),length(exptab{i}));
        for j=1:length(exptab{i})
            vec(:,j)=exptab{i}{j}(:,3);
        end
        tempmat{i}=vec;
    end
    mat=cell2mat(tempmat);
    labels=handles.attributes.gnID;
    colnames=get(handles.arrayObjectList,'String');
    
end

% Create an axes object
handles.Image.ax=axes('Units','normalized','Position',[0.293 0.337 0.697 0.64]);
if extflag
    handles.Image.him=createDataImage(mat,labels,colnames,handles.Image.ax);
    if nanmin(nanmin(mat))<0
        climprop=[-nanmax(nanmax(abs(mat))) nanmax(nanmax(abs(mat)))];
    else
        climprop=[nanmin(nanmin(mat)) nanmax(nanmax(mat))];
    end
    S=load('redgreenmaps.mat','aredgreenmap');
    colormap(S.aredgreenmap)
    set(handles.Image.ax,'CLim',climprop)
else
    if indexist
        handles.Image.him=createRawImage(stru,handles.attributes,handles.Image.ax);
    else
        handles.Image.him=createRawImageNoGrid(greenmat,redmat,labels,colnames,...
                                               handles.Image.ax);
    end
end
axis('off')
% Create image navigation
handles.Image.hscroll=imscrollpanel(handles.ARMADA_main,handles.Image.him);
handles.Image.hmove=imoverviewpanel(handles.ARMADA_main,handles.Image.him);
handles.Image.hmag=immagbox(handles.Image.hmove,handles.Image.him);
set(handles.Image.hscroll,'Units','normalized','Position',[0.293 0.52 0.697 0.47])
set(handles.Image.hmove,'Units','Normalized','Position',[0.29 0.34 0.7 0.17]);
set(handles.Image.hmag,'Units','normalized','Position',[0.01 0.35 0.1 0.2],...
                       'FontSize',9,'FontWeight','demi');
api=iptgetapi(handles.Image.hscroll);
api.setMagnification(3);
zoomTxt=uicontrol(handles.Image.hmove,...
                  'String','Zoom',...
                  'Units','normalized',...
                  'Style','Text',...
                  'Position',[0.01 0.55 0.1 0.1],...
                  'BackgroundColor',get(handles.ARMADA_main,'Color'),...
                  'FontSize',8);

guidata(hObject,handles);


% --- Executes on button press in normImageButton.
function normImageButton_Callback(hObject, eventdata, handles)

ind=handles.currentSelectionIndex;

% Check if we have external data to visualize without indice support
if isempty(handles.datstruct)
    extflag=true;
else
    extflag=false;
    if ~isempty(handles.attributes.Indices)
        indexist=true;
    else
        indexist=false;
    end
    if handles.experimentInfo.imgsw==99 || handles.experimentInfo.imgsw==98
        indexist=false;
    end
end

% Delete previous image... this GUI must not be full of trash
if isfield(handles,'Image')
    if ishandle(handles.Image.ax)
        delete(handles.Image.ax);
    end
    if ishandle(handles.Image.him)
        delete(handles.Image.him);
    end
    if ishandle(handles.Image.hscroll)
        delete(handles.Image.hscroll);
    end
    if ishandle(handles.Image.hmove)
        delete(handles.Image.hmove);
    end
    if ishandle(handles.Image.hmag)
        delete(handles.Image.hmag);
    end
end

% Delete previous table... this GUI must not be full of trash
if isfield(handles,'Table')
    if ishandle(handles.Table)
        delete(handles.Table);
    end
end

contents=get(handles.arrayObjectList,'String');
val=get(handles.arrayObjectList,'Value');
if length(val)>1 && indexist
    uiwait(warndlg('Cannot display more than one image at a time.',...
                   'Please select only one array from the list.','Warning'));
    set(handles.arrayObjectList,'Value',val(1))
    return
end
selcont=contents(val);
t=handles.analysisInfo(ind).numberOfConditions;
exprp=handles.analysisInfo(ind).exprp;

% Find the appropriate part of datstruct
if ~extflag
    
    if indexist
        
        lsel=length(handles.selectedConditions);
        linf=length(handles.analysisInfo);
        if ind==1 && lsel<linf
            datstr=handles.datstruct;
        elseif ind~=1 && lsel<linf
            datstr=cell(1,handles.selectedConditions(ind-1).NumberOfConditions);
            for i=1:handles.selectedConditions(ind-1).NumberOfConditions
                datstr{i}=handles.datstruct{handles.selectedConditions(ind-1).Conditions(i)}...
                    (handles.selectedConditions(ind-1).Replicates{i});
            end
        else
            datstr=cell(1,handles.selectedConditions(ind).NumberOfConditions);
            for i=1:handles.selectedConditions(ind).NumberOfConditions
                datstr{i}=handles.datstruct{handles.selectedConditions(ind).Conditions(i)}...
                    (handles.selectedConditions(ind).Replicates{i});
            end
        end

        % Find the array from the list
        for i=1:t
            for j=1:max(size(exprp{i}))
                if strcmp(selcont,exprp{i}{j})
                    stru=datstr{i}{j};
                    m=i;
                    n=j;
                    break
                end
            end
        end

        if isfield(handles.analysisInfo,'DataCellNormLo')
            if ~isempty(handles.analysisInfo(ind).DataCellNormLo)
                logratnorm=handles.analysisInfo(ind).DataCellNormLo{2};
                normdata=logratnorm{m}{n};
                climprop=[-max(abs(normdata)) max(abs(normdata))];
                if isfield(handles.attributes,'pbID') && length(handles.attributes.gnID)~=length(handles.attributes.pbID)
                    labels=handles.attributes.gnID;
                    colnames=cell(handles.Project.Analysis(ind).NumberOfSlides,1);
                    exprp=handles.analysisInfo(ind).exprp;
                    count=0;
                    for i=1:length(exprp)
                        for j=1:length(exprp{i})
                            count=count+1;
                            colnames{count}=exprp{i}{j};
                        end
                    end
                end
            else
                return
            end
        end
        
    else
        
        if isfield(handles.analysisInfo,'DataCellNormLo')
            if ~isempty(handles.analysisInfo(ind).DataCellNormLo)
                DataCellNormLo=handles.analysisInfo(ind).DataCellNormLo;
                tempmat=cell(1,length(DataCellNormLo{2}));
                for i=1:length(DataCellNormLo{2})
                    tempmat{i}=cell2mat(DataCellNormLo{2}{i});
                end
                mat=cell2mat(tempmat);
                labels=handles.attributes.gnID;
                colnames=cell(handles.Project.Analysis(ind).NumberOfSlides,1);
                exprp=handles.analysisInfo(ind).exprp;
                count=0;
                for i=1:length(exprp)
                    for j=1:length(exprp{i})
                        count=count+1;
                        colnames{count}=exprp{i}{j};
                    end
                end
            end
        end
        
    end
    
else
    
    if isfield(handles.analysisInfo,'DataCellNormLo')
        if ~isempty(handles.analysisInfo(ind).DataCellNormLo)
            DataCellNormLo=handles.analysisInfo(1).DataCellNormLo;
            tempmat=cell(1,length(DataCellNormLo{2}));
            for i=1:length(DataCellNormLo{2})
                tempmat{i}=cell2mat(DataCellNormLo{2}{i});
            end
            mat=cell2mat(tempmat);
            labels=handles.attributes.gnID;
            colnames=cell(handles.Project.Analysis(ind).NumberOfSlides,1);
            exprp=handles.analysisInfo(ind).exprp;
            count=0;
            for i=1:length(exprp)
                for j=1:length(exprp{i})
                    count=count+1;
                    colnames{count}=exprp{i}{j};
                end
            end
        end
    else
        uiwait(errordlg('Cannot create image! Data probably not normalized.','Error'));
    end
    
end

% Create an axes object
sums=0;
handles.Image.ax=axes('Units','normalized','Position',[0.293 0.337 0.697 0.64]);
if extflag
    handles.Image.him=createDataImage(mat,labels,colnames,handles.Image.ax);
    mat(isinf(mat))=NaN;
    if min(min(mat))<0
        climprop=[-max(max(abs(mat))) max(max(abs(mat)))];
    else
        climprop=[min(min(mat)) max(max(mat))];
    end
    S=load('redgreenmaps.mat','aredgreenmap');
    colormap(S.aredgreenmap)
    set(handles.Image.ax,'CLim',climprop)
else
    if indexist
        try
            handles.Image.him=createRawNormImage(stru,handles.attributes,normdata,1,handles.Image.ax);
            S=load('redgreenmaps.mat','aredgreenmap');
            colormap(S.aredgreenmap)
            set(handles.Image.ax,'CLim',climprop)
        catch
            sums=1;
            handles.Image.him=createDataImage(normdata,labels,colnames,handles.Image.ax);
            if min(min(normdata))<0
                climprop=[-max(max(abs(normdata))) max(max(abs(normdata)))];
            else
                climprop=[min(min(normdata)) max(max(normdata))];
            end
            S=load('redgreenmaps.mat','aredgreenmap');
            colormap(S.aredgreenmap)
            set(handles.Image.ax,'CLim',climprop)
        end
    else
        mat(isinf(mat))=NaN;
        handles.Image.him=createDataImage(mat,labels,colnames,handles.Image.ax);
        if min(min(mat))<0
            climprop=[-max(max(abs(mat))) max(max(abs(mat)))];
        else
            climprop=[min(min(mat)) max(max(mat))];
        end
        S=load('redgreenmaps.mat','aredgreenmap');
        colormap(S.aredgreenmap)
        set(handles.Image.ax,'CLim',climprop)
    end
end
axis('off')

% Create image navigation
handles.Image.hscroll=imscrollpanel(handles.ARMADA_main,handles.Image.him);
handles.Image.hmove=imoverviewpanel(handles.ARMADA_main,handles.Image.him);
handles.Image.hmag=immagbox(handles.Image.hmove,handles.Image.him);
set(handles.Image.hscroll,'Units','normalized','Position',[0.293 0.52 0.697 0.47])
set(handles.Image.hmove,'Units','Normalized','Position',[0.29 0.34 0.7 0.17]);
set(handles.Image.hmag,'Units','normalized','Position',[0.01 0.35 0.1 0.2],...
                       'FontSize',9,'FontWeight','demi');
api=iptgetapi(handles.Image.hscroll);
api.setMagnification(3);
zoomTxt=uicontrol(handles.Image.hmove,...
                  'String','Zoom',...
                  'Units','normalized',...
                  'Style','Text',...
                  'Position',[0.01 0.55 0.1 0.1],...
                  'BackgroundColor',get(handles.ARMADA_main,'Color'),...
                  'FontSize',8);

if (sums)
    uiwait(helpdlg({'Array probe values were summarized during normalization','A single column image has been created.'},'Info'));
end
              
guidata(hObject,handles);


% --- Executes on button press in arrayRawButton.
function arrayRawButton_Callback(hObject, eventdata, handles)

contents=get(handles.arrayObjectList,'String');
val=get(handles.arrayObjectList,'Value');
if length(val)>1
    uiwait(warndlg('Cannot display more than one image at a time.',...
                   'Please select only one array','Warning'));
    set(handles.arrayObjectList,'Value',val(1))
    return
end

% Check if we have external data to visualize without indice support
if isempty(handles.datstruct)
    extflag=true;
else
    extflag=false;
end

% Delete previous image... this GUI must not be full of trash
if isfield(handles,'Image')
    if ishandle(handles.Image.ax)
        delete(handles.Image.ax);
    end
    if ishandle(handles.Image.him)
        delete(handles.Image.him);
    end
    if ishandle(handles.Image.hscroll)
        delete(handles.Image.hscroll);
    end
    if ishandle(handles.Image.hmove)
        delete(handles.Image.hmove);
    end
    if ishandle(handles.Image.hmag)
        delete(handles.Image.hmag);
    end
end

% Delete previous table... this GUI must not be full of trash
if isfield(handles,'Table')
    if ishandle(handles.Table)
        delete(handles.Table);
    end
end

hh=showinfowindow('Loading data table - Please wait...');

selcont=contents(val);
t=handles.experimentInfo.numberOfConditions;
exprp=handles.experimentInfo.exprp;

% Find the array from the list
if ~extflag
    for i=1:t
        for j=1:max(size(exprp{i}))
            if strcmp(selcont,exprp{i}{j})
                stru=handles.datstruct{i}{j};
                break
            end
        end
    end
    % Create data
    if handles.experimentInfo.imgsw==99
        [celldata,colnames]=createCellDataTableAffy(stru);
    elseif handles.experimentInfo.imgsw==98
        [celldata,colnames]=createCellDataTableIllu(stru);
    else
        [celldata,colnames]=createCellDataTable(stru,handles.attributes);
    end
else
    exptab=handles.analysisInfo(1).exptab;
    exprp=handles.experimentInfo.exprp;
    ids=handles.attributes.gnID;
    % Create data in the case of external
    [celldata,colnames]=createExternalDataTable(exptab,exprp,ids);
end

% Create table
handles.Table=uitable('Data',celldata,...
                      'ColumnNames',colnames,...
                      'Parent',handles.ARMADA_main,...
                      'NumRows',size(celldata,1),...
                      'NumColumns',length(colnames));
set(handles.Table,'Units','normalized',...
                  'Position',[0.293 0.333 0.697 0.655],...
                  'Editable',false);

set(hh,'CloseRequestFcn','closereq')
close(hh)

guidata(hObject,handles);


% --- Executes on button press in DEListButton.
function DEListButton_Callback(hObject, eventdata, handles)

% Delete previous image... this GUI must not be full of trash
if isfield(handles,'Image')
    if ishandle(handles.Image.ax)
        delete(handles.Image.ax);
    end
    if ishandle(handles.Image.him)
        delete(handles.Image.him);
    end
    if ishandle(handles.Image.hscroll)
        delete(handles.Image.hscroll);
    end
    if ishandle(handles.Image.hmove)
        delete(handles.Image.hmove);
    end
    if ishandle(handles.Image.hmag)
        delete(handles.Image.hmag);
    end
end

% Delete previous table... this GUI must not be full of trash
if isfield(handles,'Table')
    if ishandle(handles.Table)
        delete(handles.Table);
    end
end

try

    hh=showinfowindow('Loading data table - Please wait...');

    ind=handles.currentSelectionIndex;

    % Create data
    if isfield(handles,'analysisInfo')
        if isfield(handles.analysisInfo,'DataCellStat')
            if ~isempty(handles.analysisInfo(ind).DataCellStat)
                
                % We have to fix exprp
                if strcmp(handles.Project.Analysis(ind).StatisticalSelection.Test,'Time Course ANOVA')
                    tind=handles.analysisInfo(ind).TCAinds{2};
                    newexprp=cell(1,length(handles.analysisInfo(ind).exprp)/2);
                    for i=1:length(newexprp)
                        for j=1:length(handles.analysisInfo(ind).exprp{tind(i)})
                            newexprp{i}{j}=handles.analysisInfo(ind).exprp{tind(i)}{j};
                        end
                    end
                else
                    newexprp=handles.analysisInfo(ind).exprp;
                end
                
                % We have to get fold change indices
                if isfield(handles.analysisInfo(ind),'fcinds')
                    fcinds=handles.analysisInfo(ind).fcinds;
                else
                    fcinds=[];
                end
                
                if handles.experimentInfo.imgsw~=99 && handles.experimentInfo.imgsw~=98
                    [headers,data]=createDEListTable(handles.analysisInfo(ind).exprp,...
                                                     newexprp,...
                                                     handles.analysisInfo(ind).exptab,...
                                                     handles.analysisInfo(ind).DataCellNormLo,...
                                                     handles.analysisInfo(ind).DataCellStat,...
                                                     fcinds,handles.exportSettings);
                else
                    opts=handles.exportSettings;
                    opts.outtype='excel';
                    [headers,data]=exportDEfinalAffy(handles.analysisInfo(ind).exprp,...
                                                     handles.analysisInfo(ind).DataCellNormLo,...
                                                     handles.analysisInfo(ind).DataCellStat,...
                                                     fcinds,opts,'foo-bar',false);
                end
            else
                uiwait(errordlg({'Unexpected Error'},'Error'));
                set(hh,'CloseRequestFcn','closereq')
                close(hh)
                return
            end
        end
    end

    % Create table
    handles.Table=uitable('Data',data,...
                          'ColumnNames',headers,...
                          'Parent',handles.ARMADA_main,...
                          'NumRows',size(data,1),...
                          'NumColumns',length(headers));
    set(handles.Table,'Units','normalized',...
                      'Position',[0.293 0.333 0.697 0.655],...
                      'Editable',false);

    set(hh,'CloseRequestFcn','closereq')
    close(hh)

    guidata(hObject,handles);

catch
    uiwait(errordlg({'Unexpected Error!',lasterr},'Error'));
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
end


% --- Executes on button press in clusterListButton.
function clusterListButton_Callback(hObject, eventdata, handles)

% Delete previous image... this GUI must not be full of trash
if isfield(handles,'Image')
    if ishandle(handles.Image.ax)
        delete(handles.Image.ax);
    end
    if ishandle(handles.Image.him)
        delete(handles.Image.him);
    end
    if ishandle(handles.Image.hscroll)
        delete(handles.Image.hscroll);
    end
    if ishandle(handles.Image.hmove)
        delete(handles.Image.hmove);
    end
    if ishandle(handles.Image.hmag)
        delete(handles.Image.hmag);
    end
end

% Delete previous table... this GUI must not be full of trash
if isfield(handles,'Table')
    if ishandle(handles.Table)
        delete(handles.Table);
    end
end

try

    hh=showinfowindow('Loading data table - Please wait...');

    ind=handles.currentSelectionIndex;

    % Create data
    if isfield(handles,'analysisInfo')
        if isfield(handles.analysisInfo,'FinalTable')
            if ~isempty(handles.analysisInfo(ind).FinalTable)
                headers=handles.analysisInfo(ind).FinalTable(1,:);
                data=handles.analysisInfo(ind).FinalTable(2:end,:);
            else
                uiwait(errordlg({'Unexpected Error'},'Error'));
                set(hh,'CloseRequestFcn','closereq')
                close(hh)
                return
            end
        end
    end

    % Create table
    handles.Table=uitable('Data',data,...
                          'ColumnNames',headers,...
                          'Parent',handles.ARMADA_main,...
                          'NumRows',size(data,1),...
                          'NumColumns',length(headers));
    set(handles.Table,'Units','normalized',...
                      'Position',[0.293 0.337 0.697 0.64],...
                      'Editable',false);

    set(hh,'CloseRequestFcn','closereq')
    close(hh)

    guidata(hObject,handles);

catch
    uiwait(errordlg({'Unexpected Error!',lasterr},'Error'));
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
end


% --- Executes on button press in exportListButton.
function exportListButton_Callback(hObject, eventdata, handles)
    
% Get the current selection in order to export the respective list
ind=handles.currentSelectionIndex;

try
    
    hh=showinfowindow('Exporting DE gene list - Please wait...','Exporting');
    
    % DataCellStat exists?
    if isfield(handles.analysisInfo(ind),'DataCellStat')
        if ~isempty(handles.analysisInfo(ind).DataCellStat)
            
            % We have to fix exprp in the case of Time Course ANOVA
            if isfield(handles.Project.Analysis(ind),'StatisticalSelection') && ...
               strcmp(handles.Project.Analysis(ind).StatisticalSelection.Test,'Time Course ANOVA')
                
                tind=handles.analysisInfo(ind).TCAinds{2};
                
                if handles.experimentInfo.imgsw~=99
                    if ~isempty(handles.exportSettings) % Run with defined export settings
                        exportDEfinalTCA(handles.analysisInfo(ind).exprp,...
                                         handles.analysisInfo(ind).conditionNames,...
                                         handles.analysisInfo(ind).exptab,...
                                         handles.analysisInfo(ind).DataCellNormLo,...
                                         handles.analysisInfo(ind).DataCellStat,...
                                         tind,...
                                         handles.exportSettings);
                    else % Run with default settings from within the export routine
                        exportDEfinalTCA(handles.analysisInfo(ind).exprp,...
                                         handles.analysisInfo(ind).conditionNames,...
                                         handles.analysisInfo(ind).exptab,...
                                         handles.analysisInfo(ind).DataCellNormLo,...
                                         handles.analysisInfo(ind).DataCellStat,...
                                         tind);
                    end
                else
                    if ~isempty(handles.exportSettings) % Run with defined export settings
                        exportDEfinalAffyTCA(handles.analysisInfo(ind).exprp,...
                                             handles.analysisInfo(ind).conditionNames,...
                                             handles.analysisInfo(ind).DataCellNormLo,...
                                             handles.analysisInfo(ind).DataCellStat,...
                                             tind,...
                                             handles.exportSettings);
                    else % Run with default settings from within the export routine
                        exportDEfinalAffyTCA(handles.analysisInfo(ind).exprp,...
                                             handles.analysisInfo(ind).conditionNames,...
                                             handles.analysisInfo(ind).DataCellNormLo,...
                                             handles.analysisInfo(ind).DataCellStat,...
                                             tind);

                    end
                end
                
            else
                
                if isfield(handles.analysisInfo(ind),'fcinds')
                    fcinds=handles.analysisInfo(ind).fcinds;
                else
                    fcinds=[];
                end
            
                if handles.experimentInfo.imgsw~=99
                    if ~isempty(handles.exportSettings) % Run with defined export settings
                        exportDEfinal(handles.analysisInfo(ind).exprp,...
                                      handles.analysisInfo(ind).exptab,...
                                      handles.analysisInfo(ind).DataCellNormLo,...
                                      handles.analysisInfo(ind).DataCellStat,...
                                      fcinds,handles.exportSettings);
                    else % Run with default settings from within the export routine
                        exportDEfinal(handles.analysisInfo(ind).exprp,...
                                      handles.analysisInfo(ind).exptab,...
                                      handles.analysisInfo(ind).DataCellNormLo,...
                                      handles.analysisInfo(ind).DataCellStat,...
                                      fcinds);

                    end
                else
                    if ~isempty(handles.exportSettings) % Run with defined export settings
                        exportDEfinalAffy(handles.analysisInfo(ind).exprp,...
                            handles.analysisInfo(ind).DataCellNormLo,...
                            handles.analysisInfo(ind).DataCellStat,...
                            fcinds,handles.exportSettings);
                    else % Run with default settings from within the export routine
                        exportDEfinalAffy(handles.analysisInfo(ind).exprp,...
                            handles.analysisInfo(ind).DataCellNormLo,...
                            handles.analysisInfo(ind).DataCellStat,...
                            fcinds);

                    end
                end
                
            end
            
        end
    end
    
    set(hh,'CloseRequestFcn','closereq')
    close(hh)

catch
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    errmsg={'An unexpected error occured during gene list exporting.',...
            'process. Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


% --- Executes on button press in exportClusterList.
function exportClusterList_Callback(hObject, eventdata, handles)

% Get the current selection in order to export the respective list
ind=handles.currentSelectionIndex;

try
    
    hh=showinfowindow('Exporting cluster list - Please wait...','Exporting');
    
    % FinalTable exists?
    if isfield(handles.analysisInfo(ind),'FinalTable')
        if ~isempty(handles.analysisInfo(ind).FinalTable)
            [clist,pathC,findex]=uiputfile({'*.txt','Text tab delimited files (*.txt)';...
                                            '*.xls','Excel files (*.xls)'},...
                                            'Save Clusters List');
            if clist==0
                uiwait(msgbox('No file specified','Export list','modal'));
                set(hh,'CloseRequestFcn','closereq')
                close(hh)
                return
            else
                fname=strcat(pathC,clist);
                if findex==1 % Text files
                    cell2csv(fname,handles.analysisInfo(ind).FinalTable,'\t');
                elseif findex==2 % Excel file
                    xlswrite(clist,handles.analysisInfo(ind).FinalTable)
                end
            end
        end
    end
    
    set(hh,'CloseRequestFcn','closereq')
    close(hh)

catch
    set(hh,'CloseRequestFcn','closereq')
    close(hh)
    errmsg={'An unexpected error occured during gene cluster list exporting process.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end

%%%%%%%%%%%%%%%%%%% END MAIN WINDOW BUTTONS %%%%%%%%%%%%%%%%%%%%


% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   HELP FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %

function out = matfromcell(datab,tablen)

% A function to transform a mxn cell array of strings to a character matrix containing the
% same words (adjusted for the purposes of ARMADA)

if nargin<2
    tablen=4;
end

[m n]=size(datab);
len=zeros(m,n);
for i=1:m
    for j=1:n
        len(i,j)=length(datab{i,j});
    end
end
maxlen=max(max(len));

% Preallocate and initialize out
out=char(m,n*(maxlen+tablen));
for i=1:size(out,1)
    for j=1:size(out,2)
        out(i,j)=' ';
    end
end
% Fill out
for i=1:m
    for j=1:n
        temp=[datab{i,j} repmat('_',[1 maxlen-length(datab{i,j})])];
        for k=(j-1)*(maxlen+tablen)+1:(j-1)*(maxlen+tablen)+maxlen
            out(i,k)=temp(k-(j-1)*(maxlen+tablen));
            out(i,k+(1:tablen))='_';
        end
    end
end
% Remove trailing spaces from the end of out
maxend=max(len(:,end));
out=out(:,1:(size(out,2)-tablen-maxlen+maxend));


function [uniRow,uniCol,metacords] = checkSubgrid(imgsw,datstruct)

% Check for the existence of subgrid in arrays

% If datstruct is empty data are externally imported, there is no subgrid, return nulls
if isempty(datstruct)
    uniRow=1;
    uniCol=1;
    metacords=[];
    return
end
% Check if subgrid exists
switch imgsw
    case 1 % QuantArray
        uniRow=unique(datstruct{1}{1}.ArrayRow);
        uniCol=unique(datstruct{1}{1}.ArrayColumn);
        metacords={datstruct{1}{1}.ArrayRow,datstruct{1}{1}.ArrayColumn};
    case 2 % ImaGene
        uniRow=unique(datstruct{1}{1}.BlockRows);
        uniCol=unique(datstruct{1}{1}.BlockColumns);
        metacords={datstruct{1}{1}.BlockRows,datstruct{1}{1}.BlockColumns};
    case 3 % GenePix
        uniBlock=unique(datstruct{1}{1}.Blocks);
        metacords={datstruct{1}{1}.Blocks};
        uniRow=uniBlock;
        uniCol=uniBlock;
    case 4 % Text delimited
        uniRow=unique(datstruct{1}{1}.MetaRows);
        uniCol=unique(datstruct{1}{1}.MetaColumns);
        if isempty(uniRow) || isempty(uniCol)
            uniRow=1;
            uniCol=1;
        else
            metacords={datstruct{1}{1}.MetaRows,datstruct{1}{1}.MetaColumns};
        end
    case 5 % Agilent Feature Extraction
            uniRow=1;
            uniCol=1;
            metacords={ones(length(datstruct{1}{1}.Rows),1),ones(length(datstruct{1}{1}.Columns),1)};
end


function [outcell,colnames] = createCellDataTable(stru,attrib)

% Function to create the cell which will be displayed in ARMADA main window for each
% array and return also the column names

len=length(attrib.pbID);

% Create value table
outcell=cell(1,23);
colnames=cell(1,23);

outcell{1}=cast(attrib.Number,'uint32');
colnames{1}='Slide Position';
outcell{2}=attrib.pbID;
colnames{2}='Gene ID';
outcell{3}=stru.ch1Intensity;
colnames{3}='Channel 1 Foreground Mean';
if ~isempty(stru.ch2Intensity)
    outcell{4}=stru.ch2Intensity;
    colnames{4}='Channel 2 Foreground Mean';
else
    outcell{4}=NaN;
    colnames{4}=NaN;
end
outcell{7}=stru.ch1Background;
colnames{7}='Channel 1 Background Mean';
if ~isempty(stru.ch2Background)
    outcell{8}=stru.ch2Background;
    colnames{8}='Channel 2 Background Mean';
else
    outcell{8}=NaN;
    colnames{8}=NaN;
end
if ~isempty(stru.ch1IntensityStd)
    outcell{11}=stru.ch1IntensityStd;
    colnames{11}='Channel 1 Foreground Standard Deviation';
else
    outcell{11}=NaN;
    colnames{11}=NaN;
end
if ~isempty(stru.ch2IntensityStd)
    outcell{12}=stru.ch2IntensityStd;
    colnames{12}='Channel 2 Foreground Standard Deviation';
else
    outcell{12}=NaN;
    colnames{12}=NaN;
end
if ~isempty(stru.ch1BackgroundStd)
    outcell{13}=stru.ch1BackgroundStd;
    colnames{13}='Channel 1 Background Standard Deviation';
else
    outcell{13}=NaN;
    colnames{13}=NaN;
end
if ~isempty(stru.ch2BackgroundStd)
    outcell{14}=stru.ch2BackgroundStd;
    colnames{14}='Channel 2 Background Standard Deviation';
else
    outcell{14}=NaN;
    colnames{14}=NaN;
end
if ~isempty(stru.ch1Intensity) && ~isempty(stru.ch1Background)
    outcell{15}=stru.ch1Intensity-stru.ch1Background;
    colnames{15}='Channel 1 Foreground - Background (Mean)';
else
    outcell{15}=NaN;
    colnames{15}=NaN;
end
if ~isempty(stru.ch2Intensity) && ~isempty(stru.ch2Background)
    outcell{16}=stru.ch2Intensity-stru.ch2Background;
    colnames{16}='Channel 2 Foreground - Background (Mean)';
else
    outcell{16}=NaN;
    colnames{16}=NaN;
end
if ~isempty(stru.ch1Intensity) && ~isempty(stru.ch1Background)
    outcell{19}=stru.ch1Intensity./stru.ch1Background;
    colnames{19}='Channel 1 Foreground / Background (Mean)';
else
    outcell{19}=NaN;
    colnames{19}=NaN;
end
if ~isempty(stru.ch2Intensity) && ~isempty(stru.ch2Background)
    outcell{20}=stru.ch2Intensity./stru.ch2Background;
    colnames{20}='Channel 2 Foreground / Background (Mean)';
else
    outcell{20}=NaN;
    colnames{20}=NaN;
end
outcell{23}=cast(stru.IgnoreFilter,'uint8');
colnames{23}='Flags';
if isfield(stru,'ch1IntensityMedian') && ~isempty(stru.ch1IntensityMedian)
    if ~isempty(stru.ch1IntensityMedian)
        outcell{5}=stru.ch1IntensityMedian;
        colnames{5}='Channel 1 Foreground Median';
    else
        outcell{5}=NaN;
        colnames{5}=NaN;
    end
    if ~isempty(stru.ch2IntensityMedian)
        outcell{6}=stru.ch2IntensityMedian;
        colnames{6}='Channel 2 Foreground Median';
    else
        outcell{6}=NaN;
        colnames{6}=NaN;
    end
    if ~isempty(stru.ch1BackgroundMedian)
        outcell{9}=stru.ch1BackgroundMedian;
        colnames{9}='Channel 1 Background Median';
    else
        outcell{9}=NaN;
        colnames{9}=NaN;
    end
    if ~isempty(stru.ch2BackgroundMedian)
        outcell{10}=stru.ch2BackgroundMedian;
        colnames{10}='Channel 2 Background Median';
    else
        outcell{10}=NaN;
        colnames{10}=NaN;
    end
    if ~isempty(stru.ch1IntensityMedian) && ~isempty(stru.ch1BackgroundMedian)
        outcell{17}=stru.ch1IntensityMedian-stru.ch1BackgroundMedian;
        colnames{17}='Channel 1 Foreground - Background (Median)';
    else
        outcell{17}=NaN;
        colnames{17}=NaN;
    end
    if ~isempty(stru.ch2IntensityMedian) && ~isempty(stru.ch2BackgroundMedian)
        outcell{18}=stru.ch2IntensityMedian-stru.ch2BackgroundMedian;
        colnames{18}='Channel 2 Foreground - Background (Median)';
    else
        outcell{18}=NaN;
        colnames{18}=NaN;
    end
    if ~isempty(stru.ch1IntensityMedian) && ~isempty(stru.ch1BackgroundMedian)
        outcell{21}=stru.ch1IntensityMedian./stru.ch1BackgroundMedian;
        colnames{21}='Channel 1 Foreground / Background (Median)';
    else
        outcell{21}=NaN;
        colnames{21}=NaN;
    end
    if ~isempty(stru.ch2IntensityMedian) && ~isempty(stru.ch2BackgroundMedian)
        outcell{22}=stru.ch2IntensityMedian./stru.ch2BackgroundMedian;
        colnames{22}='Channel 2 Foreground / Background (Median)';
    else
        outcell{22}=NaN;
        colnames{22}=NaN;
    end
end

% Remove the empty columns
remain=ones(1,23);
for i=4:length(remain)
    if isempty(colnames{i}) | isnan(colnames{i})
        remain(i)=false;
    end
end 
remain=logical(remain);
outcell=outcell(remain);
colnames=colnames(remain);

outcell_part1=mat2cell(outcell{1},ones(1,len),1);
outcell_part2=outcell{2};
outcell_part3=cell2mat(outcell(3:end-1));
outcell_part3=mat2cell(outcell_part3,ones(1,len),ones(1,size(outcell_part3,2)));
outcell_part4=mat2cell(outcell{end},ones(1,len),1);
outcell=[outcell_part1,outcell_part2,outcell_part3,outcell_part4];


function [outcell,colnames] = createCellDataTableAffy(stru)

% Function to create the cell which will be displayed in ARMADA main window for each
% array and return also the column names for Affymetrix arrays (OUT OF MEMORY...)

len=length(stru.Intensity);

% Create value table
% outcell=cell(1,8);
% outcell{1}=cast(1:len,'uint16');
% outcell{1}=outcell{1}';
% outcell{2}=cast(stru.PosX,'uint16');
% outcell{3}=cast(stru.PosY,'uint16');
% outcell{4}=cast(stru.Intensity,'uint16');
% outcell{6}=cast(stru.Pixels,'uint16');
% outcell{7}=cast(stru.Outlier,'uint16');
% outcell{8}=cast(stru.ProbeType,'uint16');

outcell=cell(1,2);
outcell{1}=1:len;
outcell{1}=outcell{1}';
% outcell{2}=stru.PosX;
% outcell{3}=stru.PosY;
outcell{2}=stru.Intensity;
outcell{3}=stru.StdDev;
% outcell{6}=stru.Pixels;
% outcell{7}=stru.Outlier;
% outcell{8}=stru.ProbeType;

if nargout>1
    % Create column names
    colnames=cell(1,3);
    colnames{1}='Probe Number';
%     colnames{2}='X Position';
%     colnames{3}='Y Position';
    colnames{2}='Mean Intensity';
    colnames{3}='StDev Intensity';
%     colnames{6}='Number of Pixels';
%     colnames{7}='Outlier';
%     colnames{8}='ProbeType';
end

outcell=cell2mat(outcell);
outcell=mat2cell(outcell,ones(1,len),ones(1,3));


function [outcell,colnames] = createCellDataTableIllu(stru)

% Function to create the cell which will be displayed in ARMADA main window for each
% array and return also the column names for Affymetrix arrays (OUT OF MEMORY...)

len=length(stru.Intensity);

outcell=cell(1,2);
outcell{1}=1:len;
outcell{1}=outcell{1}';
outcell{2}=stru.Intensity;
outcell{3}=stru.Detection;

if nargout>1
    % Create column names
    colnames=cell(1,3);
    colnames{1}='Probe Number';
    colnames{2}='Intensity';
    colnames{3}='Detection';
end

outcell=cell2mat(outcell);
outcell=mat2cell(outcell,ones(1,len),ones(1,3));


function [outcell,colnames] = createExternalDataTable(exptab,exprp,geneids)

% Function to create a table similar to the array raw table but for externally imported
% data. It will be the same for every array/replicate. Mainly it will be a replication of
% the external file adjusted to ARMADA.

% Find total size of arrays
count=0;
for i=1:length(exprp)
    for j=1:length(exprp{i})
        count=count+1;
    end
end
colnames=cell(1,2*count); % Column names for ratio-intensity pairs
datacell=cell(1,2*count); % Ratio-intensity pairs, even if intensity is NaN

% Fill them
count=0;
for i=1:length(exprp)
    for j=1:length(exprp{i})
        count=count+1;
        colnames((2*count-1):2*count)={['Ratio ',exprp{i}{j}],['Intensity ',exprp{i}{j}]};
        datacell((2*count-1):2*count)={exptab{i}{j}(:,3),exptab{i}{j}(:,1)};
    end
end
colnames=['GeneID',colnames];
datacell=cell2mat(datacell);
datacell=mat2cell(datacell,ones(size(datacell,1),1),ones(size(datacell,2),1));
outcell=[geneids,datacell];


function [headers,finaldata] = createDEListTable(exprp,sexprp,exptab,DataCellNormLo,DataCellStat,fcinds,opts)

% Function to create a data table similar to the DE list to be viewable from within
% ARMADA

if isempty(opts)
    opts.sp=true;
    opts.genenames=true;
    opts.pvalues=true;
    opts.qvalues=false;
    opts.fdr=false;
    opts.foldchange=true;
    opts.rawratio=false;
    opts.logratio=false;
    opts.meanrawratio=false;
    opts.meanlogratio=false;
    opts.medianrawratio=false;
    opts.medianlogratio=false;
    opts.stdevrawratio=false;
    opts.stdevlogratio=false;
    opts.intensity=false;
    opts.meanintensity=true;
    opts.medianintensity=false;
    opts.stdevintensity=true;
    opts.normlogratio=true;
    opts.meannormlogratio=true;
    opts.mediannormlogratio=false;
    opts.stdevnormlogratio=true;
    opts.normrawratio=false;
    opts.meannormrawratio=false;
    opts.mediannormrawratio=false;
    opts.stdevnormrawratio=false;
    opts.trustfactors=true;
    opts.cvs=true;
end

% Condition names
names=DataCellStat{6};
% Number of conditions
t=length(names);
% Find number of replicates for each condition
cellsize=size(DataCellStat{5});
repcol=zeros(size(DataCellStat{5},2));
for ind=1:cellsize(2)
    repsize=size(DataCellStat{5}{ind});
    repcol(ind)=repsize(2);
end

headers={};
% Slide Positions
if opts.sp
    headers=[headers,'Slide Positions'];
end
% Gene Names
if opts.genenames
    headers=[headers,'GeneID'];
end
% p-values
if opts.pvalues
    headers=[headers,'p-value'];
end
% FDR
if opts.fdr && ~isempty(DataCellStat{8})
    headers=[headers,'FDR'];
end
% q-values
if opts.qvalues && ~isempty(DataCellStat{8})
    headers=[headers,'q-value'];
end

% Fold changes
if opts.foldchange && length(DataCellStat)>8 && ~isempty(fcinds)
    for i=1:length(fcinds{1})
        headers=[headers,['''Fold Change (log2) ',names{fcinds{2}(i)},'vs',names{fcinds{1}(i)},''','],...
                         ['''Fold Change (natural)',names{fcinds{2}(i)},'vs',names{fcinds{1}(i)},''',']];
    end
end

for i=1:t
    % Raw Ratios
    if opts.rawratio
        for j=1:length(exprp{i})
            headers=[headers,['Raw Ratio ' exprp{i}{j}]];
        end
    end
    % Mean Raw Ratios
    if opts.meanrawratio
        headers=[headers,['Mean Raw Ratio ',names{i}]];
    end
    % Median Raw Ratios
    if opts.medianrawratio
        headers=[headers,['Median Raw Ratio ',names{i}]];
    end
    % StDev Raw Ratios
    if opts.stdevrawratio
        headers=[headers,['StDev Raw Ratio ',names{i}]];
    end
    % Log Ratios
    if opts.logratio
        for j=1:length(exprp{i})
            headers=[headers,['Log2 Ratio ' exprp{i}{j}]];
        end
    end
    % Mean Log Ratios
    if opts.meanlogratio
        headers=[headers,['Mean Log2 Ratio ',names{i}]];
    end
    % Median Log Ratios
    if opts.medianlogratio
        headers=[headers,['Median Log2 Ratio ',names{i}]];
    end
    % StDev Log Ratios
    if opts.stdevlogratio
        headers=[headers,['StDev Log2 Ratio ',names{i}]];
    end
    % Normalized Raw Ratios
    if opts.normrawratio
        for j=1:length(sexprp{i})
            headers=[headers,['Normalized Raw Ratio ' sexprp{i}{j}]];
        end
    end
    % Mean Normalized Raw Ratios
    if opts.meannormrawratio
        headers=[headers,['Mean Normalized Raw Ratio ',names{i}]];
    end
    % Median Normalized Raw Ratios
    if opts.mediannormrawratio
        headers=[headers,['Median Normalized Raw Ratio ',names{i}]];
    end
    % StDev Normalized Raw Ratios
    if opts.stdevnormrawratio
        headers=[headers,['StDev Normalized Raw Ratio ',names{i}]];
    end
    % Normalized Log2 Ratios
    if opts.normlogratio
        for j=1:length(sexprp{i})
            headers=[headers,['Normalized Log2 Ratio ' sexprp{i}{j}]];
        end
    end
    % Mean Normalized Raw Ratios
    if opts.meannormlogratio
        headers=[headers,['Mean Normalized Raw Ratio ',names{i}]];
    end
    % Median Normalized Raw Ratios
    if opts.mediannormlogratio
        headers=[headers,['Median Normalized Raw Ratio ',names{i}]];
    end
    % StDev Normalized Raw Ratios
    if opts.stdevnormlogratio
        headers=[headers,['StDev Normalized Raw Ratio ',names{i}]];
    end
    % Intensities
    if opts.intensity
        for j=1:length(exprp{i})
            headers=[headers,['Intensity ' exprp{i}{j}]];
        end
    end
    % Mean Intensites
    if opts.meanintensity
        headers=[headers,['Mean Intensity ',names{i}]];
    end
    % Median Intensity
    if opts.medianintensity
        headers=[headers,['Median Intensity ',names{i}]];
    end
    % StDev Intensity
    if opts.stdevintensity
        headers=[headers,['StDev Intensity ',names{i}]];
    end
    % Coefficients of Variation
    if opts.cvs
        headers=[headers,['CV ',names{i},]];
    end
    % Trust Factors
    if opts.trustfactors
        headers=[headers,['TF ',names{i}]];
    end
end

% Create some help variables (for the case where we have to calculate some means, medians
% etc. and they are placed in different cells)
sigsp=DataCellStat{3}; % Indices
rawratio=cell(1,t);
inten=cell(1,t);
for i=1:t
    rawratio{i}=nan(size(exptab{i}{1},1),size(exptab{i},2));
    for j=1:size(exptab{i},2)
        rawratio{i}(:,j)=exptab{i}{j}(:,3);
    end
end
for i=1:t
    inten{i}=nan(size(DataCellNormLo{3}{i}{1},1),size(DataCellNormLo{3}{i},2));
    for j=1:size(DataCellNormLo{3}{i},2)
        inten{i}(:,j)=DataCellNormLo{3}{i}{j};
    end
end

finaldata={};
% Slide Positions
if opts.sp
    finaldata=[finaldata,cast(DataCellStat{3},'uint16')];
end
% Gene Names
if opts.genenames
    finaldata=[finaldata,DataCellStat(2)];
end
% p-values
if opts.pvalues
    finaldata=[finaldata,DataCellStat{1}(:,2)];
end
% FDR
if opts.fdr && ~isempty(DataCellStat{8})
    finaldata=[finaldata,DataCellStat{8}(:,1)];
end
% q-values
if opts.qvalues && ~isempty(DataCellStat{8})
    finaldata=[finaldata,DataCellStat{8}(:,2)];
end

% Fold Changes
if opts.foldchange && length(DataCellStat)>8 && ~isempty(fcinds)
    for j=1:length(fcinds{1})
        finaldata=[finaldata,DataCellStat{9}(:,j)];
        finaldata=[finaldata,2.^DataCellStat{9}(:,j)];
    end
end

for j=1:t
    % Raw Ratios
    if opts.rawratio
        finaldata=[finaldata,2.^rawratio{j}(sigsp,:)];
    end
    % Mean Raw Ratios
    if opts.meanrawratio
        finaldata=[finaldata,nanmean(2.^rawratio{j}(sigsp,:),2)];
    end
    % Median Raw Ratios
    if opts.medianrawratio
        finaldata=[finaldata,nanmedian(2.^rawratio{j}(sigsp,:),2)];
    end
    % StDev Raw Ratios
    if opts.stdevrawratio
        finaldata=[finaldata,nanstd(2.^rawratio{j}(sigsp,:),0,2)];
    end
    % Log Ratios
    if opts.logratio
        finaldata=[finaldata,rawratio{j}(sigsp,:)];
    end
    % Mean Log Ratios
    if opts.meanlogratio
        finaldata=[finaldata,nanmean(rawratio{j}(sigsp,:),2)];
    end
    % Median Log Ratios
    if opts.medianlogratio
        finaldata=[finaldata,nanmedian(rawratio{j}(sigsp,:),2)];
    end
    % StDev Log Ratios
    if opts.stdevlogratio
        finaldata=[finaldata,nanstd(rawratio{j}(sigsp,:),0,2)];
    end
    % Normalized Raw Ratios
    if opts.normrawratio
        finaldata=[finaldata,2.^DataCellStat{5}{j}];
    end
    % Mean Normalized Raw Ratios
    if opts.meannormrawratio
        finaldata=[finaldata,mean(2.^DataCellStat{5}{j},2)];
    end
    % Median Normalized Raw Ratios
    if opts.mediannormrawratio
        finaldata=[finaldata,median(2.^DataCellStat{5}{j},2)];
    end
    % StDev Normalized Raw Ratios
    if opts.stdevnormrawratio
        finaldata=[finaldata,nanstd(2.^DataCellStat{5}{j},0,2)];
    end
    % Normalized Log2 Ratios
    if opts.normlogratio
        finaldata=[finaldata,DataCellStat{5}{j}];
    end
    % Mean Normalized Log2 Ratios
    if opts.meannormlogratio
        finaldata=[finaldata,mean(DataCellStat{5}{j},2)];
    end
    % Median Normalized Log2 Ratios
    if opts.mediannormlogratio
        finaldata=[finaldata,median(DataCellStat{5}{j},2)];
    end
    % StDev Normalized Log2 Ratios
    if opts.stdevnormlogratio
        finaldata=[finaldata,nanstd(2.^DataCellStat{5}{j},0,2)];
    end
    % Intensities
    if opts.intensity
        finaldata=[finaldata,inten{j}(sigsp,:)];
    end
    % Mean Intensites
    if opts.meanintensity
        finaldata=[finaldata,nanmean(inten{j}(sigsp,:),2)];
    end
    % Median Intensity
    if opts.medianintensity
        finaldata=[finaldata,nanmedian(inten{j}(sigsp,:),2)];
    end
    % StDev Intensity
    if opts.stdevintensity
        finaldata=[finaldata,nanstd(inten{j}(sigsp,:),0,2)];
    end
    % Coefficients of Variation
    if opts.cvs
        finaldata=[finaldata,nanstd(DataCellStat{5}{j},0,2)./mean(DataCellStat{5}{j},2)];
    end
    % Trust Factors
    if opts.trustfactors
        finaldata=[finaldata,DataCellStat{7}(:,j)];
    end
end

% Create the final cell for exporting
if opts.genenames && opts.sp % Fix problem of non-arithmetic data
    final_p1=finaldata(:,1);
    final_p1=cell2mat(final_p1);
    final_p1=mat2cell(final_p1,ones(length(final_p1),1),1);
    final_p2=finaldata{:,2};
    final_p3=finaldata(:,3:end);
    final_p3=cell2mat(final_p3);
    final_p3=mat2cell(final_p3,ones(size(final_p3,1),1),ones(size(final_p3,2),1));
    finaldata=[final_p1,final_p2,final_p3];
elseif opts.genenames && ~opts.sp % Fix problem of non-arithmetic data
    final_p2=finaldata{:,1};
    final_p3=finaldata(:,2:end);
    final_p3=cell2mat(final_p3);
    final_p3=mat2cell(final_p3,ones(size(final_p3,1),1),ones(size(final_p3,2),1));
    finaldata=[final_p2,final_p3];
else % No problem
    finaldata=cell2mat(finaldata);
    finaldata=mat2cell(finaldata,ones(size(finaldata,1),1),ones(size(finaldata,2),1));
end


function [headers,finaldata] = createNormListTable(exprp,exptab,DataCellNormLo,gnID,names,fcinds,opts)

% Function to create a data table similar to the norm list to be viewable from within
% ARMADA

if isempty(opts)
    opts.sp=true;
    opts.genenames=true;
    opts.foldchange=true;
    opts.rawratio=false;
    opts.logratio=false;
    opts.meanrawratio=false;
    opts.meanlogratio=false;
    opts.medianrawratio=false;
    opts.medianlogratio=false;
    opts.stdevrawratio=false;
    opts.stdevlogratio=false;
    opts.intensity=false;
    opts.meanintensity=true;
    opts.medianintensity=false;
    opts.stdevintensity=true;
    opts.normlogratio=true;
    opts.meannormlogratio=true;
    opts.mediannormlogratio=false;
    opts.stdevnormlogratio=true;
    opts.normrawratio=false;
    opts.meannormrawratio=false;
    opts.mediannormrawratio=false;
    opts.stdevnormrawratio=false;
    opts.cvs=true;
end

% Number of conditions
t=length(names);
% Data
slipos=1:length(gnID);
slipos=slipos';
lograt=DataCellNormLo{1};
logratnorm=DataCellNormLo{2};
inten=DataCellNormLo{3};
for i=1:length(names)
    lograt{i}=cell2mat(lograt{i});
    logratnorm{i}=cell2mat(logratnorm{i});
    inten{i}=cell2mat(inten{i});
end
rawratio=cell(1,t);
for i=1:t
    rawratio{i}=nan(size(exptab{i}{1},1),size(exptab{i},2));
    for j=1:size(exptab{i},2)
        rawratio{i}(:,j)=exptab{i}{j}(:,3);
    end
end
% Find number of replicates for each condition
cellsize=size(lograt);
repcol=zeros(size(lograt,2));
for ind=1:cellsize(2)
    repsize=size(lograt{ind});
    repcol(ind)=repsize(2);
end

headers={};
% Slide Positions
if opts.sp
    headers=[headers,'Slide Position'];
end
% Gene Names
if opts.genenames
    headers=[headers,'GeneID'];
end
% Fold changes
if opts.foldchange && length(DataCellNormLo)>6 && ~isempty(fcinds)
    for i=1:length(fcinds{1})
        headers=[headers,['''Fold Change (log2) ',names{fcinds{2}(i)},'vs',names{fcinds{1}(i)},''','],...
                         ['''Fold Change (natural)',names{fcinds{2}(i)},'vs',names{fcinds{1}(i)},''',']];
    end
end
for i=1:t
    % Raw Ratios
    if opts.rawratio
        for j=1:length(exprp{i})
            headers=[headers,['Raw Ratio ' exprp{i}{j}]];
        end
    end
    % Mean Raw Ratios
    if opts.meanrawratio
        headers=[headers,['Mean Raw Ratio ',names{i}]];
    end
    % Median Raw Ratios
    if opts.medianrawratio
        headers=[headers,['Median Raw Ratio ',names{i}]];
    end
    % StDev Raw Ratios
    if opts.stdevrawratio
        headers=[headers,['StDev Raw Ratio ',names{i}]];
    end
    % Log Ratios
    if opts.logratio
        for j=1:length(exprp{i})
            headers=[headers,['Log2 Ratio ' exprp{i}{j}]];
        end
    end
    % Mean Log Ratios
    if opts.meanlogratio
        headers=[headers,['Mean Log2 Ratio ',names{i}]];
    end
    % Median Log Ratios
    if opts.medianlogratio
        headers=[headers,['Median Log2 Ratio ',names{i}]];
    end
    % StDev Log Ratios
    if opts.stdevlogratio
        headers=[headers,['StDev Log2 Ratio ',names{i}]];
    end
    % Normalized Raw Ratios
    if opts.normrawratio
        for j=1:length(exprp{i})
            headers=[headers,['Normalized Raw Ratio ' exprp{i}{j}]];
        end
    end
    % Mean Normalized Raw Ratios
    if opts.meannormrawratio
        headers=[headers,['Mean Normalized Raw Ratio ',names{i}]];
    end
    % Median Normalized Raw Ratios
    if opts.mediannormrawratio
        headers=[headers,['Median Normalized Raw Ratio ',names{i}]];
    end
    % StDev Normalized Raw Ratios
    if opts.stdevnormrawratio
        headers=[headers,['StDev Normalized Raw Ratio ',names{i}]];
    end
    % Normalized Log2 Ratios
    if opts.normlogratio
        for j=1:length(exprp{i})
            headers=[headers,['Normalized Log2 Ratio ' exprp{i}{j}]];
        end
    end
    % Mean Normalized Raw Ratios
    if opts.meannormlogratio
        headers=[headers,['Mean Normalized Raw Ratio ',names{i}]];
    end
    % Median Normalized Raw Ratios
    if opts.mediannormlogratio
        headers=[headers,['Median Normalized Raw Ratio ',names{i}]];
    end
    % StDev Normalized Raw Ratios
    if opts.stdevnormlogratio
        headers=[headers,['StDev Normalized Raw Ratio ',names{i}]];
    end
    % Intensities
    if opts.intensity
        for j=1:length(exprp{i})
            headers=[headers,['Intensity ' exprp{i}{j}]];
        end
    end
    % Mean Intensites
    if opts.meanintensity
        headers=[headers,['Mean Intensity ',names{i}]];
    end
    % Median Intensity
    if opts.medianintensity
        headers=[headers,['Median Intensity ',names{i}]];
    end
    % StDev Intensity
    if opts.stdevintensity
        headers=[headers,['StDev Intensity ',names{i}]];
    end
    % Coefficients of Variation
    if opts.cvs
        headers=[headers,['CV ',names{i},]];
    end
end

finaldata=[];
% Slide Positions
if opts.sp
    %slp=mat2cell(slipos,ones(size(slipos)),1);
    finaldata=[finaldata,slipos];
end
% Fold Changes
if opts.foldchange && length(DataCellNormLo)>6 && ~isempty(fcinds)
    for j=1:length(fcinds{1})
        finaldata=[finaldata,DataCellNormLo{7}(:,j)];
        finaldata=[finaldata,2.^DataCellNormLo{7}(:,j)];
    end
end
for j=1:t
    % Raw Ratios
    if opts.rawratio
        finaldata=[finaldata,2.^rawratio{j}(slipos,:)];
    end
    % Mean Raw Ratios
    if opts.meanrawratio
        finaldata=[finaldata,nanmean(2.^rawratio{j}(slipos,:),2)];
    end
    % Median Raw Ratios
    if opts.medianrawratio
        finaldata=[finaldata,nanmedian(2.^rawratio{j}(slipos,:),2)];
    end
    % StDev Raw Ratios
    if opts.stdevrawratio
        finaldata=[finaldata,nanstd(2.^rawratio{j}(slipos,:),0,2)];
    end
    % Log Ratios
    if opts.logratio
        finaldata=[finaldata,rawratio{j}(slipos,:)];
    end
    % Mean Log Ratios
    if opts.meanlogratio
        finaldata=[finaldata,nanmean(rawratio{j}(slipos,:),2)];
    end
    % Median Log Ratios
    if opts.medianlogratio
        finaldata=[finaldata,nanmedian(rawratio{j}(slipos,:),2)];
    end
    % StDev Log Ratios
    if opts.stdevlogratio
        finaldata=[finaldata,nanstd(rawratio{j}(slipos,:),0,2)];
    end
    % Normalized Raw Ratios
    if opts.normrawratio
        finaldata=[finaldata,2.^logratnorm{j}];
    end
    % Mean Normalized Raw Ratios
    if opts.meannormrawratio
        finaldata=[finaldata,nanmean(2.^logratnorm{j},2)];
    end
    % Median Normalized Raw Ratios
    if opts.mediannormrawratio
        finaldata=[finaldata,nanmedian(2.^logratnorm{j},2)];
    end
    % StDev Normalized Raw Ratios
    if opts.stdevnormrawratio
        finaldata=[finaldata,nanstd(2.^logratnorm{j},0,2)];
    end
    % Normalized Log2 Ratios
    if opts.normlogratio
        finaldata=[finaldata,logratnorm{j}];
    end
    % Mean Normalized Log2 Ratios
    if opts.meannormlogratio
        finaldata=[finaldata,nanmean(logratnorm{j},2)];
    end
    % Median Normalized Log2 Ratios
    if opts.mediannormlogratio
        finaldata=[finaldata,nanmedian(logratnorm{j},2)];
    end
    % StDev Normalized Log2 Ratios
    if opts.stdevnormlogratio
        finaldata=[finaldata,nanstd(logratnorm{j},0,2)];
    end
    % Intensities
    if opts.intensity
        finaldata=[finaldata,inten{j}(slipos,:)];
    end
    % Mean Intensites
    if opts.meanintensity
        finaldata=[finaldata,nanmean(inten{j}(slipos,:),2)];
    end
    % Median Intensity
    if opts.medianintensity
        finaldata=[finaldata,nanmedian(inten{j}(slipos,:),2)];
    end
    % StDev Intensity
    if opts.stdevintensity
        finaldata=[finaldata,nanstd(inten{j}(slipos,:),0,2)];
    end
    % Coefficients of Variation
    if opts.cvs
        finaldata=[finaldata,nanstd(logratnorm{j},0,2)./nanmean(logratnorm{j},2)];
    end
end

% Create the final cell for viewing
if opts.genenames % Fix problem of non-arithmetic data
    if opts.sp
        final_p1=finaldata(:,1);
        final_p1=mat2cell(final_p1,ones(length(final_p1),1),1);
        final_p2=gnID;
        final_p3=finaldata(:,2:end);
        final_p3=mat2cell(final_p3,ones(size(final_p3,1),1),ones(size(final_p3,2),1));
        finaldata=[final_p1,final_p2,final_p3];
    else
        finaldata=[gnID,num2cell(finaldata)];
    end
else % No problem
    finaldata=mat2cell(finaldata,ones(size(finaldata,1),1),ones(size(finaldata,2),1));
end


function vdata = retrieveArrayData(wh,normcell,tab,stru,m,n)

% Function to create data vectors for array plots based on ARMADA structures

if isempty(stru)
    wh=1;
end

% Create data
switch wh
    case 1 % Ratio
        vdata=normcell{2}{m}{n};
    case 2 % Intensity
        vdata=normcell{3}{m}{n};
    case 3 % Channel 1 Foreground Mean
        vdata=stru{m}{n}.ch1Intensity;
    case 4 % Channel 2 Foreground Mean
        vdata=stru{m}{n}.ch2Intensity;
    case 5 % Channel 1 Foreground Median
        vdata=stru{m}{n}.ch1IntensityMedian;
    case 6 % Channel 2 Foreground Median
        vdata=stru{m}{n}.ch2IntensityMedian;
    case 7 % Channel 1 Background Mean
        vdata=stru{m}{n}.ch1Background;
    case 8 % Channel 2 Background Mean
        vdata=stru{m}{n}.ch2Background;
    case 9 % Channel 1 Background Median
        vdata=stru{m}{n}.ch1BackgroundMedian;
    case 10 % Channel 2 Background Median
        vdata=stru{m}{n}.ch2BackgroundMedian;
    case 11 % Channel 1 Foreground Standard Deviation
        vdata=stru{m}{n}.ch1IntensityStd;
    case 12 % Channel 2 Foreground Standard Deviation
        vdata=stru{m}{n}.ch2IntensityStd;
    case 13 % Channel 1 Background Standard Deviation
        vdata=stru{m}{n}.ch1BackgroundStd;
    case 14 % Channel 2 Background Standard Deviation
        vdata=stru{m}{n}.ch2BackgroundStd;
    case 15 % Channel 1 Foreground - Background (Mean)
        vdata=stru{m}{n}.ch1Intensity-stru{m}{n}.ch1Background;
    case 16 % Channel 2 Foreground - Background (Mean)
        vdata=stru{m}{n}.ch2Intensity-stru{m}{n}.ch2Background;
    case 17 % Channel 1 Foreground - Background (Median)
        vdata=stru{m}{n}.ch1IntensityMedian-stru{m}{n}.ch1BackgroundMedian;
    case 18 % Channel 2 Foreground - Background (Median)
        vdata=stru{m}{n}.ch2IntensityMedian-stru{m}{n}.ch2BackgroundMedian;
    case 19 % Channel 1 Foreground/Background (Mean)
        vdata=stru{m}{n}.ch1Intensity./stru{m}{n}.ch1Background;
    case 20 % Channel 2 Foreground/Background (Mean)
        vdata=stru{m}{n}.ch2Intensity./stru{m}{n}.ch2Background;
    case 21 % Channel 1 Foreground/Background (Median)
        vdata=stru{m}{n}.ch1IntensityMedian./stru{m}{n}.ch1BackgroundMedian;
    case 22 % Channel 2 Foreground - Background (Median)
        vdata=stru{m}{n}.ch2IntensityMedian./stru{m}{n}.ch2BackgroundMedian;
    % Start Affymetrix
    case 101 % Intensity
        vdata=stru{m}{n}.Intensity;
    case 102 % StdDev
        vdata=stru{m}{n}.StdDev;
    case 103 % PM
        vdata=tab{m}{n}(:,1);
    case 104 % MM
        vdata=tab{m}{n}(:,2);
    case 105 % Back PM
        vdata=tab{m}{n}(:,3);
    case 106 % Norm MM
        vdata=tab{m}{n}(:,4);
    case 107 % Expression (raw)
        vdata=normcell{1}{m}{n};
    case 108 % Expression (back)
        vdata=normcell{3}{m}{n};
    case 109 % Expression (norm)
        vdata=normcell{2}{m}{n};
    % Start Illumina
    case 201 % Expression (raw)
        try
            vdata=normcell{1}{m}{n};
        catch
            vdata=stru{m}{n}.Intensity;
        end
    case 202 % Expression (back)
        try
            vdata=normcell{3}{m}{n};
        catch
            vdata=stru{m}{n}.Intensity;
        end
    case 203 % Expression (norm)
        try
            vdata=normcell{2}{m}{n};
        catch
            vdata=stru{m}{n}.Intensity;
        end
end


function data = createBoxplotData(wh,datagiv,stru,m,n)

% Function to create a data matrix for boxplots based on ARMADA structures

if nargin==4
    array=false;
elseif nargin==5
    array=true;
end

data=cell(1,length(m));

% If stru is empty then data are external, only ratio can be plotted (boxplot editor will
% return 1 anyway for plotting... but just to be sure...)
if isempty(stru)
    wh=1;
end

% Create data
if array
    
    switch wh
        case 1 % Ratio
            for i=1:length(m)
                data{i}=datagiv{m(i)}{n(i)};
            end
            data=cell2mat(data);
        case 2 % Channel 1 Foreground Mean
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch1Intensity;
            end
            data=cell2mat(data);
        case 3 % Channel 2 Foreground Mean
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch2Intensity;
            end
            data=cell2mat(data);
        case 4 % Channel 1 Foreground Median
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch1IntensityMedian;
            end
            data=cell2mat(data);
        case 5 % Channel 2 Foreground Median
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch2IntensityMedian;
            end
            data=cell2mat(data);
        case 6 % Channel 1 Background Mean
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch1Background;
            end
            data=cell2mat(data);
        case 7 % Channel 2 Background Mean
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch2Background;
            end
            data=cell2mat(data);
        case 8 % Channel 1 Background Median
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch1BackgroundMedian;
            end
            data=cell2mat(data);
        case 9 % Channel 2 Background Median
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch2BackgroundMedian;
            end
            data=cell2mat(data);
        case 10 % Channel 1 Foreground Standard Deviation
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch1IntensityStd;
            end
            data=cell2mat(data);
        case 11 % Channel 2 Foreground Standard Deviation
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch2IntensityStd;
            end
            data=cell2mat(data);
        case 12 % Channel 1 Background Standard Deviation
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch1BackgroundStd;
            end
            data=cell2mat(data);
        case 13 % Channel 2 Background Standard Deviation
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch2BackgroundStd;
            end
            data=cell2mat(data);
        case 14 % Channel 1 Foreground - Background (Mean)
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch1Intensity-...
                        stru{m(i)}{n(i)}.ch1Background;
            end
            data=cell2mat(data);
        case 15 % Channel 2 Foreground - Background (Mean)
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch2Intensity-...
                        stru{m(i)}{n(i)}.ch2Background;
            end
            data=cell2mat(data);
        case 16 % Channel 1 Foreground - Background (Median)
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch1IntensityMedian-...
                        stru{m(i)}{n(i)}.ch1BackgroundMedian;
            end
            data=cell2mat(data);
        case 17 % Channel 2 Foreground - Background (Median)
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch2IntensityMedian-...
                        stru{m(i)}{n(i)}.ch2BackgroundMedian;
            end
            data=cell2mat(data);
        case 18 % Channel 1 Foreground/Background (Mean)
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch1Intensity./...
                        stru{m(i)}{n(i)}.ch1Background;
            end 
            data=cell2mat(data);
        case 19 % Channel 2 Foreground/Background (Mean)
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch2Intensity./...
                        stru{m(i)}{n(i)}.ch2Background;
            end
            data=cell2mat(data);
        case 20 % Channel 1 Foreground/Background (Median)
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch1IntensityMedian./...
                        stru{m(i)}{n(i)}.ch1BackgroundMedian;
            end
            data=cell2mat(data);
        case 21 % Channel 2 Foreground - Background (Median)
            for i=1:length(m)
                data{i}=stru{m(i)}{n(i)}.ch2IntensityMedian./...
                        stru{m(i)}{n(i)}.ch2BackgroundMedian;
            end
            data=cell2mat(data);
    end
    
else
    
    switch wh
        case 1 % Ratio
            for i=1:length(m)
                data{i}=cell2mat(datagiv{m(i)});
            end
            data=cell2mat(data);
        case 2 % Channel 1 Foreground Mean
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch1Intensity;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 3 % Channel 2 Foreground Mean
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch2Intensity;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 4 % Channel 1 Foreground Median
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch1IntensityMedian;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 5 % Channel 2 Foreground Median
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch2IntensityMedian;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 6 % Channel 1 Background Mean
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch1Background;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 7 % Channel 2 Background Mean
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch2Background;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 8 % Channel 1 Background Median
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch1BackgroundMedian;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 9 % Channel 2 Background Median
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch2BackgroundMedian;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 10 % Channel 1 Foreground Standard Deviation
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch1IntensityStd;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 11 % Channel 2 Foreground Standard Deviation
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch2IntensityStd;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 12 % Channel 1 Background Standard Deviation
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch1BackgroundStd;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 13 % Channel 2 Background Standard Deviation
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch2BackgroundStd;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 14 % Channel 1 Foreground - Background (Mean)
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch1Intensity-...
                            stru{m(i)}{j}.ch1Background;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 15 % Channel 2 Foreground - Background (Mean)
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch2Intensity-...
                            stru{m(i)}{j}.ch2Background;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 16 % Channel 1 Foreground - Background (Median)
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch1IntensityMedian-...
                            stru{m(i)}{j}.ch1BackgroundMedian;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 17 % Channel 2 Foreground - Background (Median)
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch2IntensityMedian-...
                            stru{m(i)}{j}.ch2BackgroundMedian;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 18 % Channel 1 Foreground/Background (Mean)
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch1Intensity./...
                            stru{m(i)}{j}.ch1Background;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 19 % Channel 2 Foreground/Background (Mean)
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch2Intensity./...
                            stru{m(i)}{j}.ch2Background;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 20 % Channel 1 Foreground/Background (Median)
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch1IntensityMedian./...
                            stru{m(i)}{j}.ch1BackgroundMedian;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
        case 21 % Channel 2 Foreground - Background (Median)
            for i=1:length(m)
                temp=cell(1,length(stru{m(i)}));
                for j=1:length(stru{m(i)})
                    temp{j}=stru{m(i)}{j}.ch2IntensityMedian./...
                            stru{m(i)}{j}.ch2BackgroundMedian;
                end
                data{i}=cell2mat(temp);
            end
            data=cell2mat(data);
    end
    
end


function [m,k] = findOptGrid(n)

% Find optimal grid size for multicluster plots

m=0;
while n>m*m
    m=m+1;
end
if n<m*m
    k=m-1;
    if n>m*k
        k=k+1;
    else
        while n>m*k
            k=k-1;
        end
    end
else
    k=m;
end


function uid = createUniqueID(id)

% Function to rename gene names in case of of multiplicate names. It is needed
% to create a dataset for exporting to MATLAB. The input is a cell array of
% strings.

[sid,idx]=sort(id);
[a,b,c]=unique(sid);
q=find(diff(c)==0);

% Preallocate cellblocksize to length of id
cellblocksize=zeros(1,length(id));
j=1;
cellblocksize(j)=1;
for i=1:length(q)-1
    if q(i)+1==q(i+1)
        cellblocksize(j)=cellblocksize(j)+1;
    else
        j=j+1;
        cellblocksize(j)=1;
    end
end
cellblocksize(cellblocksize==0)=[];
cq=mat2cell(q,cellblocksize,1);

% Replace
for i=1:length(cq)
    inds=cq{i};
    for j=1:length(inds)
        sid{inds(j)+1}=[sid{inds(j)+1},'_',num2str(j)];
    end
end

% Return to original state
[sidx,idxx]=sort(idx);
uid=sid(idxx);


function opts = change2AffyExport

opts.sp=false;
opts.genenames=true;
opts.pvalues=true;
opts.qvalues=false;
opts.fdr=false;
opts.foldchange=true;
opts.rawint=false;
opts.meanrawint=false;
opts.medianrawint=false;
opts.stdevrawint=false;
opts.backint=false;
opts.meanbackint=false;
opts.medianbackint=false;
opts.stdevbackint=false;
opts.normint=true;
opts.meannormint=true;
opts.mediannormint=false;
opts.stdevnormint=true;
opts.trustfactors=true;
opts.cvs=true;
opts.calls=true;
opts.scale.natural=false;
opts.scale.log=false;
opts.scale.log2=true;
opts.scale.log10=false;
opts.outtype='text';


function opts = change2cDNAExport

opts.sp=true;
opts.genenames=true;
opts.pvalues=true;
opts.qvalues=false;
opts.fdr=false;
opts.foldchange=true;
opts.rawratio=false;
opts.logratio=false;
opts.meanrawratio=false;
opts.meanlogratio=false;
opts.medianrawratio=false;
opts.medianlogratio=false;
opts.stdevrawratio=false;
opts.stdevlogratio=false;
opts.intensity=false;
opts.meanintensity=true;
opts.medianintensity=false;
opts.stdevintensity=true;
opts.normlogratio=true;
opts.meannormlogratio=true;
opts.mediannormlogratio=false;
opts.stdevnormlogratio=true;
opts.normrawratio=false;
opts.meannormrawratio=false;
opts.mediannormrawratio=false;
opts.stdevnormrawratio=false;
opts.trustfactors=true;
opts.cvs=true;
opts.outtype='text';
handles.exportSettings=opts;


function out = randomint(varargin)

% Create random integers of range [1 n]

% Basic function setup.
error(nargchk(0,4,nargin));

% Placeholder for the signature string.
sigStr='';
m=[];
n=[];
range=[];
state=[];

% Identify string and numeric arguments
for i=1:nargin
   if(i>1)
      sigStr(size(sigStr,2)+1) = '/';
   end
   % Assign the string and numeric flags
   if(isnumeric(varargin{i}))
      sigStr(size(sigStr,2)+1) = 'n';
   else
      error('Only numeric arguments are accepted.');
   end
end

% Identify parameter signitures and assign values to variables
switch sigStr
   case '' % randomint
       % Nothing
   case 'n' % randomint(m)
      m=varargin{1};
	case 'n/n' % randomint(m, n)
      m=varargin{1};
      n=varargin{2};
	case 'n/n/n' % randomint(m, n, range)
      m=varargin{1};
      n=varargin{2};
      range=varargin{3};
	case 'n/n/n/n' % randomint(m, n, range, state)
      m=varargin{1};
      n=varargin{2};
      range=varargin{3};
      state=varargin{4};
    otherwise % If the parameter list does not match one of these signatures
      error('Syntax error.');
end

if isempty(m)
   m=1;
end
if isempty(n)
   n=m;
end
if isempty(range)
   range=[0, 1];
end

len_range=size(range,1)*size(range,2);

% Typical error-checking.
if (~isfinite(m)) | (~isfinite(n))
   error('Matrix dimensions must be finite.');
elseif (floor(m)~=m) | (floor(n)~=n) || (~isreal(m)) | (~isreal(n))
   error('Matrix dimensions must be real integers.');
elseif (m<0) | (n<0)
   error('Matrix dimensions must be positive.');
elseif (length(m)>1) | (length(n)>1)
   error('Matrix dimensions must be scalars.');
elseif len_range>2
   error('The IRANGE parameter should contain no more than two elements.');
elseif max(max(floor(range)~=range)) | (~isreal(range)) | (~isfinite(range))
   error('The IRANGE parameter must only contain real finite integers.');
end

% If the IRANGE is specified as a scalar.
if len_range<2
	if range<0
       range=[range+1,0];
    elseif range>0
       range=[0,range-1];
    else
       range=[0,0];    % Special case of zero range.
    end
end

% Make sure IRANGE is ordered properly.
range=sort(range);

% Calculate the range the distance for the random number generator.
distance=range(2)-range(1);

% Set the initial state if specified.
if ~isempty(state)
   rand('state',state);
end

% Generate the random numbers.
r=floor(rand(m,n)*(distance+1));

% Offset the numbers to the specified value.
out=ones(m,n)*range(1);
out=out+r;


function rotateIfLong(xticks,deg)

% Rotate the x-axis labels if everything very long. Argument xticks is a cell array of
% strings ONLY (preferably, the XTickLabel property of current axis). Do not use in other
% types than cell arrays of strings. Will generate error. Default rotation, 90 degrees.

if nargin<2
    deg=90;
end

fs=get(gca,'FontSize');
fw=get(gca,'FontWeight');
fn=get(gca,'FontName');

lens=zeros(1,length(xticks));
for i=1:length(xticks)
    lens(i)=length(xticks{i});
end
if (max(lens)>20 && length(xticks)>2) || ...
   (max(lens)>10 && length(xticks)>5) || ...
   length(xticks)>10
    rotateXTickLabel([],deg,[],'Interpreter','none',...
                               'FontName',fn,...
                               'FontSize',fs,...
                               'FontWeight',fw);
end


function enablecDNAItems(stru)

% Enable raw table view... too much memory
set(stru.arrayRawButton,'Enable','on')
set(stru.viewRawData,'Enable','on')
% Enable raw table view... OUT OF MEMORY...
set(stru.arrayRawButton,'Enable','on')
set(stru.viewRawData,'Enable','on')
set(stru.arrayContextData,'Enable','on')
% Disable cDNA preprocessing options
set(stru.preprocessBackground,'Visible','on')
set(stru.preprocessFilter,'Visible','on')
set(stru.preprocessNormalization,'Visible','on')
% Disable cDNA plots
set(stru.plotsNormUnnorm,'Visible','on')
set(stru.plotsMA,'Visible','on')
set(stru.plotsSlideDistrib,'Visible','on')
set(stru.plotsBoxplot,'Visible','on')


function disablecDNAItems(stru)

% Disable raw table view... too much memory
set(stru.arrayRawButton,'Enable','off')
set(stru.viewRawData,'Enable','off')
% Disable raw table view... OUT OF MEMORY...
set(stru.arrayRawButton,'Enable','off')
set(stru.viewRawData,'Enable','off')
set(stru.arrayContextData,'Enable','off')
% Disable cDNA preprocessing options
set(stru.preprocessBackground,'Visible','off')
set(stru.preprocessFilter,'Visible','off')
set(stru.preprocessNormalization,'Visible','off')
% Disable cDNA plots
set(stru.plotsNormUnnorm,'Visible','off')
set(stru.plotsMA,'Visible','off')
set(stru.plotsSlideDistrib,'Visible','off')
set(stru.plotsBoxplot,'Visible','off')


function enableAffyItems(stru)

% Enable Affy preprocessing options
set(stru.preprocessAffyBackNormSum,'Visible','on')
set(stru.preprocessAffyFiltering,'Visible','on')
% Enable Affy plots
set(stru.plotsMAAffy,'Visible','on')
set(stru.plotsSlideDistribAffy,'Visible','on')
set(stru.plotsBoxplotAffy,'Visible','on')


function disableAffyItems(stru)

% Enable Affy preprocessing options
set(stru.preprocessAffyBackNormSum,'Visible','off')
set(stru.preprocessAffyFiltering,'Visible','off')
% Enable Affy plots
set(stru.plotsMAAffy,'Visible','off')
set(stru.plotsSlideDistribAffy,'Visible','off')
set(stru.plotsBoxplotAffy,'Visible','off')


function enableIlluItems(stru)

% Enable Illumina preprocessing options
set(stru.preprocessFilteringIllu,'Visible','on')
set(stru.preprocessNormalizationIllu,'Visible','on')
% Enable Illu plots
set(stru.plotsMAAffy,'Visible','on')
set(stru.plotsSlideDistribAffy,'Visible','on')
set(stru.plotsBoxplotAffy,'Visible','on')


function disableIlluItems(stru)

% Disable Illumina preprocessing options
set(stru.preprocessFilteringIllu,'Visible','off')
set(stru.preprocessNormalizationIllu,'Visible','off')
% Enable Illu plots
set(stru.plotsMAAffy,'Visible','on')
set(stru.plotsSlideDistribAffy,'Visible','on')
set(stru.plotsBoxplotAffy,'Visible','on')


function [hmenu,hbtn] = disableActive

% Find active menus and buttons
hmenu=findobj('Type','uimenu','Enable','on');
hbtn=findobj('Style','pushbutton','Enable','on');
% Disable them
set(hmenu,'Enable','off')
set(hbtn,'Enable','off')


function enableActive(hmenu,hbtn)

% Enable items
set(hmenu,'Enable','on')
set(hbtn,'Enable','on')


function stru = reinit(stru)

% Function to reinitiate the handles structure in case of a new project

% Re-inititialize the main structure (handles)
stru.version=stru.currentVersion;
if isfield(stru,'experimentInfo')
    stru=rmfield(stru,'experimentInfo');
end
if isfield(stru,'analysisInfo')
    stru=rmfield(stru,'analysisInfo');
end
if isfield(stru,'Project')
    stru=rmfield(stru,'Project');
end
if isfield(stru,'datstruct')
    stru=rmfield(stru,'datstruct');
end
if isfield(stru,'selectConditionsIndex')
    stru.selectConditionsIndex=1;
end
if isfield(stru,'currentSelectionIndex')
    stru.currentSelectionIndex=1;
end
if isfield(stru,'selectedConditions')
    stru=rmfield(stru,'selectedConditions');
end
if isfield(stru,'mainmsg')
    stru=rmfield(stru,'mainmsg');
end
if isfield(stru,'attributes')
    stru=rmfield(stru,'attributes');
end
if isfield(stru,'notes')
    stru.notes={};
end
if isfield(stru,'cdfstruct')
    stru=rmfield(stru,'cdfstruct');
end
if isfield(stru,'tree')
    if ishandle(stru.tree)
        delete(stru.tree);
    end
    stru=rmfield(stru,'tree');
end
% For compatibility only
if isfield(stru,'gnID')
    stru=rmfield(stru,'gnID');
end
if isfield(stru,'Image')
    if ishandle(stru.Image.ax)
        delete(stru.Image.ax);
    end
    if ishandle(stru.Image.him)
        delete(stru.Image.him);
    end
    if ishandle(stru.Image.hscroll)
        delete(stru.Image.hscroll);
    end
    if ishandle(stru.Image.hmove)
        delete(stru.Image.hmove);
    end
    if ishandle(stru.Image.hmag)
        delete(stru.Image.hmag);
    end
    stru=rmfield(stru,'Image');
end
if isfield(stru,'Table')
    if ishandle(stru.Table)
        delete(stru.Table);
        stru=rmfield(stru,'Table');
    end
end

% Hide project explorer items
set(stru.projExpStatic,'Visible','off')
set(stru.itemInfoEdit,'Visible','off','String','')

% Manage menus
set(stru.mainTextbox,'String','')
set(stru.fileSaveAs,'Enable','off')
set(stru.fileSave,'Enable','off')
set(stru.fileDataExport,'Enable','off')
set(stru.preprocess,'Enable','off')
set(stru.stats,'Enable','off')
set(stru.plots,'Enable','off')
set(stru.plotsExprProfile,'Enable','off')
set(stru.statsFoldChangeCalc,'Enable','off')
set(stru.toolsPCA,'Enable','off')
set(stru.toolsGap,'Enable','off')
set(stru.statsClassification,'Enable','off')

% Manage listboxes
set(stru.analysisObjectList,'Value',1,'String','')
set(stru.arrayObjectList,'Value',1,'String','')

% Manage buttons
set(stru.rawImageButton,'Enable','off')
set(stru.normImageButton,'Enable','off')
set(stru.arrayRawButton,'Enable','off')
set(stru.DEListButton,'Enable','off')
set(stru.clusterListButton,'Enable','off')
set(stru.exportClusterList,'Enable','off')
set(stru.exportListButton,'Enable','off')

% Manage context menus
set(stru.arrayContextImage,'Enable','off')
set(stru.arrayContextData,'Enable','off')
set(stru.arrayContextNormImage,'Enable','off')
set(stru.arrayContextReport,'Enable','off')
set(stru.analysisContextNormList,'Enable','off')
set(stru.analysisContextDEList,'Enable','off')
set(stru.analysisContextClusterList,'Enable','off')
set(stru.analysisContextExportNormList,'Enable','off')
set(stru.analysisContextExportDEList,'Enable','off')
set(stru.analysisContextExportClusterList,'Enable','off')
set(stru.analysisContextReport,'Enable','off')
