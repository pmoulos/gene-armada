function [DataCellNormLo,probesetIDs] = AffySum(exptab,cdffile,method,opts,isdone,htext)

% Function to background adjustment Affymetrix data
% method : one of 'quantile', 'rankinvariant'
% opts   : options structure for each method

if nargin<3
    method='medianpolish';
    opts.output='log2';
    isdone={'none','none'};
    htext=[];
end
if nargin<4
    opts.output='log2';
    isdone={'none','none'};
    htext=[];
end
if nargin<5
    isdone={'none','none'};
    htext=[];
end
if nargin<6
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
