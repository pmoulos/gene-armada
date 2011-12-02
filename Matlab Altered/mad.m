function y = mad(x,useMedian)
%MAD    Mean or Median Absolute Deviation. 
%   Y = MAD(X) calculates the mean absolute deviation of X.
%   For matrix X, MAD returns a row vector containing the mean absolute
%   deviation of each column. 
%
%   Y = MAD(X,MEDIANFLAG) when a second input is given calculates the
%   median absolute deviation of X. For matrix X, MAD returns a row vector
%   containing the median absolute deviation of each column.
%
%   The algorithm involves subtracting the mean, or median, of X from X,
%   taking absolute values, and then finding the mean, or median, of the
%   result.  

%   References:
%      [1] L. Sachs, "Applied Statistics: A Handbook of Techniques",
%      Springer-Verlag, 1984, page 253.

%   Copyright 2003 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/03/19 18:50:21 $

nrow = size(x,1);
if nargin == 2
    useMedian = true;
else
    useMedian = false;
end
if useMedian
    med = nanmedian(x);
else
    med = nanmean(x);
end
y = abs(x - med(ones(nrow,1),:));
if useMedian
    y = nanmedian(y);
else
    y = nanmean(y);
end
