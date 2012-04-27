function [DataCellNormLo,ngnID]=NormalizationLOAutoSub(metacords,exptab,exprp,t,imgsw,s,chanInput,SP,...
                                                       usetimebar,gnID,sumprobes,sumhow,htext)

%
% Global mean/median and LOWESS/LOESS subgrid normalization
%
% User does not interact with the command window
%
% Usage: DataCellNormLo = NormalizationLOAutoSub(exptab,expr,t)
%        DataCellNormLo = NormalizationLOAutoSub(exptab,expr,t,imgsw)
%        DataCellNormLo = NormalizationLOAutoSub(exptab,expr,t,imgsw,s)
%        DataCellNormLo = NormalizationLOAutoSub(exptab,expr,t,imgsw,s,chanInput)
%        DataCellNormLo = NormalizationLOAutoSub(exptab,expr,t,imgsw,s,chanInput,SP)
%
% Arguments:
% metacords : A cell containing the {metarow,metacolumn} or {block} vectors
% exptab    : The structure containing expression values for all conditions and replicates
%             (exists as output from FindBadPoints.m)
% exprp     : A cell array of strings containing condition and replicate filenames
% t         : The number of experimental conditions
% imgsw     : Image Analysis software: 
%             QuantArray --> imgsw=1
%             ImaGene    --> imgsw=2
%             GenePix    --> imgsw=3
%             Text delim --> imgsw=4
%             Agilent FE --> imgsw=5
% s         : The normalization method:
%             s==1 : Linear Fit LOWESS
%             s==2 : Robust Linear Fit LOWESS
%             s==3 : Quadratic Fit LOESS
%             s==4 : Robust Quadratic Fit LOESS
%             s==5 : Global Mean
%             S==6 : Global Median
% chanInput : The reference/treatment color code. If chanInput==1 the Cy3-->Reference
%             and Cy5-->Treatment else if chanInput==2 the Cy3-->Treatment and Cy5-->Reference.
%             Defaults to 1. Useful when 2 rounds of normalization have to be executed as a result of
%             a dye-swap experiment.
% SP        : The spanning neighborhood for LOWESS/LOESS methods. Does not have to be
%             given if s=5 or 6 (global mean/median normalization)
% usetimebar : Monitor the time required for normalization with two timebars: one for the
%              overal time needed for normalization and one for each array. However, the
%              use of the timebars is not advised because it can increase the time used
%              for normalization up to 10 times! Use it only if you really like graphics
%              usetimebar=0 : don't display timebars (default)
%              usetimebar=1 : use timebars
% sumprobes  : Summarize probes with the same name to a common value
%              sumprobes=0 : don't summarize
%              sumprobes=1 : summarize (default)
% gnID       : A cell array with probe IDs which must be provided if sumprobes=1,
%              otherwise it can be empty
% sumhow     : If sumprobes=1, the method of expression summarization. Can be one of 'mean' 
%              or 'median' (default is 'mean')
% htext      : Handle to edit uicontrol for updating main message
%
% Output:
% Contents of DataCellNormLo
% LogRat               : The initial log2 ratio of channel 2 to channel 1 signals
% LogRatnormlo         : The normalized log2 channel ratio
% Intens               : The intensities for each spot
% SP                   : The span parameter for LOWESS/LOESS methods
% s                    : The normalization method chosen
% CorrsAF              : Correlation Coefficient matrix of log ratio vs spot intensity
%                        AFTER normalization
% CorrsBF              : Correlation Coefficient matrix of log ratio vs spot intensity
%                        BEFORE normalization
% length(exptab{1}{1}) : The number of genes
% t                    : The number of Conditions
% exprp                : The cell array of strings containing condition and replicate
%                        filenames
% gnID                 : The gene identifiers
% LogRatsmth           : The smoothing vector produced by the normalization method which
%                        contains the points of the normalization curve
% areas                : The indexing of the genes belonging to each subgrid part (cell of
%                        size mxn where mxn is the size of the subgrid matrix)
%
% See also FINDBADPOINTS, NORMALIZATIONSTART, NORMALIZATIONLO, NORMALIZATIONLOAUTO
%

