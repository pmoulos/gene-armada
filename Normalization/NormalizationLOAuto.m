function [DataCellNormLo,ngnID]=NormalizationLOAuto(exptab,exprp,t,s,chanInput,SP,usetimebar,gnID,...
                                                    sumprobes,sumhow,sumwhen,htext,rankopts)

%
% Global mean/median and LOWESS/LOESS normalization
%
% User does not interact with the command window
%
% Usage: DataCellNormLo = NormalizationLOAuto(exptab,expr,t)
%        DataCellNormLo = NormalizationLOAuto(exptab,expr,t,s)
%        DataCellNormLo = NormalizationLOAuto(exptab,expr,t,s,chanInput)
%        DataCellNormLo = NormalizationLOAuto(exptab,expr,t,s,chanInput,SP)
%
% Arguments:
% exptab     : The structure containing expression values for all conditions and replicates
%             (exists as output from FindBadPoints.m)
% exprp      : A cell array of strings containing condition and replicate filenames
% t          : The number of experimental conditions
% s          : The normalization method:
%              s==1 : Linear Fit LOWESS
%              s==2 : Robust Linear Fit LOWESS
%              s==3 : Quadratic Fit LOESS
%              s==4 : Robust Quadratic Fit LOESS
%              s==5 : Global Mean
%              s==6 : Global Median
%              s==7 : Rank Invariant normalization
%              s==8 : No normalization
% chanInput  : The reference/treatment color code. If chanInput==1 the Cy3-->Reference
%              and Cy5-->Treatment else if chanInput==2 the Cy3-->Treatment and Cy5-->Reference.
%              Defaults to 1. Useful when 2 rounds of normalization have to be executed as 
%              a dye-swap experiment. It can be a matrix of 1s and 2s where rows represent
%              conditions and columns represent array replicates. 1 and 2 are set as each
%              element of the matrix to represent color code.
% SP         : The spanning neighborhood for LOWESS/LOESS methods. Does not have to be
%              given if s=5 or 6 (global mean/median normalization)
% usetimebar : Monitor the time required for normalization with two timebars: one for the
%              overal time needed for normalization and one for each array. However, the
%              use of the timebars is not advised because it can increase the time used
%              for normalization up to 10 times! Use it only if you really like graphics
%              usetimebar=0 : don't display timebars (default)
%              usetimebar=1 : use timebars
% sumprobes  : Summarize probes with the same name to a common value
%              sumprobes=0 : don't summarize
%              sumprobes=1 : summarize (default)
% sumhow     : If sumprobes=1, the method of expression summarization. Can be one of 'mean' 
%              or 'median' (default is 'mean')
% sumwhen    : If sumprobes=1, summarize the probes before or after normalization? It
%              should be 0 for before (default) or 1 for after
% gnID       : A cell array with probe IDs which must be provided if sumprobes=1,
%              otherwise it can be empty
% htext      : Handle to edit uicontrol for updating main message
% rankopts   : Inputs for Rank Invariant normalization 
%
% Output:
% Contents of DataCellNormLo
% LogRat               : The initial log2 ratio of channel 2 to channel 1 signals
% LogRatnormlo         : The normalized log2 channel ratio
% Intens               : The intensities for each spot
% SP                   : The span parameter for LOWESS/LOESS methods
% s                    : The normalization method chosen
% LogRatsmth           : The smoothing vector produced by the normalization method which
%                        contains the points of the normalization curve
%
% See also FINDBADPOINTS, NORMALIZATIONSTART, NORMALIZATIONLO, NORMALIZATIONLOAUTOSUB
%

% Check various inputs
if nargin<4
    s=1;
    chanInput=1;
    SP=0.2;
    usetimebar=0;
    gnID='';
    sumprobes=0;
    sumhow='mean';
    sumwhen=0;
    htext=[];
    rankopts=[];
elseif nargin<5
    chanInput=1;
    if ismember(s,[1 2 3 4 7])
        SP=0.2;
    else
        SP=NaN;
    end
    usetimebar=0;
    gnID='';
    sumprobes=0;
    sumhow='mean';
    sumwhen=0;
    htext=[];
    if s~=7
        rankopts=[];
    else
        rankopts=setRankDef;
    end
elseif nargin<6
    if ismember(s,[1 2 3 4 7])
        SP=0.2;
    else
        SP=NaN;
    end
    usetimebar=0;
    gnID='';
    sumprobes=0;
    sumhow='mean';
    sumwhen=0;
    htext=[];
    if s~=7
        rankopts=[];
    else
        rankopts=setRankDef;
    end
