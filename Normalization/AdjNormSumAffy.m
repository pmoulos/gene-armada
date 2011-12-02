% function [exptab,DataCellNormLo,probesetIDs] = AdjNormSumAffy(datstruct,cdffile,varargin)
function [DataCellNormLo,probesetIDs] = AdjNormSumAffy(datstruct,cdffile,varargin)

% Function to do everything for Affymetrix data

% Set defaults
back='rma';
backopts.method='RMA';
backopts.trunc=true;
backopts.showplot=[];
norm='quantile';
normopts.median=false;
normopts.display=false;
summ='rma';
summopts.output='log2';
seqfile='';
affinfile='';

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'adjust','adjopts','normalization','normopts','summary','sumopts','seqfile','affinfile'};
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
                case 1 % Background adjustment
                    okbacks={'rma','gcrma','plier','none'};
                    if ~ischar(parVal)
                        error('The %s parameter value must be a character',parName)
                    else
                        m=strmatch(lower(parVal),okbacks);
                        if isempty(m)
                            error('The %s parameter value must be a one of ''rma'', ''gcrma'', ''plier'', ''none''',parName)
                        end
                        back=parVal;
                    end
                case 2 % Background adjustment options
                    if ~isstruct(parVal) && ~isempty(parVal)
                        error('The %s parameter value must be an options structure or empty',parName)
                    else
                        switch back
                            case 'rma'
                                if ~isfield(parVal,'method') || ~isfield(parVal,'trunc') || ~isfield(parVal,'showplot')
                                    error('The %s parameter structure must contain the fields method, trunc and showplot',parName)
                                end
                            case 'gcrma'
                                if ~isfield(parVal,'optcorr') || ~isfield(parVal,'corrconst') || ~isfield(parVal,'method') ...
                                   || ~isfield(parVal,'addvar') || ~isfield(parVal,'tuningpar') || ~isfield(parVal,'gsbcorr') ...
                                   || ~isfield(parVal,'alpha') || ~isfield(parVal,'steps') || ~isfield(parVal,'showplot')
                                    errmsg=['The parameter structure for gcrma must contain the fields optcorr, corrconst, ',...
                                            'method, tuningpar, gsbcorr, alpha, steps and showplot'];
                                    error(errmsg)
                                end
                            case 'plier'
                                % When we implement plier we see...
                        end
                        backopts=parVal;
                    end
                case 3 % Normalization
                    oknorms={'quantile','rankinvariant','none'};
                    if ~ischar(parVal)
                        error('The %s parameter value must be a character',parName)
                    else
                        m=strmatch(lower(parVal),oknorms);
                        if isempty(m)
                            error('The %s parameter value must be a one of ''quantile'', ''rankinvariant'', ''none''',parName)
                        end
                        norm=parVal;
                    end
                case 4 % Normalization options
                    if ~isstruct(parVal) && ~isempty(parVal)
                        error('The %s parameter value must be an options structure or empty',parName)
                    else
                        switch norm
                            case 'quantile'
                                if ~isfield(parVal,'median') || ~isfield(parVal,'display')
                                    error('The %s parameter structure must contain the fields median, display',parName)
                                end
                            case 'rankinvariant'
                                if ~isfield(parVal,'base') || ~isfield(parVal,'thresh') || ~isfield(parVal,'stoppct')...
                                   || ~isfield(parVal,'raypct') || ~isfield(parVal,'method') || ~isfield(parVal,'showplot')
                                    errmsg=['The parameter structure for rankinavariant must contain the fields base, thresh, ',...
                                            'stoppct, raypct, method and showplot'];
                                    error(errmsg)
                                end
                        end
                        normopts=parVal;
                    end
                case 5 % Summarization
                    oksums={'medianpolish','mas5'};
                    if ~ischar(parVal)
                        error('The %s parameter value must be a character',parName)
                    else
                        m=strmatch(lower(parVal),oksums);
                        if isempty(m)
                            error('The %s parameter value must be a one of ''rma''',parName)
                        end
                        summ=parVal;
                    end
                case 6 % Summarization options
                    if ~isstruct(parVal)
                        error('The %s parameter value must be an options structure',parName)
                    else
                        switch summ
                            case 'rma'
                                if ~isfield(parVal,'output')
                                    error('The %s parameter structure must contain the fields median, display',parName)
                                end
                        end
                        summopts=parVal;
                    end
                case 7 % Sequence data
                    if ~ischar(parVal)
                        error('The %s parameter value must be a string containing a proper path',parName)
                    end
                    seqfile=parVal;
                case 8 % Affinities
                    if ~ischar(parVal)
                        error('The %s parameter value must be a string containing a proper path',parName)
                    end
                    affinfile=parVal;
            end
        end
    end
end

if strcmpi(back,'gcrma') && isempty(seqfile) && isempty(affinfile)
    warning('AdjNormSumAffy:NoSeqProv','Sequence or affinities file not provided. Continuing with GCRMA without sequence info...')
end