% Check various inputs
if nargin<5
    disp('Select Microarray Image Analysis software used:')
    imgsw=input('1. QuantArray   2. ImaGene  3. GenePix  4. Text tab-delimited  5. Agilent Feature Extraction :');
    s=1;
    chanInput=1;
    SP=0.2;
    usetimebar=0;
    gnID='';
    sumprobes=0;
    sumhow='mean';
    htext=[];
elseif nargin<6
    s=1;
    chanInput=1;
    SP=0.2;
    usetimebar=0;
    gnID='';
    sumprobes=0;
    sumhow='mean';
    htext=[];
elseif nargin<7
    chanInput=1;
    if ismember(s,[1 2 3 4])
        SP=0.2;
    else
        SP=NaN;
    end
    usetimebar=0;
    gnID='';
    sumprobes=0;
    sumhow='mean';
    htext=[];
elseif nargin<8
    if ismember(s,[1 2 3 4])
        SP=0.2;
    else
        SP=NaN;
    end
    usetimebar=0;
    gnID='';
    sumprobes=0;
    sumhow='mean';
    htext=[];
elseif nargin<9
    usetimebar=0;
    gnID='';
    sumprobes=0;
    sumhow='mean';
    htext=[];
elseif nargin<10
    gnID='';
    sumprobes=0;
    sumhow='mean';
    htext=[];
elseif nargin<11
    sumprobes=0;
    sumhow='mean';
    htext=[];
elseif nargin<12
    sumhow='mean';
    htext=[];
elseif nargin<13
    htext=[];
end

% Be sure about gene IDs
ngnID = gnID;

if ~ismember(s,[1 2 3 4 5 6])
    uiwait(errordlg('Bad Input for Normalization Method','Error'));
end
    
if ~isempty(htext)
    mainmsg=get(htext,'String');
    mainmsg=[mainmsg;' ';...
             'RATIO SUBGRID NORMALIZATION Per Chip';...
             '=========================================================================';' '];
    set(htext,'String',mainmsg)
    drawnow;
else
    disp('  ')
    disp('                           RATIO SUBGRID NORMALIZATION Per Chip                            ')
    disp('===================================================================================')
    disp('  ')
end

%Create ch1,ch2 data
%-ch1,ch2 include badpoints, which are marked as nan-
if chanInput==1
    for d=1:t
        for i=1:max(size(exprp{d}))
            ch1{d}{i}=2.^(exptab{d}{i}(:,1)); %Cy3
            ch2{d}{i}=2.^(exptab{d}{i}(:,2)); %Cy5
            
            %Find intensity and Ratio for every replicate per experiment
            LogRat{d}{i}=log2(ch2{d}{i})-log2(ch1{d}{i});
            Intens{d}{i}=0.5*(log2(ch2{d}{i})+log2(ch1{d}{i}));
        end
    end
elseif chanInput==2
    for d=1:t
        for i=1:max(size(exprp{d}))
            ch2{d}{i}=2.^(exptab{d}{i}(:,1)); %Cy3
            ch1{d}{i}=2.^(exptab{d}{i}(:,2)); %Cy5
            
            %Find intensity and Ratio for every replicate per experiment
            LogRat{d}{i}=log2(ch2{d}{i})-log2(ch1{d}{i});
            Intens{d}{i}=0.5*(log2(ch2{d}{i})+log2(ch1{d}{i}));
        end
    end
else
    uiwait(errordlg('Bad input!','Error'));
end

