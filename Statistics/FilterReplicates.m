function DataCellFiltered = FilterReplicates(DataCellNormLo,t,gnID,varargin)

%
% Gene filtering before statistical selection, MAD Centering and data averaging for
% filtered missing values based on the Trust Factor
%
% Cut off genes for all experiments which have no data in all replicates
% Replace every gene/experiment NaN elements with the average of all the available
% replicates
% Select how much "rigorous" want your filtering to be by setting the trust factor 
% Accept or not by monitoring how many genes have been cut off
%
% User does not interact with the command window
%
% Usage: DataCellFiltered = FilterReplicates(DataCellNormLo,t,gnID)
%        DataCellFiltered = FilterReplicates(DataCellNormLo,t,gnID,'ParameterName',ParameterValue)
%
% Arguments:
% DataCellNormLo   : A cell array containing experiment information after normalization
%                    (output from NormalizationStart or other normalization functions)
% t                : The number of experimental conditions
% gnID             : A cell array of string with gene IDs
%
% 
% ParameterName          ParameterValue                                                  
% -----------------------------------------------------------------------------
% BetweenNorm      Method for data centering and between slide normalization. It should be
%                  among 'mad' (default) for Median Absolute Deviation, 'quantile' for
%                  Quantile normalization or 'none' for no further scaling
%                       
% BetweenNormOpts  Options parameter for BetweenNorm. If BetweenNorm = 'mad' or 'none' it
%                  should be empty (default), else a structure with two fields: usemedian
%                  with values true or false for using the median instead of mean for
%                  quantile normalization and display for diaplaying a graph with
%                  normalized quantiles.
%                  Example: opts.usemedian=true; opts.display=true;
%                  DataCellFiltered = FilterReplicates(DataCellNormLo,t,gnID,...
%                                        'BetweenNorm','quantile','BetweenNormOpts',opts);
%         
% Impute           Method for missing value imputation. It can be one between
%                  'conditionmean' for imputation based on the mean value of the remaining
%                  genes from the SAME condition or 'knn' for k nearest neighbor based
%                  imputation from Troyanskaya et al., 2001.
%
% ImputeOpts       Options parameter for Impute. If Impute = 'conditionmean'it should be
%                  empty (default), else a structure with three fields: distance with
%                  values 'euclidean', 'seuclidean', etc. (see PDIST for details), k for
%                  the number of NNs and usemedian with values true or false for using the
%                  median instead of weighted mean for imputing a missing data position.
%                  Example: opts.distance='seuclidean'; opts.k=3; opts.usemedian=true;
%                  DataCellFiltered = FilterReplicates(DataCellNormLo,t,gnID,...
%                                         'Impute','knn','ImputeOpts',opts);
%
% ImputeWhen       Perform missing value imputation before or after between slide 
%                  normalization. Value should be 1 for imputing BEFORE or 2 for AFTER 
%                  (default)
% 
% TrustFactor      The Trust Factor for genes (#Appearances in Replicates/#Replicates)
%                  It should lie between 0 and 1, default: 0.65
%
% ViewBoxplot      Display boxplots before and after scaling. 1 for displaying, 0 for not.
%                  
% HText            Textbox handle for ARMADA. If using on command line, leave empty.
%
% Output:
% Contents of DataCellFiltered
% FNormIRfinal                    : A cell containing as many subcells as the number of
%                                   experimental conditions. Each subcell is a matrix with
%                                   size (#FilteredGenes)x(#ConditionReplicates) and
%                                   contains normalized expression values after MAD
%                                   centering (either performed or not)
% c2mAfterMADCenterMeans          : A matrix with size (#Genes)x(#Conditions) containing
%                                   the mean expression of filtered genes over all
%                                   replicates for each condition after MAD centering
%                                   (either performed or not) for ALL genes
% gnCutFilter                     : Slide Positions for filtered genes
% gnIDCutFilter                   : Gene IDs for filtered genes
% c2mAfterMADCenterMeansCUTF      : A matrix with size (#FilteredGenes)x(#Conditions) 
%                                   containing the mean expression of filtered genes over
%                                   all replicates for each condition after MAD centering
%                                   (either performed or not) for filtered genes
% UnionNoTrust                    : Slide Positions for trust factor sensitive filtered
%                                   genes
% TrustCoeffsCUTF                 : Trust Factor coefficients for 'trustworthy' genes
%                                   (trust factor filter robust genes)
% FNormIRfinalALL                 : A cell containing as many subcells as the number of
%                                   experimental conditions. Each subcell is a matrix with
%                                   size (#Genes)x(#ConditionReplicates) and contains
%                                   normalized expression values after MAD centering
%                                   (either performed or not) for ALL genes
% TrustCoeffs                     : Trust Factor coefficients for ALL genes
%             
% See also NORMALIZATIONSTART, FILTERREPLICATES
%

% Set defaults
bnorm='mad';
bnormOpts=[];
impute='conditionmean';
imputeOpts=[];
when=2;
tf=0.65;
seebox=0;
htext=[];

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)==0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'betweennorm','betweennormopts','impute','imputeopts','imputewhen',...
            'trustfactor','viewboxplot','htext'};
    for i=1:2:length(varargin)-1
        parName=varargin{i};
        parVal=varargin{i+1};
        j=strmatch(lower(parName),okargs,'exact');
        if isempty(j)
            error('Unknown parameter name: %s.',parName);
        elseif length(j)>1
            error('Ambiguous parameter name: %s.',parName);
        else
            switch(j)
                case 1 % Between normalization method
                    oknorms={'mad','quantile','none'};
                    if isempty(strmatch(parVal,oknorms,'exact'))
                        error('The %s parameter value must be one among ''mad'', ''quantile'' or ''none''',parName)
                    else
                        bnorm=parVal;
                    end
                case 2 % Between normalization parameters
                    if isempty(parVal)
                        if strcmp(bnorm,'mad') || strcmp(bnorm,'none')
                            bnormOpts=parVal;
                        else
                            error('The %s parameter value must not be empty for quantile normalization',parName)
                        end
                    elseif isstruct(parVal)
                        if strcmp(bnorm,'quantile')
                            fields=fieldnames(parVal);
                            z=strcmp({'usemedian';'display'},fields);
                            if all(z==1) || all(z==0)
                                bnormOpts=parVal;
                            else
                                error('The %s parameter value contains invalid fields',parName)
                            end
                        else
                            error('The %s parameter value contents are invalid',parName)
                        end
                    end
                case 3 % Missing value imputation methods
                    okimpts={'conditionmean','knn'};
                    if isempty(strmatch(parVal,okimpts,'exact'))
                        error('The %s parameter value must be one among ''conditionmean'' or ''knn''',parName)
                    else
                        impute=parVal;
                    end
                case 4 % Missing value imputation options
                    if isempty(parVal)
                        if strcmp(impute,'conditionmean')
                            imputeOpts=parVal;
                        else
                            error('The %s parameter value must not be empty for kNN imputation',parName)
                        end
                    elseif isstruct(parVal)
                        if strcmp(impute,'knn')
                            fields=fieldnames(parVal);
                            okcont=zeros(1,3);
                            z=strcmp('distance',fields);
                            if ~isempty(z)
                                okcont(1)=1;
                            end
                            z=strcmp('k',fields);
                            if ~isempty(z)
                                okcont(2)=1;
                            end
                            z=strcmp('usemedian',fields);
                            if ~isempty(z)
                                okcont(3)=1;
                            end
                            if all(okcont)
                                imputeOpts=parVal;
                            else
                                error('The %s parameter value contains invalid fields',parName)
                            end
                        else
                            error('The %s parameter value contents are invalid',parName)
                        end
                    end
                case 5 % When to impute
                    if parVal~=1 && parVal~=2
                        error('The %s parameter value must be 1 or 2',parName)
                    else
                        when=parVal;
                    end
                case 6 % Trust factor
                    if parVal<0 || parVal>1
                        error('The %s parameter value must be between 0 and 1',parName)
                    else
                        tf=parVal;
                    end
                case 7 % View box plot
                    z=destf(parVal);
                    if isempty(z)
                        error('The %s parameter value must be 0 or 1 (true or false)',parName)
                    else
                        seebox=parVal;
                    end
                case 8 % Textbox handle, no need for an error here
                    if ~ishandle(parVal)
                        htext=[];
                    else
                        htext=parVal;
                    end
            end
        end
    end
end
% End various input checking

% Some additional error checking
if strcmpi(bnorm,'quantile')
    if ~isstruct(bnormOpts)
        error('You must provide the parameter ''BetweenNormOpts''. See help.')
    end
end
if strcmpi(impute,'knn')
    if ~isstruct(imputeOpts)
        error('You must provide the parameter ''ImputeOpts''. See help.')
    end
end

LogRatnormlo=DataCellNormLo{2};
fsize=length(DataCellNormLo{1}{1}{1});
if seebox
    s=DataCellNormLo{5};
    SP=DataCellNormLo{4};
end

% Create cell2mat matrix table which includes all normalized data 
c2mRat=cell(1,t);
for k=1:t
    c2mRat{k}=cell2mat(LogRatnormlo{k});
end

% Update message in ARMADA
if ~isempty(htext)
    mainmsg=get(htext,'String');
    mainmsg=[mainmsg;' ';...
        '   DATA SCALING AND MISSING VALUE IMPUTATION   ';...
        '===================================================';' ';...
        '+++ Scaling and imputation are currently being performed... +++';' '];
    set(htext,'String',mainmsg)
    drawnow;
else
    disp(' ')
    disp('                DATA SCALING AND MISSING VALUE IMPUTATION                ')
    disp('=========================================================================')
    disp('+++++++  Scaling and imputation are currently being performed...  +++++++')
    disp(' ')
end

% Perform centering and imputation
[FNormIRfinal,AfterMADCenterMeans]=imputeAndScale(c2mRat,when,bnorm,bnormOpts,impute,imputeOpts);

% Diplay boxplot if wanted
if seebox
    dispBoxplots(s,SP,c2mRat,FNormIRfinal)
end

% Update message in ARMADA (again)
if ~isempty(htext)
    mainmsg=get(htext,'String');
    mainmsg=[mainmsg;' ';...
        '   REPLICATES FILTERING   ';...
        '===============================';' ';...
        '+++ Auto Filter is now running... +++';' '];
    set(htext,'String',mainmsg)
    drawnow;
else
    disp(' ')
    disp('                             REPLICATES FILTERING                ')
    disp('=========================================================================')
    disp('                +++++++   Auto Filter is now running...  +++++++')
    disp(' ')
end

EfficientTrustExp=cell(1,t);
for k=1:t
    [EfficientTrustExp{k}]=FindTrustEfficient(c2mRat{k}');
end

c2mAfterMADCenterMeanstotal=cell2mat(AfterMADCenterMeans);
TrustCoeffstotal=1-cell2mat(EfficientTrustExp);
[m n]=size(DataCellNormLo{1});
SelectConditions=1:n;

% Select which conditions will participate in the filtering process
TrustCoeffs=TrustCoeffstotal(:,SelectConditions);
c2mAfterMADCenterMeans=c2mAfterMADCenterMeanstotal(:,SelectConditions);

[rc cc]=find(TrustCoeffs==0);
allrepbad_row=unique(rc);

% Update message in ARMADA (again)
if ~isempty(htext)
    mainmsg=get(htext,'String');
    mainmsg=[mainmsg;' ';...
        ['Genes After Auto Filter Cut Off : ',num2str(fsize-length(allrepbad_row))];...
        ' ';'---------------------------------------------------'];
    set(htext,'String',mainmsg)
    drawnow;
else
    disp('Genes After Auto Filter Cut Off')
    aafc=fsize-length(allrepbad_row);
    disp(aafc)
    disp('---------------------------------------------------')
end
     
% Find Genes Below Trust Factor
[SelectedTF SelectedTFc]=find(TrustCoeffs<tf);
SelectedTF=unique(SelectedTF);
UnionNoTrust=union(SelectedTF,allrepbad_row);
UnionNoTrust=unique(UnionNoTrust);

newnumber=fsize-length(UnionNoTrust);
qstring={'The number of trustworthy genes for this',...
         ['set of conditions is ',num2str(newnumber)],...
         'Do you accept?'};
answ=questdlg(qstring,'Trust genes','Yes','No','Yes');
if strcmp(answ,'No')
    unsatisfied={'Please go back to the Statistical Selection window',...
                 'and set again the Trust Factor cutoff'};
    uiwait(msgbox(unsatisfied,'Trust genes not accepted','modal'));
    DataCellFiltered=[];
    return
elseif strcmp(answ,'Yes')
    
    % Update again main window
    if ~isempty(htext)
        mainmsg=get(htext,'String');
        mainmsg=[mainmsg;' ';...
            ['Total Trust Genes : ',num2str(fsize-length(UnionNoTrust))];...
             ' ';'---------------------------------------------------'];
        set(htext,'String',mainmsg)
        drawnow;
    else
        disp('Total Trust Genes : ')
        disp(fsize-length(UnionNoTrust))
    end
    
    % Continue with scripting
    c2mAfterMADCenterMeansCUTF=c2mAfterMADCenterMeans;
    c2mAfterMADCenterMeansCUTF(UnionNoTrust,:)=[];
    TrustCoeffsCUTF=TrustCoeffs;
    TrustCoeffsCUTF(UnionNoTrust,:)=[];

    FNormIRfinalALL=FNormIRfinal;
    for i=1:t
        FNormIRfinal{i}(UnionNoTrust,:)=[];
    end

    % Number Label gene
    gn=1:fsize;
    gn=gn';
    gnCutFilter=gn;
    % Cut off below TF genes to associate with Labels
    gnCutFilter(UnionNoTrust)=[];

    % Cut off below TF genes to associate with names
    gnIDCutFilter=gnID;
    gnIDCutFilter(UnionNoTrust)=[];

    % Create output cell
    DataCellFiltered={FNormIRfinal,...
                      c2mAfterMADCenterMeans,...
                      gnCutFilter,...
                      gnIDCutFilter,...
                      c2mAfterMADCenterMeansCUTF,...
                      UnionNoTrust,...
                      TrustCoeffsCUTF,...
                      FNormIRfinalALL};
end


function dispBoxplots(s,SP,LogRatnorm,Rat)

%Create title
switch s
    case 1
        titlab2{1}{1}=strcat('Lowess  -Span : ',num2str(SP));
    case 2
        titlab2{1}{1}=strcat('Lowess Robust -Span : ',num2str(SP));
    case 3
        titlab2{1}{1}=strcat('Loess  -Span : ',num2str(SP));
    case 4
        titlab2{1}{1}=strcat('Loess Robust -Span : ',num2str(SP));
    case 5
        titlab2{1}{1}='Global Mean';
    case 6
        titlab2{1}{1}='Global Median';
    case 7
        titlab2{1}{1}='Rank Invariant';
    otherwise
        titlab2{1}{1}='Externally Normalized';
end

% Boxplots before and after Centering
figure
subplot(2,1,1)
maboxplot(cell2mat(LogRatnorm));
title(strcat('BEFORE Mad Centering -> Normalization :',titlab2{1}{1}))
subplot(2,1,2)
maboxplot(cell2mat(Rat));
title(strcat('AFTER Mad Centering -> Normalization :',titlab2{1}{1}))


function tf = destf(pval)

if islogical(pval)
    tf=all(pval);
    return
end
if isnumeric(pval)
    tf=all(pval~=0);
    return
end
if ischar(pval)
    truevals={'true','yes','on','t'};
    k=any(strcmpi(pval,truevals));
    if k
        tf=true;
        return
    end
    falsevals={'false','no','off','f'};
    k=any(strcmpi(pval,falsevals));
    if k
        tf=false;
        return
    end
end
tf=logical([]);