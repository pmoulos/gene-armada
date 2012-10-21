function [DataCellNormLo,probesetIDs] = AffySum(exptab,cdffile,method,opts,isdone,zerohandle,htext)

% Function to background adjustment Affymetrix data
% method : one of 'quantile', 'rankinvariant'
% opts   : options structure for each method

if nargin<3
    method='medianpolish';
    opts.output='log2';
    isdone={'none','none'};
    zerohandle.strategy='constant';
    zerohandle.offset=1;
    htext=[];
end
if nargin<4
    opts.output='log2';
    isdone={'none','none'};
    zerohandle.strategy='constant';
    zerohandle.offset=1;
    htext=[];
end
if nargin<5
    isdone={'none','none'};
    zerohandle.strategy='constant';
    zerohandle.offset=1;
    htext=[];
end
if nargin<6
    zerohandle.strategy='constant';
    zerohandle.offset=1;
    htext=[];
end
if nargin<7
    htext=[];
end

% If cdffile is structure use it, else read cdf library
if isstruct(cdffile)
    cdfstruct=cdffile;
else
    cdfstruct=affyread(cdffile);
end

% Initialize some variables
nProbeSets=cdfstruct.NumProbeSets;
nProbes=sum([cdfstruct.ProbeSets.NumPairs]);
probesetIDs={cdfstruct.ProbeSets.Name}';
probesetIDs(nProbeSets+1:end)=[]; % Remove QC probesets names

% Create probe indices vector
probeIndices=zeros(nProbes,1,'uint8');
probeCount=0;
for i=1:nProbeSets
    numPairs=cdfstruct.ProbeSets(i).NumPairs;
    probeIndices(probeCount+1:probeCount+numPairs)=(0:numPairs-1)';
    probeCount=probeCount+numPairs;
end

% The DataCellNormLo...
DataCellNormLo=cell(1,6);

% Fix the possible zero issue
if ~strcmp(zerohandle.strategy,'none')
    for i=1:length(exptab)
        for j=1:length(exptab{i})
            for k=1:4
                exptab{i}{j}(:,k)=removeZeros(exptab{i}{j}(:,k),zerohandle.strategy,zerohandle.offset);
            end
        end
    end
end

% Summarize and store values in DataCellNormLo (summarized raw, background adjusted,
% normalized)
back=isdone{1};
norm=isdone{2};
switch method
    case 'medianpolish'
        for i=1:length(exptab)
            for j=1:length(exptab{i})
                mymessage(['Summarizing for Condition ',num2str(i),' - Replicate ',num2str(j)],htext)
                % Background adjusted and normalized
                DataCellNormLo{2}{i}{j}=rmasummary(probeIndices,exptab{i}{j}(:,4),'Output',opts.output);
                % Background unadjusted and un-normalized
                if strcmpi(back,'none') && strcmpi(norm,'none')
                    DataCellNormLo{1}{i}{j}=DataCellNormLo{2}{i}{j};
                else
                    DataCellNormLo{1}{i}{j}=rmasummary(probeIndices,exptab{i}{j}(:,1),'Output',opts.output);
                end
                % Background adjusted and non-normalized
                if strcmpi(norm,'none')
                    DataCellNormLo{3}{i}{j}=DataCellNormLo{2}{i}{j};
                else
                    DataCellNormLo{3}{i}{j}=rmasummary(probeIndices,exptab{i}{j}(:,3),'Output',opts.output);
                end
            end
        end
    case 'mas5'
        % We have to implement it
end

% DataCellNormLo{5} contains the normalization method... we can use it now as a triplet of
% names for the triplet adjustment, normalization, summarization
DataCellNormLo{5}={back,norm,method,opts.output};

% DataCellNormLo{6} will contain (probably) the absent calls

function y = removeZeros(x,strategy,offset)

if nargin<2
    strategy='constant';
    offset=1;
elseif nargin<3
    offset=1;
end

switch strategy
    case 'constant'
        x(x<1)=1;
    case 'offset'
        x(x<1)=x(x<1)+offset;
    case 'minpos'
        x(x<1)=min(x(x>1));
    case 'rnoise'
        ind=find(x<1);
        m=min(x(x>1));
        for i=1:length(ind)
            x(ind(i))=m+1+3*rand(1);
        end
    case 'none'
        % Nothing
end
y=x;
