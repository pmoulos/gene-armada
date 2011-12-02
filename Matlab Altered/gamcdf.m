function p = gamcdf(x,a,b)
%GAMCDF Gamma cumulative distribution function.
%   P = GAMCDF(X,A,B) returns the gamma cumulative distribution
%   function with parameters A and B at the values in X.
%
%   The size of P is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   Some references refer to the gamma distribution with a single
%   parameter. This corresponds to the default of B = 1. 
%
%   GAMMAINC does computational work.

%   References:
%      [1]  L. Devroye, "Non-Uniform Random Variate Generation", 
%      Springer-Verlag, 1986. p. 401.
%      [2]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.32.

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 2.12 $  $Date: 2002/01/17 21:30:39 $

if nargin < 3, 
    b = 1; 
end

if nargin < 2, 
    error('Requires at least two input arguments.'); 
end

[errorcode x a b] = distchck(3,x,a,b);

if errorcode > 0
    error('Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
p = zeros(size(x));

%   Return NaN if the arguments are outside their respective limits.
p(a <= 0 | b <= 0) = NaN;

k = find(x > 0 & ~(a <= 0 | b <= 0));
if any(k), 
    p(k) = gammainc(x(k) ./ b(k),a(k));
end

% Make sure that round-off errors never make P greater than 1.
p(p > 1) = 1;

% If we have NaN or Inf, fix if possible
k = ~isfinite(p);
if (any(k)), p(x>=sqrt(realmax)) = 1; end
