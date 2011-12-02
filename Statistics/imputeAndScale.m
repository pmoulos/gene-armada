function [outdata,aftermeans] = imputeAndScale(indata,when,scale,scaleopts,impt,imptopts)

% indata are in the main format of ARMADA. A cell with as many subcells as the number
% of conditions. The subcells are one matrix with number of columns equal to the number of
% replicates for one condition

if nargin<2
    when=2;
    scale='mad';
    scaleopts=[];
    impt='conditionmean';
    impt.opts=[];
elseif nargin<3
    scale='mad';
    scaleopts=[];
    impt='conditionmean';
    impt.opts=[];
elseif nargin<4
    if strcmpi(scale,'mad')
        scaleopts=[];
    elseif strcmpi(scale,'quantile')
        scaleopts.usemedian=false;
        scaleopts.display=false;
    end
    impt='conditionmean';
    impt.opts=[];
elseif nargin<5
    impt='conditionmean';
    impt.opts=[];
elseif nargin<6
    if strcmpi(impt,'conditionmean')
        imptopts=[];
    elseif strcmpi(impt,'knn')
        imptopts.distance='euclidean';
        imptopts.k=1;
        imptopts.usemedian=false;
    end
end

% Calculate number of replicates for each condition so as to break again to a cell after
% the imputation
cellSize=size(indata);
breakvec=zeros(1,cellSize(2));
for index=1:cellSize(2)
    breakvec(index)=size(indata{index},2);
end

% If we choose to impute BEFORE centering (or not scaling at all, as if we do not scale it
% does not matter whether we impute before or after)
if when==1  
    if strcmpi(impt,'conditionmean')
        indataImp=cell(1,length(indata));
        for i=1:length(indata)
            meanCol=nanmean(indata{i},2);
            indataImp{i}=mknanavg(indata{i},meanCol');
        end
    elseif strcmpi(impt,'knn')
        % Silence warnings because we definitely have whole rows of NaNs
        warning('off','Bioinfo:KNNIMPUTE:RowAllNans')
        c2mindataImp=knnimpute(cell2mat(indata),imptopts.k,...
                               'Distance',imptopts.distance,...
                               'Median',imptopts.usemedian);
        % Break again whole data matrix to a cell
        indataImp=mat2cell(c2mindataImp,size(c2mindataImp,1),breakvec);
    end
else
    indataImp=indata;
end


if strcmpi(scale,'mad')
    
    % Preallocate
    cntrdata=cell(1,length(indataImp));
    aftermeans=cell(1,length(indataImp));

    for i=1:length(indataImp)

        medianvalue=nanmedian(indataImp{i});
        madvalue=mad(indataImp{i});

        scldmeddata=zeros(size(indataImp{i}));
        cntrdata{i}=zeros(size(indataImp{i}));

        %Normalize by centering filtered replicates
        for j=1:size(indataImp{i},2)
            scldmeddata(:,j)=indataImp{i}(:,j)-medianvalue(1,j);
            cntrdata{i}(:,j)=scldmeddata(:,j)/madvalue(1,j);
        end

    end
    
elseif strcmpi(scale,'quantile')
    
    % Protect against the case of plotting over ARMADA window figures
    if scaleopts.display
        figure
    end
    
    c2mcntrdata=quantilenorm(cell2mat(indataImp),'Median',scaleopts.usemedian,...
                                                 'Display',scaleopts.display);
    % Break again whole data matrix to a cell
    cntrdata=mat2cell(c2mcntrdata,size(c2mcntrdata,1),breakvec);
    
elseif strcmpi(scale,'none')
    
    %outdata=indataImp;
    cntrdata=indataImp;
    aftermeans=calcAM(indataImp);
    %% No point of going further, imputation has been performed
    %return
    
end

% If we choose to average AFTER centering
if when==2
    if strcmpi(impt,'conditionmean')
        cntrdataImp=cell(1,length(cntrdata));
        aftermeans=calcAM(cntrdata);
        for i=1:length(cntrdata)
            cntrdataImp{i}=mknanavg(cntrdata{i},aftermeans{i}');
        end
    elseif strcmpi(impt,'knn')
        % Silence warnings because we definitely have whole rows of NaNs
        warning('off','Bioinfo:KNNIMPUTE:RowAllNans')
        c2mcntrdataImp=knnimpute(cell2mat(cntrdata),imptopts.k,...
                                 'Distance',imptopts.distance,...
                                 'Median',imptopts.usemedian);
        % Break again whole data matrix to a cell
        cntrdataImp=mat2cell(c2mcntrdataImp,size(c2mcntrdataImp,1),breakvec);
        % Calculate aftermeans
        aftermeans=calcAM(cntrdataImp);
    end
else
    cntrdataImp=cntrdata;
    aftermeans=calcAM(cntrdata);
end

outdata=cntrdataImp;


function am = calcAM(dat)

% Correct for the case of only one replicate
am=cell(1,length(dat));
for i=1:length(dat)
    if ~isvector(dat{i})
        am{i}=nanmean(dat{i},2);
    else
        am{i}=dat{i};
    end
end