% Find subgrid areas
switch imgsw
    case 1 % QuantArray
        Row=metacords{1};
        Col=metacords{2};
        uniRow=unique(metacords{1});
        uniCol=unique(metacords{2});
        for i=1:length(uniRow)
            for j=1:length(uniCol)
                areas{i,j}=find(Row==uniRow(i) & Col==uniCol(j));
            end
        end
    case 2 % ImaGene
        Row=metacords{1};
        Col=metacords{2};
        uniRow=unique(metacords{1});
        uniCol=unique(metacords{2});
        for i=1:length(uniRow)
            for j=1:length(uniCol)
                areas{i,j}=find(Row==uniRow(i) & Col==uniCol(j));
            end
        end
    case 3 % GenePix
        Block=metacords{1};
        uniBlock=unique(metacords{1});
        for i=1:length(uniBlock)
            areas{i}=find(Block==uniBlock(i));
        end
    case 4 % Text delimited
        Row=metacords{1};
        Col=metacords{2};
        uniRow=unique(metacords{1});
        uniCol=unique(metacords{2});
        for i=1:length(uniRow)
            for j=1:length(uniCol)
                areas{i,j}=find(Row==uniRow(i) & Col==uniCol(j));
            end
        end
    case 5 % Agilent Feature Extractor
        Row=metacords{1};
        Col=metacords{2};
        uniRow=unique(metacords{1});
        uniCol=unique(metacords{2});
        for i=1:length(uniRow)
            for j=1:length(uniCol)
                areas{i,j}=find(Row==uniRow(i) & Col==uniCol(j));
            end
        end
end

