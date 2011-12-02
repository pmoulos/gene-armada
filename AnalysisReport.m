function varargout = AnalysisReport(varargin)
% ANALYSISREPORT M-file for AnalysisReport.fig
%      ANALYSISREPORT, by itself, creates a new ANALYSISREPORT or raises the existing
%      singleton*.
%
%      H = ANALYSISREPORT returns the handle to a new ANALYSISREPORT or the handle to
%      the existing singleton*.
%
%      ANALYSISREPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSISREPORT.M with the given input arguments.
%
%      ANALYSISREPORT('Property','Value',...) creates a new ANALYSISREPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnalysisReport_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnalysisReport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnalysisReport

% Last Modified by GUIDE v2.5 29-Aug-2008 13:01:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnalysisReport_OpeningFcn, ...
                   'gui_OutputFcn',  @AnalysisReport_OutputFcn, ...
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


% --- Executes just before AnalysisReport is made visible.
function AnalysisReport_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.AnalysisReport,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.AnalysisReport,'Position',winpos);

% Get inputs
handles.ind=varargin{1};
analysis=varargin{2};
project=varargin{3};
soft=varargin{4};

% Correct title
set(handles.titleStatic,'String',['Report for Analysis ',num2str(handles.ind)])

% Start filling textbox
if ~isempty(analysis)
    % Find number of slides
    count=0;
    index=0;
    
    for i=1:analysis.numberOfConditions
        maxes{i}=[];
        for j=1:length(analysis.exprp{i})
            maxes{i}=[maxes{i},length(analysis.exprp{i}{j})];
        end
        maxesall{i}=max(maxes{i});
    end
    for i=1:analysis.numberOfConditions
        count=count+size(analysis.exprp{i},2);
        datatable{1,i}=analysis.conditionNames{i};
        for j=1:max(size(analysis.exprp{i}))
            index=index+1;
            arrays{index}=analysis.exprp{i}{j};
            %datatable{2+j,i}=analysis.exprp{i}{j};
            datatable{2+j,i}=[analysis.exprp{i}{j},repmat(' ',[1 maxesall{i}-length(analysis.exprp{i}{j})]),'|'];
        end
    end   
    maintext={'General Information';'----------------------------------------';' ';...
              ['Number of Conditions : ',num2str(analysis.numberOfConditions)];' ';...
              'Condition Names : ';char(analysis.conditionNames);' ';...
              ['Number of Arrays : ',num2str(count)];' ';...
              'Array Names : ';char(arrays);' ';...
              'Structure summary (1st row contains the condition names, the rest the slides of each condition)';
              ' ';'------------------------------------------------------------';...
              matfromcell(datatable,0);...
              '------------------------------------------------------------';' ';' '}; 
else
    maintext='';
end

