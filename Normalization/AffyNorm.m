function exptab = AffyNorm(exptab,method,opts,htext)

% Function to background adjustment Affymetrix data
% method : one of 'quantile', 'rankinvariant'
% opts   : options structure for each method
% htext  : for ARMADA use

if nargin<2
    method='quantile';
    opts.usemedian=false;
    opts.display=false;
    htext=[];
end
if nargin<3
    opts.usemedian=false;
    opts.display=false;
    htext=[];
end
if nargin<4
    htext=[];
end

% Flatten exptab as normalization requires a matrix of all arrays
mat=flatData(exptab,3);
% Normalize
mymessage('Normalizing...',htext)
switch method
    case 'quantile'
        normat=quantilenorm(mat,'Median',opts.usemedian,...
                                'Display',opts.display);
    case 'rankinvariant'
        normat=affyinvarsetnorm(mat,'Baseline',opts.baseline,...
                                    'Thresholds',[opts.lowrank opts.uprank],...
                                    'StopPrctile',opts.maxdata,...
                                    'RayPrctile',opts.maxinvar,...
                                    'Method',opts.method,...
                                    'Span',opts.span,...
                                    'Showplot',opts.showplot);
    case 'none'
        normat=mat;
end

% Put values to exptab
currcol=0;
for i=1:length(exptab)
    for j=1:length(exptab{i})
        currcol=currcol+1;
        exptab{i}{j}(:,4)=normat(:,currcol);
    end
end
