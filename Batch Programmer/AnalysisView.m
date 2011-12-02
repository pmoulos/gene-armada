function varargout = AnalysisView(varargin)
% ANALYSISVIEW M-file for AnalysisView.fig
%      ANALYSISVIEW, by itself, creates a new ANALYSISVIEW or raises the existing
%      singleton*.
%
%      H = ANALYSISVIEW returns the handle to a new ANALYSISVIEW or the handle to
%      the existing singleton*.
%
%      ANALYSISVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSISVIEW.M with the given input arguments.
%
%      ANALYSISVIEW('Property','Value',...) creates a new ANALYSISVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnalysisView_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnalysisView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnalysisView

% Last Modified by GUIDE v2.5 23-Oct-2007 15:42:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnalysisView_OpeningFcn, ...
                   'gui_OutputFcn',  @AnalysisView_OutputFcn, ...
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


% --- Executes just before AnalysisView is made visible.
function AnalysisView_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.AnalysisView,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.AnalysisView,'Position',winpos);

% Get inputs
handles.ind=varargin{1};
backcorr=varargin{2};
filtering=varargin{3};
normalization=varargin{4};
selectconditions=varargin{5};
statistics=varargin{6};
clustering=varargin{7};

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

if ~isempty(backcorr)
    bl1=['Background correction method : ',backcorr.name];
else
    bl1='No information on background correction.';
end
maintext=[maintext;'Background Correction Information';...
          '----------------------------------------';' ';bl1;' '];
      
if ~isempty(filtering)
    fl1=['Signal estimation using : ',filtering.meanmedianName];
    fl2=['Filtering method used : ',filtering.methodName];
    fl3=['Filtering parameter for filtering method : ',filtering.paramValue];
    fl4=['Outlier test performed : ',filtering.outliertestName];
else
    fl1='No information on filtering.';
    fl2='';fl3='';fl4='';
end
maintext=[maintext;'Filtering Information';...
          '----------------------------------------';' ';...
          fl1;fl2;fl3;fl4;' '];
      
if ~isempty(normalization)
    nl1=['Normalization method : ',normalization.methodName];
    nl2=['Span (if LOWESS/LOESS methods chosen : ',normalization.spanValue];
    nl3=['Subgrid normalization (if subgrid present) performed : ',normalization.subgridValue];
    nl4=['Channel - Dye correspondence : ',normalization.channelValue];
else
    nl1='No information on normalization.';
    nl2='';nl3='';nl4='';
end
maintext=[maintext;'Normalization Information';...
          '----------------------------------------';' ';...
          nl1;nl2;nl3;nl4;' '];

if ~isempty(statistics)
    sl1=['Between slide normalization  : ',statistics.scalename];
    sl2=['Trust Factor threshold : ',num2str(statistics.tf)];    
    if str2double(statistics.tf)~=1
        sl3=['Missing value imputation method : ',statistics.imputename];
    else
        sl3='Missing value imputation method : not required (TF=1)';
    end
    sl4=['Missing value imputation relative to between slide normalization (if performed) : ',...
          statistics.imputebeforaftname];
    sl5=['Statistical test : ',statistics.stattestname];
    sl6=['Multiple testing correction : ',statistics.multicorrname];
    sl7=['p-value or FDR threshold : ',num2str(statistics.thecut)];
else
    sl1='No Information on Statistical Selection';
    sl2='';sl3='';sl4='';sl5='';sl6='';sl7='';
end
maintext=[maintext;'Statistical Selection Information';...
          '----------------------------------------';' ';...
          sl1;sl2;sl3;sl4;sl5;sl6;sl7;' ';' '];

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

% UIWAIT makes AnalysisView wait for user response (see UIRESUME)
uiwait(handles.AnalysisView);


% --- Outputs from this function are returned to the command line.
function varargout = AnalysisView_OutputFcn(hObject, eventdata, handles)


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

uiresume(handles.AnalysisView);
delete(handles.AnalysisView);



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
