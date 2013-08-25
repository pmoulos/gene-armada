function [FinalTable,clusters,pIndex,centroids,u,group] = FCMClustering(DataCellStat,k,varargin)

%
% Fuzzy C-Means Clustering and formation of Clusters for significant genes
%
% Implemented for ARMADA GUI
%
% Usage: FinalTable = ExpHClustering(DataCellStat,k,varargin)
%
% Arguments:
% DataCellStat : A cell array containing experiment information after the statistical
%                selection procedure (output from MA_StatExp.m)
% k            : Number of desired centroids (clusters)
%
% PropertyName     PropertyValue                                                  
% -----------------------------------------------------------------------------
% ClusterWhat      : A string declaring whether to use the mean expression over all the
%                    replicates for each condition or use the expression of each slide
%                    replicate separetely. The latter might require much more computational
%                    time for hierarchical clustering. However it might provide a sort of
%                    quality control for the experiment as slide replicates from the same
%                    condition are expected to cluster together
%                    Values : 'means' for using the mean expression
%                             'replicates' (default) for using the expression of all 
%                             replicates
% ClusterDim       : Cluster rows (genes) or conditions (replicates)?
%                    Values : 1 for genes (default)
%                             2 for replicates
%
% PValue           : A p-value cutoff for genes to be used for clustering. For example, if
%                    you have created DataCellStat with a p-value cutoff of 0.05, you might
%                    prefer to perform clustering using only the genes with p-value<0.01. Set
%                    p=-1 to use all the genes from DataCellStat
%
% FuzzyParam       : The fuzzy parameter. Recommended not to be over 2 (default).
%
% Tolerance       : Algorithm convergence tolerance. Defaults to 1e-5.
%
% MaxIter         : The maximum number of iterations
%
% Optimize        : True or false (default). Optimize the fuzzy parameter.     
%
% CVThreshold     : A constant such as CV(Dims) = CVConstant * Data dimensionality (see
%                   the reference below for further information).
% MTol            : Fuzzy parameter optimization tolerance.
%
% OptMaxIter      : Maximum number of iterations for optimizing fuzzy parameter.
%
% HText           : Edit text handle (optional for ARMADA use) 
%
% Outputs :
% FinalTable        : Output as in hierarhical clustering with minor differences
% clusters          : The cluster IDs
% pIndex            : The indices of the cut due to p-value restricitions genes
% centroids         : Centroid coordinates for each of the k clusters
% u                 : final fuzzy partition matrix (or membership function matrix)
% group             : Group names (useful for plotting expression profiles)
%             
% See also MA_STATEXP, MA_STATEXP_AUTO, EXPHCLUSTERING
%
% Reference : Dembele, D. and Kastner, P.: Fuzzy C-Means Method for Clustering Microarray
%             Data, Bioinformatics 19(8), 973-980, 2003.
%

