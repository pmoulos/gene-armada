function varargout = AnalysisViewAffy(varargin)
% ANALYSISVIEWAFFY M-file for AnalysisViewAffy.fig
%      ANALYSISVIEWAFFY, by itself, creates a new ANALYSISVIEWAFFY or raises the existing
%      singleton*.
%
%      H = ANALYSISVIEWAFFY returns the handle to a new ANALYSISVIEWAFFY or the handle to
%      the existing singleton*.
%
%      ANALYSISVIEWAFFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSISVIEWAFFY.M with the given input arguments.
%
%      ANALYSISVIEWAFFY('Property','Value',...) creates a new ANALYSISVIEWAFFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnalysisViewAffy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnalysisViewAffy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnalysisViewAffy

% Last Modified by GUIDE v2.5 21-Nov-2008 18:56:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnalysisViewAffy_OpeningFcn, ...
                   'gui_OutputFcn',  @AnalysisViewAffy_OutputFcn, ...
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


% --- Executes just before AnalysisViewAffy is made visible.
function AnalysisViewAffy_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.AnalysisViewAffy,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.AnalysisViewAffy,'Position',winpos);

% Get inputs
handles.ind=varargin{1};
backnormsum=varargin{2};
filtering=varargin{3};
selectconditions=varargin{4};
statistics=varargin{5};
clustering=varargin{6};

% Correct title
set(handles.titleStatic,'String',['Details for Analysis ',num2str(handles.ind)])

% Start filling textbox
if ~isempty(selectconditions)
    % Find number of slides
    count=0;
    index=0;
    
    maxes=cell(1,selectconditions.number);
    maxesall=cell(1,selectconditions.number);
    for i=1:selectconditions.number
        for j=1:length(selectconditions.exprp{i})
            maxes{i}=[maxes{i},length(selectconditions.exprp{i}{j})];
        end
        maxesall{i}=max(maxes{i});
    end
    for i=1:selectconditions.number
        count=count+size(selectconditions.exprp{i},2);
        datatable{1,i}=selectconditions.names{i};
        for j=1:max(size(selectconditions.exprp{i}))
            index=index+1;
            arrays{index}=selectconditions.exprp{i}{j};
            datatable{2+j,i}=[selectconditions.exprp{i}{j},...
                              repmat(' ',[1 maxesall{i}-length(selectconditions.exprp{i}{j})]),'|'];
        end
    end   
    maintext={'General Information';'----------------------------------------';' ';...
              ['Number of Conditions : ',num2str(selectconditions.number)];' ';...
              'Condition Names : ';char(selectconditions.names);' ';...
              ['Number of Arrays : ',num2str(count)];' ';...
              'Array Names : ';char(arrays);' ';...
              'Structure summary (1st row contains the condition names, the rest the slides of each condition)';
              ' ';'------------------------------------------------------------';...
              matfromcell(datatable,0);...
              '------------------------------------------------------------';' ';' '}; 
else
    maintext='';
end

