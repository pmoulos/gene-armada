function iset = invariantrankselect(baseline, data, tdLIM, stopPCN, L, iterate, adjustTD)
% INVARIANTRANKSELECT  Helper function for INVARAINTSETNORM AND MAIRANKNORM Rank
% invariant selection chooses a group of points with a difference in rank below
% a given threshold.
%
% Usage: Z = invariantrankselect(X,Y,prdTD,stopPCN)
%        Z = invariantrankselect(X,Y,prdTD,stopPCN,false,25)
%
% X,Y          input data
% tdLIM        sets a 1-by-2 vector for the low and the high threshold limits,
%              default is [0.003, 0.007] 
% stopCN       stops iteration if the points of invariant set is STOP percent of
%              total points 
% L            Returns invariant set that is not among the highest L ranks and
%              lowest L ranks, default is 0.  %                
% iterate      Iterates until the number of invariant set does not decrease or
%              reach the stop limit, default is true. Set this option to false
%              if to get invariant set without iteration.
% adjustTD     Adjust each threshold by factor of 0.1 at each iteration.
%              Default is false
%
% Note: 
% 
% References:
% [1] George C. Tseng, Min-Kyu Oh, Lars Rohlin, James C. Liao, and Wing Hung
% Wong. (2001) Issues in cDNA microarray analysis: quality filtering, channel
% normalization, models of variations and assessment of gene effects. Nucleic
% Acids Research. 29: 2549-2557.
% [2] Eric E. Schadt 1 4 *, Cheng Li 3, Byron Ellis 2, Wing H. Wong Feature
% extraction and normalization algorithms for high-density oligonucleotide gene
% expression array data. Journal of Cellular Biochemistry Supplement. 2001;Suppl
% 37:120-5.   
% [3] Hoffmann,R., Seidl,T., and Dugas,M. (2002) Profound effect of
% normalization on detection of differentially expressed genes in
% oligonucleotide microarray data analysis. Genome Biology
% 3(7):research0033.1-0033.11  

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.10.2 $  $Date: 2006/09/27 00:19:45 $

% Initialize
% Set x, y, and np
baseline = baseline(:);
data = data(:);
np = numel(data);  % Number of points

if numel(baseline) ~= np
    error('Bioinfo:InvariantRankSelectXYmustBeSameLength',...
          'X and Y must be the same length.');
end

% Set low and high threshold limit
if nargin<3 || isempty(tdLIM)
    tdLIM = [0.003, 0.007];     % default low threshold 0.003, and high threshold 0.007
elseif tdLIM(1) < 0 || tdLIM(1) > 1  % threld must be between 0 and 1
    error('Bioinfo:InvariantRankSelectInvalidLowLimits', ...
          'Low threshould limit is invalid. It must be between 0 and 1.');
elseif tdLIM(2) < 0 || tdLIM(2) > 1  % threld must be between 0 and 1
    error('Bioinfo:InvariantRankSelectInvalidLowLimits', ...
          'High threshould limit is invalid. It must be between 0 and 1.');
end 

% Set stop
if nargin<4 || isempty(stopPCN)
    stopPCN = 1;
elseif stopPCN < 0 || stopPCN > 100  % stop percent must be between 0 and 100
    error('Bioinfo:InvariantRankSelectInvalidStopPercent', ...
          'Invariant set stop percentage is invalid. It must be between 0 and 100.');
end
stop = floor(np*stopPCN*0.01);

ord = floor(log10(stop)); % order of the number
stop = ceil(stop/10^ord)*10^ord; 

% Set L
if nargin<5 || isempty(L)
    L = 0;
elseif ~isnumeric(L) || L < 0 || L > np  
    error('Bioinfo:InvariantRankSelectInvalidRank', ...
          'The rank input must be positive number and less than total number of points.');
end

% Set interate
if nargin<6 || isempty(iterate)
    iterate = true;
end

% Set adjust threshold
if nargin<7 || isempty(adjustTD)
    adjustTD = false;
end

adj_prdTD = tdLIM;       % Adjusted threshold
iset = true(np, 1);        % Set all the points in the invariant set 
ns = sum(iset);            % number of points in the invariant set

% rank the baseline and data
rbaseline = marank(baseline);
rdata = marank(data);

% If L > 0, exclude the highest L ranks and lowest L ranks
if L > 0
    air = (rbaseline(iset) + rdata(iset))/2;
    iset(iset) = (air > L & air < ns - L);
end


% Iterates until the number of the points in the invariant set does not decrease
% anymore
ns_old = ns + 1; 

while ( ns_old - ns > 0 )
    % % average intensity rank for the ppoints
    % air = (rbaseline(iset) + rdata(iset))/ ( 2*ns);

    % Compute the average rank distance for the points
    air = avgrankdist(rbaseline(iset), rdata(iset));

    % The threshold for a particular point depends on the its intensities, the
    % minimum and the maximum intensities in the of any remaining points in the
    % two experiments, its rank among the remaining points in the two
    % experiments and the number of points remaining.

    % Threshold
    threshold = ns*(adj_prdTD(2) * air + (1-air)*adj_prdTD(1));

    % proportional rank difference
    prd = abs(rbaseline(iset) - rdata(iset)); 
   
    iset_old = iset;
    iset(iset_old) = prd < threshold;

    ns_old = ns;
    ns = sum(iset);

    if( ns_old ~= ns && ns < stop )
       iset= iset_old;
%        ns = ns_old;
       break;
    end

    if adjustTD && adj_prdTD(1) > tdLIM(1)
        adj_prdTD(1) = adj_prdTD(1)*0.9;
        adj_prdTD(2) = adj_prdTD(2)*0.9;
    end
    
    if ~iterate
        ns_old = ns;
    end
end


function retrank = marank(x)
[sx,i] = sort(x);%#ok
j = 1:length(i); 
retrank(i) = j;
retrank= retrank';

% Returns the relative rank distance to the average minimum rank compared to the
% average maximum rank. 
% Ex. ref = rbaseline(iset); data = rdata(iset);
function air = avgrankdist(ref, data)
ws = warning;
warning('off','MATLAB:divideByZero');
air = (ref + data - min(ref) - min(data))/...
    (max(ref) + max(data)- min(ref) -min(data));
warning(ws);
