function exptab = AffyBackAdjust(datstruct,cdffile,method,opts,htext)

% Function to background adjustment Affymetrix data
% method : one of 'rma', 'gcrma', 'plier', 'none'
% opts   : options structure for each method
% htext  : for ARMADA use

% Check inputs
if nargin<3
    method='gcrma';
    opts.optcorr=true;
    opts.corrconst=0.7;
    opts.method='MLE';
    opts.addvar=true;
    opts.tuningpar=5;
    opts.gsbcorr=true;
    opts.alpha=0.5;
    opts.steps=128;
    opts.showplot=false;
    opts.eachaffin=false;
    opts.seqfile='';
    opts.affinfile='';
    htext=[];
end
if nargin<4
    opts.optcorr=true;
    opts.corrconst=0.7;
    opts.method='MLE';
    opts.addvar=true;
    opts.tuningpar=5;
    opts.gsbcorr=true;
    opts.alpha=0.5;
    opts.steps=128;
    opts.showplot=false;
    opts.eachaffin=false;
    opts.seqfile='';
    opts.affinfile='';
    htext=[];
end
if nargin<5
    htext=[];
end


% Further error checking
okbacks={'rma','gcrma','plier','none'};
if ~ischar(method)
    error('The method argument value must be a character')
else
    m=strmatch(lower(method),okbacks);
    if isempty(m)
        error('Method must be a one of ''rma'', ''gcrma'', ''plier'', ''none''')
    end
end

if ~isstruct(opts) && ~isempty(opts)
    error('The method options must be a structure or empty')
else
    switch method
        case 'rma'
            if ~isfield(opts,'method') || ~isfield(opts,'trunc') || ~isfield(opts,'showplot')
                error('The options structure for rma must contain the fields method, trunc and showplot')
            end
        case 'gcrma'
            if ~isfield(opts,'optcorr') || ~isfield(opts,'corrconst') || ~isfield(opts,'method') ...
                    || ~isfield(opts,'addvar') || ~isfield(opts,'tuningpar') || ~isfield(opts,'gsbcorr') ...
                    || ~isfield(opts,'alpha') || ~isfield(opts,'steps') || ~isfield(opts,'showplot') ...
                    || ~isfield(opts,'seqfile') || ~isfield(opts,'affinfile') || ~isfield(opts,'eachaffin')
                errmsg=['The options structure for gcrma must contain the fields optcorr, corrconst, ',...
                        'method, tuningpar, gsbcorr, alpha, steps, showplot, seqfile, affinfile and eachaffin'];
                error(errmsg)
            end
        case 'plier'
            % When we implement plier we see...
    end
end

if strcmpi(method,'gcrma') && ~isempty(opts)
    seqfile=opts.seqfile;
    affinfile=opts.affinfile;
end

% If cdffile is structure use it, else read cdf library
if isstruct(cdffile)
    cdfstruct=cdffile;
else
    cdfstruct=affyread(cdffile);
end

% Start job
nProbes=sum([cdfstruct.ProbeSets.NumPairs]);

% Get PM and MM intensities in exptab
exptab=cell(1,length(datstruct));
for i=1:length(datstruct)
    exptab{i}=cell(1,length(datstruct{i}));
    for j=1:length(datstruct{i})
        mymessage(['Retrieving PMs and MMs for Condition ',num2str(i),' - Replicate ',num2str(j)],htext)
        exptab{i}{j}=zeros(nProbes,4);
        exptab{i}{j}(:,1)=getProbeIntensity(datstruct{i}{j},cdfstruct,nProbes,1); % PM
        exptab{i}{j}(:,2)=getProbeIntensity(datstruct{i}{j},cdfstruct,nProbes,2); % MM
    end
end