elseif nargin<7
    usetimebar=0;
    gnID='';
    sumprobes=0;
    sumhow='mean';
    sumwhen=0;
    htext=[];
    if s~=7
        rankopts=[];
    else
        rankopts=setRankDef;
    end
    gnID='';
    sumprobes=0;
    sumhow='mean';
    sumwhen=0;
elseif nargin<8
    gnID='';
    sumprobes=0;
    sumhow='mean';
    sumwhen=0;
    htext=[];
    if s~=7
        rankopts=[];
    else
        rankopts=setRankDef;
    end
    gnID='';
    sumprobes=0;
    sumhow='mean';
    sumwhen=0;
elseif nargin<9
    sumprobes=0;
    sumhow='mean';
    sumwhen=0;
    htext=[];
    if s~=7
        rankopts=[];
    else
        rankopts=setRankDef;
    end
elseif nargin<10
    sumhow='mean';
    sumwhen=0;
    htext=[];
    if s~=7
        rankopts=[];
    else
        rankopts=setRankDef;
    end
elseif nargin<11
    sumwhen=0;
    htext=[];
    if s~=7
        rankopts=[];
    else
        rankopts=setRankDef;
    end
elseif nargin<12
    htext=[];
    if s~=7
        rankopts=[];
    else
        rankopts=setRankDef;
    end
elseif nargin<13
    if s~=7
        rankopts=[];
    else
        rankopts=setRankDef;
    end
end

% Assign empty value to rireport which is a value used only for rank invariant
% normalization
rireport=[];

% Be sure about gene IDs
ngnID = gnID;

if ~ismember(s,[1 2 3 4 5 6 7 8])
    uiwait(errordlg('Bad Input for Normalization Method','Error'));
end
    
if ~isempty(htext)
    mainmsg=get(htext,'String');
    mainmsg=[mainmsg;' ',...
             'RATIO NORMALIZATION Per Chip';...
             '=========================================================================';' '];
    set(htext,'String',mainmsg)
    drawnow;
else
    disp('  ')
    disp('                           RATIO NORMALIZATION Per Chip                            ')
    disp('===================================================================================')
    disp('  ')
end

%Create ch1,ch2 data
%-ch1,ch2 include badpoints, which are marked as nan-
ch1=cell(1,length(exprp));
ch2=cell(1,length(exprp));
LogRat=cell(1,length(exprp));
Intens=cell(1,length(exprp));
LogRatnormlo=cell(1,length(exprp));
LogRatsmth=cell(1,length(exprp));

if ~isscalar(chanInput)
    % Determine which i,j (conditions, replicates) correspond to dye-swap experiments and run
    % logical control during the creation of ch1, ch2 data. chanInput should become a matrix
    % of the same size as the dataset containing 1, 2 or 0
    for i=1:t
        LogRat{i}=cell(1,max(size(exprp{i})));
        Intens{i}=cell(1,max(size(exprp{i})));
        ch1{i}=cell(1,max(size(exprp{i})));
        ch2{i}=cell(1,max(size(exprp{i})));
        for j=1:max(size(exprp{i}))
            if chanInput(i,j)==1
                ch1{i}{j}=2.^(exptab{i}{j}(:,1)); %Cy3
                ch2{i}{j}=2.^(exptab{i}{j}(:,2)); %Cy5
            elseif chanInput(i,j)==2
                ch2{i}{j}=2.^(exptab{i}{j}(:,1)); %Cy3
                ch1{i}{j}=2.^(exptab{i}{j}(:,2)); %Cy5
            else
                uiwait(errordlg('Bad input!','Error'))
                DataCellNormLo=[];
                return
            end
            LogRat{i}{j}=log2(ch2{i}{j})-log2(ch1{i}{j});
            Intens{i}{j}=0.5*(log2(ch2{i}{j})+log2(ch1{i}{j}));
        end
    end
