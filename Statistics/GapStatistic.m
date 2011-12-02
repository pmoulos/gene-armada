function [bestk,gapk,sk] = GapStatistic(DataCellStat,ks,varargin)

%
% Calculation of Gap statistic for the estimation of the optimum number of clusters (based
% on the paper of Tibshirani et al., 2001).
%
% GAPSTAT calculates the optimal number of clusters based on the intra-cluster distances
% measured by specified distance metrics and one of the clustering algorithms supported.
% For a more detailed description of the method used to calculate the result, see the
% reference in the end of help text.
%
% Adjusted for ARMADA
%
% Syntax:
% ---------------------------
%
% [best]=gapstat(DataCellStat,ks)
% [bestk,gapk]=gapstat(DataCellStat,ks)
% [bestk,gapk,sk]=gapstat(DataCellStat,ks)
% [...]=gapstat(DataCellStat,ks,'PropertyName',PropertyValue)
%
% Arguments:
%
% DataCellStat : The output from StatisticalTest.
%        
% ks   : The range of number of clusters to which the dataset will be clustered into in
%        order to choose the optimal one. ks can also be a scalar.
%
% PropertyName   PropertyValue                                                  
% -----------------------------------------------------------------------------
% Algorithm      : A string declaring which clustering algorithm to use.
%                  Values : 'hierarchical' for hierarchical clustering
%                           'kmeans' for k-means clustering (default)
%                           'fcm' for fuzzy c-means clustering
%                  Hierarchical and k-means clustering are based on the functions
%                  CLUSTERDATA and KMEANS from the Statistics Toolbox while fuzzy c-means
%                  clustering is based on the function FCM of the Fuzzy Logic Toolbox.
% AlgoArgs       : A cell array of the type {'PropertyName',PropertyValue} used in many
%                  MATLAB functions (e.g. see KMEANS). See the help of each MATLAB
%                  function for details on Properties. Note that in the case of
%                  hierarchical clustering the property 'MaxClust' should not be given.
%
% Reference      : A string declaring the reference data matrix generation method. See 
%                  the reference paper for detatails.
%                  Values: 'uniform' (default) for reference data matrix based on uniform
%                          distribution with ranges from the original data matrix
%                          'pca' for reference data matrix based on uniform distribution
%                          based on the principal components of the original data matrix
%                          'boot' to use a bootstraped matrix of the initial data matrix
%                          instead of uniformly distributed version
%                          'bootpca' to use a bootstrapped matrix calculated based on the
%                          principal components of the original data matrix
%
%
% Refsize        : How many reference data matrices to be generated. Default is 500.
%
% Repetitions    : How many times the method should be repeated. Because of the
%                  stochastic nature of the algorithm, it would be better to perform for
%                  example 10 repetitions and choose as the optimal number of clusters
%                  the number with the highest frequency among the 10 repetitions.
%                  Default is 1.
%
% ShowPlots      : Display the Gap curve and the intra-cluster sum of squares (see
%                  reference paper).
%                  Values : true (default)
%                           false
%
% Verbose        : Display verbose messages.
%                  Values : true
%                           false (default)
%
% UseWaitbar     : Display a multiple waitbar to show the progress for each step of the
%                  algorithm. This feature uses the cwaitbar function implemented by
%                  Rasmus Anthin taken from MATLAB exchange and very slightly modified.
%                  Values : true (default)
%                           false
%
% UseSquared     : Whether to use the squared euclidean distance in the calculation of the
%                  pooled within cluster sum of distances Wk (see paper) as the authors
%                  propose or to use the same distance that was used for the clustering
%                  process. Sometimes the latter works better.
%                  Values : true
%                           false (default)
%
%
% Outputs :
%
% bestk : The optimal number of clusters.
% gapk  : The Gap statistic vector from the last repetition.
% sk    : The standard deviation estimation (see paper) from the last repetition.
%
% IMPORTANT NOTE: The algorithm that the authors of the reference paper present will not
% always return the best number of clusters. They propose to always perform a graphical
% inspection of the Gap curve so as to have sometimes a better estimation. Thus, it is
% recommended to run the program with the 'ShowPlots' property set to true.
%
% Reference:
% Tibshirani, R., Walther, G., Hastie, T.: Estimating the Number of Clusters in a Data Set
% via the Gap Statistic, Journal of the Royal Statistical Society, Vol. 63, No. 2, 2001,
% pp. 411-423.
%
% Examples:
%
% % Generate a pseudo-dataset consisting of 3 clusters
% y1=-0.5+rand(100,3)+0.1*randn(100,3);
% y2=-0.5+rand(100,3)+0.1*randn(100,3)+10;
% y3=-0.5+rand(100,3)+0.1*randn(100,3)+100;
% data=[y1;y2;y3];
%
% [bestk,gap,sk]=gapstat(data,1:10,'Verbose',true,...
%                                  'ShowPlots',true);
%
% bestk=gapstat(data,1:10,'Algorithm','hierarchical',...
%                         'AlgoArgs',{'distance','correlation','linkage','complete'},...
%                         'ShowPlots',true);
%
% bestk=gapstat(data,1:10,'Reference','pca',...
%                         'Refsize',100,...
%                         'Repetitions',10,...
%                         'ShowPlots',true);
%
% See also : CLUSTERDATA, KMEANS, FCM, PDIST
%

