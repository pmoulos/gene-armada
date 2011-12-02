function [exptab,DataCellNormLo] = IlluminaNorm(datstruct,method,opts,outscale,htext)

% Function to normalize Illumina data
% method : one of 'quantile', 'rankinvariant'
% opts   : options structure for each method
% htext  : for ARMADA use

if nargin<2
    method='quantile';
    opts.usemedian=false;
    opts.display=false;
    outscale='log2';
    htext=[];
end
if nargin<3
    opts.usemedian=false;
    opts.display=false;
    outscale='log2';
    htext=[];
end
if nargin<4
    outscale='log2';
    htext=[];
end
if nargin<5
    htext=[];
end

% Create exptab (probably useless...)
exptab=cell(1,length(datstruct));
for i=1:length(datstruct)
    exptab{i}=cell(1,length(datstruct{i}));
    for j=1:length(datstruct{i})
        exptab{i}{j}(:,1)=datstruct{i}{j}.Intensity;
    end
end     

% Flatten exptab as normalization requires a matrix of all arrays
mat=flatData(exptab,1);
% Normalize
message('Normalizing...',htext)
switch method
    case 'quantile'
        normat=quantilenorm(mat,'Median',opts.usemedian,...
                                'Display',opts.display);
    case 'rankinvariant'
        [m n]=size(mat);
        normat=zeros(m,n);
        % Put here option to calculate baseline if array not given
        if opts.baseline==-1
            baseid=findBaseline(mat);
            baseline=mat(:,baseid);
        else
            baseline=mat(:,opts.baseline);
        end
        for i=1:n
            normat(:,i)=mainvarsetnorm(baseline,mat(:,i),...
                                       'Thresholds',[opts.lowrank opts.uprank],...
                                       'Exclude',opts.exclude,...
                                       'Prctile',opts.percentage,...
                                       'Iterate',opts.iterate,...
                                       'Method',opts.method,...
                                       'Span',opts.span,...
                                       'Showplot',opts.showplot);
        end
    case 'none'
        normat=mat;
end

switch outscale
    case 'log'
        mat=log(mat);
        normat=log(normat);
    case 'log2'
        mat=log2(mat);
        normat=log2(normat);
    case 'log10'
        mat=log10(mat);
        normat=log10(normat);
end

% Create DataCellNormLo
DataCellNormLo=cell(1,6);
currcol=0;
for i=1:length(exptab)
    for j=1:length(exptab{i})
        currcol=currcol+1;
        % Background adjusted and normalized
        DataCellNormLo{2}{i}{j}=normat(:,currcol);
        % Background unadjusted and un-normalized... Empty but have to be there
        DataCellNormLo{1}{i}{j}=[];
        % Background adjusted and non-normalized
        DataCellNormLo{3}{i}{j}=mat(:,currcol);
    end
end

% DataCellNormLo{5} contains the normalization method... we can use it now as a triplet of
% names for the triplet adjustment, normalization, summarization
DataCellNormLo{5}={method,outscale};

% DataCellNormLo{6} will contain (probably) the absent calls


function baseid = findBaseline(values)

allmeds=nanmedian(values,1);
medrank=tiedrank(allmeds);
rankmed=fix(median(medrank));
baseid=find(fix(medrank)==rankmed,1);