else
    if chanInput==1
        for i=1:t
            LogRat{i}=cell(1,max(size(exprp{i})));
            Intens{i}=cell(1,max(size(exprp{i})));
            ch1{i}=cell(1,max(size(exprp{i})));
            ch2{i}=cell(1,max(size(exprp{i})));
            for j=1:max(size(exprp{i}))
                ch1{i}{j}=2.^(exptab{i}{j}(:,1)); %Cy3
                ch2{i}{j}=2.^(exptab{i}{j}(:,2)); %Cy5
                LogRat{i}{j}=log2(ch2{i}{j})-log2(ch1{i}{j});
                Intens{i}{j}=0.5*(log2(ch2{i}{j})+log2(ch1{i}{j}));
            end
        end
    elseif chanInput==2
        for i=1:t
            LogRat{i}=cell(1,max(size(exprp{i})));
            Intens{i}=cell(1,max(size(exprp{i})));
            ch1{i}=cell(1,max(size(exprp{i})));
            ch2{i}=cell(1,max(size(exprp{i})));
            for j=1:max(size(exprp{i}))
                ch2{i}{j}=2.^(exptab{i}{j}(:,1)); %Cy3
                ch1{i}{j}=2.^(exptab{i}{j}(:,2)); %Cy5
                LogRat{i}{j}=log2(ch2{i}{j})-log2(ch1{i}{j});
                Intens{i}{j}=0.5*(log2(ch2{i}{j})+log2(ch1{i}{j}));
            end
        end
    else
        uiwait(errordlg('Bad input!','Error'))
        DataCellNormLo=[];
        return
    end
end

if sumprobes && ~sumwhen
    [mapObj,ngnID] = constructMap(gnID);
    if s==7
        for i=1:t
            for j=1:max(size(exprp{i}))
                ch1{i}{j}=sumProbes(ch1{i}{j},ngnID,mapObj,sumhow);
                ch2{i}{j}=sumProbes(ch2{i}{j},ngnID,mapObj,sumhow);
            end
        end
    else    
        for i=1:t
            for j=1:max(size(exprp{i}))
                LogRat{i}{j}=sumProbes(LogRat{i}{j},ngnID,mapObj,sumhow);
                Intens{i}{j}=sumProbes(Intens{i}{j},ngnID,mapObj,sumhow);
            end
        end
    end
end