% Author        : Panagiotis Moulos (pmoulos@eie.gr)
% First created : January 3, 2008
% Last modified : -
% 
% This function uses the following functions taken from MATLAB exchange:
% CWAITBAR by Rasmus Anthin (File Id: 4121)
% FREQTABLE by Mukhtar Ullah (File Id: 6631)
% I would like to thank the above users for their submissions.
% Also the function:
% BOOTSRP by A. M. Zoubir and D. R. Iskander from the Bootstrap Toolbox
% (http://www.csp.curtin.edu.au/downloads/bootstrap.zip)

% Set defaults
algo='kmeans';
algoargs={};
method='uniform';
refsize=500;
repeat=1;
showplot=true;
verbose=false;
usewait=true;
usesquared=false;

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'algorithm','algoargs','reference','refsize','repetitions','showplots',...
            'verbose','usewaitbar','usesquared'};
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
                case 1 % Algorithm
                    okalgs={'hierarchical','kmeans','fcm'};
                    if ~ischar(parVal)
                        error('The %s parameter value must be a string.',parName)
                    elseif isempty(strmatch(lower(parVal),okalgs))
                        error('The %s parameter value must be a valid algorithm argument. See help.',parName)
                    else
                        algo=lower(parVal);
                    end
                case 2 % Algorithm args
                    if ~iscell(parVal)
                        error('The %s parameter value must be a cell array.',parName)
                    else
                        algoargs=parVal;
                        if strcmpi(algo,'hierarchical')
                            algoargs=checkMaxClust(algoargs);
                        elseif strcmpi(algo,'kmeans')
                            algoargs=checkEu(algoargs);
                        end
                    end
                case 3 % Reference distribution estimation method
                    okrefs={'uniform','pca','boot','bootpca'};
                    if isempty(strmatch(lower(parVal),okrefs))
                        error('The %s parameter value must be a valid reference argument. See help.',parName)
                    else
                        method=lower(parVal);
                    end
                case 4 % Reference data generation repetitions
                    if ~isnumeric(parVal) || ~isscalar(parVal) || parVal<0 || rem(parVal,1)~=0
                        error('The %s parameter value must be a positive integer.',parName)
                    else
                        refsize=parVal;
                    end
                case 5 % Method repetitions
                    if ~isnumeric(parVal) || ~isscalar(parVal) || parVal<0 || rem(parVal,1)~=0
                        error('The %s parameter value must be a positive integer.',parName)
                    else
                        repeat=parVal;
                    end
                case 6 % Show Gap curve
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        showplot=parVal;
                    end
                case 7 % Display verbose messages
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        verbose=parVal;
                    end
                case 8 % Use waitbar
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        usewait=parVal;
                    end
                case 9 % Use squared euclidean distance in Wk
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        usesquared=parVal;
                    end
            end
        end
    end
