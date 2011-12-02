function c = marunmed(x,y,k)
%MARUNMED One dimensional running median smoother.
%   Y = MARUNMED(X,Y, K) computes the running median of order K. 
%   K - integer width of median window, Default K = 3.
%   For K odd, Y(n) is the median of X( n-(K-1)/2 : n+(K-1)/2 ).
%   For K even, Y(n) is the median of X( n-K/2 : n+K/2-1 ).
%   
%   median filtering of X.  Y is the same size as X; for the edge points,
%   zeros are assumed to the left and right of X.  If X is a matrix,
%   then MEDFILT1 operates along the columns of X.
%
%   Y = MEDFILT1(X,N,BLKSZ) uses a for-loop to compute BLKSZ ("block size") 
%   output samples at a time.  Use this option with BLKSZ << LENGTH(X) if 
%   you are low on memory (MEDFILT1 uses a working matrix of size
%   N y BLKSZ).  By default, BLKSZ == LENGTH(X); this is the fastest
%   execution if you have the memory for it.
%
%   See also MEDIAN, FILTER, SGOLAYFILT, and MEDFILT2 in the Image
%   Processing Toolbox.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $  $Date: 2006/09/27 00:19:46 $

outputAsRow = diff(size(y))>0;

% Set x, y, and t as columns
y = y(:);
t = numel(y);
if isempty(x)
    x = (1:t)';
elseif numel(x) == t
    x = x(:)+ min(x) + 1; % for better conditioning
else
    error('Bioinfo:MArunmedXYmustBeSameLength',...
          'X and Y must be the same length.');
end

% Set span
if nargin<3 || isempty(k)
    k = 3;     % default span
elseif k <= 0  % span must be positive
    error('Bioinfo:MArunmedSpanMustBePositive', ...
          'SPAN must be positive.'); 
elseif k < 1   % percent convention
    k = ceil(k*t); 
else              % span is given in samples, then round
    k = round(k);
end 

% is x sorted ? sort
if any(diff(x(~isnan(x)))<0)
    [x,idx] = sort(x);
    y = y(idx);
    unSort = true;
else
    unSort = false;
end

c = NaN(size(y), class(y));
xnotNaN = ~isnan(x);

%High limit for k
k = min(k, sum(xnotNaN));

c(xnotNaN) = runmedian(y(xnotNaN), k);

if unSort
    c(idx) = c;
end

if outputAsRow
    c = c';
end

%-------------------------------------------------------------------
%                       Local Function
%-------------------------------------------------------------------
function y = runmedian(x,n)
%RUNMEDIAN does single smooth operation. Smoothed values yi are calculated from
%a window of the set {x1, x2,, ..., xn}; The set is sorted. In a median smooth
%with window size 2k+1, the smoothed value yi at location i in the set {x1, x2,
%... xn} is the middle values of xi-k, xi-k+1, ..., xi+k-1, xi+k; 
%  yi = median[xi-k, xi-k+1, ..., xi+k-1, xi+k];
%
% Inputs:
%   x     - input data vector
%   k     - integer width of the median window

nx = length(x);
y = zeros(size(x), class(x));

ws = warning;
warning('off','MATLAB:divideByZero');
warning('off','MATLAB:rankDeficientMatrix');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nx = length(y);
if rem(n,2)~=1    % n even
    m = n/2;
else
    m = (n-1)/2;
end
X = [zeros(m,1); x; zeros(m,1)];

% Work in chunks to save memory
indr = (0:n-1)';
indc = 1:nx;

ind = indc(ones(1,n),1:nx) + indr(:,ones(1,nx));
xx = X(ind);
% % xx = reshape(X(ind), n, nx);
y(1:nx) = median(xx,1);
y = smoothEnds(y,x, m);

warning(ws);

function c = smoothEnds(y,x, k)
% SMOOTHENDS smooth end points of a sorted vector y subsequently smaller medians
% and Tukey's extrapolation medthod to smooth the very end points.
% y1 = median(y1, y2, 3*y2 - 2y3)
% yn = median(yn, yn-1, 3*yn-1 - 2*yn-2).
%
% References:
% John W. Tukey (1977) Exploratory Data Analysis, Addison
% Velleman, P.F., and Hoaglin, D.C. (1981) ABC of EDA (Applications, Basics, and
% Computing of Exploratory Data Analysis); Duxbury. 

c = y;
if k < 1
    return;
end

n = numel(y);
if k >= 2
    for i = 2:k
        c(i) = median(x(1:2*i-1));
        c(n-i+1) = median( x(n+1-(2*i-1) : n) );
    end
end

% For the first point and last point, use Tukey's end-point rule
c(1) = median([x(1), c(2), 3*c(2) - 2*c(3)]);
c(n) = median([x(n), c(n-1), 3*c(n-1) - 2*c(n-2)]);

    
    