% If cdffile is structure use it, else read cdf library
if isstruct(cdffile)
    cdfstruct=cdffile;
else
    cdfstruct=affyread(cdffile);
end

% Start job

% Initialize some variables
nProbeSets=cdfstruct.NumProbeSets;
nProbes=sum([cdfstruct.ProbeSets.NumPairs]);
probesetIDs={cdfstruct.ProbeSets.Name}';
probesetIDs(nProbeSets+1:end)=[]; % Remove QC probesets names

% Create probesetindexes vector and probe indexes vector
probeIndices=zeros(nProbes,1, 'uint8');
probeCount=0;
for i=1:nProbeSets
    numPairs=cdfstruct.ProbeSets(i).NumPairs;
    probeIndices(probeCount+1:probeCount+numPairs)=(0:numPairs-1)';
    probeCount=probeCount+numPairs;
end

% Get dataset size
n=0;
for i=1:length(datstruct)
    for j=1:length(datstruct{i})
        n=n+1;
    end
end

% % Get PM and MM intensities in exptab
% exptab=cell(1,length(datstruct));
% for i=1:length(datstruct)
%     exptab{i}=cell(1,length(datstruct{i}));
%     for j=1:length(datstruct{i})
%         exptab{i}{j}=zeros(nProbes,2);
%         exptab{i}{j}(:,1)=getProbeIntensity(datstruct{i}{j},cdfstruct,nProbes,1); % PM
%         exptab{i}{j}(:,2)=getProbeIntensity(datstruct{i}{j},cdfstruct,nProbes,1); % MM
%     end
% end

% Get PM and MM intensities by flattening datstruct
currcol=0;
pmdata=zeros(nProbes,n);
mmdata=zeros(nProbes,n);
for i=1:length(datstruct)
    for j=1:length(datstruct{i})
        currcol=currcol+1;
        pmdata(:,currcol)=getProbeIntensity(datstruct{i}{j},cdfstruct,nProbes,1); % PM
        if strcmpi(back,'gcrma') % We need MMs
            mmdata(:,currcol)=getProbeIntensity(datstruct{i}{j},cdfstruct,nProbes,2); % MM
        end
    end
end

% Background adjustment
back=lower(back);
switch back    
    case 'rma'
        backadjusted=rmabackadj(pmdata,'Method',backopts.method,...
                                       'Truncate',backopts.trunc,...
                                       'Showplot',backopts.showplot);
    case 'gcrma'
        if isempty(seqfile) && isempty(affinfile)
            affinpm=[];
            affinmm=[];
        elseif ~isempty(seqfile) && isempty(affinfile)
            [pathstr,name,ext]=fileparts(seqfile);
            seqstru=affyprobeseqread([name,ext],cdfstruct,'SeqPath',pathstr);
            seqmatrix=seqstru.SequenceMatrix;
            [affinpm,affinmm]=affyprobeaffinities(seqmatrix,mean(mmdata,2));
        else % In any other case read affinities file, definitely quicker
            fid=fopen(affinfile,'r');
            affs=cell2mat(textscan(fid,'%f%f','Delimiter','\t','CollectOutput',true));
            affinpm=affs(:,1);
            affinmm=affs(:,2);
        end
        backadjusted=gcrmabackadj(pmdata,mmdata,affinpm,affinmm,'OpticalCorr',backopts.optcorr,...
                                                                'CorrConst',backopts.corrconst,...
                                                                'Method',backopts.method,...
                                                                'TuningParam',backopts.tuningpar,...
                                                                'AddVariance',backopts.addvar,...
                                                                'GSBCorr',backopts.gsbcorr,...
                                                                'Alpha',backopts.alpha,...
                                                                'Steps',backopts.steps,...
                                                                'ShowPlot',backopts.showplot,...
                                                                'Verbose',false);
    case 'plier'
        % We have to implement it
    case 'mas5'
        % We have to implement it
    case 'none'
        backadjusted=pmdata;
end

% Normalization
norm=lower(norm);
switch norm
    case 'quantile'
        normdata=quantilenorm(backadjusted,'Median',normopts.median,...
                                           'Display',normopts.display);
    case 'rankinvariant'
        normdata=affyinvarsetnorm(backadjusted,'Baseline',normopts.base,...
                                               'Thresholds',normopts.thresh,...
                                               'StopPrctile',normopts.stoppct,...
                                               'RayPrctile',normopts.raypct,...
                                               'Method',normopts.method,...
                                               'Showplot',normopts.showplot);
    case 'none'
        normdata=backadjusted;
end
                                 
% Summarization
summ=lower(summ);
switch summ
    case 'medianpolish'
        exprmat=rmasummary(probeIndices,normdata,'Output',summopts.output);
    case 'mas5'
        % We have to implement it
end

% The construction of DataCellNormLo...
DataCellNormLo=cell(1,6);

% DataCellNormLo{1} contains unadjusted and unnormalized values (just summarized), so we 
% resummarize only if any adjustment or normalization has been performed
if strcmpi(back,'none') && strcmpi(norm,'none')
    rawdata=exprmat;