if ismember(s,[1 2 3 4])

    if usetimebar
        % Initialize global timebar
        global HH
        global TOTAL_GOOD
        HH=timebar('Overall Progress in Normalization procedure','Overall Progress',0.5,0.7);
        TOTAL_GOOD=0;
        for i=1:t
           for j=1:max(size(exprp{i}))
               TOTAL_GOOD=TOTAL_GOOD+(length(exptab{i}{j}(:,3))-length(find(isnan(exptab{i}{j}(:,3)))));
           end
        end
        funfun=['malowess_time_bar(Intens{i}{j},LogRat{i}{j},''Order'',OR,''Robust'',TF,',...
                '''Span'',SP)'];
    else
        hh=showinfowindow('Normalizing data. Please wait...');
        funfun='malowess(Intens{i}{j},LogRat{i}{j},''Order'',OR,''Robust'',TF,''Span'',SP)';
    end

    % Decide on LOWESS/LOESS type
    switch s
        %LOWESS normalization
        %----------------------------------------
        case 1
            TF=false;OR=1;
            %LOWESS-robust normalization
            %-----------------------------------------
        case 2
            TF=true;OR=1;
            %LOESS normalization
            %----------------------------------------
        case 3
            TF=false;OR=2;
            %LOESS-robust normalization
            %----------------------------------------
        case 4
            TF=true;OR=2;
    end

    for i=1:t
        for j=1:max(size(exprp{i}))
            str1=['Normalizing the ',':',' ',exprp{i}{j},' -Please Wait'];
            str2=['Normalizing (Condition,Slide) part (',num2str(i),',',num2str(j),')',' out of ',...
                  '(',num2str(t),',',num2str(max(size(exprp{i}))),')'];
            
            if ~isempty(htext)
                mainmsg=get(htext,'String');
                mainmsg=[mainmsg;str1;str2];
                set(htext,'String',mainmsg)
                drawnow;
            else
                disp(str1)
                disp(str2)
            end
            
            % Normalizing data
            LogRatsmth{i}{j}=eval(funfun);

            %Normalized Ratios and log2(Ratios)
            LogRatnormlo{i}{j}=LogRat{i}{j}-LogRatsmth{i}{j}; % ./ or -

            %Calculate the correlation coefficient R-I after L normalization
            %CorrsAF{i}{j}=corrcoef(abs(LogRatnormlo{i}{j}),abs(Intens{i}{j}),'rows','complete');
            %CorrsBF{i}{j}=corrcoef(abs(LogRat{i}{j}),abs(Intens{i}{j}),'rows','complete');
            
            % Repaint
            drawnow;

        end
    end
    
    if usetimebar
        %Clear global variables created for the overall progress timebar
        close(HH);
        clear HH TOTAL_GOOD masmooth_timebar
    else
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
    end
    
elseif ismember(s,[5 6])
    
    switch s        
        case 5 % Global Mean
            for i=1:t
                for j=1:max(size(exprp{i}))
                    meanvalue{i}{j}=nanmean(LogRat{i}{j});
                    LogRatnormlo{i}{j}=LogRat{i}{j}-meanvalue{i}{j};
                    LogRatsmth{i}{j}=repmat(meanvalue{i}{j},[length(LogRat{i}{j}) 1]);
                    %CorrsAF{i}{j}=corrcoef(abs(LogRatnormlo{i}{j}),abs(Intens{i}{j}),'rows','complete');
                    %CorrsBF{i}{j}=corrcoef(abs(LogRat{i}{j}),abs(Intens{i}{j}),'rows','complete');
                end
            end
            SP=NaN;
        
        case 6 % Global Median
            for i=1:t
                for j=1:max(size(exprp{i}))
                    medianvalue{i}{j}=nanmedian(LogRat{i}{j});
                    LogRatnormlo{i}{j}=LogRat{i}{j}-medianvalue{i}{j};
                    LogRatsmth{i}{j}=repmat(medianvalue{i}{j},[length(LogRat{i}{j}) 1]);
                    %CorrsAF{i}{j}=corrcoef(abs(LogRatnormlo{i}{j}),abs(Intens{i}{j}),'rows','complete');
                    %CorrsBF{i}{j}=corrcoef(abs(LogRat{i}{j}),abs(Intens{i}{j}),'rows','complete');
                end
            end
            SP=NaN;
    end
    
elseif s==7 % Rank invariant normalization
    
    % Put parameter names and values in a string cell to the output cell for use with
    % ARMADA reports. If parameter checking is succesful it should work. Also, they will
    % come from inside the GUI in a specific order, so changing their names to something more
    % readable will not change the parameter - value correspondence.
    rireport=createReportData(rankopts);
    
    % Redirect some output
    if ~isempty(htext)
        mainmsg=get(htext,'String');
        mainmsg=[mainmsg;' ';'Rank Invariant Normalization details : ';...
                 char(rireport);' '];
        set(htext,'String',mainmsg)
        drawnow;
    else
        disp('  ')
        disp('                        Rank Invariant Nornmalization details                      ')
        disp('  ')
        disp(char(rireport))
        disp('  ')
    end
    
    % Perform rank invariant normalization
    for i=1:t
        for j=1:max(size(exprp{i}))
            str1=['Normalizing the ',':',' ',exprp{i}{j},' -Please Wait'];
            str2=['Normalizing (Condition,Slide) part (',num2str(i),',',num2str(j),')',' out of ',...
                  '(',num2str(t),',',num2str(max(size(exprp{i}))),')'];
            
            if ~isempty(htext)
                mainmsg=get(htext,'String');
                mainmsg=[mainmsg;str1;str2];
                set(htext,'String',mainmsg)
                drawnow;
            else
                disp(str1)
                disp(str2)
            end

            % Normalizing data
            [normCH2{i}{j} iset{i}{j} ich2S]=mainvarsetnorm(ch1{i}{j},ch2{i}{j},...
                                             'Thresholds',[rankopts.lowrank rankopts.uprank],...
                                             'Exclude',rankopts.exclude,...
                                             'Prctile',rankopts.percentage,...
                                             'Iterate',rankopts.iterate,...
                                             'Method',rankopts.method,...
                                             'Span',rankopts.span,...
                                             'Showplot',rankopts.showplot);

            % Smoothed ratio (only for the rank invariant set!)
            LogRatsmth{i}{j}=nan(size(normCH2{i}{j}));
            % LogRatsmth{i}{j}(iset{i}{j})=log2(ich2S)-log2(ch1{i}{j}(iset{i}{j}));
            LogRatsmth{i}{j}(iset{i}{j})=log2(ch2{i}{j}(iset{i}{j}))-log2(ch1{i}{j}(iset{i}{j}));

            % Normalized Ratios and log2(Ratios)
            LogRatnormlo{i}{j}=log2(normCH2{i}{j})-log2(ch1{i}{j});

            %Calculate the correlation coefficient R-I after L normalization
            %CorrsAF{i}{j}=corrcoef(abs(LogRatnormlo{i}{j}),abs(Intens{i}{j}),'rows','complete');
            %CorrsBF{i}{j}=corrcoef(abs(LogRat{i}{j}),abs(Intens{i}{j}),'rows','complete');

            % Repaint
            drawnow;
            
            % Assign proper span from varargin
            SP=rankopts.span;

        end
    end
    

elseif s==8 % Do not normalize
    
    str='No data normalization has been performed';
    if ~isempty(htext)
        mainmsg=get(htext,'String');
        mainmsg=[mainmsg;' ';str];
        set(htext,'String',mainmsg)
        drawnow;
    else
        disp(' ')
        disp(str)
    end
    for i=1:t
        for j=1:max(size(exprp{i}))
            LogRatsmth{i}{j}=nan(size(LogRat{i}{j}));
            LogRatnormlo{i}{j}=LogRat{i}{j};
            %CorrsAF{i}{j}=corrcoef(abs(LogRatnormlo{i}{j}),abs(Intens{i}{j}),'rows','complete');
            %CorrsBF{i}{j}=corrcoef(abs(LogRat{i}{j}),abs(Intens{i}{j}),'rows','complete');
        end
    end
    
end

if sumprobes && sumwhen
    [mapObj,ngnID] = constructMap(gnID);
    for i=1:t
        for j=1:max(size(exprp{i}))
            LogRat{i}{j}=sumProbes(LogRat{i}{j},ngnID,mapObj,sumhow);
            LogRatnormlo{i}{j}=sumProbes(LogRatnormlo{i}{j},ngnID,mapObj,sumhow);
            Intens{i}{j}=sumProbes(Intens{i}{j},ngnID,mapObj,sumhow);
        end
    end
end

% Create DataCellNormLo
DataCellNormLo={LogRat,...
                LogRatnormlo,...
                Intens,...
                SP,...
                s,...
                LogRatsmth};

if ~isempty(rireport)
    DataCellNormLo{13}=[]; % Used only in subgrid normalization
    DataCellNormLo{14}=rireport;
end
            
if ~isempty(htext)
    mainmsg=get(htext,'String');
    mainmsg=[mainmsg;' ';...
             'Process Completed';...
             '-------------------------------------------------------------'];
    set(htext,'String',mainmsg)
    drawnow;
else
    disp('-----------------------------------------------------------------------')
end


function areport = createReportData(para)

% Helper function to create report for ARMADA

areport=cell(6,1);
areport{1}=['Average rank theresholds : Lower - ',num2str(para.lowrank),...
                ' Upper - ',num2str(para.uprank)];
areport{2}=['Higher or Lower average rank exclusion position : ',num2str(para.exclude)];
areport{3}=['Maximum percentage of dataset points included in the rank invariant set : ',...
                num2str(para.percentage),'%'];
if para.iterate
    str1='Yes';
else
    str1='No';
end
areport{4}=['Iterate until specified rank invariant set size reached : ',str1];
if strcmpi(para.method,'lowess')
    str2='LOWESS';
elseif strcmpi(para.method,'runmed')
    str2='Running Median';
elseif strcmpi(para.method,'runmean')
    str2='Running Mean';
end
areport{5}=['Method for data smoothing : ',str2];
areport{6}=['Span : ',num2str(para.span)];


function opts = setRankDef

opts.lowrank=0.03;
opts.uprank=0.07;
opts.exclude=0;
opts.percentage=1;
opts.iterate=true;
opts.method='lowess';
opts.span=0.1;
opts.showplot=false;


function [mapObj,newid] = constructMap(id)

i=1;
pos=1;
newid=cell(length(unique(id)),1);
mapObj = containers.Map;

while i<=length(id)
    if isKey(mapObj,id{i})
        mapObj(id{i})=[mapObj(id{i}),i];
    else
        mapObj(id{i})=i;
        newid{pos}=id{i};
        pos=pos+1;
    end
    i=i+1;
end


function y = sumProbes(x,nid,map,met)

y=zeros(length(nid),1);
if strcmp(met,'mean')
    for i=1:length(y)
        y(i)=nanmean(x(map(nid{i})));
    end
elseif strcmp(met,'median')
    for i=1:length(y)
        y(i)=nanmedian(x(map(nid{i})));
    end
end