% Background adjustment
method=lower(method);
switch method    
    case 'rma'
        for i=1:length(datstruct)
            for j=1:length(datstruct{i})
                mymessage(['Background adjusting for Condition ',num2str(i),' - Replicate ',num2str(j)],htext)
                exptab{i}{j}(:,3)=rmabackadj(exptab{i}{j}(:,1),'Method',opts.method,...
                                                               'Truncate',opts.trunc,...
                                                               'Showplot',opts.showplot);
            end
        end
    case 'gcrma'
        if isempty(seqfile) && isempty(affinfile)
            warning('AffyBackAdjust:NoSeqAffinProv',['Sequence or affinities file not provided.',...
                                                     ' Continuing with GCRMA without sequence info...'])
            opts.eachaffin=false; % Turn off affinities for each array
            nogiven=true;
            affgiven=false;
        elseif ~isempty(seqfile) && isempty(affinfile)
            seqmatrix=readSeqFile(seqfile,cdfstruct);
            nogiven=false;
            affgiven=false;
        elseif isempty(seqfile) && ~isempty(affinfile)
            if opts.eachaffin
                warning('AffyBackAdjust:NoSeqProv',['Sequence file not provided. Calculation of',...
                                                    ' affinities for each array will be ignored...'])
                opts.eachaffin=false; % Turn off affinities for each array
            end
            [affinpm,affinmm] = readAffinFile(affinfile); % Read affinities
            nogiven=false;
            affgiven=true;
        elseif ~isempty(seqfile) && ~isempty(affinfile)
            if opts.eachaffin % Read sequence matrix
                seqmatrix=readSeqFile(seqfile,cdfstruct);
            else % Read affinities, easier and quicker
                [affinpm,affinmm]=readAffinFile(affinfile);
                nogiven=false;
                affgiven=true;
            end
        end
        if opts.eachaffin
            for i=1:length(datstruct)
                for j=1:length(datstruct{i})
                    mymessage(['Calculating probe affinities and background adjusting for Condition ',...
                               num2str(i),' - Replicate ',num2str(j)],htext)
                    [affinpm,affinmm]=affyprobeaffinities(seqmatrix,exptab{i}{j}(:,2));
                    exptab{i}{j}(:,3)=gcrmabackadj(exptab{i}{j}(:,1),exptab{i}{j}(:,2),...
                                                   affinpm,affinmm,'OpticalCorr',opts.optcorr,...
                                                                   'CorrConst',opts.corrconst,...
                                                                   'Method',opts.method,...
                                                                   'TuningParam',opts.tuningpar,...
                                                                   'AddVariance',opts.addvar,...
                                                                   'GSBCorr',opts.gsbcorr,...
                                                                   'Alpha',opts.alpha,...
                                                                   'Steps',opts.steps,...
                                                                   'ShowPlot',opts.showplot,...
                                                                   'Verbose',false);
                end
            end
        else
            mmdata=flatData(exptab,2);
            if ~affgiven && ~nogiven
                [affinpm,affinmm]=affyprobeaffinities(seqmatrix,mean(mmdata,2));
            elseif ~affgiven && nogiven
                affinpm=[]; affinmm=[];
            end
            for i=1:length(datstruct)
                for j=1:length(datstruct{i})
                    mymessage(['Background adjusting for Condition ',num2str(i),' - Replicate ',num2str(j)],htext)
                    exptab{i}{j}(:,3)=gcrmabackadj(exptab{i}{j}(:,1),exptab{i}{j}(:,2),...
                                                   affinpm,affinmm,'OpticalCorr',opts.optcorr,...
                                                                   'CorrConst',opts.corrconst,...
                                                                   'Method',opts.method,...
                                                                   'TuningParam',opts.tuningpar,...
                                                                   'AddVariance',opts.addvar,...
                                                                   'GSBCorr',opts.gsbcorr,...
                                                                   'Alpha',opts.alpha,...
                                                                   'Steps',opts.steps,...
                                                                   'ShowPlot',opts.showplot,...
                                                                   'Verbose',false);
                end
            end
        end
    case 'plier'
        % We have to implement it
    case 'mas5'
        % We have to implement it
    case 'none'
        for i=1:length(datstruct)
            for j=1:length(datstruct{i})
                exptab{i}{j}(:,3)=exptab{i}{j}(:,1);
            end
        end
end


function seqmat = readSeqFile(file,cstru)

[pathstr,name,ext]=fileparts(file);
seqstru=affyprobeseqread([name,ext],cstru,'SeqPath',pathstr);
seqmat=seqstru.SequenceMatrix;

function [affpm,affmm] = readAffinFile(file)

fid=fopen(file,'r');
affs=cell2mat(textscan(fid,'%f%f','Delimiter','\t','CollectOutput',true));
affpm=affs(:,1);
affmm=affs(:,2);