% Set some defaults
repCh='replicates';
clusDim=1;
pClustCut=-1;
m=2;
tol=1e-5;
maxiter=500;
optimize=false;
cvcon=0.03;
mtol=1e-3;
miter=500;
htext=[];

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'clusterwhat','clusterdim','pvalue','fuzzyparam','tolerance','maxiter',...
            'optimize','cvthreshold','mtol','optmaxiter','htext'};
    for i=1:2:length(varargin)-1
        parName=varargin{i};
        parVal=varargin{i+1};
        j=strmatch(lower(parName),okargs);
        if isempty(j)
            error('Unknown parameter name: %s.',parName);
        elseif length(j)>1
            error('Ambiguous parameter name: %s.',parName);
        else
            switch(j)
                case 1 % Cluster means or replicates
                    if ~ischar(parVal)
                        error('The %s parameter value must be the string ''means'' or ''replicates''',parName)
                    else
                        repCh=parVal;
                    end
                case 2 % Clustering dimension
                    if ~(isscalar(parVal) && isnumeric(parVal))
                        error('The %s parameter value must be 1 or 2.',parName)
                    else
                        clusDim=parVal;
                    end
                case 3 % p-value cutoff
                    if ~(isscalar(parVal) && isnumeric(parVal))
                        error('The %s parameter value must be numeric',parName)
                    elseif parVal<0 || parVal>1
                        error('The %s parameter value must be between 0 and 1.',parName)
                    else
                        pClustCut=parVal;
                    end
                case 4 % Fuzzy parameter
                    if ~(isscalar(parVal) && isnumeric(parVal) && parVal>0)
                        error('The %s parameter value must be a positive value.',parName)
                    else
                        m=parVal;
                    end
                case 5 % Tolerance
                    if ~(isscalar(parVal) && isnumeric(parVal) && parVal>0)
                        error('The %s parameter value must be a positive value.',parName)
                    else
                        tol=parVal;
                    end
                case 6 % Maximum iterations
                    if ~(isscalar(parVal) && isnumeric(parVal) && parVal>0 && rem(parVal,1)==0)
                        error('The %s parameter value must be a positive integer.',parName)
                    else
                        maxiter=parVal;
                    end
                case 7 % Optimize
                    z=destf(parVal);
                    if isempty(z)
                        error('The %s parameter value must be either true or false',parName)
                    else
                        optimize=z;
                    end
                case 8 % Constant CV
                    if ~(isscalar(parVal) && isnumeric(parVal) && parVal>0)
                        error('The %s parameter value must be a positive value.',parName)
                    else
                        cvcon=parVal;
                    end
                case 9 % Optimization tolerance
                    if ~(isscalar(parVal) && isnumeric(parVal) && parVal>0)
                        error('The %s parameter value must be a positive value.',parName)
                    else
                        mtol=parVal;
                    end
                case 10 % Optimization maximum iterations
                    if ~(isscalar(parVal) && isnumeric(parVal) && parVal>0 && rem(parVal,1)==0)
                        error('The %s parameter value must be a positive integer.',parName)
                    else
                        miter=parVal;
                    end 
                case 11 % Edit text
                    if ~ishandle(htext)
                        error('The %s parameter value must be a valid handle.',parName)
                    else
                        htext=parVal;
                    end
            end
        end
    end
end

% Begin process
gnCutSliPos=DataCellStat{1}(:,1); %Slide Position
gnCutNam=DataCellStat{2}; %Gene names
pval=DataCellStat{1}(:,2);
groupInit=DataCellStat{6}; %Initialize group names

if strcmpi(repCh,'replicates')
    exprdata=cell2mat(DataCellStat{5}); %Contains expression for all replicates
    cellSize=size(DataCellStat{5});
    repCol=zeros(size(DataCellStat{5},2));
    for ind=1:cellSize(2)
        repSize=size(DataCellStat{5}{ind});
        repCol(ind)=repSize(2);
    end
    group=cell(0);
    for i=1:cellSize(2)
        for j=1:repCol(i)
            group=[group,strcat(groupInit{i},'_Rep_',num2str(j))];
        end
    end
elseif strcmpi(repCh,'means')
    exprdata=DataCellStat{1}(:,3:end);
    group=groupInit;
end

if pClustCut~=-1
    pIndex=find(pval<=pClustCut);
else
    pIndex=1:length(pval);
end

% Create clustering data
exprdataClust=exprdata(pIndex,:);
% Because this algorithm works with transposed data relative to others
if clusDim==1 
    exprdataClust=exprdataClust';
end

% Find optimum fuzzy parameter if chosen
if optimize
    [mub,itopt]=calcMub(exprdataClust,cvcon,miter,mtol);
    m=setm(mub);
end

% Run FCM clustering
[u,centroids,itall]=dk_fcm(exprdataClust,k,m,tol,maxiter);

% Bring back clustering data to normal format
if clusDim==1 
    exprdataClust=exprdataClust';
end

% Find the clusters
indices=cell(1,k);
if clusDim==1
    clusters=zeros(size(exprdataClust,1),1);
else
    clusters=zeros(size(exprdataClust,2),1);
end
maxu=max(u);
for i=1:k
    indices{i}=find(u(i,:)==maxu);
    clusters(indices{i})=i;
end
u=u';

