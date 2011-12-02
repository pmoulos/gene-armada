function [FinalTable,clusters,pIndex,fig] = ExpHClustering(DataCellStat,varargin)

%
% Hierarchical Clustering and formation of Clusters for significant genes
%
% Available linkage algorithms: single, average, complete  
% Available distance algorithms: euclidean, standardized euclidean, Pearson correlation,
% Mahalanobis, Manhattan, cosine, Spearman correlation 
%
% Usage: FinalTable = ExpHClustering(DataCellStat,varargin)
%
% Arguments:
% DataCellStat : A cell array containing experiment information after the statistical
%                selection procedure (output from MA_StatExp.m)
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
% Distance         : The distance metric to be used for clustering
%                    Values : 'euclidean'   -> Euclidean distance (default)
%                             'seuclidean'  -> Standardized Euclidean distance
%                             'correlation' -> 1 - Pearson correlation coefficient
%                             'cityblock'   -> The cityblock (Manhattan) distance
%                             'minkowski'   -> The Minkowski metric family
%                             'cosine'      -> The cosine distance
%                             'spearman'    -> 1 - Spearman's ranking correlation coefficient
%
% Linkage          : The linkage algorithm to be used for clustering
%                    Values : 'single'   -> Single linkage
%                             'average   -> Average linkage (default)
%                             'complete' -> Complete linkage
%
% PValue           : A p-value cutoff for genes to be used for clustering. For example, if
%                    you have created DataCellStat with a p-value cutoff of 0.05, you might
%                    prefer to perform clustering using only the genes with p-value<0.01. Set
%                    p=-1 to use all the genes from DataCellStat
%
% Inconsistency    : The inconsistency coefficient cutoff to determine the number of clusters
%                    and the depth of the dendrogram. Defaults to 1.
%
% MaxClust         : The maximum number of allowed clusters. Only one of Inconsistency or
%                    MaxClust should be used, else a warning is thrown and maximum number
%                    of clsters is used as criterion.
%
% OptimalLeafOrder : Whether to optimize the leaf order in the dendrogram. Values are true
%                    or false. It can take some time to complete, especially for larger
%                    datasets.
%
% DisplayHeatmap   : A logical variable to control whether a heatmap will be displayed or
%                    not. 'true' for displaying (default), 'false' for the opposite.
%
% Title            : A title for the heatmap
% HText            : Textbox handle (for ARMADA)
%
% Output:
% A figure of the clustering heatmap and a MatLab matrix or Excel file containing
% information about formed clusters.
%             
% See also STATISTICALTEST, KMEANSCLUSTERING
%

% Set some defaults
repCh='replicates';
d=3;
dis='euclidean';
lin='average';
pClustCut=-1;
incut=1;
% maxclust=[];
maxclust=NaN;
optleaf=false;
disheat=true;
tit='';
htext=[];

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)==0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'clusterwhat','clusterdim','distance','linkage','optimalleaforder','pvalue',...
            'inconsistency','maxclust','displayheatmap','title','htext'};
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
                        d=parVal;
                    end
                case 3 % Distance argument
                    okdists={'euclidean','seuclidean','correlation','mahalanobis','cityblock','minkowski',...
                             'cosine','spearman'};
                    if isempty(strmatch(lower(parVal),okdists))
                        error('The %s parameter value must be a valid distance argument. See help.',parName)
                    else
                        dis=parVal;
                    end
                case 4 % Linkage argument
                    oklins={'single','average','complete','weighted','centroid','median','ward'};
                    if isempty(strmatch(lower(parVal),oklins))
                        error('The %s parameter value must be a valid linkage argument. See help.',parName)
                    else
                        lin=parVal;
                    end
                case 5 % Optimal leaf order
                    if ~isa(parVal,'logical') || numel(parVal)~=1
                        error('Parameter %s must be a logical scalar, true or false.',parName);
                    else
                        optleaf=parVal;
                    end
                case 6 % p-value cutoff
                    if ~(isscalar(parVal) && isnumeric(parVal))
                        error('The %s parameter value must be numeric.',parName)
                    elseif parVal<0 || parVal>1
                        error('The %s parameter value must be between 0 and 1.',parName)
                    else
                        pClustCut=parVal;
                    end
                case 7 % Inconsistency
                    if ~(isscalar(parVal) && isnumeric(parVal)) && ~isnan(parVal)
                        error('The %s parameter value must be numeric or empty.',parName)
                    elseif parVal<0
                        error('The %s parameter value must be positive.',parName)
                    else
                        incut=parVal;
                    end
                case 8 % Maximum number of clusters
                    if ~(isscalar(parVal) && isnumeric(parVal) && parVal>0 && rem(parVal,1)==0) && ~isnan(parVal)
                        error('The %s parameter value must be a positive integer or empty',parName)
                    else
                        maxclust=parVal;
                    end
                case 9 % Display heatmap
                    disheat=destf(parVal);
                    if isempty(disheat)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        disheat=parVal;
                    end
                case 10 % Title
                    if ~ischar(parVal)
                        error('The %s parameter value must be a string.',parName)
                    else
                        tit=parVal;
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
gnCutST=DataCellStat{2}; %Gene names
pval=DataCellStat{1}(:,2);
groupInit=DataCellStat{6}; %Initialize group names