else
    rawdata=rmasummary(probeIndices,pmdata,'Output',summopts.output);
end
currcol=0;
DataCellNormLo{1}=cell(1,length(datstruct));
for i=1:length(datstruct)
    DataCellNormLo{1}{i}=cell(1,length(datstruct{i}));
    for j=1:length(datstruct{i})
        currcol=currcol+1;
        DataCellNormLo{1}{i}{j}=rawdata(:,currcol);
    end
end

% DataCellNormLo{2} contains normalized and summarized data
currcol=0;
DataCellNormLo{2}=cell(1,length(datstruct));
for i=1:length(datstruct)
    DataCellNormLo{2}{i}=cell(1,length(datstruct{i}));
    for j=1:length(datstruct{i})
        currcol=currcol+1;
        DataCellNormLo{2}{i}{j}=exprmat(:,currcol);
    end
end

% DataCellNormLo{3} contains adjusted, not normalized but summarized data
if ~strcmpi(norm,'none')
    fdata=backadjusted;
else
    fdata=rmasummary(probeIndices,backadjusted,'Output',summopts.output);
end
currcol=0;
DataCellNormLo{2}=cell(1,length(datstruct));
for i=1:length(datstruct)
    DataCellNormLo{2}{i}=cell(1,length(datstruct{i}));
    for j=1:length(datstruct{i})
        currcol=currcol+1;
        DataCellNormLo{2}{i}{j}=fdata(:,currcol);
    end
end

% DataCellNormLo{4} contains the span value for LOESS... useless but we could put
% something else there, empty for the moment

% DataCellNormLo{5} contains the normalization method... we can use it now as a triplet of
% names for the triplet adjustment, normalization, summarization
DataCellNormLo{5}={back,norm,summ};

% DataCellNormLo{6} contains the smoothing factor... no such thing here... empty again


function intensity = getProbeIntensity(celstru,cdfstru,numprobes,type)

% Help function to read out the probe intensity from a Affymetrix ARMADA structure.

intensity=zeros(numprobes,1);
numcols=cdfstru.Cols;
paircount=0;

colid=0;
if type==1 % For PM probe intensity 
    colid=3;
elseif type==2
    colid=5; % for MM probe intensity
end
    
for i=1:cdfstru.NumProbeSets
    numpairs=cdfstru.ProbeSets(i).NumPairs;
    thepairs=cdfstru.ProbeSets(i).ProbePairs;
    PX=thepairs(:,colid);
    PY=thepairs(:,colid+1);
    intensity(paircount+1:paircount+numpairs,1)=celstru.Intensity(PY*numcols+PX+1);
    paircount=paircount+numpairs;
end


% backopts.optcorr=true
% backopts.corrconst=0.7
% backopts.method='MLE'
% backopts.addvar=true;
% backopts.tuningpar=5;
% backopts.showplot=false;
% normopts.median=false;
% normopts.display=false;
% summopts.output='log2';

% [DataCellNormLo, probesetIDs] = AdjNormSumAffy(datstruct,fullfile(cdfpath,cdfname),'Adjust','gcrma',...
%                                                                                    'AdjOpts',backopts,...
%                                                                                    'Normalization','quantile',...
%                                                                                    'NormOpts',normopts,...
%                                                                                    'Summary','RMA',...
%                                                                                    'SumOpts',summopts,...
%                                                                                    'SeqFile','I:\Datasets\Affy Sweden\GSE2372_RAW\Mouse430_2.probe_fasta')

% backopts.optcorr=true;
% backopts.corrconst=0.7;
% backopts.method='MLE';
% backopts.addvar=true;
% backopts.tuningpar=5;
% backopts.gsbcorr=true;
% backopts.alpha=0.5;
% backopts.steps=128;
% backopts.showplot=false;
% normopts.median=false;
% normopts.display=false;
% summopts.output='log2';
% 
% [DataCellNormLo, probesetIDs] = AdjNormSumAffy(datstruct,fullfile(cdfpath,cdfname),'Adjust','gcrma',...
%                                                                                    'AdjOpts',backopts,...
%                                                                                    'Normalization','quantile',...
%                                                                                    'NormOpts',normopts,...
%                                                                                    'Summary','RMA',...
%                                                                                    'SumOpts',summopts,...
%                                                                                    'SeqFile','I:\Datasets\Affy Sweden\GSE2372_RAW\Mouse430_2.probe_fasta');
% 
% tic
% [DataCellNormLo, probesetIDs] = AdjNormSumAffy(datstruct,cdfstruct,'Adjust','gcrma',...
%                                                                    'AdjOpts',backopts,...
%                                                                    'Normalization','quantile',...
%                                                                    'NormOpts',normopts,...
%                                                                    'Summary','RMA',...
%                                                                    'SumOpts',summopts,...
%                                                                    'AffinFile','I:\Datasets\Affy Sweden\GSE2372_RAW\Data\test.affin');
% toc