if ismember(s,[1 2 3 4])

    if usetimebar
        %Initialize global timebar
        global HH
        global TOTAL_GOOD
        HH=timebar('Overall Progress in Normalization procedure','Overall Progress',0.5,0.7);
        TOTAL_GOOD=0;
        for d=1:t
            for i=1:max(size(exprp{d}))
                for p=1:size(areas,1)
                    for q=1:size(areas,2)
                        TOTAL_GOOD=TOTAL_GOOD+(length(exptab{d}{i}(areas{p,q},3))-...
                                   length(find(isnan(exptab{d}{i}(areas{p,q},3)))));
                    end
                end
            end
        end
        if ismember(imgsw,[1 2 4])
            funfun=['malowess_time_bar(Intens{d}{i}(areas{p,q}),LogRat{d}{i}(areas{p,q}),',...
                    '''Order'',OR,''Robust'',TF,''Span'',SP)'];
        elseif imgsw==3
            funfun=['malowess_time_bar(Intens{d}{i}(areas{k}),LogRat{d}{i}(areas{k}),',...
                    '''Order'',OR,''Robust'',TF,''Span'',SP)'];
        end
    else
        hh=showinfowindow('Normalizing data. Please wait...');
        if ismember(imgsw,[1 2 4])
            funfun=['malowess(Intens{d}{i}(areas{p,q}),LogRat{d}{i}(areas{p,q}),',...
                    '''Order'',OR,''Robust'',TF,''Span'',SP)'];
        elseif imgsw==3
            funfun=['malowess(Intens{d}{i}(areas{k}),LogRat{d}{i}(areas{k}),',...
                    '''Order'',OR,''Robust'',TF,''Span'',SP)'];
        end
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

    if ismember(imgsw,[1 2 4])
        
        for d=1:t
            for i=1:max(size(exprp{d}))

                str1=['Normalizing the ',':',' ',exprp{d}{i},' -Please Wait'];                
                str2=['Normalizing (Condition,Slide) part (',num2str(d),',',num2str(i),')',' out of ',...
                      '(',num2str(t),',',num2str(max(size(exprp{d}))),')'];
                
                if ~isempty(htext)
                    mainmsg=get(htext,'String');
                    mainmsg=[mainmsg;str1;str2];
                    set(htext,'String',mainmsg)
                    drawnow;
                else
                    disp(str1)
                    disp(str2)
                end
                
                for p=1:size(areas,1)
                    for q=1:size(areas,2)
                        
                        str3=['Normalizing subgrid part (',num2str(p),',',num2str(q),')','out of ',...
                              '(',num2str(size(areas,1)),',',num2str(size(areas,2)),')'];
                        if ~isempty(htext)
                            mainmsg=get(htext,'String');
                            mainmsg=[mainmsg;str3];
                            set(htext,'String',mainmsg)
                            drawnow;
                        else
                            disp(str3)
                        end 
                        
                        %Normalizing data
                        LogRatsmth{d}{i}(areas{p,q})=eval(funfun);
                        %Normalized Ratios and log2(Ratios)                      
                        LogRatnormlo{d}{i}(areas{p,q})=LogRat{d}{i}(areas{p,q})-LogRatsmth{d}{i}(areas{p,q})'; % ./ or - !
                    end
                end

                %Fix problem with dimensionality
                LogRatnormlo{d}{i}=LogRatnormlo{d}{i}';
                LogRatsmth{d}{i}=LogRatsmth{d}{i}';
                %Calculate the correlation coefficient R-I after L normalization
                %CorrsAF{d}{i}=corrcoef(abs(LogRatnormlo{d}{i}),abs(Intens{d}{i}),'rows','complete');
                %CorrsBF{d}{i}=corrcoef(abs(LogRat{d}{i}),abs(Intens{d}{i}),'rows','complete');
                
                % Repaint
                drawnow;
            end
        end
        
    elseif imgsw==3
        
        for d=1:t
            for i=1:max(size(exprp{d}))
                
                str1=['Normalizing the ',':',' ',exprp{d}{i},' -Please Wait'];
                str2=['Normalizing (Condition,Slide) part (',num2str(d),',',num2str(i),')',' out of ',...
                      '(',num2str(t),',',num2str(max(size(exprp{d}))),')'];
                
                if ~isempty(htext)
                    mainmsg=get(htext,'String');
                    mainmsg=[mainmsg;str1;str2];
                    set(htext,'String',mainmsg)
                    drawnow;
                else
                    disp(str1)
                    disp(str2)
                end
                
                for k=1:length(areas)
      
                        str3=['Normalizing block ',num2str(k),' out of ',num2str(length(areas))];
                        if ~isempty(htext)
                            mainmsg=get(htext,'String');
                            mainmsg=[mainmsg;str3];
                            set(htext,'String',mainmsg)
                            drawnow;
                        else
                            disp(str3)
                        end
                        
                        %Normalizing data
                        LogRatsmth{d}{i}(areas{k})=eval(funfun);
                        %Normalized Ratios and log2(Ratios)                      
                        LogRatnormlo{d}{i}(areas{k})=LogRat{d}{i}(areas{k})-LogRatsmth{d}{i}(areas{k})'; % ./ or - !
                end

                %Fix problem with dimensionality
                LogRatnormlo{d}{i}=LogRatnormlo{d}{i}';
                LogRatsmth{d}{i}=LogRatsmth{d}{i}';
                %Calculate the correlation coefficient R-I after L normalization
                %CorrsAF{d}{i}=corrcoef(abs(LogRatnormlo{d}{i}),abs(Intens{d}{i}),'rows','complete');
                %CorrsBF{d}{i}=corrcoef(abs(LogRat{d}{i}),abs(Intens{d}{i}),'rows','complete');
                
                % Repaint
                drawnow;
            end
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
            if ismember(imgsw,[1 2 4])
                for d=1:t
                    for i=1:max(size(exprp{d}))
                        for p=1:size(areas,1)
                            for q=1:size(areas,2)
                                meanvalue{d}{i}(p,q)=nanmean(LogRat{d}{i}(areas{p,q}));
                                LogRatnormlo{d}{i}(areas{p,q})=LogRat{d}{i}(areas{p,q})-meanvalue{d}{i}(p,q);
                                LogRatsmth{d}{i}(areas{p,q})=repmat(meanvalue{d}{i}(p,q),...
                                                                    [length(LogRat{d}{i}(areas{p,q})) 1]);
                            end
                        end
                        LogRatnormlo{d}{i}=LogRatnormlo{d}{i}';
                        LogRatsmth{d}{i}=LogRatsmth{d}{i}';
                        %CorrsAF{d}{i}=corrcoef(abs(LogRatnormlo{d}{i}),abs(Intens{d}{i}),'rows','complete');
                        %CorrsBF{d}{i}=corrcoef(abs(LogRat{d}{i}),abs(Intens{d}{i}),'rows','complete');
                    end
                end
            elseif imgsw==3
                for d=1:t
                    for i=1:max(size(exprp{d}))
                        for k=1:length(areas)
                            meanvalue{d}{i}(k)=nanmean(LogRat{d}{i}(areas{k}));
                            LogRatnormlo{d}{i}(areas{k})=LogRat{d}{i}(areas{k})-meanvalue{d}{i}(k);
                            LogRatsmth{d}{i}(areas{k})=repmat(meanvalue{d}{i}(k),...
                                                              [length(LogRat{d}{i}(areas{k})) 1]);
                        end
                        LogRatnormlo{d}{i}=LogRatnormlo{d}{i}';
                        LogRatsmth{d}{i}=LogRatsmth{d}{i}';
                        %CorrsAF{d}{i}=corrcoef(abs(LogRatnormlo{d}{i}),abs(Intens{d}{i}),'rows','complete');
                        %CorrsBF{d}{i}=corrcoef(abs(LogRat{d}{i}),abs(Intens{d}{i}),'rows','complete');
                    end
                end
            end
            SP=NaN;
        
        case 6 % Global Median
            if ismember(imgsw,[1 2 4])
                for d=1:t
                    for i=1:max(size(exprp{d}))
                        for p=1:size(areas,1)
                            for q=1:size(areas,2)
                                medianvalue{d}{i}(p,q)=nanmedian(LogRat{d}{i}(areas{p,q}));
                                LogRatnormlo{d}{i}(areas{p,q})=LogRat{d}{i}(areas{p,q})-medianvalue{d}{i}(p,q);
                                LogRatsmth{d}{i}(areas{p,q})=repmat(medianvalue{d}{i}(p,q),...
                                                                    [length(LogRat{d}{i}(areas{p,q})) 1]);
                            end
                        end
                        LogRatnormlo{d}{i}=LogRatnormlo{d}{i}';
                        LogRatsmth{d}{i}=LogRatsmth{d}{i}';
                        %CorrsAF{d}{i}=corrcoef(abs(LogRatnormlo{d}{i}),abs(Intens{d}{i}),'rows','complete');
                        %CorrsBF{d}{i}=corrcoef(abs(LogRat{d}{i}),abs(Intens{d}{i}),'rows','complete');
                    end
                end
            elseif imgsw==3
                for d=1:t
                    for i=1:max(size(exprp{d}))
                        for k=1:length(areas)
                            medianvalue{d}{i}(k)=nanmedian(LogRat{d}{i}(areas{k}));
                            LogRatnormlo{d}{i}(areas{k})=LogRat{d}{i}(areas{k})-medianvalue{d}{i}(k);
                            LogRatsmth{d}{i}(areas{k})=repmat(medianvalue{d}{i}(k),...
                                                              [length(LogRat{d}{i}(areas{k})) 1]);
                        end
                        LogRatnormlo{d}{i}=LogRatnormlo{d}{i}';
                        LogRatsmth{d}{i}=LogRatsmth{d}{i}';
                        %CorrsAF{d}{i}=corrcoef(abs(LogRatnormlo{d}{i}),abs(Intens{d}{i}),'rows','complete');
                        %CorrsBF{d}{i}=corrcoef(abs(LogRat{d}{i}),abs(Intens{d}{i}),'rows','complete');
                    end
                end
            end
            SP=NaN;
    end
    
end

if sumprobes
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
                LogRatsmth,...
                areas};

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