if strcmpi(repCh,'replicates')
    FinalNormIRfinal=cell2mat(DataCellStat{5}); %Contains expression for all replicates
    cellSize=size(DataCellStat{5});
    repCol=[];
    for ind=1:cellSize(2)
        repSize=size(DataCellStat{5}{ind});
        repCol=[repCol,repSize(2)];
    end
    group=cell(0);
    for i=1:cellSize(2)
        for j=1:repCol(i)
            group=[group,strcat(groupInit{i},'_Rep_',num2str(j))];
        end
    end
elseif strcmpi(repCh,'means')
    FinalNormIRfinal=DataCellStat{1}(:,3:end);
    group=groupInit;
else
    error('Bad Input')
end

if pClustCut>1
    error('Probability should be within 0 and 1')
elseif pClustCut~=-1
    pIndex=find(pval<pClustCut);
    pvalNew=pval(pIndex);
else
    pIndex=1:length(pval);
    pvalNew=pval;
end

%Create data for clustering
FinalNormIRfinalClust=FinalNormIRfinal(pIndex,:);

pdTable=pdist(FinalNormIRfinalClust,dis);
LkTable=linkage(pdTable,lin);
sLkTable=LkTable;

if disheat
    
    %Create clustergram title
    if isempty(tit)
        maxpval=max(pvalNew);
        if (maxpval<=0.001 || maxpval<=0.005)
            z='%1.3f';
        else
            z='%1.2f';
        end
        %A check for visibility of possible subscript (character '_')
        zz=strrep(groupInit,'_','-');
        %Create properly this part of title depending on the string length
        titlepar=[num2str(length(zz)),' ','Conditions'];
        clstitle=['Hierarchical Clustering - ',lin,' - ',dis,' - ',...
            titlepar,' - ','p-value<',sprintf(z,maxpval)];
        if rem(length(group),2)==0
            xpos=length(group)/2+0.5;
        else
            xpos=length(group)/2;
        end
        ypos=length(pIndex)+30*length(pIndex)/100;
    else
        if ~isempty(strfind(tit,'_'))
            tit=strrep(tit,'_','-');
        end
        clstitle=tit;
    end

    %Create Figure
    if d==1
        fig=figure;
        myclustergram(FinalNormIRfinalClust,'ROWLABELS',gnCutST,'COLUMNLABELS',group,...
                      'PDIST',dis,'LINKAGE',lin,'OPTIMALLEAFORDER',optleaf);
    elseif d==2
        fig=figure;
        myclustergram(FinalNormIRfinalClust','ROWLABELS',group,'COLUMNLABELS',gnCutST,...
                      'PDIST',dis,'LINKAGE',lin,'OPTIMALLEAFORDER',optleaf);
    elseif d==3
        fig=figure;
        myclustergram(FinalNormIRfinalClust,'ROWLABELS',gnCutST,'COLUMNLABELS',group,...
                      'PDIST',dis,'LINKAGE',lin,'DIMENSION',2,'OPTIMALLEAFORDER',optleaf);
    end

    %Fill figure with extras
    if isempty(tit)
        title(clstitle,'FontSize',12,'FontWeight','bold','Position',[xpos ypos])
    else
        title(clstitle,'FontSize',12,'FontWeight','bold')
    end
    set(gca,'FontSize',11-2*log(length(group)))
    % colorbar('OuterPosition',[0.9 -0.025 0.05 0.85],'FontSize',10);
    % fillscreen(fig)
    
