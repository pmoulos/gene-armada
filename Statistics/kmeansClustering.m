function [FinalTable,clusters,pIndex,centroids,sumofdists,singledists,group,n] = ...
            kmeansClustering(DataCellStat,k,varargin)

%
% k-means Clustering and formation of Clusters for significant genes
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
% Distance         : The distance metric to be used for clustering
%                    Values: 'sqeuclidean' -> Euclidean distance (default)
%                            'correlation' -> 1 - Pearson correlation coefficient
%                            'cityblock'   -> The cityblock (Manhattan) distance
%                            'hamming'     -> The Minkowski metric family
%                            'cosine'      -> The cosine distance
%
% Start            : Method used to choose initial cluster centroid positions,sometimes 
%                    known as "seeds".
%                    Values: 'sample'  -> Select K observations from X at random
%                            'uniform' -> Select K points uniformly at random from
%                                         the range of X. Not valid for Hamming distance.
%                            'cluster' -> Perform preliminary clustering phase on
%                                         random 10% subsample of X.  This preliminary
%                                         phase is itself initialized using 'sample'.
%                            'matrix'    - A K-by-P matrix of starting locations.  In
%                                          this case, you can pass in [] for K, and
%                                          KMEANS infers K from the first dimension of
%                                          the matrix.  You can also supply a 3D array,
%                                          implying a value for 'Replicates'
%                                          from the array's third dimension.
%
% Replications      : Number of times to repeat the clustering, each with a new set of 
%                     initial centroids
%
% MaxIter           : The maximum number of iterations
%
% EmptyAction       : Action to take if a cluster loses all of its member observations.
%                     Values: 'error'     -> Treat an empty cluster as an error
%                             'drop'      -> Remove any clusters that become empty, and
%                                            set corresponding values in C and D to NaN.
%                                            (default)
%                             'singleton' -> Create a new cluster consisting of the one
%                                            observation furthest from its centroid.
%
% Display           : Display what
%
% HText             : Edit text handle (optional for ARMADA use) 
%
% Outputs :
% FinalTable        : Output as in hierarhical clustering with minor differences
% clusters          : The cluster IDs
% pIndex            : The indices of the cut due to p-value restricitions genes
% centroids         : Centroid coordinates for each of the k clusters
% sumofdists        : Within-cluster sums of point-to-centroid distances 
% singledists       : Distances from each point to every centroid
% group             : Group names (useful for plotting expression profiles)
%             
% See also MA_STATEXP, MA_STATEXP_AUTO, EXPHCLUSTERING
%

% Set some defaults
repCh='replicates';
clusDim=1;
pClustCut=-1;
dis='sqeuclidean';
strt='sample';
repli=1;
maxiter=100;
emptyact='drop';
displayopt='off';
htext=[];

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'clusterwhat','clusterdim','pvalue','distance','start','replications',...
            'maxiter','emptyaction','display','htext'};
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
                case 4 % Distance argument
                    okdists={'sqeuclidean','cityblock','correlation','hamming','cosine'};
                    if isempty(strmatch(lower(parVal),okdists))
                        error('The %s parameter value must be a valid distance argument. See help.',parName)
                    else
                        dis=parVal;
                    end
                case 5 % Start
                    okstarts={'sample','uniform','cluster'};
                    if isempty(strmatch(lower(parVal),okstarts)) && ~isnumeric(parVal)
                        error('The %s parameter value must be a valid start argument. See help.',parName)
                    else
                        strt=parVal; % Further input checking on kmeans
                    end
                case 6 % Replications
                    if ~(isscalar(parVal) && isnumeric(parVal) && parVal>0 && rem(parVal,1)==0)
                        error('The %s parameter value must be a positive integer.',parName)
                    else
                        repli=parVal;
                    end
                case 7 % Maximum iterations
                    if ~(isscalar(parVal) && isnumeric(parVal) && parVal>0 && rem(parVal,1)==0)
                        error('The %s parameter value must be a positive integer.',parName)
                    else
                        maxiter=parVal;
                    end
                case 8 % Empty cluster action
                    okempts={'error','drop','singleton'};
                    if isempty(strmatch(lower(parVal),okempts))
                        error('The %s parameter value must be a valid empty action argument. See help.',parName)
                    else
                        emptyact=parVal;
                    end
                case 9 % Display
                    okdisps={'off','iter','final','notify'};
                    if isempty(strmatch(lower(parVal),okdisps))
                        error('The %s parameter value must be a valid display argument. See help.',parName)
                    else
                        displayopt=parVal;
                    end
                case 10 % Edit text
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
if clusDim==2
    exprdataClust=exprdataClust';
end