if ~isempty(backnormsum)

    switch backnormsum.backmethod
        case 'rma'
            bl1=['Background Adjustment Method : ',backnormsum.backname];
            bl2='Background Adjustment Options :';
            bl3=['Truncate distribution : ',log2lang(backnormsum.backopts.trunc)];
            bl4='';bl5='';bl6='';bl7='';bl8='';bl9='';bl10='';bl11='';
        case 'gcrma'
            bl1=['Background Adjustment Method : ',backnormsum.backname];
            bl2='Background Adjustment Options :';
            bl3=['Optical correction : ',log2lang(backnormsum.backopts.optcorr)];
            bl4=['Gene specific binding correction : ',log2lang(backnormsum.backopts.gsbcorr)];
            bl5=['Add signal variance : ',log2lang(backnormsum.backopts.addvar)];
            bl6=['Correlation coefficient constant : ',num2str(backnormsum.backopts.corrconst)];
            bl7=['Signal estimation method : ',backnormsum.backopts.method];
            bl8=['Tuning parameter : ',num2str(backnormsum.backopts.tuningpar)];
            bl9=['Calculate affinities for each chip : ',log2lang(backnormsum.backopts.eachaffin)];
            bl10=backnormsum.backopts.seqfile;
            bl11=backnormsum.backopts.affinfile;
        case 'plier'
            % When we implement...
        case 'none'
            bl1=['Background Adjustment Method : ' backnormsum.backname];
            bl2='';bl3='';bl4='';bl5='';bl6='';bl7='';bl8='';bl9='';bl10='';bl11='';
    end
    
    switch backnormsum.normmethod
        case 'quantile'
            nl1=['Normalization Method : ' backnormsum.normname];
            nl2='Normalization Options :';
            nl3=['Use median : ',log2lang(backnormsum.normopts.usemedian)];
            nl4='';nl5='';nl6='';nl7='';nl8='';
        case 'rankinvariant'
            nl1=['Normalization Method : ' backnormsum.normname];
            nl2='Normalization Options :';
            nl3=['Rank thresholds : ',num2str(backnormsum.normopts.lowrank),' ',num2str(backnormsum.normopts.uprank)];
            nl4=['Higher or lower average rank exclusion position : ',num2str(backnormsum.normopts.maxdata)];
            nl5=['Maximum percentage of genes included in the rank invariant set : ',num2str(backnormsum.normopts.maxinvar)];
            if backnormsum.normopts.baseline==-1
                nl6='Baseline array : Median of medians';
            else
                nl6=['Baseline array : ',arrays{backnormsum.normopts.baseline}];
            end
            nl7=['Data smoothing : ',backnormsum.normopts.method];
            nl8=['Span for data smoothing : ',num2str(backnormsum.normopts.span)];
        case 'none'
            nl1=['Normalization Method : ' backnormsum.normname];
            nl2='';nl3='';nl4='';nl5='';nl6='';nl7='';nl8='';
    end
    
    switch backnormsum.summmethod
        case 'medianpolish'
            sl1=['Summarization Method : ' backnormsum.summname];
            sl2='Summarization Options :';
            sl3=['Output values : ',backnormsum.summopts.output];
        case 'mas5'
            % When we implement...
    end
        
else
    bl1='No information on background adjustment.';
    bl2='';bl3='';bl4='';bl5='';bl6='';bl7='';bl8='';bl9='';bl10='';bl11='';
    nl1='No information on normalization';
    nl2='';nl3='';nl4='';nl5='';nl6='';nl7='';nl8='';
    sl1='No information on summarization';
    sl2='';sl3='';
end
maintext=[maintext;'Background Adjustment Information';...
          '----------------------------------------';' ';...
          bl1;bl2;bl3;bl4;bl5;bl6;bl7;bl8;bl9;bl10;bl11;' ';...
          'Normalization Information';...
          '----------------------------------------';' ';...
          nl1;nl2;nl3;nl4;nl5;nl6;nl7;nl8;' ';...
          'Summarization Information';...
          '----------------------------------------';' ';...
          sl1;sl2;sl3;' '];
      
if ~isempty(filtering)
    
    if ~filtering.nofilt
        if ~isempty(filtering.alpha)
            fl1=['MAS5 Calls filter : Yes at alpha ',num2str(filtering.alpha),' tau ',...
                  num2str(filtering.tau),' and marginal limits (',num2str(filtering.alphalims(1)),...
                  ',',num2str(filtering.alphalims(2)),')'];
        else
            fl1='MAS5 Calls filter : No';
        end
        fl2=['IQR filter : ',log2lang(filtering.iqrv)];
        fl3=['Variance filter : ',log2lang(filtering.varv)];
        fl4=['Intensity filter : ',log2lang(filtering.inten)];
        fl5=['Custom filter : ',log2lang(filtering.custom)];
        fl6=['Outlier test : ',log2lang(filtering.outlierTest),' p-value : ',log2lang(filtering.pvalue)];    
    else
        fl1='No gene filtering performed';
        fl2='';fl3='';fl4='';fl5='';fl6='';
    end
    