end

% %Find clusters
% if isempty(maxclust) && ~isempty(incut)
%     clusters=cluster(sLkTable,'cutoff',incut);
% elseif isempty(incut) && ~isempty(maxclust)
%     clusters=cluster(sLkTable,'maxclust',maxclust);
% elseif ~isempty(incut) && ~isempty(maclust)
%     msg=['Only one of ''Inconsistency'' or ''MaxClust'' should be given!',...
%          'Proceeding with maximum number of clusters...'];
%     warning('ARMADA:IncutAndMaxClust',msg)
%     clusters=cluster(sLkTable,'maxclust',maxclust);
% end

%Find clusters
if isnan(maxclust) && ~isnan(incut)
    clusters=cluster(sLkTable,'cutoff',incut);
elseif isnan(incut) && ~isnan(maxclust)
    clusters=cluster(sLkTable,'maxclust',maxclust);
elseif ~isnan(incut) && ~isnan(maxclust)
    msg=['Only one of ''Inconsistency'' or ''MaxClust'' should be given!',...
         'Proceeding with maximum number of clusters...'];
    warning('ARMADA:IncutAndMaxClust',msg)
    clusters=cluster(sLkTable,'maxclust',maxclust);
end
    
maxCl=max(clusters);

%Find Silhouette value
s=silhouette(FinalNormIRfinalClust,clusters,'Euclidean');

msg1=['Silhouette values < 0 : ',num2str(length(find(s<0))),' out of ',num2str(length(clusters))];
msg2=['Clusters : ',num2str(maxCl)];

if ~isempty(htext)
    mainmsg=get(htext,'String');
    mainmsg=[mainmsg;' ';msg1;...
             '----------------------------------------------';...
             msg2;'----------------------------------------------',' '];
    set(htext,'String',mainmsg)
else
    disp(msg1)
    disp('-------------------------------------------------------------')
    disp(msg2)
    disp('-------------------------------------------------------------')
end

%Create FinalTable
header={'Slide Position','GeneID','ClusterNo','Silhouette','p-value'};
for i=1:length(group)
    header=[header,group{i}];
end
v=strcmp(gnCutST(pIndex),'NA');
if any(v)
    pIndex=pIndex(~v);
    FinalNormIRfinalClust=FinalNormIRfinalClust(~v,:);
end

FinalTable=cell(length(pIndex)+1,length(header));

[sortedclusters,ix]=sort(clusters);
gnCutSliPos=gnCutSliPos(pIndex);
gnCutSliPos=gnCutSliPos(ix);
gnCutST=gnCutST(pIndex);
gnCutST=gnCutST(ix);
pval=pval(pIndex);
pval=pval(ix);
s=s(ix,:);
FinalNormIRfinalClust=FinalNormIRfinalClust(ix,:);

FinalTable(1,:)=header;
FinalTable(2:end,1)=mat2cell(cast(gnCutSliPos,'uint16'),ones(1,length(gnCutSliPos)));
FinalTable(2:end,2)=gnCutST;
FinalTable(2:end,3)=mat2cell(int16(sortedclusters),ones(1,length(int16(sortedclusters)),1));
FinalTable(2:end,4)=mat2cell(s,ones(1,length(s)),1);
FinalTable(2:end,5)=mat2cell(pval,ones(1,length(pval)),1);
FinalTable(2:end,6:end)=mat2cell(FinalNormIRfinalClust,ones(1,size(FinalNormIRfinalClust,1)),...
                                 ones(1,size(FinalNormIRfinalClust,2)));


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