end

% Start process

bestk=zeros(1,repeat);

if usewait
    h=cwaitbar([0 0 0],{'Method repetitions - Progress',...
               'Calculating Gap statistic - Progress','Clustering reference dataset - Progress'},...
               {'g','r','b'});
end

for iter=1:repeat
    
    if usewait
        cwaitbar([1 iter/repeat])
    end

    % Generate reference distribution based on what to cluster (means or replicates)
    what=findClusterWhat(algoargs);
    if strcmpi(what,'replicates')
        sdata=cell2mat(DataCellStat{5});
    elseif strcmpi(what,'means')
        sdata=DataCellStat{1}(:,3:end);
    end
    refcell=cell(1,refsize);
    if verbose
        outmsg=['Reference data generation method : ',method];
        disp(' ')
        disp(outmsg)
        disp('Generating reference data. Please wait...')
        disp(' ')
        for i=1:refsize
            inmsg=['Generating reference data matrix ',num2str(i),' out of ',num2str(refsize)];
            disp(inmsg)
            refcell{i}=generateRefData(sdata,method);
        end
        disp(' ')
    else
        for i=1:refsize
            refcell{i}=generateRefData(sdata,method);
        end
    end
    % Distance metric for calculating Wk subfunction
    distance=findDistance(algoargs);
    
    % Sort ks and verify that we have unique elements
    if ~isscalar(ks) && ~issorted(ks)
        ks=sort(ks);
    end
    ks=unique(ks);

    % Some pre-allocations
    wkd=zeros(1,length(ks));
    gapk=zeros(1,length(ks));
    sdk=zeros(1,length(ks));
    sk=zeros(1,length(ks));
    wkref=cell(1,length(ks));
    clusters=cell(1,length(ks));
    refclusters=cell(1,length(ks));
    
    % Handle the case of data to be clustered only in one cluster
    if min(ks)==1
        start=2;
        if verbose
            disp('Handling the case of 1 cluster...')
            disp(' ')
        end
        clusters{1}=ones(size(sdata,1),1);
        wkd(1)=calcWk(sdata,clusters{1},distance,usesquared);
        refclusters{1}=cell(1,refsize);
        wkref{1}=zeros(1,refsize);
        for i=1:refsize
            refclusters{1}{i}=ones(size(sdata,1),1);
            wkref{1}(i)=calcWk(refcell{i},refclusters{1}{i},distance,usesquared);
        end
        % Calculate Gap statistic for the case of 1 cluster
        gapk(1)=nanmean(log(wkref{1}))-log(wkd(1));
        % Calculate sk according to paper for the case of 1 cluster
        sdk(1)=nanstd(log(wkref{1}),1);
        sk(1)=sdk(1)*sqrt(1+1/refsize);
        if verbose
            disp('Done!')
            disp(' ')
        end
    else
        start=1;
    end
    for ind=start:length(ks)

        k=ks(ind);
        
        if usewait
            cwaitbar([2 ind/length(ks)])
        end

        if verbose
            outermsg=['Calculating Gap statistic for ',num2str(k),' clusters.'];
            disp(outermsg)
            disp(' ')
        end

        % Cluster the original and reference data
        switch algo

            case 'hierarchical'
                
                rightargs=findHier(algoargs);

                if verbose
                    disp('Hierarchical clustering.')
                    disp('Clustering given data...')
                    [ft,clusters{ind}]=ExpHClustering(DataCellStat,'MaxClust',k,algoargs{:});
                    disp('Done!')
                    disp(' ')
                    refclusters{ind}=cell(1,refsize);
                    for i=1:refsize
                        if usewait
                            cwaitbar([3 i/refsize])
                        end
                        msg=['Clustering reference data matrix ',num2str(i),' out of ',num2str(refsize)];
                        disp(msg)
                        refclusters{ind}{i}=clusterdata(refcell{i},'MaxClust',k,rightargs{:});
                    end
                    disp(' ')
                else
                    [ft,clusters{ind}]=ExpHClustering(DataCellStat,'MaxClust',k,algoargs{:});
                    refclusters{ind}=cell(1,refsize);
                    for i=1:refsize
                        if usewait
                            cwaitbar([3 i/refsize])
                        end
                        refclusters{ind}{i}=clusterdata(refcell{i},'MaxClust',k,rightargs{:});
                    end
                end

            case 'kmeans'
                
                rightargs=findkMeans(algoargs);

                if verbose
                    disp('k-means clustering.')
                    disp('Clustering given data...')
                    [ft,clusters{ind}]=kmeansClustering(DataCellStat,k,algoargs{:});
                    disp('Done!')
                    disp(' ')
                    refclusters{ind}=cell(1,refsize);
                    for i=1:refsize
                        if usewait
                            cwaitbar([3 i/refsize])
                        end
                        msg=['Clustering reference data matrix ',num2str(i),' out of ',num2str(refsize)];
                        disp(msg)
                        refclusters{ind}{i}=kmeans(refcell{i},k,rightargs{:});
                    end
                    disp(' ')
                else
                    [ft,clusters{ind}]=kmeansClustering(DataCellStat,k,algoargs{:});
                    refclusters{ind}=cell(1,refsize);
                    for i=1:refsize
                       if usewait
                           cwaitbar([3 i/refsize])
                       end
                       refclusters{ind}{i}=kmeans(refcell{i},k,rightargs{:});
                    end
                end

            case 'fcm'
                
                [m,tol,mit]=findFuzzy(algoargs);
               
                if verbose
                    disp('Fuzzy C-Means clustering.')
                    disp('Clustering given data...')
                    [ft,clusters{ind}]=FCMClustering(DataCellStat,k,algoargs{:});
                    disp('Done!')
                    disp(' ')
                    refclusters{ind}=cell(1,refsize);
                    for i=1:refsize
                        if usewait
                            cwaitbar([3 i/refsize])
                        end
                        msg=['Clustering reference data matrix ',num2str(i),' out of ',num2str(refsize)];
                        disp(msg)
                        u=dk_fcm(refcell{i}',k,m,tol,mit);
                        indices=cell(1,k);
                        refclusters{ind}{i}=zeros(size(sdata,1),1);
                        maxu=max(u);
                        for j=1:k
                            indices{j}=find(u(j,:)==maxu);
                            refclusters{ind}{i}(indices{j})=j;
                        end
                    end
                    disp(' ')
                else
                    [ft,clusters{ind}]=FCMClustering(DataCellStat,k,algoargs{:});
                    refclusters{ind}=cell(1,refsize);
                    for i=1:refsize
                        if usewait
                            cwaitbar([3 i/refsize])
                        end
                        u=dk_fcm(refcell{i}',k,m,tol,mit);
                        indices=cell(1,k);
                        refclusters{ind}{i}=zeros(size(sdata,1),1);
                        maxu=max(u);
                        for j=1:k
                            indices{j}=find(u(j,:)==maxu);
                            refclusters{ind}{i}(indices{j})=j;
                        end
                    end
                end

        end

        % Find Wk for original and reference data
        if verbose
            disp('Calculating within cluster sum of squares Wk for original data...')
            wkd(ind)=calcWk(sdata,clusters{ind},distance,usesquared);
            disp('Done!')
            disp(' ')
            wkref{ind}=zeros(1,refsize);
            disp('Calculating within cluster sum of squares Wk for reference data...')
            for i=1:refsize
                onemsg=['Calculating Wk for reference data matrix ',num2str(i),' out of ',num2str(refsize)];
                disp(onemsg)
                wkref{ind}(i)=calcWk(refcell{i},refclusters{ind}{i},distance,usesquared);
            end
            disp(' ')
        else
            wkd(ind)=calcWk(sdata,clusters{ind},distance,usesquared);
            wkref{ind}=zeros(1,refsize);
            for i=1:refsize
                wkref{ind}(i)=calcWk(refcell{i},refclusters{ind}{i},distance,usesquared);
            end
        end

        % Calculate Gap statistic
        gapk(ind)=nanmean(log(wkref{ind}))-log(wkd(ind));

        % Calculate sk according to paper
        sdk(ind)=nanstd(log(wkref{ind}),1);
        sk(ind)=sdk(ind)*sqrt(1+1/refsize);

    end


    % Find best number of clusters, if ks is a vector
    if length(ks)>1
        % Code for MATLAB versions <7.3
        %df=find(gapk(1:end-1)>=gapk(2:end)-sk(2:end));
        %bestk=ks(df(1));
        df=find(gapk(1:end-1)>=gapk(2:end)-sk(2:end),1,'first');
        if ~isempty(df)
            bestk(iter)=ks(df);
        else
            bestk(iter)=ks(1);
        end
    else
        bestk(iter)=ks;
    end

    if showplot
        figure;
        subplot(2,1,1)
        plot(ks,log(wkd),'.-r')
        set(gca,'FontSize',9,'FontWeight','bold')
        title('Within sum of squares W_k vs number of clusters','FontSize',11,'FontWeight','bold')
        xlabel('Number of clusters - k','FontSize',10,'FontWeight','bold')
        ylabel('Within clusters sum of squares W_k','FontSize',10,'FontWeight','bold')

        subplot(2,1,2)
        E=sk.*ones(size(gapk));
        errorbar(ks,gapk,E,'.-b')
        set(gca,'FontSize',9,'FontWeight','bold')
        title('Gap curve','FontSize',12,'FontWeight','bold')
        xlabel('Number of clusters - k','FontSize',10,'FontWeight','bold')
        ylabel('Gap statistic','FontSize',10,'FontWeight','bold')
        if ~isscalar(ks)
            xlim([ks(1) ks(end)])
        end
    end

end

if usewait
    close(h)
end

% If method is repeated more than once, return the k with the greatest frequence of
% appearance
if repeat>1
    [els,freq]=freqtable(bestk');
    [melem,idx]=max(freq);
    bestk=els(idx);
else
    bestk=bestk(repeat);
end
    
    
function wk = calcWk(x,c,dis,sq)

% Function to calculate the Wk argument of the gap statistic. Wk is defined as the sum
% from r=1:k of the quantity (1/2*nr)*Dr, where k is the number of clusters, nr is the
% length of the cluster r, and Dr is the within cluster sum of pairwise distances.
% Arguments: x   : data matrix, genes (variables) are rows, replicates (samples,
%                  dimensions) are columns.
%            c   : vector of cluster memberships, each element corresponds to a row of x
%                  (must be a numeric vector)
%            dis : the distance metric (see PDIST)

% To make kmeans and clusterdata compatible in the case of the squared euclidean, force
% the use of squared euclidean distance
if strcmpi(dis,'sqeuclidean')
    sq=true;
end

% Pre-allocate for speed
n=max(c); % To avoid the use of unique, for speed
dr=zeros(1,n);
nr=zeros(1,n);

% Do job
if ~sq
    for r=1:n
        dr(r)=nansum(pdist(x(c==r,:),dis));
        nr(r)=size(x(c==r,:),1);
    end
else
    for r=1:n
        dr(r)=nansum(pdist(x(c==r,:)).^2);
        nr(r)=size(x(c==r,:),1);
    end
end
temp=(1./(2*nr)).*dr;
wk=nansum(temp);


function Z = generateRefData(X,met)

% Function to calculate reference distribution for gap statistic

if strcmp(met,'uniform')
    % Pre-allocate reference matrix
    Z=zeros(size(X));
    % Each column sampled from uniform distribution with same range as the column from the
    % initial data matrix
    for j=1:size(X,2)
        low=min(X(:,j));
        high=max(X(:,j));
        Z(:,j)=low+(high-low)*rand(size(X,1),1);
    end
elseif strcmp(met,'pca')
    % Columns should have mean zero
    m=nanmean(X);
    for j=1:size(X,2)
        X(:,j)=X(:,j)-m(j);
    end
    % Perform SVD and transformations
    [U,D,V]=svd(X);
    Xt=X*V;
    % Draw uniform features from the column ranges of the transformed Xt
    Zt=zeros(size(Xt));
    for j=1:size(Xt,2)
        low=min(Xt(:,j));
        high=max(Xt(:,j));
        Zt(:,j)=low+(high-low)*rand(size(Xt,1),1);
    end
    % Backtransform to obtain final reference data
    Z=Zt*V';
elseif strcmp(met,'boot')
    % Bootstrap the original dataset to create the reference distribution
    Z=bootrsp(X);
elseif strcmp(met,'bootpca')
    % Bootstrap data based on PCA
    % Columns should have mean zero
    m=nanmean(X);
    for j=1:size(X,2)
        X(:,j)=X(:,j)-m(j);
    end
    % Perform SVD and transformations
    [U,D,V]=svd(X);
    Xt=X*V;
    % Bootstrap
    Zt=bootrsp(Xt);
    % Backtransform to obtain final reference data
    Z=Zt*V';
end


function newargs = checkEu(args)

% Rename euclidean to sqeuclidean for kmeans clustering

newargs=args;
for i=1:length(newargs)
    if ischar(newargs{i})
        z=strmatch('distance',lower(newargs{i}));
        if ~isempty(z)
            if strcmpi(newargs{i+1},'euclidean')
                newargs{i+1}='sqeuclidean';
            end
            break
        end
    end
end


function newargs = checkMaxClust(args)

% Remove maxclust property and value in case of hierachical clustering

newargs=args;
for i=1:length(newargs)
    if ischar(newargs{i})
        z=strmatch('maxclust',lower(newargs{i}));
        if ~isempty(z)
            warning('GapStat:IncorrectInputArgument',...
                    ['MaxClust property should not be given if you choose hierarchical clustering.',...
                     'It will be automaticaally removed.'])
            newargs(i)=[];
            newargs(i+1)=[];
            break
        end
    end
end


function dis = findDistance(args)

% Return the distance argument from clustering arguments. Returns euclidean if not found.

% Check only odd properties since they come in pairs and this has been checked by the
% clustering algorithms. If not in proper pairs, program should have already produced an
% error
dis='';
for i=1:length(args)/2
    z=strmatch('distance',lower(args{2*i-1}));
    if ~isempty(z)
        dis=args{2*i};
        break
    end
end
if isempty(dis) % Not found, assume default (euclidean for hierarchical and kmeans)
    dis='euclidean';
end


function hargs = findHier(args)

% Return some arguments for the hierarchical clustering in ARMADA in form of
% clusterdata. Returns defaults if not found.

% Defaults
dis='euclidean';
lin='average';
for i=1:length(args)/2
    x=strmatch('distance',lower(args{2*i-1}));
    if ~isempty(x)
        dis=args{2*i};
        break
    end
end
for i=1:length(args)/2
    y=strmatch('linkage',lower(args{2*i-1}));
    if ~isempty(y)
        lin=args{2*i};
        break
    end
end
hargs={'distance',dis,'linkage',lin};

function hargs = findkMeans(args)

% Return some arguments for the kmeans clustering in ARMADA in form of kmeans of MATLAB
% Returns defaults if not found.

% Defaults
dis='sqeuclidean';
strt='sample';
repli=1;
maxiter=100;
emptyact='drop';
displayopt='off';
for i=1:length(args)/2
    x=strmatch('distance',lower(args{2*i-1}));
    if ~isempty(x)
        dis=args{2*i};
        break
    end
end
for i=1:length(args)/2
    y=strmatch('start',lower(args{2*i-1}));
    if ~isempty(y)
        strt=args{2*i};
        break
    end
end
for i=1:length(args)/2
    z=strmatch('replicates',lower(args{2*i-1}));
    if ~isempty(z)
        repli=args{2*i};
        break
    end
end
for i=1:length(args)/2
    p=strmatch('maxiter',lower(args{2*i-1}));
    if ~isempty(p)
        maxiter=args{2*i};
        break
    end
end
for i=1:length(args)/2
    q=strmatch('emptyaction',lower(args{2*i-1}));
    if ~isempty(q)
        emptyact=args{2*i};
        break
    end
end
for i=1:length(args)/2
    r=strmatch('display',lower(args{2*i-1}));
    if ~isempty(r)
        displayopt=args{2*i};
        break
    end
end
hargs={'distance',dis,'start',strt,'replicates',repli,'maxiter',maxiter,...
       'emptyaction',emptyact,'display',displayopt};


function [m,tol,maxiter] = findFuzzy(args)

% Return some arguments for the FCM clustering in ARMADA. Returns defaults if not found.

% Defaults
m=2;
tol=1e-5;
maxiter=500;
for i=1:length(args)/2
    x=strmatch('fuzzyparam',lower(args{2*i-1}));
    if ~isempty(x)
        m=args{2*i};
        break
    end
end
for i=1:length(args)/2
    y=strmatch('tolerance',lower(args{2*i-1}));
    if ~isempty(y)
        tol=args{2*i};
        break
    end
end
for i=1:length(args)/2
    z=strmatch('maxiter',lower(args{2*i-1}));
    if ~isempty(z)
        maxiter=args{2*i};
        break
    end
end


function wh = findClusterWhat(args)

% Return the proper choice from algoargs to create proper size reference dataset.

wh='replicates';
for i=1:length(args)/2
    z=strmatch('clusterwhat',lower(args{2*i-1}));
    if ~isempty(z)
        wh=args{2*i};
        break
    end
end


function fout = cwaitbar(x,name,col)

% Very slight alterations of the function cwaitbar, writter from Rasmus Anthin and taken
% from MATLAB exchange

xline=[100 0 0 100 100];
yline=[0 0 1 1 0];

switch nargin
    
    case 1   % waitbar(x) update

        bar=x(1);
        x=max(0,min(100*x(2),100));
        f=findobj(allchild(0),'flat','Tag','CWaitbar');
        if ~isempty(f)
            f=f(1);
        end
        a=sort(get(f,'child')); % axes objects
        if isempty(f) || isempty(a),
            error('Couldn''t find waitbar handles.');
        end
        bar=length(a)+1-bar; % first bar is the topmost bar instead
        if length(a)<bar
            error('Bar number exceeds number of available bars.')
        end
        p=zeros(1,length(a));
        l=zeros(1,length(a));
        for i=1:length(a)
            p(i)=findobj(a(i),'type','patch');
            l(i)=findobj(a(i),'type','line');
        end

        p=p(bar);
        l=l(bar);
        xpatchold=get(p,'xdata');
        xold=xpatchold(2);
        if xold>x % erase old patches (if bar is shorter than before)
            set(p,'erase','normal')
        end
        xold=0;
        % previously: (continue on old patch)
        xpatch=[xold x x xold];
        set(p,'xdata',xpatch,'erase','none')
        set(l,'xdata',xline)
        
    case 2   % waitbar(x,name)  initialize
        
        x=fliplr(max(0,min(100*x,100)));

        oldRootUnits=get(0,'Units');
        set(0,'Units','points');
        pos=get(0,'ScreenSize');
        pointsPerPixel=72/get(0,'ScreenPixelsPerInch');

        L=length(x)*.6+.4;
        width =360*pointsPerPixel;
        height=75*pointsPerPixel*L;
        pos=[pos(3)/2-width/2 pos(4)/2-height/2 width height];

        f = figure('Units','points', ...
                   'Position', pos, ...
                   'Resize','off', ...
                   'CreateFcn','', ...
                   'NumberTitle','off', ...
                   'IntegerHandle','off', ...
                   'MenuBar', 'none', ...
                   'Tag','CWaitbar',...
                   'Name','Gap Statistic - Overall progress');
        colormap([]);

        for i=1:length(x)
            h=axes('XLim',[0 100],'YLim',[0 1]);
            if ~iscell(name)
                if i==length(x)
                    title(name,'FontSize',8);
                end
            else
                if length(name)~=length(x)
                    error('There must be equally many titles as waitbars, or only one title.')
                end
                title(name{end+1-i},'FontSize',8)
            end
            set(h,'Box','on', ...
                  'Position',[.05 .3/L*(2*i-1) .9 .2/L],...
                  'XTickMode','manual',...
                  'YTickMode','manual',...
                  'XTick',[],...
                  'YTick',[],...
                  'XTickLabelMode','manual',...
                  'XTickLabel',[],...
                  'YTickLabelMode','manual',...
                  'YTickLabel',[]);

            xpatch=[0 x(i) x(i) 0];
            ypatch=[0 0 1 1];

            patch(xpatch,ypatch,'r','edgec','r','erase','none')
            line(xline,yline,'color','k','erase','none');
        end
        
        set(f,'HandleVisibility','callback');
        set(0, 'Units', oldRootUnits);

    case 3
        
        if iscell(col) && length(col)~=length(x)
            error('There must be equally many colors as waitbars, or only one color.')
        end
        f=cwaitbar(x,name);
        a=get(f,'child');
        p=findobj(a,'type','patch');
        l=findobj(a,'type','line');
        if ~iscell(col)
            set(p,'facec',col,'edgec',col)
        else
            for i=1:length(col)
                set(p(i),'facec',col{i},'edgec',col{i})
            end
        end
        set(l,'xdata',xline')
end

drawnow
figure(f)

if nargout==1,
    fout=f;
end


function [B,N] = freqtable(A)

% [Y,N]=FREQTABLE(X) takes a vector X and returns the unique values of X in the output Y,
% and the number of instances of each value in the output N. X can be a charachter array
% or cell array of strings. 
% This function was written by Mukhtar Ullah and taken from MATLAB exchange.

if isnumeric(A) % use of built-in functions to avoid UNIQUE
    S=sort(A(~isnan(A)));
    B=S([find(diff(S));end]);
    N=histc(S,B);
else
    [B,m,n]=unique(A);
    N=histc(n,1:numel(B));
end


function[out]=bootrsp(in,B)
   
%   Bootstrap  resampling  procedure. 
%
%     Inputs:
%        in - input data 
%         B - number of bootstrap resamples (default B=1)        
%     Outputs:
%       out - B bootstrap resamples of the input data  
%
%   For a vector input data of size [N,1], the  resampling 
%   procedure produces a matrix of size [N,B] with columns 
%   being resamples of the input vector.
%
%   For a matrix input data of size  [N,M], the resampling
%   procedure produces a 3D matrix of  size  [N,M,B]  with 
%   out(:,:,i), i = 1,...,B, being a resample of the input 
%   matrix.
%
%  Created by A. M. Zoubir and D. R. Iskander

if nargin<2
    B=1;
end

s=size(in);     
if length(s)>2, 
  error('Input data can be a vector or a 2D matrix only'); 
end
if min(s)==1,  
  out=in(ceil(max(s)*rand(max(s),B)));    
else         
  out=in(ceil(s(1)*s(2)*rand(s(1),s(2),B))); 
end;