% Run k-means clustering
[clusters,centroids,sumofdists,singledists]=kmeans(exprdataClust,k,'distance',dis,...
                                                                   'start',strt,...
                                                                   'replicates',repli,...
                                                                   'maxiter',maxiter,...
                                                                   'emptyaction',emptyact,...
                                                                   'display',displayopt);

%Find Silhouette value
%s=silhouette(exprdataClust,clusters,'euclidean');
s=silhouette(exprdataClust,clusters,dis);
n=length(find(s<0));
                                                               
% Create display messages
line1=' ';
line2=['k-means Clustering with k set to ',num2str(k),' data clusters'];
line3='----------------------------------------------';
line4='Within-cluster sums of point-to-centroid distances :';
line5=cell(k,1);
for i=1:k
    line5{i}=['Sum for centroid ',num2str(i),' is '];
end
line5=char(line5);
line5=[line5 num2str(sumofdists,'%10.5f')];
line6=['Total sum of distances is ',num2str(sum(sumofdists))];
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
    
    header={'Slide Position','GeneID','ClusterNo','Sum of Dist from Centroid','p-value'};
    for i=1:length(group)
        header=[header,group{i}];
    end
    v=strcmp(gnCutNam(pIndex),'NA');
    if any(v)
        pIndex=pIndex(~v);
        exprdataClust=exprdataClust(~v,:);
    end
    
    FinalTable=cell(length(pIndex)+1,length(header));
    %s=zeros(length(clusters),1);
    
    [sortedclusters,ix]=sort(clusters);
    gnCutSliPos=gnCutSliPos(pIndex);
    gnCutSliPos=gnCutSliPos(ix);
    gnCutNam=gnCutNam(pIndex);
    gnCutNam=gnCutNam(ix);
    pval=pval(pIndex);
    pval=pval(ix);
    %singledists=singledists(ix,:);
    %for i=1:size(singledists,1)
    %    s(i)=sum(singledists(i,:));
    %end
    s=s(ix,:);
    exprdataClust=exprdataClust(ix,:);
    
    FinalTable(1,:)=header;
    FinalTable(2:end,1)=mat2cell(cast(gnCutSliPos,'uint16'),ones(1,length(gnCutSliPos)));
    FinalTable(2:end,2)=gnCutNam;
    FinalTable(2:end,3)=mat2cell(int16(sortedclusters),ones(1,length(int16(sortedclusters)),1));
    FinalTable(2:end,4)=mat2cell(s,ones(1,length(s)),1);
    FinalTable(2:end,5)=mat2cell(pval,ones(1,length(pval)),1);
    FinalTable(2:end,6:end)=mat2cell(exprdataClust,ones(1,size(exprdataClust,1)),...
                                     ones(1,size(exprdataClust,2)));

elseif clusDim==2
    
    header={'Name','ClusterNo','Sum of Dist from Centroid'};
    for i=1:length(gnCutNam)
        header=[header,gnCutNam{i}];
    end
    
    FinalTable=cell(length(group)+1,length(header));
    %s=zeros(length(clusters),1);
    
    [sortedclusters,ix]=sort(clusters);
    %singledists=singledists(ix,:);
    %for i=1:size(singledists,1)
    %    s(i)=sum(singledists(i,:));
    %end
    s=s(ix,:);
    
    exprdataClust=exprdataClust(ix,:);
    FinalTable(1,:)=header;
    FinalTable(2:end,1)=group;
    FinalTable(2:end,2)=mat2cell(int16(sortedclusters),ones(1,length(int16(sortedclusters)),1));
    FinalTable(2:end,3)=mat2cell(s,ones(1,length(s)),1);
    FinalTable(2:end,4:end)=mat2cell(exprdataClust,ones(1,size(exprdataClust,1)),...
                                     ones(1,size(exprdataClust,2)));
end

% FinalTable(1,:)=header;
% FinalTable(2:end,1)=mat2cell(cast(gnCutSliPos(pIndex),'uint16'),...
%     ones(1,length(gnCutSliPos(pIndex))));
% FinalTable(2:end,2)=gnCutNam(pIndex);
% FinalTable(2:end,3)=mat2cell(int16(clusters(pIndex)),ones(1,length(int16(clusters(pIndex))),1));
% FinalTable(2:end,4)=mat2cell(s(pIndex),ones(1,length(s(pIndex))),1);
% FinalTable(2:end,5)=mat2cell(pval(pIndex),ones(1,length(pval(pIndex))),1);
% FinalTable(2:end,6:end)=mat2cell(exprdataClust,ones(1,size(exprdataClust,1)),...
%     ones(1,size(exprdataClust,2)));

% filename=['Clustering ',datestr(now),' ',upper(dis),' ',upper(lin),' ',...
%           'p-val ',strrep(sprintf(z,maxpval),'.','dot')];
% xlswrite(filename,FinalTable)
