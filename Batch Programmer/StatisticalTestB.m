function DataCellStat = StatisticalTestB(DataCellFiltered,t,group,slcstatest,multcorr,thecut,htext)

%
% Statistical selection procedure: calculate p-values per gene
% Available statistical tests are Kruskal-Wallis and ANOVA-1way
%
% User does not interact with the command window
%
% Usage: DataCellStat = MA_StaTestExp(DataCellFiltered,DataCellNormLo)
%        DataCellStat = MA_StaTestExp(DataCellFiltered,group)
%        DataCellStat = MA_StaTestExp(DataCellFiltered,group,slcstatest)
%        DataCellStat = MA_StaTestExp(DataCellFiltered,group,slcstatest,multcorr)
%        DataCellStat = MA_StaTestExp(DataCellFiltered,group,slcstatest,multcorr,thecut)
%        DataCellStat = MA_StaTestExp(DataCellFiltered,group,slcstatest,multcorr,thecut,htext)
%
% Arguments:
% DataCellFiltered : A cell array containing experiment information after the trust factor
%                    filtering procedure (output from filterReplicates.m)
% group            : A cell array of strings containing names for experimental categories.
%                    If not specified it will be created automatically with group names
%                    'Experiment_1', 'Experiment_2',... etc.
% slcstatest       : Select the statistical test for DE genes identification
%                    slcstatest=1 for Kruskal-Wallis (non-parametric)
%                    slcstatest=2 for ANOVA-1way (parametric, default)
%                    slcstatest=3 for t-test between TWO conditions 
% multcorr         : Which method to use for multiple testing correction:
%                    multcorr=1 : None (no correction, default)
%                    multcorr=2 : Bonferroni
%                    multcorr=3 : Benjamini-Hochberg FDR
%                    multcorr=4 : Storey pFDR (bootstrap)
%                    multcorr=5 : Storey pFDR (polynomial)
% thecut           : Either the p-value cutoff to select DE genes after statistical
%                    tests if usefdr=2 (NOT using the FDR control) or the desired FDR 
%                    control level if usefdr=1 (using the FDR control). Both should lie
%                    between 0 and 1. Default is 0.05
% htext            : Message handle (for ARMADA)         
%
% Output:
% Contents of DataCellStat:
% FinalTable      : A matrix of data after statistical test containing the slide positions
%                   of DE genes, 2 reserved columns, the corresponding p-values, 1 more
%                   reserved column and the following columns contain the normalized and
%                   possibly centered values for all replicates and conditions (in the
%                   order given or selected)
% gnIDCutStat     : The IDs of DE genes
% gnCutStat       : The Slide Positions of the DE genes
% FinalTableALL   : A matrix whose 1st column contains the Slide Positions for ALL the
%                   genes in the array and the following columns contain the mean
%                   expression over the replicates of each condition (1 column for each 
%                   condition)
% NormIRfinalStat : A cell containing as many matrices as the number of conditions. Each
%                   matrix contains the expression values of DE genes for all the
%                   replicates of the condition where the matrix refers to. Normally each
%                   matrix has dimension (#DEgenes)x(#Replicates)
% FNormIRfinalALL : A cell containing as many matrices as the number of conditions. Each
%                   matrix contains the expression expression values of ALL genes for all
%                   the replicates of the condition where the matrix refers to. Normally
%                   each matrix has dimension (#Genes)x(#Replicates). The values in these
%                   matrices are log2 transformed, normalized and averaged for missing
%                   values
% group           : The condition names
% TrustCoeffs     : A matrix of size (#Genes)x(#Conditions) containing the Trust Factor
%                   coefficients for ALL the genes in the array 
%             
% See also NORMALIZATIONSTART, FILTERREPLICATES, MA_STATESTEXP
%

% Check for various inputs
if nargin<3
    % Assign automatic group names
    group=cell(1,t);
    for i=1:t
        group{i}=strcat('Experiment_',num2str(i));
    end
    slcstatest=2; % Default test is ANOVA1
    multcorr=1;   % Dont' use multiple testing correction
    thecut=0.05;
    htext=[];
elseif nargin<4
    slcstatest=2; 
    multcorr=1;
    thecut=0.05;
    htext=[];
elseif nargin<5
    multcorr=1;
    thecut=0.05;
    htext=[];
elseif nargin<6
    thecut=0.05;
    htext=[];
elseif nargin<7
    htext=[];
end
% End various input checking

gnCut=DataCellFiltered{3}; %Slide Position for so far filtered genes
gnIDCut=DataCellFiltered{4}; %ReArrayID for so far filtered genes
NormIRfinal=DataCellFiltered{1}; %Filtered genes for each replicate and condition
c2mMean_coldata=DataCellFiltered{2}; %Means over replicates for each condition after MAD for ALL genes
c2mMean_coldataCUTF=DataCellFiltered{5}; %Means over replicates for each condition after MAD for FILTERED genes
UnionNoTrust=DataCellFiltered{6}; %Slide Positions for so far cut genes (not trusted)
TrustCoeffs=DataCellFiltered{7}; %Trust coefficients for ALL genes

if ~isempty(htext)
    mainmsg=get(htext,'String');
    mainmsg=[mainmsg;' ';...
        '++++++ STATISTICAL TEST +++++';...
        '====================================';' ';
        ['Number of Conditions : ',num2str(t)]];
    set(htext,'String',mainmsg)
    drawnow;
else
    disp(' ')
    disp(' ')
    disp('                     ++++++ STATISTICAL TEST +++++')
    disp('======================================================================')
    exps=['Experiments : ',num2str(t)];
    disp(exps)
    disp(' ')
end

% Calculate p-values
p=statTestInternal(t,NormIRfinal,group,slcstatest);
% Correct for multiple testing and find DE gene indices
switch multcorr
    case 1 % No correction
        dfexpr=find(p<=thecut);
        fdr=[];
        q=[];
    case 2 % Bonferroni
        dfexpr=find(p<=thecut/length(p));
        fdr=[];
        q=[];
    case 3 % FDR Benjamini-Hochberg
        fdr=mafdr(p,'BHFDR',true);
        q=nan(length(fdr),1);
        dfexpr=find(fdr<=thecut);
    case 4 % pFDR Storey (bootstrap)
        [fdr,q]=mafdr(p);
        dfexpr=find(fdr<=thecut);
    case 5 % pFDR Storey (polynomial)
        [fdr,q]=mafdr(p,'Method','polynomial');
        dfexpr=find(fdr<=thecut);
end
        
if isempty(dfexpr)
    if ~isempty(htext)
        mainmsg=get(htext,'String');
        mainmsg=[mainmsg;' ';...
                 'No Differentially Expressed genes meet the criteria you specified.';' '];
        set(htext,'String',mainmsg)
        drawnow;
    else
        disp(' ')
        disp('No Differentially Expressed genes meet the criteria you specified.')
        disp(' ')
    end
    DataCellStat=[];
    return
else
    
    if ~isempty(htext)
        mainmsg=get(htext,'String');
        mainmsg=[mainmsg;' ';...
            ['Final DE genes: ',num2str(length(dfexpr))];' '];
        set(htext,'String',mainmsg)
        drawnow;
    else
        fdeg=['              Final DE : ',num2str(length(dfexpr))];
        disp(fdeg)
    end

    %Associate Differentially Expresed Genes
    pCut=p(dfexpr);
    if ~isempty(fdr)
        fdrCut=fdr(dfexpr);
        qCut=q(dfexpr);
    else
        %fdrCut=nan(length(dfexpr),1);
        fdrCut=[];
        qCut=[];
    end
    %Assosiate Differentially Expressed Genes to labels
    gnCutStat=gnCut(dfexpr);
    gnIDCutStat=gnIDCut(dfexpr);
    c2mMean_coldataCUTS=c2mMean_coldataCUTF(dfexpr,:);

    %FinalTable includes all DE genes associated with the
    %p-values, the trust efficient and the means per sample
    NormIRfinalStat=cell(1,t);
    for j=1:t
        NormIRfinalStat{j}=NormIRfinal{j}(dfexpr,:);
    end

    FinalTable=zeros(length(pCut),t+2);
    FinalTable(:,1)=gnCutStat;
    FinalTable(:,2)=pCut;

    for i=1:t %Conditions
        FinalTable(:,2+i)=c2mMean_coldataCUTS(:,i);
    end

    %FinalTableALL includes all filtered genes associated with the
    %p-values the trust efficient and the means per sample
    FinalTableALL=zeros(length(c2mMean_coldata),2);
    Genes=1:length(c2mMean_coldata);
    Genes=Genes';
    GENESFILT=Genes;
    GENESFILT(UnionNoTrust)=[];
    FinalTableALL(:,1)=Genes;
    FinalTableALL(GENESFILT,2)=p;
    FinalTableALL(UnionNoTrust,2)=nan;
        
    % Create output cell
    DataCellStat={FinalTable,...
                  gnIDCutStat,...
                  gnCutStat,...
                  FinalTableALL,...
                  NormIRfinalStat,...
                  group,...
                  TrustCoeffs(dfexpr,:),...
                  [fdrCut(:),qCut(:)]};

end
          
          
function p = statTestInternal(t,datamat,g,st)

if t==1
    c2mdatamat=cell2mat(datamat);
    [h,p]=ttest(c2mdatamat',0);
elseif t>1
    if t==2
        if st==1 || st==2
            p=AnovaKruskalTab(datamat,g,st);
        elseif st==3
            mat1=datamat{1};
            mat2=datamat{2};
            if isvector(mat1)
                mat1=mat1(:);
            end
            if isvector(mat2)
                mat2=mat2(:);
            end
            [h,p]=ttest2(mat1',mat2');
        end             
    elseif t>2
        if st==3
            warnmsg={'t-test does not work for more than two conditions',...
                     'Switching to ANOVA (default)...'};
            uiwait(warndlg(warnmsg,'Warning'));
            p=AnovaKruskalTab(datamat,g,2);
        else
            p=AnovaKruskalTab(datamat,g,st);
        end
    end  
end