if ~isempty(project)
    
    % Preprocessing information
    if isfield(project,'Preprocess')

        if soft~=99 % cDNAs

            if isfield(project.Preprocess,'BackgroundCorrection')
                pl1=['Background Correction Method : ',project.Preprocess.BackgroundCorrection];
            else
                pl1='';
            end
            if isfield(project.Preprocess,'UseEstimate')
                pl2=['Signal Estimation using : ',project.Preprocess.UseEstimate];
            else
                pl2='';
            end
            if isfield(project.Preprocess,'FilterMethod')
                pl3=['Filtering Method used : ',project.Preprocess.FilterMethod];
            else
                pl3='';
            end
            if isfield(project.Preprocess,'FilterParameter')
                pl4=['Filtering Parameter for filtering method : ',project.Preprocess.FilterParameter];
            else
                pl4='';
            end
            if isfield(project.Preprocess,'OutlierTest')
                pl5=['Outlier Test performed : ',project.Preprocess.OutlierTest];
            else
                pl5='';
            end
            if isfield(project.Preprocess,'Normalization')
                pl6=['Normalization Method : ',project.Preprocess.Normalization];
            else
                pl6='';
            end
            if isfield(project.Preprocess,'Span')
                if ~isempty(project.Preprocess.Span)
                    pl7=['Span (if LOWESS/LOESS methods chosen : ',project.Preprocess.Span];
                else
                    pl7='';
                end
            else
                pl7='';
            end
            if isfield(project.Preprocess,'Subgrid')
                pl8=['Subgrid Normalization (if subgrid present) performed : ',project.Preprocess.Subgrid];
            else
                pl8='';
            end
            if isfield(project.Preprocess,'ChannelInfo')
                pl9=['Channel - Dye correspondence : ',project.Preprocess.ChannelInfo];
            else
                pl9='';
            end
            pl10='';pl11='';pl12='';
            
        else
            
            if isfield(project.Preprocess,'BackgroundAdjustment')
                pl1=['Background Adjustment method : ',project.Preprocess.BackgroundAdjustment];
            else
                pl1='';
            end
            if isfield(project.Preprocess,'BackgroundOptions')    
                pl2=['Background Adjustment Options : ',project.Preprocess.BackgroundOptions];
            else
                pl2='';
            end
            if isfield(project.Preprocess,'Normalization')
                pl3=['Normalization method : ',project.Preprocess.Normalization];
            else
                pl3='';
            end
            if isfield(project.Preprocess,'NormalizationOptions')
                pl4=['Normalization Options : ',project.Preprocess.NormalizationOptions];
            else
                pl4='';
            end
            if isfield(project.Preprocess,'Summarization')
                pl5=['Summarization method : ',project.Preprocess.Summarization];
            else
                pl5='';
            end
            if isfield(project.Preprocess,'SummarizationOptions')
                pl6=['Summarization Options : ',project.Preprocess.SummarizationOptions];
            else
                pl6='';
            end
            if isfield(project.Preprocess,'MAS5Filter')
                pl7=['MAS5 Filter : ',project.Preprocess.MAS5Filter];
            else
                pl7='';
            end
            if isfield(project.Preprocess,'IQRFilter')
                pl8=['IQR Filter : ',project.Preprocess.IQRFilter];
            else
                pl8='';
            end
            if isfield(project.Preprocess,'VarianceFilter')
                pl9=['Variance Filter : ',project.Preprocess.VarianceFilter];
            else
                pl9='';
            end
            if isfield(project.Preprocess,'IntensityFilter')
                pl10=['Intensity Filter : ',project.Preprocess.IntensityFilter];
            else
                pl10='';
            end
            if isfield(project.Preprocess,'CustomFilter')
                pl11=['Custom Filter : ',project.Preprocess.CustomFilter];
            else
                pl11='';
            end
            if isfield(project.Preprocess,'OutlierTest')
                pl12=['Outlier Detection test performed : ',project.Preprocess.OutlierTest];
            else
                pl12='';
            end
            
        end
        
        if isfield(analysis,'TotalBadpoints') && ~isempty(analysis.TotalBadpoints)
            pl13='Number of poor spots for each slide of the Analysis : ';
            index=0;
            for i=1:analysis.numberOfConditions
                for j=1:max(size(analysis.TotalBadpoints{i}))
                    index=index+1;
                    leg{index}=[analysis.exprp{i}{j},' : ',...
                                num2str(length(analysis.TotalBadpoints{i}{j}))];
                end
            end
        else
            pl13='';
            leg='';
        end
                    
    else
        pl1='No Information on Preprocessing';
        pl2='';pl3='';pl4='';pl5='';pl6='';pl7='';pl8='';pl9='';pl10='';pl11='';pl12='';pl13='';leg='';
    end
    
    if isfield(project,'Preprocess') && isempty(project.Preprocess)
        disp('5')
        pl1='No Information on Preprocessing';
        pl2='';pl3='';pl4='';pl5='';pl6='';pl7='';pl8='';pl9='';pl10='';pl11='';pl12='';pl13='';leg='';
    end

    maintext=[maintext;'Preprocessing Information';'----------------------------------------';...
              ' ';pl1;pl2;pl3;pl4;pl5;pl6;pl7;pl8;pl9;pl10;pl11;pl12;' ';pl13;...
              char(leg);' ';' ']; 
          
    % Statistical selection information
    if isfield(project,'StatisticalSelection')
        if isfield(project.StatisticalSelection,'BSN')
            sl1=['Between Slide Normalization performed : ',project.StatisticalSelection.BSN];
        else
            sl1='';
        end
        if isfield(project.StatisticalSelection,'TF')
            sl2=['Trust Factor threshold : ',project.StatisticalSelection.TF];
        else
            sl2='';
        end
        if isfield(project.StatisticalSelection,'ImputeMethod')
            if str2double(project.StatisticalSelection.TF)~=1
                sl3=['Missing Value Imputation method (if needed) : ',...
                    project.StatisticalSelection.ImputeMethod];
            else
                sl3='Missing Value Imputation method : Not required (TF=1)';
            end
        else
            sl3='';
        end
        if isfield(project.StatisticalSelection,'Impute')
            sl4=['Missing Value Imputation relative to BSN (if performed) : ',...
                project.StatisticalSelection.Impute];
        else
            sl4='';
        end
        if isfield(project.StatisticalSelection,'Test')
            sl5=['Statistical Test : ',project.StatisticalSelection.Test];
        else
            sl5='';
        end
        if isfield(project.StatisticalSelection,'Correction')
            sl6=['Multiple Testing Correction procedure : ',project.StatisticalSelection.Correction];
        else
            sl6='';
        end
        if isfield(project.StatisticalSelection,'Cut')
            sl7=['p-value or FDR threshold : ',num2str(project.StatisticalSelection.Cut)];
        else
            sl7='';
        end
        if isfield(project.StatisticalSelection,'DEGenes')
            sl8=['Number of DE Genes : ',num2str(project.StatisticalSelection.DEGenes)];
        else
            sl8='';
        end
    else
        sl1='No Information on Statistical Selection';
        sl2='';sl3='';sl4='';sl5='';sl6='';sl7='';sl8='';
    end
    if isfield(project,'StatisticalSelection') && isempty(project.StatisticalSelection)
        sl1='No Information on Statistical Selection';
        sl2='';sl3='';sl4='';sl5='';sl6='';sl7='';sl8='';
    end
    
    maintext=[maintext;'Statistical Selection Information';...
              '----------------------------------------';' ';...
              sl1;sl2;sl3;sl4;sl5;sl6;sl7;sl8;' ';' '];
    
   % Information on Clustering 
   if isfield(project,'Clustering')
        if isfield(project.Clustering,'Algorithm')
            cl1=['Clustering Algorithm used : ',project.Clustering.Algorithm];
        else
            cl1='';
        end
        if isfield(project.Clustering,'Linkage')
            if ~isempty(project.Clustering.Linkage)
                cl2=['Linkage method used : ',project.Clustering.Linkage];
            else
                cl2='';
            end
        else
            cl2='';
        end
        if isfield(project.Clustering,'Distance')
            cl3=['Distance metric used : ',project.Clustering.Distance];
        else
            cl3='';
        end
        if isfield(project.Clustering,'Limit')
            cl4=['Cluster limit criterion : ',num2str(project.Clustering.Limit)];
        else
            cl4='';
        end
        if isfield(project.Clustering,'Seed')
            cl5=['Initial seeds estimation : ',project.Clustering.Seed];
        else
            cl5='';
        end
        if isfield(project.Clustering,'PValue')
            cl6=['DE Genes p-value cutoff for clustering : ',num2str(project.Clustering.PValue)];
        else
            cl6='';
        end
        if isfield(project.Clustering,'Limit')
            cl7=['Number of Clusters formed : ',num2str(project.Clustering.Clusters)];
        else
            cl7='';
        end
   else
       cl1='No Information on Clustering';
       cl2='';cl3='';cl4='';cl5='';cl6='';cl7='';
   end
   if isfield(project,'Clustering') && isempty(project.Clustering)
        cl1='No Information on Clustering';
        cl2='';cl3='';cl4='';cl5='';cl6='';cl7='';
    end
   
   maintext=[maintext;'Clustering Information';...
             '----------------------------------------';' ';...
             cl1;cl2;cl3;cl4;cl5;cl6;cl7;' ';' '];

end
    
set(handles.reportMainEdit,'String',maintext,'Max',length(maintext))


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AnalysisReport wait for user response (see UIRESUME)
uiwait(handles.AnalysisReport);


% --- Outputs from this function are returned to the command line.
function varargout = AnalysisReport_OutputFcn(hObject, eventdata, handles)


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
    line1='ARMADA v.2.0 Analysis Report';
    line2=repmat('-',[1 50]);
    line3=['INFORMATION ON ANALYSIS RUN ',num2str(handles.ind)];
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

uiresume(handles.AnalysisReport);
delete(handles.AnalysisReport);



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