%Find Silhouette value
if clusDim==1
    s=silhouette(exprdataClust,clusters,'euclidean');
else
    s=silhouette(exprdataClust',clusters,'euclidean');
end

% Create display messages
line1=' ';
line2=['Fuzzy C-Means Clustering with number of clusters set to ',num2str(k),' data clusters'];
line3='----------------------------------------------';
if optimize
    line4=['Number of iterations required for fuzzy parameter optimization : ',num2str(itopt)];
else
    line4='Optimization of fuzzy parameter was not performed';
end
line5=['Fuzzy parameter : ',num2str(m)];
line6=['Number of iterations required for algorithm convergence : ',num2str(itall)];
line7=['Number of silhouette values < 0 : ',num2str(length(find(s<0))),' out of ',...
       num2str(length(clusters))];
line8='----------------------------------------------';
line9=' ';

if ~isempty(htext)
    mainmsg=get(htext,'String');
    mainmsg=[mainmsg;line1;line2;line3;line4;line5;line6;line7;line8;line9];
    set(htext,'String',mainmsg)
else
    disp(line1)
    disp(line2)
    disp(line3)
    disp(line4)
    disp(line5)
    disp(line6)
    disp(line7)
    disp(line8)
    disp(line9)
end

%Create FinalTable
if clusDim==1
    
    header={'Slide Position','GeneID','ClusterNo','Silhouette','p-value'};
    suphead=cell(1,size(u,2));
    for i=1:length(group)
        header=[header,group{i}];
    end
    for j=1:size(u,2)
        suphead{j}=['Membership_in_',num2str(j)];
    end
    header=[header,suphead];
    v=strcmp(gnCutNam(pIndex),'NA');
    if any(v)
        pIndex=pIndex(~v);
        exprdataClust=exprdataClust(~v,:);
    end
    
    FinalTable=cell(length(pIndex)+1,length(header));
    
    [sortedclusters,ix]=sort(clusters);
    gnCutSliPos=gnCutSliPos(pIndex);
    gnCutSliPos=gnCutSliPos(ix);
    gnCutNam=gnCutNam(pIndex);
    gnCutNam=gnCutNam(ix);
    pval=pval(pIndex);
    pval=pval(ix);
    s=s(ix,:);
    u=u(ix,:);
    exprdataClust=exprdataClust(ix,:);
    
    FinalTable(1,:)=header;
    FinalTable(2:end,1)=mat2cell(cast(gnCutSliPos,'uint16'),ones(1,length(gnCutSliPos)));
    FinalTable(2:end,2)=gnCutNam;
    FinalTable(2:end,3)=mat2cell(int16(sortedclusters),ones(1,length(int16(sortedclusters)),1));
    FinalTable(2:end,4)=mat2cell(s,ones(1,length(s)),1);
    FinalTable(2:end,5)=mat2cell(pval,ones(1,length(pval)),1);
    FinalTable(2:end,6:6+length(group)-1)=mat2cell(exprdataClust,ones(1,size(exprdataClust,1)),...
                                                   ones(1,size(exprdataClust,2)));
    FinalTable(2:end,6+length(group):end)=mat2cell(u,ones(1,size(u,1)),ones(1,size(u,2)));

elseif clusDim==2
    
    header={'Name','ClusterNo','Silhouette'};
    for i=1:length(gnCutNam)
        header=[header,gnCutNam{i}];
    end
    
    FinalTable=cell(length(group)+1,length(header));
    s=zeros(length(clusters),1);
    
    [sortedclusters,ix]=sort(clusters);
    s=s(ix,:);
    
    exprdataClust=exprdataClust';
    exprdataClust=exprdataClust(ix,:);
    FinalTable(1,:)=header;
    FinalTable(2:end,1)=group;
    FinalTable(2:end,2)=mat2cell(int16(sortedclusters),ones(1,length(int16(sortedclusters)),1));
    FinalTable(2:end,3)=mat2cell(s,ones(1,length(s)),1);
    FinalTable(2:end,4:end)=mat2cell(exprdataClust,ones(1,size(exprdataClust,1)),...
                                     ones(1,size(exprdataClust,2)));
end


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