else
    fl1='No information on filtering.';
    fl2='';fl3='';fl4='';fl5='';fl6='';
end
maintext=[maintext;'Filtering Information';...
          '----------------------------------------';' ';...
          fl1;fl2;fl3;fl4;fl5;fl6;' '];

if ~isempty(statistics)
    stl1=['Between slide normalization  : ',statistics.scalename];
    stl2=['Trust Factor threshold : ',num2str(statistics.tf)];    
    if str2double(statistics.tf)~=1
        stl3=['Missing value imputation method : ',statistics.imputename];
    else
        stl3='Missing value imputation method : not required (TF=1)';
    end
    stl4=['Missing value imputation relative to between slide normalization (if performed) : ',...
          statistics.imputebeforaftname];
    stl5=['Statistical test : ',statistics.stattestname];
    stl6=['Multiple testing correction : ',statistics.multicorrname];
    stl7=['p-value or FDR threshold : ',num2str(statistics.thecut)];
else
    stl1='No Information on Statistical Selection';
    stl2='';stl3='';stl4='';stl5='';stl6='';stl7='';
end
maintext=[maintext;'Statistical Selection Information';...
          '----------------------------------------';' ';...
          stl1;stl2;stl3;stl4;stl5;stl6;stl7;' ';' '];

if ~isempty(clustering)        
    cl1=['Clustering algorithm used : ',clustering.methodname];
    cl2=['Linkage method used : ',clustering.linkage];
    cl3=['Distance metric used : ',clustering.distance];
    if ~isnan(clustering.incutoff)
        cl4=['Cluster limit criterion : inconsistency coefficient (',...
             num2str(clustering.incutoff),')'];
    else
        cl4=['Cluster limit criterion : number of clusters (',...
             num2str(clustering.k),')'];
    end
    cl5=['Initial seeds estimation : ',clustering.seedname];
    cl6=['DE Genes p-value cutoff for clustering : ',num2str(clustering.pvalue)];
else
    cl1='No information on clustering';
    cl2='';cl3='';cl4='';cl5='';cl6='';
end
maintext=[maintext;'Clustering Information';...
          '----------------------------------------';' ';...
          cl1;cl2;cl3;cl4;cl5;cl6;' ';' '];
      
set(handles.viewMainEdit,'String',maintext,'Max',length(maintext))

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AnalysisViewAffy wait for user response (see UIRESUME)
uiwait(handles.AnalysisViewAffy);


% --- Outputs from this function are returned to the command line.
function varargout = AnalysisViewAffy_OutputFcn(hObject, eventdata, handles)


function viewMainEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function viewMainEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function rightClick_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function rightExport_Callback(hObject, eventdata, handles)

str=char(get(handles.viewMainEdit,'String'));
[filename,pathname]=uiputfile('*.txt','Export details');
if filename==0
    return
else
    line1='ARMADA v.2.0 Batch Programmer Analysis Details';
    line2=repmat('-',[1 50]);
    line3=['DETAILS ON ANALYSIS BATCH ',num2str(handles.ind)];
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

set(handles.viewMainEdit,'String','')


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)

uiresume(handles.AnalysisViewAffy);
delete(handles.AnalysisViewAffy);



% HELP FUNCTIONS

function out = matfromcell(datab,tablen)

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
        temp=[datab{i,j} repmat(' ',[1 maxlen-length(datab{i,j})])];
        for k=(j-1)*(maxlen+tablen)+1:(j-1)*(maxlen+tablen)+maxlen
            out(i,k)=temp(k-(j-1)*(maxlen+tablen));
        end
    end
end
% Remove trailing spaces from the end of out
out=strtrim(out);
